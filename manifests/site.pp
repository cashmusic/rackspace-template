# site.pp

hiera_include('classes')
import "nodes/*.pp"

filebucket { main: server => puppet }

# global defaults
File { backup => main }
Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin" }
