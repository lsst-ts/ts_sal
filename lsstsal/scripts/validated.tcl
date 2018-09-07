#!/usr/bin/env tclsh

cd validated
set all [glob *.idl]
foreach i $all {
  if { [file size $i] > 0 } {
    set d [file rootname $i]
    set upd [join [split [file rootname $i] _] .]
    set flist [glob $d*]
    foreach x $flist {
       exec mv $x ../$upd/.
    }
    puts stdout "Installed $d to $upd files $flist"
  }
}

