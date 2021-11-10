#!/usr/bin/env tclsh
## \file geneventtestsjava.tcl
# \brief Generate Java code to test the SAL Command API
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
## Documented proc \c geneventtestsjava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate Java code to test the SAL Event API
#

proc geneventtestsjava { subsys } {
global EVENT_ALIASES EVTS EVENT_ALIASES EVTS SAL_WORK_DIR SYSDIC SAL_DIR
 if { [info exists EVENT_ALIASES($subsys)] } {
  if { [info exists SYSDIC($subsys,keyedID)] } {
       set initializer "( (short) 1 )"
  } else {
       set initializer "()"
  }
  foreach alias $EVENT_ALIASES($subsys) {
    if { [info exists EVTS($subsys,$alias,param)] } {
      stdlog "	: event test send for = $alias"
      set revcode [getRevCode [set subsys]_logevent_[set alias] short]
      set fcmd [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]Event_[set alias]Test.java w]
      puts $fcmd "


// This file contains the implementation for the [set subsys]_[set alias] event generator test.
package org.lsst.sal.junit.[set subsys];

import junit.framework.TestCase;
import [set subsys].*;
import org.lsst.sal.SAL_[set subsys];

public class [set subsys]Event_[set alias]Test extends TestCase \{

   	public [set subsys]Event_[set alias]Test(String name) \{
   	   super(name);
   	\}

	public void test[set subsys]Event_[set alias] () \{

          short aKey=1;
	  SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];
          mgr.setDebugLevel(1);

	  // Issue Event
          int status=0;

            mgr.salEventPub(\"[set subsys]_logevent_[set alias]\");
            int priority=1;
	    [set subsys].logevent_[set alias] event  = new [set subsys].logevent_[set alias]();
	    event.private_revCode = \"[string trim $revcode _]\";"
     set narg 1
     foreach p $EVTS($subsys,$alias,param) {
       set pname [lindex $p 1]
       set ptype [lindex $p 0]
       if { [llength [split $pname "()"]] > 1 } {
        set pspl [split $pname "()"]
        set pname [lindex $pspl 0]
        set pdim  [lindex $pspl 1]
        switch $ptype {
          boolean { puts $fcmd "            for (int i=0; i<$pdim; i++) \{event.[set pname]\[i\] = true; \}" }
          double  { puts $fcmd "            for (int i=0; i<$pdim; i++) \{event.[set pname]\[i\] = (double) 1.0; \}" }
          int     { puts $fcmd "            for (int i=0; i<$pdim; i++) \{event.[set pname]\[i\] = (int) 1; \}" }
          long    { puts $fcmd "            for (int i=0; i<$pdim; i++) \{event.[set pname]\[i\] = (int) 1; \}" }
        }
       } else {
        switch $ptype {
          boolean { puts $fcmd "  	    event.[set pname] = true;" }
          double  { puts $fcmd "  	    event.[set pname] = (double) 1.0;" }
          int     { puts $fcmd "  	    event.[set pname] = (int) 1;" }
          long    { puts $fcmd "   	    event.[set pname] = (int) 1;" }
          string  { puts $fcmd "  	    event.[set pname] = \"testing\";" }
       }
      }
      incr narg 1
     }
     puts $fcmd "
	    status = mgr.logEvent_[set alias](event,priority);

	    try \{Thread.sleep(1000);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}

	    /* Remove the DataWriters etc */
	    mgr.salShutdown();

      \}

\}

"
      close $fcmd
      stdlog "	: event logger for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]EventLogger_[set alias]Test.java w]
      puts $fcmd "
// This file contains the implementation for the [set subsys]_[set alias] event logger test.
package org.lsst.sal.junit.[set subsys];

import junit.framework.TestCase;
import [set subsys].*;
import org.lsst.sal.SAL_[set subsys];

public class [set subsys]EventLogger_[set alias]Test extends TestCase \{

   	public [set subsys]EventLogger_[set alias]Test(String name) \{
   	   super(name);
   	\}

	public void test[set subsys]EventLogger_[set alias] () \{


	  int status   = SAL_[set subsys].SAL__OK;
          int count = 0;
	  boolean finished=false;

	  // Initialize
	  SAL_[set subsys] evt = new SAL_[set subsys][set initializer];
          evt.setDebugLevel(1);
          evt.salEventSub(\"[set subsys]_logevent_[set alias]\");
	  [set subsys].logevent_[set alias] event = new [set subsys].logevent_[set alias]();
          System.out.println(\"Event [set alias] logger ready \");

	  while (!finished) \{
	     status = evt.getEvent_[set alias](event);
	     if (status == SAL_[set subsys].SAL__OK) \{
                System.out.println(\"=== Event Logged : \" + event);"
       if { [file exists $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Jsub.tmp] } {
         set fjsub [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Jsub.tmp r]
         while { [gets $fjsub rec] > -1 } {
            puts $fcmd $rec
         }
         close $fjsub
       }
       puts $fcmd "                finished = true;
             \}
             count++;
             if ( count > 9 ) \{
                finished=true;
             \}
 	     try \{Thread.sleep(100);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}
	  \}

	  /* Remove the DataWriters etc */
	  evt.salShutdown();
       \}
\}
"
       close $fcmd
     }
   }
   puts stdout "Generating events test Makefile"
   set frep [open /tmp/makerep.sal w]
   foreach alias $EVENT_ALIASES($subsys) {
     if { [info exists EVTS($subsys,$alias,param)] } {
        puts stdout "	: for $subsys $alias"
        exec cp $SAL_DIR/code/templates/Makefile.saj_SAL_testevents.template $SAL_WORK_DIR/$subsys/java/src/Makefile.saj_[set subsys]_[set alias]_test
        puts $frep "perl -pi -w -e 's/SALData/[set subsys]/g;' [set subsys]/java/src/Makefile.saj_[set subsys]_[set alias]_test"
        puts $frep "perl -pi -w -e 's/SALALIAS/[set alias]Test/g;' [set subsys]/java/src/Makefile.saj_[set subsys]_[set alias]_test"
      }
   }
   close $frep
   exec chmod 755 /tmp/makerep.sal
   catch { set result [exec /tmp/makerep.sal] } bad
   if { $bad != "" } {puts stdout $bad}
  }
}

 
