#!/usr/bin/env tclsh
## \file gensalcodes.tcl
# \brief This contains utility routines to generate SAL API code
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

#
## Documented proc \c checkTopicTypes .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Check the existance of tcl format topic defnitions, and read them in
#
proc checkTopicTypes { base } {
global SAL_WORK_DIR OPTIONS CMD_ALIASES EVENT_ALIASES TLM_ALIASES CMDS EVTS TLMS
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> checkTopicTypes $base"}
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
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< checkTopicTypes $base"}
}



#
## Documented proc \c genTelemetryCodes .
# \param[in] idlfile File containing IDL format data
# \param[in] targets List of Subsystems/CSCs to generate code for
#
#  Generate SAL API code for a set of Subsystems/CSCs
#
proc genTelemetryCodes { idlfile targets } {
global DONE_CMDEVT OPTIONS ONEPYTHON SAL_DIR
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> genTelemetryCodes $targets"}
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
         catch { set result [exec make_salUtils] } bad
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
     }
  }
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< genTelemetryCodes $targets"}
}


#
## Documented proc \c genGenericCodes .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate the generic code sections for SAL APIs
#
proc genGenericCodes { base } {
global OPTIONS SAL_WORK_DIR DONE_CMDEVT
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> genGenericCodes $base"}
  if { $DONE_CMDEVT == 0 } {
    set idlfile $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set base].idl
    if { $OPTIONS(cpp) } {
      set result none
      catch { set result [makesalcmdevt $base cpp] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
      catch { set result [makesalcode $idlfile $base "notused" cpp] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
    } 
    if { $OPTIONS(java) } {
      set result none
      catch { set result [makesalcmdevt $base java] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
      catch { set result [makesalcode $idlfile $base "notused" java] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
    } 
    if { $OPTIONS(python) } {
      set result none
      catch { set result [makesalcmdevt $base python] } bad
      if { $result == "none" } {stdlog "makesalcmdevt : $bad"}
      if { $OPTIONS(verbose) } {stdlog $result}
#      catch { set result [makesalcode $idlfile $base "notused" python] } bad
#      if { $result == "none" } {stdlog $bad}
#      if { $OPTIONS(verbose) } {stdlog $result}
    }
    exec rm -fr $SAL_WORK_DIR/[set base]_notused
    if { $OPTIONS(verbose) } {stdlog "###TRACE<<< genGenericCodes $base"}
  }
}


#
## Documented proc \c genGenericCodes .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate the test programs for sets of SAL APIs (command,event,telemetry)
#
proc genSingleProcessTests { base } {
global OPTIONS CMD_ALIASES EVENT_ALIASES TLM_ALIASES
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> genSingleProcessTests $base"}
  if { $base ==" LOVE" } {return}
  if { $OPTIONS(cpp) } {
    set result none
    if { [info exists CMD_ALIASES($base)] } {
       catch { set result [gencommandtestsinglefilescpp $base] } bad
       if { $result == "none" } {stdlog $bad}
       if { $OPTIONS(verbose) } {stdlog $result}
    }
    set result none
    if { [info exists EVENT_ALIASES($base)] } {
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
    set result none
    if { [info exists CMD_ALIASES($base)] } {
       catch { set result [gencommandtestssinglefilejava $base] } bad
       if { $OPTIONS(verbose) } {stdlog $result}
    }
    if { [info exists EVENT_ALIASES($base)] } {
      catch { set result [geneventtestssinglefilejava $base] } bad
      if { $OPTIONS(verbose) } {stdlog $result}
    }
    if { [info exists TLM_ALIASES($base)] } {
      catch { set result [gentelemetrytestssinglefilejava $base] } bad
      if { $OPTIONS(verbose) } {stdlog $result}
    }
  }
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< genSingleProcessTests $base"}
}




