#!/usr/bin/env tclsh


set nafiles [glob /home/shared/data/skycam/kp_n*.fits]
set rfiles [glob /home/shared/data/skycam/kp_r*.fits]
set bfiles [glob /home/shared/data/skycam/kp_b*.fits]
set biglist ""
set index 0
while { $index < [llength $rfiles] } {
   lappend biglist [lindex $rfiles $index ]
   lappend biglist [lindex $bfiles $index ]
   lappend biglist [lindex $nafiles $index ]
   incr index 1
}

puts stdout "Looping through [llength $biglist] images"
foreach i $biglist {
   puts stdout "Processing $i"
   exec ./test_looparchive.tcl $i
   after 15000
}


