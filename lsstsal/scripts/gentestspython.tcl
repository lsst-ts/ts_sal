#!/usr/bin/env tclsh
## \file gentestspython.tcl
# \brief This contains procedures to create and manage the
# MD5SUM revision codes used to uniqely identify versioned
# DDS Topic names.
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code


source $SAL_DIR/pythonprint.tcl

#
## Documented proc \c gentelemetrytestspython .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate a set of Python tests for each SAL Telemetry Topic
#
proc gentelemetrytestspython { subsys } {
global SAL_WORK_DIR SYSDIC SAL_DIR
   if { [info exists SYSDIC($subsys,keyedID)] } {
       set initializer "(1)"
   } else {
       set initializer "()"
   }
   set idlfile "$SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl"
   set ptypes [split [exec grep pragma $idlfile] \n]
   foreach j $ptypes {
      set name [lindex $j 2]
      set type [lindex [split $name _] 0]
      if { $type != "command" && $type != "logevent" && $type != "ackcmd" } {
         stdlog "	: publisher for = $name"
         set fpub [open $SAL_WORK_DIR/$subsys/python/[set subsys]_[set name]_Publisher.py w]
	 puts $fpub "
import time
import sys
import numpy
from SALPY_[set subsys] import *
mgr = SAL_[set subsys][set initializer]
mgr.salTelemetryPub(\"[set subsys]_[set name]\")
myData = [set subsys]_[set name]C()"
         set farg [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set name]Ppub.tmp r]
	 while { [gets $farg rec] > -1 } {
	    puts $fpub $rec
	 }
	 puts $fpub "i=0
while i<10:
  retval = mgr.putSample_[set name](myData)
  i=i+1
  time.sleep(1)

mgr.salShutdown()
exit()
"
         close $fpub
         exec chmod 755 $SAL_WORK_DIR/$subsys/python/[set subsys]_[set name]_Publisher.py
         stdlog "	: subscriber for = $name"
         set fsub [open $SAL_WORK_DIR/$subsys/python/[set subsys]_[set name]_Subscriber.py w]
	 puts $fsub "
import time
import sys
import numpy
from SALPY_[set subsys] import *
mgr = SAL_[set subsys][set initializer]
mgr.salTelemetrySub(\"[set subsys]_[set name]\")
myData = [set subsys]_[set name]C()
print(\"[set subsys]_[set name] subscriber ready\")
while True:
  retval = mgr.getNextSample_[set name](myData)
  if retval==0:"
         pythonprinter $fsub [set subsys]_[set name]
	 puts $fsub "  time.sleep(1)

mgr.salShutdown()
exit()
"
         close $fsub
         exec chmod 755 $SAL_WORK_DIR/$subsys/python/[set subsys]_[set name]_Subscriber.py
      }
   }
}


#
## Documented proc \c geneventtestspython .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate a set of Python tests for each SAL Event Topic
#
proc geneventtestspython { subsys } {
global EVENT_ALIASES EVTS SAL_WORK_DIR SYSDIC SAL_DIR EVENT_ENUM
 exec mkdir -p $SAL_WORK_DIR/$subsys/python
 if { [info exists EVENT_ALIASES($subsys)] } {
   if { [info exists SYSDIC($subsys,keyedID)] } {
       set initializer "(1)"
   } else {
       set initializer "()"
   }
   foreach alias $EVENT_ALIASES($subsys) {
    if { [info exists EVTS($subsys,$alias,param)] } {
      stdlog "	: event test send for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/python/[set subsys]_Event_[set alias].py w]
      puts $fcmd "
import time
import sys
import numpy
if len(sys.argv) < [expr [llength $EVTS([set subsys],[set alias],plist)] +1]:
  print(\"ERROR : Invalid or missing arguments : $EVTS([set subsys],[set alias],plist)\")
  exit()

from SALPY_[set subsys] import *
mgr = SAL_[set subsys][set initializer]
mgr.salEventPub(\"[set subsys]_logevent_[set alias]\")
myData = [set subsys]_logevent_[set alias]C()"
      set farg [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Pargs.tmp r]
      while { [gets $farg rec] > -1 } {
         puts $fcmd $rec
      }
      close $farg
      puts $fcmd "priority=int(myData.priority)
mgr.logEvent_[set alias](myData, priority)
time.sleep(1)
mgr.salShutdown()
exit()
"
      close $fcmd
      exec chmod 755 $SAL_WORK_DIR/$subsys/python/[set subsys]_Event_[set alias].py
      stdlog "	: event test receive for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/python/[set subsys]_EventLogger_[set alias].py w]
      puts $fcmd "
import time
import sys
import numpy
from SALPY_[set subsys] import *
mgr = SAL_[set subsys][set initializer]
mgr.salEventSub(\"[set subsys]_logevent_[set alias]\")
print(\"[set subsys]_[set alias] logger ready\")
event = [set subsys]_logevent_[set alias]C()
while True:
  retval = mgr.getEvent_[set alias](event)
  if retval==0:
    print(\"Event $subsys $alias received\")"
      if { [info exists EVENT_ENUM($alias)] && [info exists enumdone($alias)] == 0 } {
          foreach e $EVENT_ENUM($alias) {
                set vname [lindex [split $e :] 0]
                set cnst [lindex [split $$e :] 1]
                foreach id [split $cnst ,] {
                   set sid [string trim $id " "]
###                   puts $fcmd "    if(event.[set vname] == [set alias]_[set sid]): print(\"[set vname] = [set sid]\")"
                }
          }
          set enumdone($alias) 1
     } 
     puts $fcmd "  time.sleep(1)
mgr.salShutdown()
exit()
"
      close $fcmd
      exec chmod 755 $SAL_WORK_DIR/$subsys/python/[set subsys]_EventLogger_[set alias].py
    } 
   }
 }
}



#
## Documented proc \c gencommandtestspython .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate a set of Python tests for each SAL Command Topic
#
proc gencommandtestspython { subsys } {
global CMD_ALIASES CMDS SAL_WORK_DIR SYSDIC SAL_DIR
 exec mkdir -p $SAL_WORK_DIR/$subsys/python
 if { [info exists CMD_ALIASES($subsys)] } {
   if { [info exists SYSDIC($subsys,keyedID)] } {
       set initializer "(1)"
   } else {
       set initializer "()"
   }
   foreach alias $CMD_ALIASES($subsys) {
    if { [info exists CMDS($subsys,$alias,param)] } {
      stdlog "	: command test send for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/python/[set subsys]_Commander_[set alias].py w]
      puts $fcmd "
import time
import sys
import numpy
timeout=5
if len(sys.argv) < [expr [llength $CMDS([set subsys],[set alias],plist)] +1]:
  print(\"ERROR : Invalid or missing arguments : $CMDS([set subsys],[set alias],plist)\")
  exit()

from SALPY_[set subsys] import *
mgr = SAL_[set subsys][set initializer]
mgr.salCommand(\"[set subsys]_command_[set alias]\")
myData = [set subsys]_command_[set alias]C()"
       set farg [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set alias]Pargs.tmp r]
       while { [gets $farg rec] > -1 } {
          puts $fcmd $rec
       }
       close $farg
       puts $fcmd "cmdId = mgr.issueCommand_[set alias](myData)
retval = mgr.waitForCompletion_[set alias](cmdId,timeout)
time.sleep(1)
mgr.salShutdown()
exit()
"
      close $fcmd
      exec chmod 755 $SAL_WORK_DIR/$subsys/python/[set subsys]_Commander_[set alias].py
      stdlog "	: command test receive for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/python/[set subsys]_Controller_[set alias].py w]
      puts $fcmd "
import time
import sys
import numpy
from SALPY_[set subsys] import *
mgr = SAL_[set subsys][set initializer]
mgr.salProcessor(\"[set subsys]_command_[set alias]\")
myData = [set subsys]_command_[set alias]C()
print(\"[set subsys]_[set alias] controller ready\")
SAL__CMD_COMPLETE=303
while True:
  cmdId = mgr.acceptCommand_[set alias](myData)
  if cmdId > 0:"
     pythonprinter $fcmd [set subsys]_command_[set alias]
     puts $fcmd "    time.sleep(1)
    mgr.ackCommand_[set alias](cmdId, SAL__CMD_COMPLETE, 0, \"Done : OK\");
  time.sleep(1)

mgr.salShutdown()
exit()
"
      close $fcmd
      exec chmod 755 $SAL_WORK_DIR/$subsys/python/[set subsys]_Controller_[set alias].py
    }
   }
 }
}



