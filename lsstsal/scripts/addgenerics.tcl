#!/usr/bin/env tclsh

set SAL_DIR $env(SAL_DIR)
source $SAL_DIR/add_system_dictionary.tcl
source $SAL_DIR/sal_version.tcl

foreach s $SYSDIC(systems) {
   stdlog "Checking $s"
   if { [file exists [set s]_Commands.xml] } {
    set gotit 0
    catch {
      set gotcmd [exec grep "_command_start" [set s]_Commands.xml]
      set gotit 1
    }
    catch {
      set gotcmd [exec grep "_command_Start" [set s]_Commands.xml]
      set gotit 1
    }
    if { $gotit == 0 } {
      stdlog ".....Adding generic commands to $s"
      set SALSubsys $s
      source $SAL_DIR/generateLifecycleCommands.tcl
      set fin [open [set s]_Commands.xml r]
      set fout [open [set s]_Commandsplus w]
      gets $fin rec ; puts $fout $rec
      gets $fin rec ; puts $fout $rec
      gets $fin rec ; puts $fout $rec
      puts $fout $SAL_GENERIC_COMMANDS
      while { [gets $fin rec] > -1 } { puts $fout $rec}
      close $fin
      close $fout
      exec mv [set s]_Commandsplus [set s]_Commands.xml
    }
   } else { 
     stdlog "$s has no commands"
   }
   if { [file exists [set s]_Events.xml] } {
    set gotit 0
    catch {
      set gotcmd [exec grep "_logevent_summaryState" [set s]_Events.xml]
      set gotit 1
    }
    catch {
      set gotcmd [exec grep "_logevent_SummaryState" [set s]_Events.xml]
      set gotit 1
    }
    if { $gotit == 0 } {
      set SALSubsys $s
      source $SAL_DIR/generateGenericEvents.tcl
      stdlog ".....Adding generic events to $s"
      set fin [open [set s]_Events.xml r]
      set fout [open [set s]_Eventsplus w]
      gets $fin rec ; puts $fout $rec
      gets $fin rec ; puts $fout $rec
      gets $fin rec ; puts $fout $rec
      puts $fout $SAL_GENERIC_EVENTS
      while { [gets $fin rec] > -1 } { puts $fout $rec}
      close $fin
      close $fout
      exec mv [set s]_Eventsplus [set s]_Events.xml
    }
   } else {
     stdlog "$s has no events"
   }
}



