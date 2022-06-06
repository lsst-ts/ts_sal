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
 if { $subsys == "LOVE" } {return}
 if { [info exists CMD_ALIASES($subsys)] } {
   if { [info exists SYSDIC($subsys,keyedID)] } {
       set initializer "( (short) 1)"
   } else {
       set initializer "(\"[set subsys]\")"
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
          String idname = System.getenv(\"LSST_IDENTITY\");
     	  SAL_[set subsys]   mgr = new SAL_[set subsys](idname);
          mgr.setDebugLevel(1);

	  // Issue command
	  int count=0;
          int cmdId=0;
          int status=0;


            int timeout=10;

  	    mgr.salCommand(\"[set subsys]_command_[set alias]\");
	    [set subsys].command_[set alias] command  = new [set subsys].command_[set alias]();

	    command.private_revCode = \"[string trim $revcode _]\";"
  if { $alias == "setAuthList" } {
       puts $fcmd "
            String pname = System.getenv(\"LSST_AUTHLIST_USERS\");
            if (pname != null) \{
               command.authorizedUsers=pname;
            \}
            String cname = System.getenv(\"LSST_AUTHLIST_CSCS\");
            if (cname != null) \{
               command.nonAuthorizedCSCs=cname;
            \}
"
   } else {
     set cpars $CMDS($subsys,$alias)
     set narg 1
     foreach p $CMDS($subsys,$alias,param) {
       set pname [lindex $p 1]
       set ptype [lindex $p 0]
       if { [llength [split $pname "()"]] > 1 } {
        set pspl [split $pname "()"]
        set pname [lindex $pspl 0]
        set pdim  [lindex $pspl 1]
        switch $ptype {
          boolean { puts $fcmd "            for (int i=0; i<$pdim; i++) \{command.[set pname]\[i\] = true; \}" }
          double  { puts $fcmd "            for (int i=0; i<$pdim; i++) \{command.[set pname]\[i\] = (double) 1.0; \}" }
          int     { puts $fcmd "            for (int i=0; i<$pdim; i++) \{command.[set pname]\[i\] = (int) 1; \}" }
          long    { puts $fcmd "            for (int i=0; i<$pdim; i++) \{command.[set pname]\[i\] = (int) 1; \}" }
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
  }
  puts $fcmd "
	    cmdId = mgr.issueCommand_[set alias](command);

	    try \{Thread.sleep(1000);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}"
  if { $alias != "setAuthList" } {
     puts $fcmd "            		
	    status = mgr.waitForCompletion_[set alias](cmdId, timeout);"
  }
  puts $fcmd "
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
	  // Initialize
          String idname = System.getenv(\"LSST_IDENTITY\");
     	  SAL_[set subsys] cmd = new SAL_[set subsys](idname);
          cmd.setDebugLevel(1);

	  cmd.salProcessor(\"[set subsys]_command_[set alias]\");
	  [set subsys].command_[set alias] command = new [set subsys].command_[set alias]();
          System.out.println(\"[set subsys]_[set alias] controller ready \");

	  while (cmdId > -1) \{
             cmd.checkAuthList(\"\");
	     cmdId = cmd.acceptCommand_[set alias](command);
	     if (cmdId > 0) \{
	       cmd.ackCommand_[set alias](cmdId, SAL_[set subsys].SAL__CMD_INPROGRESS, 0, \"Ack : OK\");
  	       try \{Thread.sleep(1000);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}
	       cmd.ackCommand_[set alias](cmdId, SAL_[set subsys].SAL__CMD_COMPLETE, 0, \"Done : OK\");
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
  if { [lsearch $CMD_ALIASES([set subsys]) "setLogLevel"] > -1 } {
    genauthlisttestsjava $subsys
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
global env CMD_ALIASES CMDS EVENT_ALIASES EVTS SAL_WORK_DIR SYSDIC SAL_DIR OPTIONS
global RELVERSION XMLVERSION SALVERSION
  set mvnrelease [set XMLVERSION]_[set SALVERSION][set RELVERSION]
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> genauthlisttestsjava $subsys"}
  if { [info exists SYSDIC($subsys,java)] } {
    if { [info exists CMD_ALIASES($subsys)] } {
      set rdir $SAL_WORK_DIR/maven/[set subsys]-[set mvnrelease] 
      set fout [open $SAL_WORK_DIR/[set subsys]/java/src/java_[set subsys]_setLogLevel_controller w]
      puts $fout "#!/bin/sh
cd $rdir
mvn -q --no-transfer-progress -Dtest=[set subsys]Controller_setLogLevelTest.java test
"
      close $fout
      exec chmod 755 $SAL_WORK_DIR/[set subsys]/java/src/java_[set subsys]_setLogLevel_controller
      set fout [open $SAL_WORK_DIR/[set subsys]/java/src/java_[set subsys]_setLogLevel_commander w]
      puts $fout "#!/bin/sh
cd $rdir
mvn -q --no-transfer-progress -Dtest=[set subsys]Commander_setLogLevelTest.java test
"
      close $fout
      exec chmod 755 $SAL_WORK_DIR/[set subsys]/java/src/java_[set subsys]_setLogLevel_commander
      set fout [open $SAL_WORK_DIR/[set subsys]/java/src/java_[set subsys]_authList_commander w]
      puts $fout "#!/bin/sh
cd $rdir
mvn -q --no-transfer-progress -Dtest=[set subsys]Commander_setAuthListTest.java test
"
      close $fout
      exec chmod 755 $SAL_WORK_DIR/[set subsys]/java/src/java_[set subsys]_authList_commander
      set fout [open $SAL_WORK_DIR/[set subsys]/java/src/testAuthList.sh w]
      set testnoauth "MTM1M3"
      if { $subsys == "MTM1M3" } {set testnoauth "MTRotator"}
      puts $fout "#!/bin/sh
export LSST_DDS_ENABLE_AUTHLIST=1
echo \"=====================================================================\"
echo \"Starting java_[set subsys]_setLogLevel_controller\"
$SAL_WORK_DIR/[set subsys]/java/src/java_[set subsys]_setLogLevel_controller &
sleep 10
echo \"=====================================================================\"
echo \"Test with authList not set at all, default identity=[set subsys]\"
echo \"Expect : completed ok\"
unset LSST_IDENTITY
export LSST_AUTHLIST_USERS=\"\"
export LSST_AUTHLIST_CSCS=\"\"
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_authList_commander
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_setLogLevel_commander 
echo \"=====================================================================\"
echo \"Test with authList not set at all, identity=user@host\"
echo \"Expect : Not permitted by authList\"
export LSST_IDENTITY=user@host
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_setLogLevel_commander
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host, identity=user@host\"
echo \"Expect : completed ok\"
export LSST_AUTHLIST_USERS=user@host
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_authList_commander
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_setLogLevel_commander 
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, identity=user@host\"
echo \"Expect : completed ok\"
export LSST_AUTHLIST_USERS=user@host,user2@other
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_authList_commander
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_setLogLevel_commander
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, identity=user2@other\"
echo \"Expect : completed ok\"
export LSST_IDENTITY=user2@other
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_authList_commander
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_setLogLevel_commander
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCs=Test identity=user2@other\"
echo \"Expect : completed ok\"
export LSST_AUTHLIST_CSCS=Test
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_authList_commander
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_setLogLevel_commander
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCs=Test identity=Test\"
echo \"Expect : Not permitted by authList\"
export LSST_IDENTITY=Test
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_setLogLevel_commander
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCs=[set testnoauth],Test identity=[set testnoauth]\"
echo \"Expect : Not permitted by authList\"
export LSST_AUTHLIST_CSCS=[set testnoauth],Test
export LSST_IDENTITY=[set testnoauth]
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_authList_commander
$SAL_WORK_DIR/$subsys/java/src/java_[set subsys]_setLogLevel_commander
sleep 10
pkill -9 java_[set subsys]
pkill -9 java
echo \"=====================================================================\"
echo \"Finished testing authList with $subsys\"
echo \"=====================================================================\"
"
      close $fout
    }
    exec chmod 755 $SAL_WORK_DIR/[set subsys]/java/src/testAuthList.sh
  }
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< genauthlisttestsjava $subsys"}
}


