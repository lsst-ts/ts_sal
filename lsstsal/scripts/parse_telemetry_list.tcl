#!/usr/bin/env tclsh

set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
source $SAL_DIR/add_system_dictionary.tcl
source $SAL_DIR/add_private_idl.tcl

set subsys [lindex $argv 0]
exec mkdir -p $SAL_WORK_DIR/html/[set subsys]

set all [lsort [glob idl-templates/validated/[set subsys]_*.idl]]
set fout [open $SAL_WORK_DIR/html/[set subsys]/[set subsys]_Telemetry.html w]
puts stdout "Generating html Telemetry table $subsys"
foreach i [lsort $all] {
 set ftyp [lindex [split [file tail $i] _] 1]
 if { $ftyp != "command" && $ftyp != "logevent" } {
  set fin [open $i r]
  gets $fin rec
puts $fout "<H3>[file tail [file rootname $i]] Telemetry Stream</H3><P><UL>"
puts $fout "<TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Stream name</TD><TD>Item</TD><TD>Type</TD><TD>Comment</TD></B></TR>"
  while { [gets $fin rec] > -1 } {
   set rec [string trim $rec "\{\}"]
   if { [lindex $rec 0] != "#pragma" } {
    if { [llength $rec] > 1 } {
      set type [lindex $rec 0]
      if { $type == "unsigned" } {
        set type [lrange $rec 0 1]
        set name [string trim [lindex $rec 2] "; "]
      } else {
        set name [string trim [lindex $rec 1] "; "]
      }
      set cmt "-"
      if { [llength [split $rec "/"]] > 1 } {
         set cmt [lindex [split $rec "/"] 2]
      }
      if { [lindex [split $name "_"] 0] != "private" } {
        puts $fout "<TR><B><TD>[file tail [file rootname $i]]</TD><TD>$name</TD><TD>$type</TD><TD>$cmt</TD></B></TR>"
      }
    }
   }
  }
  close $fin
  puts $fout "</TABLE></UL><P></BODY></HTML>"
  puts stdout "Processed $i"
 }
}
 
close $fout



