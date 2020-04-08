

source $SAL_DIR/geneventtests.tcl 
source $SAL_DIR/geneventtestssinglefile.tcl
source $SAL_DIR/geneventtestsjava.tcl 
source $SAL_DIR/geneventtestssinglefilejava.tcl
source $SAL_DIR/gentestspython.tcl 

proc geneventaliascode { subsys lang fout } {
global EVENT_ALIASES EVTS DONE_CMDEVT
 if { [info exists EVENT_ALIASES($subsys)] } {
  stdlog "Generate event alias support for $lang"
  if { $lang == "include" } {
     foreach i $EVENT_ALIASES($subsys) { 
      if { [info exists EVTS($subsys,$i,param)] } {
         puts $fout "
      salReturn logEvent_[set i]( SALData_logevent_[set i]C *data, int priority );      
      int getEvent_[set i]( SALData_logevent_[set i]C *data );"
      }
     }
  }
  if { $lang == "cpp" } {
     set result none
     catch { set result [geneventaliascpp $subsys $fout] } bad
     if { $result == "none" } {errorexit "failure in geneventaliascpp" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       set result none
       catch { set result [geneventtestscpp $subsys] } bad       
       if { $result == "none" } {errorexit "failure in geneventtestscpp" }
       stdlog "$result"
     }
   }
  if { $lang == "java" }  {
     set result none
     catch { set result [geneventaliasjava $subsys $fout] } bad
     if { $result == "none" } {errorexit "failure in geneventaliasjava" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       set result none
       catch { set result [geneventtestsjava $subsys] } bad
       if { $result == "none" } {errorexit "failure in geneventtestsjava" }
       stdlog "$result"
     }
  }
  if { $lang == "python" } {
     set result none
     catch { set result [geneventaliaspython $subsys $fout] } bad
     if { $result == "none" } {errorexit "failure in geneventaliaspython" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       set result none
       catch { set result [geneventtestspython $subsys] } bad
       if { $result == "none" } {errorexit "failure in geneventtestspython" }
       stdlog "$result"
     }
  }
  if { $lang == "isocpp" } {
     set result none
     catch { set result [geneventaliasisocpp $subsys $fout] } bad
     if { $result == "none" } {errorexit "failure in geneventaliasisocpp" }
     stdlog "$result"
  }
 }
}


proc geneventaliascpp { subsys fout } {
global EVENT_ALIASES EVTS SAL_WORK_DIR OPTIONS
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> geneventaliascpp $subsys $fout"}
   foreach i $EVENT_ALIASES($subsys) {
    if { [info exists EVTS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
      puts $fout "
int SAL_SALData::getEvent_[set i](SALData_logevent_[set i]C *data)
\{
  ReturnCode_t status =  -1;
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
  data->priority=priority;
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


proc geneventaliasjava { subsys fout } {
global EVENT_ALIASES EVTS
   foreach i $EVENT_ALIASES($subsys) {
    if { [info exists EVTS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
      puts $fout "
	public int getEvent_[set i](SALData.logevent_[set i] anEvent)
	\{
	  int status =  -1;
          int actorIdx = SAL__SALData_logevent_[set i]_ACTOR;
          if (sal\[actorIdx\].subscriber == null) \{
             createSubscriber(actorIdx);
             createReader(actorIdx,false);
             sal\[actorIdx\].isEventReader = true;
          \}
          int maxSample = sal\[actorIdx\].maxSamples;
          sal\[actorIdx\].maxSamples=1;
          status = getSample(anEvent);
          sal\[actorIdx\].maxSamples=maxSample;
	  return status;
	\}

	public int logEvent_[set i]( SALData.logevent_[set i] event, int priority )
	\{
	   int status = 0;
           int actorIdx = SAL__SALData_logevent_[set i]_ACTOR;
           event.priority=priority;
           if (sal\[actorIdx\].publisher == null) \{
              createPublisher(actorIdx);
              boolean autodispose_unregistered_instances = true;
              createWriter(actorIdx,autodispose_unregistered_instances);
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



proc geneventaliaspython { subsys fout } {
global EVENT_ALIASES EVTS
   foreach i $EVENT_ALIASES($subsys) {
    if { [info exists EVTS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
      puts $fout "
        .def( \"getEvent_[set i]\",  &SAL_SALData::getEvent_[set i] )
        .def( \"logEvent_[set i]\",  &SAL_SALData::logEvent_[set i] )
      "
    } else {
#      stdlog "Alias $i has no parameters - uses standard [set subsys]_logevent"
    }
   }
}



proc geneventaliasisocpp { subsys fout } {
global EVENT_ALIASES
   foreach i $EVENT_ALIASES { 
    if { [info exists EVTS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
    } else {
#      stdlog "Alias $i has no parameters - uses standard [set subsys]_command"
    }
   }
}




