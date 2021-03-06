#!/usr/bin/env tclsh
## \file gencommandtestsjava.tcl
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
## Documented proc \c gencommandtestsjava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate Java code to test the SAL Command API
#

proc gencommandtestsjava { subsys } {
global CMD_ALIASES CMDS EVENT_ALIASES EVTS SAL_WORK_DIR SYSDIC SAL_DIR OPTIONS
 if { $OPTIONS(verbose) } {stdlog "###TRACE>>> gencommandtestsjava $subsys"}
 if { [info exists CMD_ALIASES($subsys)] } {
   if { [info exists SYSDIC($subsys,keyedID)] } {
       set initializer "( (short) 1)"
   } else {
       set initializer "()"
   }
   foreach alias $CMD_ALIASES($subsys) {
    if { [info exists CMDS($subsys,$alias,param)] } {
      stdlog "	: command test send for = $alias"
      set revcode [getRevCode [set subsys]_command_[set alias] short]
      set fcmd [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]Commander_[set alias]Test.java w]
      puts $fcmd "


// This file contains the implementation for the [set subsys]_[set alias] commander test.
package org.lsst.sal.junit.[set subsys];

import junit.framework.TestCase;
import [set subsys].*;
import org.lsst.sal.SAL_[set subsys];

public class [set subsys]Commander_[set alias]Test extends TestCase \{

   	public [set subsys]Commander_[set alias]Test(String name) \{
   	   super(name);
   	\}

	public void test[set subsys]Commander_[set alias]() \{

   	  SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];

	  // Issue command
	  int count=0;
          int cmdId=0;
          int status=0;


            int timeout=3;

  	    mgr.salCommand(\"[set subsys]_command_[set alias]\");
	    [set subsys].command_[set alias] command  = new [set subsys].command_[set alias]();

	    command.private_revCode = \"[string trim $revcode _]\";"
  set cpars $CMDS($subsys,$alias)
  set narg 1
  foreach p $CMDS($subsys,$alias,param) {
       set pname [lindex $p 1]
       set ptype [lindex $p 0]
       if { [llength [split $pname "()"]] > 1 } {
        set l 0
        set pspl [split $pname "()"]
        set pname [lindex $pspl 0]
        set pdim  [lindex $pspl 1]
        while { $l < $pdim } {
         switch $ptype {
          boolean { puts $fcmd "            command.[set pname]\[$l\] = true;" }
          double  { puts $fcmd "            command.[set pname]\[$l\] = (double) 1.0;" }
          int     { puts $fcmd "            command.[set pname]\[$l\] = (int) 1;" }
          long    { puts $fcmd "            command.[set pname]\[$l\] = (int) 1;" }
         }
         incr l 1
        }
       } else {
        switch $ptype {
          boolean { puts $fcmd "            command.[set pname] = true;" }
          double  { puts $fcmd "            command.[set pname] = (double) 1.0;" }
          int     { puts $fcmd "            command.[set pname] = (int) 1;" }
          long    { puts $fcmd "            command.[set pname] = (int) 1;" }
          string  { puts $fcmd "            command.[set pname] = \"testing\";" }
       }
      }
      incr narg 1
  }
  puts $fcmd "
	    cmdId = mgr.issueCommand_[set alias](command);

	    try \{Thread.sleep(1000);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}
	    status = mgr.waitForCompletion_[set alias](cmdId, timeout);

	    /* Remove the DataWriters etc */
	    mgr.salShutdown();

      \}

\}

"
      close $fcmd
      stdlog "	: command test receive for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]Controller_[set alias]Test.java w]
      puts $fcmd "
package org.lsst.sal.junit.[set subsys];

import junit.framework.TestCase;
import [set subsys].*;
import org.lsst.sal.SAL_[set subsys];

public class [set subsys]Controller_[set alias]Test extends TestCase \{

   	public [set subsys]Controller_[set alias]Test(String name) \{
   	   super(name);
   	\}

	public void test[set subsys]Controller_[set alias]() \{
          short aKey   = 1;
	  int status   = SAL_[set subsys].SAL__OK;
	  int cmdId    = 0;
          int timeout  = 3;
          boolean finished=false;

	  // Initialize
	  SAL_[set subsys] cmd = new SAL_[set subsys][set initializer];

	  cmd.salProcessor(\"[set subsys]_command_[set alias]\");
	  [set subsys].command_[set alias] command = new [set subsys].command_[set alias]();
          System.out.println(\"[set subsys]_[set alias] controller ready \");

	  while (!finished) \{

	     cmdId = cmd.acceptCommand_[set alias](command);
	     if (cmdId > 0) \{
	       if (timeout > 0) \{
	          cmd.ackCommand_[set alias](cmdId, SAL_[set subsys].SAL__CMD_INPROGRESS, 0, \"Ack : OK\");
 	          try \{Thread.sleep(timeout);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}
	       \}       
	       cmd.ackCommand_[set alias](cmdId, SAL_[set subsys].SAL__CMD_COMPLETE, 0, \"Done : OK\");
               finished = true;
	     \}
             timeout = timeout-1;
             if (timeout == 0) \{
               finished = true;
             \}
 	     try \{Thread.sleep(1000);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}
	  \}

	  /* Remove the DataWriters etc */
	  cmd.salShutdown();
       \}
\}

"
         close $fcmd
       }
     }
     puts stdout "Generating commands test Makefile"
     set frep [open /tmp/makerep.sal w]
     foreach alias $CMD_ALIASES($subsys) {
      if { [info exists CMDS($subsys,$alias,param)] } {
        puts stdout "	: for $subsys $alias"
        exec cp $SAL_DIR/code/templates/Makefile.saj_SAL_testcommands.template $SAL_WORK_DIR/$subsys/java/src/Makefile.saj_[set subsys]_[set alias]_test
        puts $frep "perl -pi -w -e 's/SALData/[set subsys]/g;' [set subsys]/java/src/Makefile.saj_[set subsys]_[set alias]_test"
        puts $frep "perl -pi -w -e 's/SALALIAS/[set alias]Test/g;' [set subsys]/java/src/Makefile.saj_[set subsys]_[set alias]_test"
      }
    }
    close $frep
    exec chmod 755 /tmp/makerep.sal
    catch { set result [exec /tmp/makerep.sal] } bad
    if { $bad != "" } {puts stdout $bad}
  }
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< gencommandtestsjava $subsys"}
}

#
## Documented proc \c genauthlisttestsjava .
# \param[in] subsys Name of CSC/Subsystem as defined in SALSubsystems.xml
#
#  Generates the authList test script for a Subsystem/CSC.
#  The tests start a Java controller, and then sends a set of
#  authList's and tries to issue a command with each.
#
#

proc genauthlisttestsjava { subsys } {
global CMD_ALIASES CMDS EVENT_ALIASES EVTS SAL_WORK_DIR SYSDIC SAL_DIR OPTIONS
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> genauthlisttestsjava $subsys"}
  if { [info exists SYSDIC($subsys,java)] } {
    if { [info exists CMD_ALIASES($subsys)] } {
      set rdir [lindex [glob $SAL_WORK_DIR/maven/[set subsys]*] end]
      set fout [open $SAL_WORK_DIR/[set subsys]/java/java_[set subsys]_enable_controller w]
      puts $fout "#!/bin/sh
cd $rdir
mvn -Dtest=[set subsys]Controller_enable.java test
"
      close $fout
      exec chmod 755 $SAL_WORK_DIR/[set subsys]/java/java_[set subsys]_enable_controller
      set fout [open $SAL_WORK_DIR/[set subsys]/java/testAuthList.sh w]
      puts $fout "#!/bin/sh
echo \"Starting java_[set subsys]_enable_controller\"
$SAL_WORK_DIR/[set subsys]/java/java_[set subsys]_enable_controller &
sleep 5
echo \"Test with authList not set at all, default identity=[set subsys]\"
$SAL_WORK_DIR/[set subsys]/sacpp_[set subsys]_enable_commander
echo \"Test with authList not set at all, default identity=user@host\"
$SAL_DIR/[set subsys]/sacpp_[set subsys]_enable_commander
python3 $SAL_DIR/sendEnableCommand.py $subsys \"user@host\" 5
echo \"Test with authList authorizedUsers=user@host, default identity=user@host\"
$SAL_DIR/[set subsys]/sacpp_[set subsys]_enable_commander
python3 $SAL_DIR/setAuthList.py $subsys \"user@host\" \"\" 1
python3 $SAL_DIR/sendEnableCommand.py $subsys \"user@host\" 5
echo \"Test with authList authorizedUsers=user@host,user2@other, default identity=user@host\"
$SAL_DIR/[set subsys]/sacpp_[set subsys]_enable_commander
python3 $SAL_DIR/setAuthList.py $subsys \"user@host,user2@other\" \"\" 1
python3 $SAL_DIR/sendEnableCommand.py $subsys \"user@host\" 5
echo \"Test with authList authorizedUsers=user@host,user2@other, default identity=user2@other\"
$SAL_DIR/[set subsys]/sacpp_[set subsys]_enable_commander
python3 $SAL_DIR/setAuthList.py $subsys \"user@host,user2@other\" \"\" 1
python3 $SAL_DIR/sendEnableCommand.py $subsys \"user2@other\" 5
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCS=Test default identity=user2@other\"
$SAL_DIR/[set subsys]/sacpp_[set subsys]_enable_commander
python3 $SAL_DIR/setAuthList.py $subsys \"user@host,user2@other\" \"Test\" 1
python3 $SAL_DIR/sendEnableCommand.py $subsys \"user2@other\" 5
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCS=Test default identity=Test\"
$SAL_DIR/[set subsys]/sacpp_[set subsys]_enable_commander
python3 $SAL_DIR/sendEnableCommand.py $subsys \"Test\" 5
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCS=MTM1M3,MTM2,Test default identity=MTM2\"
$SAL_DIR/[set subsys]/sacpp_[set subsys]_enable_commander
python3 $SAL_DIR/setAuthList.py $subsys \"user@host,user2@other\" \"MTM1M3,MTM2,Test\" 1
python3 $SAL_DIR/sendEnableCommand.py $subsys \"MTM2\" 5
echo \"Finished testing authList with $subsys\"
"
      close $fout
    }
  }
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< genauthlisttestsjava $subsys"}
}



