#!/usr/bin/env tclsh

set fin [open tmatlm r]
while { [gets $fin rec] > -1 } {
   if { [string range $rec 0 0] == "\["} {
     set name [lindex [split $rec "\[\]"]  1]
     set tname [join $name _]
   } else {
     set size 1
     set type [lindex $rec 0]
     if { [lindex $rec 1] != "Telemetry" } {
       set type [join [lrange $rec 0 1] _]
       set size [lindex [split $rec =] 1]
       gets $fin rec
       set id [lindex [split $rec =] 1]
     } else {
       set size 1
       set id [lindex [split $rec =] 1]
    }
    puts stdout "$name $type $id $size"
   }
}
close $fin


