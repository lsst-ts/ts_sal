#!/usr/bin/wish

proc updateview { subsys poll } {
global NROW
  set q [lrange [split [exec mysql EFD < /tmp/dosql] \n] 2 end]
  foreach t $q { set NROW([lindex $t 0]) [format %12d [lindex $t 1]] }
  after $poll "updateview $subsys $poll"
}

set fout [open /tmp/dosql w]
puts $fout "SELECT table_name, table_rows FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='EFD' order by table_rows;\nexit"
close $fout 
set subsys [lindex $argv 0]
set poll 5000
if { $argc > 1 } { set poll [expr [lindex $argv 1]*1000] }
toplevel .[set subsys] -width 1500 -height 900
set topics [split [glob $env(SAL_WORK_DIR)/sql/[set subsys]*.sqldef]]
set iy 0
set ix 10
set n 0
foreach t [lsort $topics] {
  set id [file root [file tail $t]]
  if { [lindex [split $id _] 1] != "command" } {
      set NROW(id) [format %10d 0]
      label .[set subsys].l[set id] -text $id -width 40 -bg gray
      label .[set subsys].t[set id] -width 16 -bg LightBlue -textvariable NROW($id)
      place .[set subsys].l[set id] -x $ix -y $iy
      place .[set subsys].t[set id] -x [expr $ix + 300] -y $iy
      incr iy 25
      incr n 1
      if { $iy > 500 } {incr ix 400; set iy 0}
  }
}
button .[set subsys].stop -text "close" -width 150 -command exit -bg orange 
place .[set subsys].stop -x 10 -y 525
wm geometry .[set subsys] [expr $ix+40]x550
wm title .[set subsys] "EFD Row counts for $subsys"
wm withdraw .
updateview $subsys $poll


