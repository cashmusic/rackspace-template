#!/bin/bash

find /var/log/httpd* -name "*.log" -mtime +1 -exec gzip -9 "{}" ";"
