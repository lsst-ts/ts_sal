#!/usr/bin/env tclsh

set scriptdir /usr/local/scripts/tcl
set start [clock seconds]
set whereami [pwd]
puts stdout "Building idl and sql definition files"
source $scriptdir/genidlshmem.tcl
set all [lsort [glob *.idl]]
foreach i $all {
  puts stdout "Building DDS libs/apps for $i"
  set subsys [file rootname $i]
  exec $scriptdir/genshmem.tcl $subsys
  cd $whereami
}
set timer [expr [clock seconds] - $start]
puts stdout "Processed idl in $timer seconds"

puts stdout "Building test scripts"
source $scriptdir/genshmtcl.tcl
puts stdout "Building libshm.so"
exec make -f makefile.shmem
exec touch Shared/*.o
exec make -f makefile.shmem

set timer [expr [clock seconds] - $start]
puts stdout "Completed in $timer seconds"
