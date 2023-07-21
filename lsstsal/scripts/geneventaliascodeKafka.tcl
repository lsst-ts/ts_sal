#!/usr/bin/env tclsh
## \file geneventaliascodeKafka.tcl
# \brief This contains procedures to create the SAL API code
#  to manager the Event Topics. It generates code and tests
#  for C++ and Java APIs
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code


set SAL_DIR $env(SAL_DIR)
source $SAL_DIR/geneventtestsKafka.tcl 
source $SAL_DIR/geneventtestssinglefile.tcl
source $SAL_DIR/geneventtestsjava.tcl 
source $SAL_DIR/geneventtestssinglefilejava.tcl

## Documented proc \c geneventaliascode .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] lang Target language to generate code for
# \param[in] fout File handle of output file
#
#  Generates the Event handling code for a Subsystem/CSC.
#  Code is generated for getEvent,logEvent
#  per Event Topic type. This routine generates header code, and then calls 
#  per language routines to generate the rest.
#
proc geneventaliascode { subsys lang fout } {
global EVENT_ALIASES EVTS DONE_CMDEVT
 if { [info exists EVENT_ALIASES($subsys)] } {
  stdlog "Generate event alias support for $lang"
  if { $lang == "include" } {
     foreach i $EVENT_ALIASES($subsys) { 
      if { [info exists EVTS($subsys,$i,param)] } {
         set turl [getTopicURL $subsys $i]
         puts $fout "
/** Publish a [set i] logevent message
  * @param data is the logevent payload $turl
  * @priority is deprecated
  */
      salReturn logEvent_[set i]( SALData_logevent_[set i]C *data, int priority );      

/** Receive a logevent message.
  * @param data is the logevent payload $turl
  * @returns SAL__NO_UPDATES if no data is available, or SAL__OK otherwise
  */
      int getEvent_[set i]( SALData_logevent_[set i]C *data );"
      }
     }
  }
  if { $lang == "cpp" } {
     set result none
     catch { set result [geneventaliascpp $subsys $fout] } bad
     if { $result == "none" } {stdlog $bad ; errorexit "failure in geneventaliascpp" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       set result none
       catch { set result [geneventtestscpp $subsys] } bad       
       if { $result == "none" } {stdlog $bad ; errorexit "failure in geneventtestscpp" }
       stdlog "$result"
     }
   }
  if { $lang == "java" }  {
     set result none
     catch { set result [geneventaliasjava $subsys $fout] } bad
     if { $result == "none" } {stdlog $bad ; errorexit "failure in geneventaliasjava" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       set result none
       catch { set result [geneventtestsjava $subsys] } bad
       if { $result == "none" } {stdlog $bad ; errorexit "failure in geneventtestsjava" }
       stdlog "$result"
     }
  }
 }
}


#
## Documented proc \c geneventaliascpp .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Generates the Event handling code for a Subsystem/CSC.
#  Code is generated for getEvent,logEvent
#  per Event Topic type. This routine generates C++ code.
#
proc geneventaliascpp { subsys fout } {
global EVENT_ALIASES EVTS SAL_WORK_DIR OPTIONS
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> geneventaliascpp $subsys $fout"}
   foreach i $EVENT_ALIASES($subsys) {
    if { [info exists EVTS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
      puts $fout "
int SAL_SALData::getEvent_[set i](SALData_logevent_[set i]C *data)
\{
  long status =  -1;
  string stopic=\"SALData_logevent_[set i]\";
  int actorIdx = SAL__SALData_logevent_[set i]_ACTOR;
  int maxSample = sal\[actorIdx\].maxSamples;
  sal\[actorIdx\].maxSamples=1;
  status = getSample_logevent_[set i](data);
  sal\[actorIdx\].maxSamples = maxSample;
  return status;
\}
"
     puts $fout "
salReturn SAL_SALData::logEvent_[set i]( SALData_logevent_[set i]C *data, int priority )
\{
  if ( data == NULL ) \{
     throw std::runtime_error(\"NULL pointer for logEvent_[set i]\");
  \}
  status = putSample_logevent_[set i](data);
  return status;
\}
"
    } else {
#      stdlog "Alias $i has no parameters - uses standard [set subsys]_logevent"
    }
   }
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< geneventaliascpp $subsys $fout"}
}


#
## Documented proc \c geneventaliasjava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Generates the Command handling code for a Subsystem/CSC.
#  Code is generated for getEvent,logEvent
#  per-command Topic type. This routine generates Java code.
#
proc geneventaliasjava { subsys fout } {
global EVENT_ALIASES EVTS
   foreach i $EVENT_ALIASES($subsys) {
    if { [info exists EVTS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
      set turl [getTopicURL $subsys $i]
      puts $fout "
/** Receive a logevent message.
  * @param data is the logevent payload $turl
  * @returns SAL__NO_UPDATES if no data is available, or SAL__OK otherwise
  */
	public int getEvent_[set i](SALData.logevent_[set i] anEvent)
	\{
	  int status =  -1;
          int actorIdx = SAL__SALData_logevent_[set i]_ACTOR;
          if (sal\[actorIdx\].subscriber == null) \{
             createSubscriber(actorIdx);
             sal\[actorIdx\].isEventReader = true;
          \}
          int maxSample = sal\[actorIdx\].maxSamples;
          sal\[actorIdx\].maxSamples=1;
          status = getSample(anEvent);
          sal\[actorIdx\].maxSamples=maxSample;
	  return status;
	\}

/** Publish a [set i] logevent message
  * @param data is the logevent payload $turl
  * @priority is deprecated
  */
	public int logEvent_[set i]( SALData.logevent_[set i] event, int priority )
	\{
	   int status = 0;
           int actorIdx = SAL__SALData_logevent_[set i]_ACTOR;
           if (sal\[actorIdx\].topic == null) \{
              createTopic(actorIdx);
              boolean autodispose_unregistered_instances = true;
              sal\[actorIdx\].isEventWriter = true;
           \}
           status = putSample(event);
           return status;
	\}
"
    } else {
#      stdlog "Alias $i has no parameters - uses standard [set subsys]_logevent"
    }
   }
}



#
## Documented proc \c geneventaliasisocpp .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Generates the Event handling code for a Subsystem/CSC.
#  Code is generated for getEvent,logEvent
#  per Event Topic type. This routine generates ISO C++ wrapper code.
#  NOT YET IMPLEMENTED
#
proc geneventaliasisocpp { subsys fout } {
global EVENT_ALIASES
   foreach i $EVENT_ALIASES { 
    if { [info exists EVTS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
    } else {
#      stdlog "Alias $i has no parameters - uses standard [set subsys]_logevent"
    }
   }
}




