#!/usr/bin/env tclsh

set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
source $SAL_DIR/add_system_dictionary.tcl
source $SAL_DIR/add_private_idl.tcl


set subsys [lindex $argv 0]
set fin [open $SAL_WORK_DIR/event_list_$subsys r]
puts stdout "Parsing event list for $subsys"


while { [gets $fin rec] > -1 } {
  if { [string index $rec 0] == "#" || [string trim $rec] == "" } {
  } else {
       if { [lindex $rec 0] == "event" } {  
          set spl   [split $rec "|"]
          set cmd [string trim [join [split [lrange [lindex $spl 0] 1 end] " "] " "]]
          set alias [string trim [lindex $spl 1]]
          set freq  [lindex $spl 2]
          set EVTS($subsys,$alias) $cmd                 
          lappend ALIASES $alias            
       } else {
          set x [string trim $rec]
          set y [join [split $x "\[" ] "("]
          set z [join [split $y "\]" ] ")"]
          lappend EVTS($subsys,$alias,param) $z
          lappend EVTS($subsys,$alias,plist) [lindex $z 1]
       }
  }
}
close $fin

puts stdout "Generating logevent IDL for $subsys"
foreach i [lsort $ALIASES] {
   set fidl [open $SAL_WORK_DIR/idl-templates/validated/[set subsys]_logevent_$i.idl w]
   puts $fidl "   struct logevent_$i \{"
   add_private_idl $fidl "      "
   puts $fidl "      long		priority;"
   if { [info exists EVTS($subsys,$i,param)] } {
     foreach p $EVTS($subsys,$i,param) {
         puts $fidl "      $p;"
     }
   }
   puts $fidl "   \};"
   if { [info exists SYSDIC($subsys,keyedID)] } {
      puts $fidl "   #pragma keylist logevent_$i [set subsys]ID" 
   } else {
      puts $fidl "   #pragma keylist logevent_$i"
   }
   close $fidl
}

puts stdout "Generating log event command gui input"        
set fout [open $SAL_WORK_DIR/idl-templates/validated/[set subsys]_evtdef.tcl w]
puts $fout "set ALIASES \"$ALIASES\""
puts $fout "set EVENT_ALIASES([set subsys]) \"$ALIASES\""
foreach c [array names EVTS] {
   puts $fout "set EVTS($c) \"$EVTS($c)\""
}
close $fout

exec mkdir -p $SAL_WORK_DIR/html/[set subsys]

set fout [open $SAL_WORK_DIR/html/[set subsys]/logevent_[set subsys].html w]
puts stdout "Generating html logevent table $subsys"
puts $fout "<H3>$subsys Logevents</H3><P><UL>"
puts $fout "<TABLE BORDER=3 CELLPADDING=5 BGCOLOR=LightBlue  WIDTH=600>
<TR BGCOLOR=Yellow><B><TD>Log Event Alias</TD><TD>Activity</TD><TD>Event
</TD><TD>Parameter(s)</TD></B></TR>"
foreach i [lsort $ALIASES] {
      set evt "$EVTS($subsys,$i) - - -"
      puts $fout "<TR><TD>$subsys<BR>$i</TD><TD>[lindex $evt 0] </TD><TD>[lindex $evt 1] </TD><TD> "
      if { [info exists EVTS($subsys,$i,param)] } {
        foreach p $EVTS($subsys,$i,param) {
          puts $fout "$p<BR>"
        } 
        puts $fout "</TD></TR>"
      } else {
        puts $fout "n/a"
      }
}
puts $fout "</TABLE></UL><P>"
close $fout



