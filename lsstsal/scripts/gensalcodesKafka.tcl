#!/usr/bin/env tclsh
## \file gensalcodesKafka.tcl
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
global SAL_WORK_DIR OPTIONS CMD_ALIASES EVENT_ALIASES TLM_ALIASES CMDS EVTS TLMS ACTIVETOPICS
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> checkTopicTypes $base"}
  set CMD_ALIASES($base) ""
  set EVENT_ALIASES($base) ""
  set TLM_ALIASES($base) ""
  set ACTIVETOPICS "ackcmd"
  if { [file exists $SAL_WORK_DIR/avro-templates/[set base]_cmddef.tcl] } {
        source $SAL_WORK_DIR/avro-templates/[set base]_cmddef.tcl
  } else {
        set ACTIVETOPICS ""
        stdlog "================================================================="
        stdlog "WARNING : No Command definitions found for $base"
        stdlog "================================================================="
  }
  if { [file exists $SAL_WORK_DIR/avro-templates/[set base]_evtdef.tcl] } {
        source $SAL_WORK_DIR/avro-templates/[set base]_evtdef.tcl
  } else {
        stdlog "================================================================="
        stdlog "WARNING : No Event definitions found for $base"
        stdlog "================================================================="
  }
  if { [file exists $SAL_WORK_DIR/avro-templates/[set base]_tlmdef.tcl] } {
        source $SAL_WORK_DIR/avro-templates/[set base]_tlmdef.tcl
  } else {
        stdlog "==================================================================="
        stdlog "WARNING : No Telemetry definitions found for $base"
        stdlog "==================================================================="
  }
  foreach t [lsort $CMD_ALIASES($base)]  {
     lappend ACTIVETOPICS "command_[set t]"
  }
  foreach t [lsort $EVENT_ALIASES($base)]  {
     lappend ACTIVETOPICS "logevent_[set t]"
  }
  foreach t [lsort $TLM_ALIASES($base)]  {
     lappend ACTIVETOPICS $t
  }
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< checkTopicTypes $base"}
}



#
## Documented proc \c genTelemetryCodes .
# \param[in] jsonfile File containing Json format data
# \param[in] targets List of Subsystems/CSCs to generate code for
#
#  Generate SAL API code for a set of Subsystems/CSCs
#
proc genTelemetryCodes { jsonfile targets } {
global DONE_CMDEVT OPTIONS SAL_DIR
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> genTelemetryCodes $targets"}
  foreach subsys $targets {
    set spl [file rootname [split $subsys _]]
    if { [lindex $spl end] != "enums" } {
     set base [lindex $spl 0]
     if { $subsys != "[set base]_hash_table.json" } {
      if { [lindex $spl 1] != "command" && [lindex $spl 1] != "logevent" && [lindex $spl 1] != "ackcmd" } {
       set name [join [lrange $spl 1 end] _]
       if { $OPTIONS(cpp) } {
         stdlog "Generating SAL CPP code for $subsys"
         set result none
         catch { set result [makesalcode $jsonfile $base $name cpp] } bad
         if { $result == "none" } {stdlog $bad}
         if { $OPTIONS(verbose) } {stdlog $result}
       } 
       if { $OPTIONS(java) } {
         stdlog "DEPRECATED : Generating SAL Java code for $subsys"
         set result none
         catch { set result [exec make_salUtils] } bad
         if { $result == "none" } {puts stderr $bad}
###         set result none
###        catch { set result [makesalcode $jsonfile $base $name java] } bad
###         if { $result == "none" } {puts stderr $bad}
###         if { $OPTIONS(verbose) } {stdlog $result}
       }
      }
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
    set jsonfile $SAL_WORK_DIR/avro-templates/sal/sal_[set base].json
    if { $OPTIONS(cpp) } {
      set result none
      catch { set result [makesalcmdevt $base cpp] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
      catch { set result [makesalcode $jsonfile $base "notused" cpp] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
    } 
    if { $OPTIONS(java) } {
      set result none
      catch { set result [makesalcmdevt $base java] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
      catch { set result [makesalcode $jsonfile $base "notused" java] } bad
      if { $result == "none" } {stdlog $bad}
      if { $OPTIONS(verbose) } {stdlog $result}
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
###    set result none
###    if { [info exists CMD_ALIASES($base)] } {
###       catch { set result [gencommandtestssinglefilejava $base] } bad
###       if { $OPTIONS(verbose) } {stdlog $result}
###    }
###    if { [info exists EVENT_ALIASES($base)] } {
###      catch { set result [geneventtestssinglefilejava $base] } bad
###      if { $OPTIONS(verbose) } {stdlog $result}
###    }
###    if { [info exists TLM_ALIASES($base)] } {
###      catch { set result [gentelemetrytestssinglefilejava $base] } bad
###      if { $OPTIONS(verbose) } {stdlog $result}
###    }
  }
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< genSingleProcessTests $base"}
}




