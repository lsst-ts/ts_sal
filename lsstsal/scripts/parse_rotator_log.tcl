#!/usr/bin/env tclsh

set id $argv
set fin [open $id r]
set num 1
set fout [open [set id]_[set num] w]
while { [gets $fin rec] > -1 }  {
   if { [lindex $rec 0] == "modifiers:" } {
    if { [string range $rec 0 16] != "    modifiers: sp" } {
      set d [split $rec ",="]
      set tai [lindex $d 1]
      set ang [lindex $d 3]
      set vel [lindex $d 5]
      if { [expr abs($vel)] > 50.0 } {
         close $fout
         incr num 1
         puts stdout "starting part $num"
         set fout [open [set id]_[set num] w]
      } else {
        puts $fout "$tai $ang $vel"  
      }
    }
   }
   if { [lindex $rec 0] == "angle" }    {set ang [lindex $rec 2]}
   if { [lindex $rec 0] == "velocity" } {set vel [lindex $rec 2]
      set idx [expr int($vel*1000)]
      incr VELS($idx) 1
   }
   if { [lindex $rec 0] == "tai" }      {
      set tai [lindex $rec 2]
      puts $fout "$tai $ang $vel"  
   }
}
close $fin
close $fout

set fout [open rot_velocity_dist w]
foreach i [array names VELS] {puts $fout "$i $VELS($i)"}
close $fout 

