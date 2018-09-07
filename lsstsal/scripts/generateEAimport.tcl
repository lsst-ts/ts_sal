#!/usr/bin/env tclsh

source $env(SAL_DIR)/add_system_dictionary.tcl
source $env(SAL_DIR)/parseXMLtoUML.tcl

foreach subsys $SYSDIC(systems) {
 exec rm -f [set subsys]_allEvents.xml
 exec rm -f [set subsys]_allCommands.xml
 if { [info exists SYSDIC([set subsys],hasGenerics)] && [file exists [set subsys]_Events.xml] } {
    exec cp [set subsys]_Events.xml [set subsys]_allEvents.xml
 }
 if { [info exists SYSDIC([set subsys],hasGenerics)] && [file exists [set subsys]_Commands.xml] } {
      exec cp [set subsys]_Commands.xml [set subsys]_allCommands.xml
 }
}

foreach subsys $SYSDIC(systems) {
 if { [file exists [set subsys]_allEvents.xml] == 0 } {
   set SALSubsys $subsys
   set SALVERSION 3.6
   source generic_Events.xml
   source generic_Commands.xml
   if { [file exists [set subsys]_Events.xml] } {
     set fin [open [set subsys]_Events.xml r]
   } else {
     set fin [open /dev/null r]
   }
   set fout [open [set subsys]_allEvents.xml w]
   while { [gets $fin rec] > -1 } {
      if { $rec == "</SALEventSet>" } {
         puts $fout $genevt
      } else  {
         puts $fout $rec
      }
   }
   close $fin
   close $fout
 }
 if { [file exists [set subsys]_allCommands.xml] == 0 } {
   if { [file exists [set subsys]_Commands.xml] } {
     set fin [open [set subsys]_Commands.xml r]
   } else {
     set fin [open /dev/null r]
   }
   set fout [open [set subsys]_allCommands.xml w]
   while { [gets $fin rec] > -1 } {
      if { $rec == "</SALCommandSet>" } {
         puts $fout $gencmd
      } else  {
         puts $fout $rec
      }
   }
   close $fin
   close $fout
 }
 parseXMLtoUML [set subsys]_allCommands.xml
 parseXMLtoUML [set subsys]_allEvents.xml
 if { [file exists [set subsys]_Telemetry.xml] } {
    parseXMLtoUML [set subsys]_Telemetry.xml
 }
 puts stdout "Converted $subsys"
}


