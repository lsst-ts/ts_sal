#!/usr/bin/env tclsh
## \file geneventtestssinglefilejava.tcl
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
## Documented proc \c geneventtestssinglefilejava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate Java code to test the SAL Event API
#
# Creates a two Java programs which contains an implementation of all the
# commands defined within this subsys. To generate these programs you must
# follow the SAL guidlines for generating Java libraries. 
# 
# 1) Navigate to /ts_sal/test/maven/[subsystem][vesion]/ with two terminals.
# 2) In one terminal run `mvn -Dtest=[subsystem]EventLogger_all test`
# 3) In another terminal run `mvn -Dtest=[subsystem]Event_all test` AFTER
#    the controller prints `===== [set subsys] all controllers ready =====`
#
proc geneventtestssinglefilejava { subsys } {

    global SAL_WORK_DIR

    # Create the file writers for the sender and logger.
    set sender_java_file_writer [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]Event_all.java w]
    set logger_java_file_writer [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]EventLogger_all.java w]
    
    # Insert content into the sender.
    insertEventHeaderJava $subsys $sender_java_file_writer
    insertSendersJava $subsys $sender_java_file_writer

    # Insert content into the logger.
    insertEventHeaderJava $subsys $logger_java_file_writer
    insertLoggersJava $subsys $logger_java_file_writer

    # Close all the file writers.
    close $sender_cpp_file_writer
    close $logger_cpp_file_writer
}

proc insertEventHeaderJava { subsys file_writer } {

    puts $file_writer "/*"
    puts $file_writer "* This file contains the implementation for the [set subsys] single file commander test."
    puts $file_writer "* [set subsys] subsystem generated via lsstsal/sal/scripts/gencommandtestssinglefilejava.tcl"
    puts $file_writer "* Open this file to for instructions on running this program."
    puts $file_writer " ***/"

    puts $file_writer "package org.lsst.sal.junit.[set subsys];"
    puts $file_writer "import junit.framework.TestCase;"
    puts $file_writer "import [set subsys].*;"
    puts $file_writer "import org.lsst.sal.SAL_[set subsys];\n"
}

proc insertSendersJava { subsys file_writer } {
    
    global SYSDIC EVENT_ALIASES EVTS

    if { [info exists EVENT_ALIASES($subsys)] } {
        if { [info exists SYSDIC($subsys,keyedID)] } {
            set initializer "( (short) 1)"
        } else {
            set initializer "()"
        }
    }

    puts $file_writer "public class [set subsys]Event_all extends TestCase \{\n"
    puts $file_writer "    public [set subsys]Event_all(String name) \{"
    puts $file_writer "        super(name);"
    puts $file_writer "    \}\n"
    puts $file_writer "    public void test[set subsys]Event_all() \{"
    puts $file_writer "        SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];"
    
    foreach alias $EVENT_ALIASES($subsys) {
        puts $file_writer "        mgr.salEventPub(\"[set subsys]_logevent_[set alias]\");"
    }
    puts $file_writer "        System.out.println(\"===== [set subsys] all events ready =====\");"

    foreach alias $EVENT_ALIASES($subsys) {
        puts $file_writer "\n        \{"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] start of topic ===\");"
        puts $file_writer "            int status = 0;"
        puts $file_writer "            int priority = 1;"
        puts $file_writer "            [set subsys].logevent_[set alias] event  = new [set subsys].logevent_[set alias]();"
        
        set revcode [getRevCode [set subsys]_logevent_[set alias] short]
        puts $file_writer "            event.private_revCode = \"[string trim $revcode _]\";"

        set narg 1

        foreach p $EVTS($subsys,$alias,param) {
            set pname [lindex $p 1]
            set ptype [lindex $p 0]
            if { [llength [split $pname "()"]] > 1 } {
                set l 0
                set pspl [split $pname "()"]
                set pname [lindex $pspl 0]
                set pdim  [lindex $pspl 1]
                while { $l < $pdim } {
                    switch $ptype {
                        boolean { puts $file_writer "            event.[set pname]\[$l\] = true;" }
                        double  { puts $file_writer "            event.[set pname]\[$l\] = (double) 1.0;" }
                        int     { puts $file_writer "            event.[set pname]\[$l\] = (int) 1;" }
                        long    { puts $file_writer "            event.[set pname]\[$l\] = (int) 1;" }
                     }
                incr l 1
                }
            } else {
                switch $ptype {
                    boolean { puts $file_writer "            event.[set pname] = true;" }
                    double  { puts $file_writer "            event.[set pname] = (double) 1.0;" }
                    int     { puts $file_writer "            event.[set pname] = (int) 1;" }
                    long    { puts $file_writer "            event.[set pname] = (int) 1;" }
                    string  { puts $file_writer "            event.[set pname] = \"testing\";" }
                }
            }
            incr narg 1
        }
        puts $file_writer "            status = mgr.logEvent_[set alias](event,priority);"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] end of topic ===\");"
        puts $file_writer "        \}"

    }

    puts $file_writer "    /* Remove the DataWriters etc */"
    puts $file_writer "    try \{Thread.sleep(100);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}"
    puts $file_writer "    mgr.salShutdown();"
    puts $file_writer "    \}"
    puts $file_writer "\}"
}

proc insertLoggersJava { subsys file_writer } {

    global SYSDIC EVENT_ALIASES EVTS SAL_WORK_DIR

    if { [info exists EVENT_ALIASES($subsys)] } {
        if { [info exists SYSDIC($subsys,keyedID)] } {
            set initializer "( (short) 1)"
        } else {
            set initializer "()"
        }
    }

    puts $file_writer "public class [set subsys]EventLogger_all extends TestCase \{\n"
    puts $file_writer "    public [set subsys]EventLogger_all(String name) \{"
    puts $file_writer "        super(name);"
    puts $file_writer "    \}\n"

    puts $file_writer "    public void test[set subsys]EventLogger_all() \{"
    puts $file_writer "        SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];"
    
    foreach alias $EVENT_ALIASES($subsys) {
        puts $file_writer "        mgr.salEventSub(\"[set subsys]_logevent_[set alias]\");"
    }
    puts $file_writer "        System.out.println(\"===== [set subsys] all loggers ready =====\");"


    foreach alias $EVENT_ALIASES($subsys) {
        puts $file_writer "\n        \{"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] start of topic ===\");"
        puts $file_writer "            int status = SAL_[set subsys].SAL__OK;"
        puts $file_writer "            int timeout = 30000;"
        puts $file_writer "            boolean finished = false;"
        puts $file_writer "            [set subsys].logevent_[set alias] event  = new [set subsys].logevent_[set alias]();"
        
        puts $file_writer "            while (!finished) \{"
        puts $file_writer "                status = mgr.getEvent_[set alias](event);"
        puts $file_writer "                try \{Thread.sleep(1);\} catch (InterruptedException e)  \{ e.printStackTrace(); \}"
        puts $file_writer "                if (status == SAL_[set subsys].SAL__OK) \{"
        puts $file_writer "                    System.out.println(\"=== Event Logged : \" + event);"
        if { [file exists $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Jsub.tmp] } {
                set fjsub [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Jsub.tmp r]
                while { [gets $fjsub rec] > -1 } {
                    puts $fcmd $rec
                }
                close $fjsub
            }
        puts $file_writer "                    finished = true;"
        puts $file_writer "                \}"


        puts $file_writer "                timeout = timeout-1;"
        puts $file_writer "                if (timeout == 0) \{"
        puts $file_writer "                    finished = true;"
        puts $file_writer "                \}"
        puts $file_writer "                if ((timeout % 1000) ==0)\{"
        puts $file_writer "                    System.out.println(\"timing out in \" + timeout/1000 + \"s\");"
        puts $file_writer "                \}"
        puts $file_writer "            \}"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] end of topic ===\");"
        puts $file_writer "        \}"
    }


    puts $file_writer "    /* Remove the DataWriters etc */"
    puts $file_writer "    mgr.salShutdown();"
    puts $file_writer "    \}"
    puts $file_writer "\}"
}
