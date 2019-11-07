proc checktopictypes { base } {
global SAL_WORK_DIR OPTIONS CMD_ALIASES EVENT_ALIASES TLM_ALIASES CMDS EVTS TLMS
  if { $OPTIONS(verbose) } {stdlog "###>>> checktopictypes $base"}
  if { [file exists $SAL_WORK_DIR/idl-templates/validated/[set base]_cmddef.tcl] } {
        source $SAL_WORK_DIR/idl-templates/validated/[set base]_cmddef.tcl
  } else {
        stdlog "================================================================="
        stdlog "WARNING : No Command definitions found for $base"
        stdlog "================================================================="
  }
  if { [file exists $SAL_WORK_DIR/idl-templates/validated/[set base]_evtdef.tcl] } {
        source $SAL_WORK_DIR/idl-templates/validated/[set base]_evtdef.tcl
  } else {
        stdlog "================================================================="
        stdlog "WARNING : No Event definitions found for $base"
        stdlog "================================================================="
  }
  if { [file exists $SAL_WORK_DIR/idl-templates/validated/[set base]_tlmdef.tcl] } {
        source $SAL_WORK_DIR/idl-templates/validated/[set base]_tlmdef.tcl
  } else {
        stdlog "==================================================================="
        stdlog "WARNING : No Telemetry definitions found for $base"
        stdlog "==================================================================="
  }
  if { $OPTIONS(verbose) } {stdlog "###<<< checktopictypes $base"}
}



proc gentelemetrycodes { idlfile targets } {
global DONE_CMDEVT OPTIONS ONEPYTHON SAL_DIR
  if { $OPTIONS(verbose) } {stdlog "###>>> gentelemetrycodes $targets"}
  foreach subsys $targets {
     set spl [file rootname [split $subsys _]]
     set base [lindex $spl 0]
     if { [lindex $spl 1] != "command" && [lindex $spl 1] != "logevent" && [lindex $spl 1] != "ackcmd" } {
       set name [join [lrange $spl 1 end] _]
       if { $OPTIONS(cpp) } {
         stdlog "Generating SAL CPP code for $subsys"
         set result none
         catch { set result [makesalcode $idlfile $base $name cpp] } bad
         if { $result == "none" } {stdlog $bad}
         if { $OPTIONS(verbose) } {stdlog $result}
       } 
       if { $OPTIONS(java) } {
         stdlog "Generating SAL Java code for $subsys"
         set result none
         catch { set result [exec $SAL_DIR/make_salUtils] } bad
         if { $result == "none" } {puts stderr $bad}
         set result none
         catch { set result [makesalcode $idlfile $base $name java] } bad
         if { $result == "none" } {puts stderr $bad}
         if { $OPTIONS(verbose) } {stdlog $result}
       }
       if { $OPTIONS(isocpp) } {
         stdlog "Generating SAL ISOCPP code for $subsys"
         set result none
         catch { set result [makesalcode $idlfile $base $name isocpp] } bad
         if { $result == "none" } {stdlog $bad}
         if { $OPTIONS(verbose) } {stdlog $result}
       }
       if { $OPTIONS(python) && $ONEPYTHON == 0 } {
         stdlog "Generating SAL Python code for $subsys $ONEPYTHON"
         set result none
         catch { set result [makesalcode $idlfile $base $name python] } bad
         if { $result == "none" } {stdlog $bad}
         set ONEPYTHON 1
         if { $OPTIONS(verbose) } {stdlog $result}
       }
       set DONE_CMDEVT 1
     }
  }
  if { $OPTIONS(verbose) } {stdlog "###<<< gentelemetrycodes $targets"}
}


proc gengenericcodes { base } {
global OPTIONS
    if { $OPTIONS(verbose) } {stdlog "###>>> gengenericcodes $base"}
    if { $OPTIONS(cpp) } {
      set result none
      catch { set result [makesalcmdevt $base cpp] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
    } 
    if { $OPTIONS(java) } {
      set result none
      catch { set result [makesalcmdevt $base java] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
    } 
    if { $OPTIONS(python) } {
      set result none
      catch { set result [makesalcmdevt $base python] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
    }
    if { $OPTIONS(verbose) } {stdlog "###<<< gengenericcodes $base"}
}


proc gensingleprocesstests { base } {
global OPTIONS CMD_ALIASES EVT_ALIASES TLM_ALIASES
  if { $OPTIONS(verbose) } {stdlog "###>>> gensingleprocesstests $base"}
  if { $OPTIONS(cpp) } {
    set result none
    if { [info exists CMD_ALIASES($base)] } {
       catch { set result [gencommandtestsinglefilescpp $base] } bad
       if { $result == "none" } {stdlog $bad}
       if { $OPTIONS(verbose) } {stdlog $result}
    }
    set result none
    if { [info exists EVT_ALIASES($base)] } {
      catch { set result [geneventtestssinglefilescpp $base] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
    }
    set result none
    if { [info exists TLM_ALIASES($base)] } {
      catch { set result [gentelemetrytestsinglefilescpp $base] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
    }
  }
  if { $OPTIONS(java) } {
    if { [info exists CMD_ALIASES($base)] } {
       catch { set result [gencommandtestssinglefilejava $base] } bad
       if { $OPTIONS(verbose) } {stdlog $result}
    }
    if { [info exists EVT_ALIASES($base)] } {
      catch { set result [geneventtestssinglefilejava $base] } bad
      if { $OPTIONS(verbose) } {stdlog $result}
    }
    if { [info exists TLM_ALIASES($base)] } {
      catch { set result [gentelemetrytestssinglefilejava $base] } bad
      if { $OPTIONS(verbose) } {stdlog $result}
    }
  }
  if { $OPTIONS(verbose) } {stdlog "###<<< gensingleprocesstests $base"}
}




