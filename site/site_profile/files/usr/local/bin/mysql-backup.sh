#!/bin/bash
#
# Script to backup all mysql databases on a host.
# Requires /root/.my.cnf be present with mysql login credentials.
# As such, this script should be run as root.
#
# The script takes two arguments:
#  - backup destination path
#  - backup retention time in days
# Ex: mysql-backup.sh /data/backup/mysql 14
# Will store mysqldump files in /data/backup/mysql and remove any .sql.gz files there
# that are older than 14 days.

backupdir=/data/backup/mysql
# Retention time in days.
cleanuptime=14

if [ "$1" == "" ]
then
  echo "No backup desintation specified, using default /data/backup/mysql"
else
  backupdir=$1
fi

if [ "$2" == "" ]
then
  echo "No backup retention time specified, using default 14 days."
else
  cleanuptime=$2
fi

if [ ! -d $backupdir ]
then
  echo "Backup destination directory does not exist, exiting."
  exit 1
fi

lockfile=${backupdir}/backup.lockfile
mypid=$$
mycnf=/root/.my.cnf
backupdate=`date +%Y-%m-%d-%H%M`

if [ -e "$lockfile" ]; then
  if [ ! -d /proc/`cat "$lockfile"` ]; then
    echo "Stale PID file, cleaning..."
    rm -f $lockfile
  else
    echo "Backups are already running!"
    exit 1
  fi
fi

echo -n "$mypid" > "$lockfile"
grep -q "$mypid" "$lockfile" || exit 1

if [ -e "$mycnf" ]; then
  # Clean up old backups.
  find "$backupdir" -maxdepth 1 -type f -name '*.sql.gz' -mtime +$cleanuptime -delete;
  for db in $(mysql --defaults-extra-file="$mycnf" -h localhost -Ne 'show databases' | grep -vE '^performance_schema$' | /grep -vE '^information_schema$'); do
    backupfile=${backupdir}/${backupdate}-${db}.sql.gz
    mysqldump --defaults-extra-file="$mycnf" --single-transaction -h localhost "$db" | /gzip > $backupfile
    chmod 600 $backupfile
    # Create "latest" symlink for each DB backup.
    latestsymlink=${backupdir}/latest-${db}.sql.gz
    rm -f $latestsymlink
    ln -s $backupfile $latestsymlink
  done
fi

rm -f "$lockfile"
