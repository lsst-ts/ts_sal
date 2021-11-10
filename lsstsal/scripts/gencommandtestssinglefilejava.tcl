#!/usr/bin/env tclsh
## \file gencommandtestssinglefilejava.tcl
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
## Documented proc \c gencommandtestssinglefilejava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate Java code to test the SAL Command API
#
# Creates a two Java programs which contains an implementation of all the
# commands defined within this subsys. To generate these programs you must
# follow the SAL guidlines for generating Java libraries. 
#  
# 1) Navigate to /ts_sal/test/maven/[subsystem][vesion]/ with two terminals.
# 2) In one terminal run `mvn -Dtest=[subsystem]Controller_all test`
# 3) In another terminal run `mvn -Dtest=[subsystem]Commander_all test` AFTER
#    the controller prints `===== [set subsys] all controllers ready =====`
proc gencommandtestssinglefilejava { subsys } {
    
    global SAL_WORK_DIR

    # Create the file writers for the commander and controller.
    set commander_java_file_writer [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]Commander_all.java w]
    set controller_java_file_writer [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]Controller_all.java w]
    
    # Insert content into the commander.
    insertCommandHeaderJava $subsys $commander_java_file_writer
    insertCommandersJava $subsys $commander_java_file_writer

    # Insert content into the controller.
    insertCommandHeaderJava $subsys $controller_java_file_writer
    insertControllersJava $subsys $controller_java_file_writer

    # Close all the file writers.
    close $commander_cpp_file_writer
    close $controller_cpp_file_writer
}

proc insertCommandHeaderJava { subsys file_writer } {

    puts $file_writer "/*"
    puts $file_writer "* This file contains the implementation for the [set subsys] single file commander test."
    puts $file_writer "* [set subsys] subsystem generated via lsstsal/scripts/gencommandtestssinglefilejava.tcl"
    puts $file_writer "* Open this file to for instructions on running this program."
    puts $file_writer " ***/"

    puts $file_writer "package org.lsst.sal.junit.[set subsys];"
    puts $file_writer "import junit.framework.TestCase;"
    puts $file_writer "import [set subsys].*;"
    puts $file_writer "import org.lsst.sal.SAL_[set subsys];\n"
}

proc insertCommandersJava { subsys file_writer } {

    global SYSDIC CMD_ALIASES CMDS

    if { [info exists CMD_ALIASES($subsys)] } {
        if { [info exists SYSDIC($subsys,keyedID)] } {
            set initializer "( (short) 1)"
        } else {
            set initializer "()"
        }
    }

    puts $file_writer "public class [set subsys]Commander_all extends TestCase \{\n"
    puts $file_writer "    public [set subsys]Commander_all(String name) \{"
    puts $file_writer "        super(name);"
    puts $file_writer "    \}\n"


    puts $file_writer "    public void test[set subsys]Commander_All() \{"
    puts $file_writer "        SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];"
    puts $file_writer "        mgr.setDebugLevel(1);"
    foreach alias $CMD_ALIASES($subsys) {
        puts $file_writer "        mgr.salCommand(\"[set subsys]_command_[set alias]\");"
    }
    puts $file_writer "        System.out.println(\"===== [set subsys] all controllers ready =====\");"

    foreach alias $CMD_ALIASES($subsys) {
        puts $file_writer "        \{"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] start of topic ===\");"
        puts $file_writer "            int cmdId = 0;"
        puts $file_writer "            int status = 0;"
        puts $file_writer "            int timeout = 3;"


        puts $file_writer "            [set subsys].command_[set alias] command  = new [set subsys].command_[set alias]();"
        
        set revcode [getRevCode [set subsys]_command_[set alias] short]
        puts $file_writer "            command.private_revCode = \"[string trim $revcode _]\";"

        set narg 1

        foreach p $CMDS($subsys,$alias,param) {
            set pname [lindex $p 1]
            set ptype [lindex $p 0]
            if { [llength [split $pname "()"]] > 1 } {
                set l 0
                set pspl [split $pname "()"]
                set pname [lindex $pspl 0]
                set pdim  [lindex $pspl 1]
                switch $ptype {
                    boolean { puts $file_writer "            for (int i=0; i<$pdim; i++) \{command.[set pname]\[i\] = true; \}" }
                    double  { puts $file_writer "            for (int i=0; i<$pdim; i++) \{command.[set pname]\[i\] = (double) 1.0; \}" }
                    int     { puts $file_writer "            for (int i=0; i<$pdim; i++) \{command.[set pname]\[i\] = (int) 1; \}" }
                    long    { puts $file_writer "            for (int i=0; i<$pdim; i++) \{command.[set pname]\[i\] = (int) 1; \}" }
                }
            } else {
                switch $ptype {
                    boolean { puts $file_writer "            command.[set pname] = true;" }
                    double  { puts $file_writer "            command.[set pname] = (double) 1.0;" }
                    int     { puts $file_writer "            command.[set pname] = (int) 1;" }
                    long    { puts $file_writer "            command.[set pname] = (int) 1;" }
                    string  { puts $file_writer "            command.[set pname] = \"testing\";" }
                }
            }
            incr narg 1
        }

        puts $file_writer "            cmdId = mgr.issueCommand_[set alias](command);"
        puts $file_writer "            status = mgr.waitForCompletion_[set alias](cmdId, timeout);"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] end of topic ===\");"
        puts $file_writer "        \}"

    }

    puts $file_writer "    /* Remove the DataWriters etc */"
    puts $file_writer "    mgr.salShutdown();"
    puts $file_writer "    \}"
    puts $file_writer "\}"
}

proc insertControllersJava { subsys file_writer } {

    global SYSDIC SAL_WORK_DIR CMD_ALIASES 

    global SYSDIC CMD_ALIASES CMDS

    if { [info exists CMD_ALIASES($subsys)] } {
        if { [info exists SYSDIC($subsys,keyedID)] } {
            set initializer "( (short) 1)"
        } else {
            set initializer "()"
        }
    }

    puts $file_writer "public class [set subsys]Controller_all extends TestCase \{\n"
    puts $file_writer "    public [set subsys]Controller_all(String name) \{"
    puts $file_writer "        super(name);"
    puts $file_writer "    \}\n"


    puts $file_writer "    public void test[set subsys]Controller_All() \{"
    puts $file_writer "        SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];"
    puts $file_writer "        mgr.setDebugLevel(1);"
    foreach alias $CMD_ALIASES($subsys) {
        puts $file_writer "        mgr.salProcessor(\"[set subsys]_command_[set alias]\");"
    }
    puts $file_writer "        System.out.println(\"===== [set subsys] all controllers ready =====\");"
     
    foreach alias $CMD_ALIASES($subsys) {
        puts $file_writer "\n        \{"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] start of topic ===\");"
        puts $file_writer "            int cmdId = 0;"
        puts $file_writer "            int status = SAL_[set subsys].SAL__OK;"
        puts $file_writer "            int timeout = 30;"
        puts $file_writer "            short akey = 1;"
        puts $file_writer "            boolean finished = false;"
        puts $file_writer "            [set subsys].command_[set alias] command = new [set subsys].command_[set alias]();"
        puts $file_writer "            while (!finished) \{"
        puts $file_writer "                cmdId = mgr.acceptCommand_[set alias](command);"
        puts $file_writer "                if (cmdId > 0) \{"
        puts $file_writer "                    if (timeout > 0) \{"
        puts $file_writer "                        mgr.ackCommand_[set alias](cmdId, SAL_[set subsys].SAL__CMD_INPROGRESS, 0, \"Ack : OK\");"
        puts $file_writer "                        try \{Thread.sleep(timeout);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}"
        puts $file_writer "                    \}       "
        puts $file_writer "                    mgr.ackCommand_[set alias](cmdId, SAL_[set subsys].SAL__CMD_COMPLETE, 0, \"Done : OK\");"
        puts $file_writer "                    System.out.println(\"=== [set subsys]_[set alias] end of topic ===\");"
        puts $file_writer "                    finished = true;"
        puts $file_writer "                \}"
        puts $file_writer "                timeout = timeout-1;"
        puts $file_writer "                if (timeout == 0) \{"
        puts $file_writer "                    finished = true;"
        puts $file_writer "                \}"
        puts $file_writer "                try \{"
        puts $file_writer "                    System.out.println(\"timing out in \" + timeout + \"s\");"
        puts $file_writer "                    Thread.sleep(1000);"
        puts $file_writer "                \}"
        puts $file_writer "                catch (InterruptedException e)\{" 
        puts $file_writer "                    e.printStackTrace();"
        puts $file_writer "                \}"
        puts $file_writer "            \}"
        puts $file_writer "        \}"
    }
    puts $file_writer "    \}"
    puts $file_writer "\}"
}
