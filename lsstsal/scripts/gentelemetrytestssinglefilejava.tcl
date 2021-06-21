#!/usr/bin/env tclsh
## \file gentelemetrytestssinglefilejava.tcl
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
## Documented proc \c gentelemetrytestssinglefilejava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate Java code to test the SAL Telemetry API
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
proc gentelemetrytestssinglefilejava { subsys } {

    global SAL_WORK_DIR

    # Create the file writers for the sender, logger and makefile.
    set publisher_java_file_writer [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]Publisher_all.java w]
    set subscriber_java_file_writer [open $SAL_WORK_DIR/$subsys/java/src/[set subsys]Subscriber_all.java w]

    # Insert content into the publisher.
    insertTelemetryHeaderJava $subsys $publisher_java_file_writer
    insertPublishersJava $subsys $publisher_java_file_writer

    # Insert content into the logger.
    insertTelemetryHeaderJava $subsys $subscriber_java_file_writer
    insertSubscribersJava $subsys $subscriber_java_file_writer

    # Close all the file writers.
    close $sender_cpp_file_writer
    close $logger_cpp_file_writer
}

proc insertTelemetryHeaderJava { subsys file_writer } {

    puts $file_writer "/*"
    puts $file_writer "* This file contains the implementation for the [set subsys] single file commander test."
    puts $file_writer "* [set subsys] subsystem generated via gencommandtestssinglefilejava.tcl"
    puts $file_writer "* Open this file to for instructions on running this program."
    puts $file_writer " ***/"

    puts $file_writer "package org.lsst.sal.junit.[set subsys];"
    puts $file_writer "import junit.framework.TestCase;"
    puts $file_writer "import [set subsys].*;"
    puts $file_writer "import org.lsst.sal.SAL_[set subsys];\n"
}

proc insertPublishersJava { subsys file_writer } {

    global SYSDIC TLM_ALIASES

    if { [info exists TLM_ALIASES($subsys)] } {
        if { [info exists SYSDIC($subsys,keyedID)] } {
            set initializer "( (short) 1)"
        } else {
            set initializer "()"
        }
    }

    puts $file_writer "public class [set subsys]Publisher_all extends TestCase \{\n"
    puts $file_writer "    public [set subsys]Publisher_all(String name) \{"
    puts $file_writer "        super(name);"
    puts $file_writer "    \}\n"
    puts $file_writer "    public void test[set subsys]Publisher_all() \{"
    puts $file_writer "        SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];"

    foreach alias $TLM_ALIASES($subsys) {
        puts $file_writer "        mgr.salTelemetryPub(\"[set subsys]_[set alias]\");"
    }
    puts $file_writer "        System.out.println(\"===== [set subsys] all publishers ready =====\");"

    foreach alias $TLM_ALIASES($subsys) {
        puts $file_writer "\n        \{"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] start of topic ===\");"
        puts $file_writer "            int count = 1;"
        puts $file_writer "            [set subsys].[set alias] theTopicInstance  = new [set subsys].[set alias]();"

        puts $file_writer "            while (count < 201) {"
        puts $file_writer "                mgr.putSample(theTopicInstance);"
        puts $file_writer "                System.out.println(\"=== \[[set alias]\] message sent \" + count);"
        puts $file_writer "                ++count;"
        puts $file_writer "                try {"
        puts $file_writer "                Thread.sleep(4);"
        puts $file_writer "                } catch (InterruptedException e) {"
        puts $file_writer "                }"
        puts $file_writer "            }"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] end of topic ===\");"
        puts $file_writer "        \}"
        puts $file_writer "        try \{"
        puts $file_writer "            Thread.sleep(2000);"
        puts $file_writer "        \}"
        puts $file_writer "        catch(InterruptedException e) \{"
        puts $file_writer "            e.printStackTrace();"
        puts $file_writer "        \}"
    }
    puts $file_writer "        mgr.salShutdown();"
    puts $file_writer "    \}"
    puts $file_writer "\}"
}

proc insertSubscribersJava { subsys file_writer } {

    global SYSDIC TLM_ALIASES

    if { [info exists TLM_ALIASES($subsys)] } {
        if { [info exists SYSDIC($subsys,keyedID)] } {
            set initializer "( (short) 1)"
        } else {
            set initializer "()"
        }
    }

    puts $file_writer "public class [set subsys]Subscriber_all extends TestCase \{\n"
    puts $file_writer "    public [set subsys]Subscriber_all(String name) \{"
    puts $file_writer "        super(name);"
    puts $file_writer "    \}\n"
    puts $file_writer "    public void test[set subsys]Subscriber_all() \{"
    puts $file_writer "        SAL_[set subsys] mgr = new SAL_[set subsys][set initializer];"

    foreach alias $TLM_ALIASES($subsys) {
        puts $file_writer "        mgr.salTelemetrySub(\"[set subsys]_[set alias]\");"
        puts $file_writer "        [set subsys].[set alias] [set alias]SALInstance = new [set subsys].[set alias]();\n"
    }

    puts $file_writer "        // Short wait here to give samples some time to arrive before flushing them. If you"
    puts $file_writer "        // remove this wait you may find yourself getting an historical topic even though"
    puts $file_writer "        // you are flushing. This is because those topics arrive AFTER the flushing"
    puts $file_writer "        try \{"
    puts $file_writer "            Thread.sleep(5000);"
    puts $file_writer "            \}"
    puts $file_writer "        catch(InterruptedException e) \{"
    puts $file_writer "            e.printStackTrace();"
    puts $file_writer "        \}\n"

    foreach alias $TLM_ALIASES($subsys) {
        puts $file_writer "        mgr.flushSamples([set alias]SALInstance);"
    }


    puts $file_writer "\n        System.out.println(\"===== [set subsys] all subscribers ready =====\");\n"

    puts $file_writer "        // The loops below follow the below schema"
    puts $file_writer "        // 1) Initialize variables"
    puts $file_writer "        // 2) Begin listening for values, check every 1ms if a value is recieved"
    puts $file_writer "        // 3) Exit loop once 200 messages recieved or 30 second timeout"
    
    foreach alias $TLM_ALIASES($subsys) {
        puts $file_writer "\n        \{"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] start of topic ===\");"
                
        puts $file_writer "            int samples = 0;"
        puts $file_writer "            int count = 0;"
        puts $file_writer "            int timeout = 30000;"
        puts $file_writer "            boolean finished = false;\n"
        
        puts $file_writer "            while (!finished) \{"
        puts $file_writer "                samples = mgr.getSample([set alias]SALInstance);"
        puts $file_writer "                if (samples == SAL_[set subsys].SAL__OK) \{"
        puts $file_writer "                    count++;"
        puts $file_writer "                    System.out.println(\"=== \[[set alias] Subscriber\] samples\" + [set alias]SALInstance.private_sndStamp);"
        puts $file_writer "                    System.out.println(\"=== \[[set alias] Subscriber\] message received :\" + count);"
        puts $file_writer "                    if (count == 200) \{"
        puts $file_writer "                        finished = true;"
        puts $file_writer "                    \}"
        puts $file_writer "                \}\n"
        
        puts $file_writer "                timeout = timeout-1;"
        puts $file_writer "                if (timeout == 0) \{"
        puts $file_writer "                    finished = true;"
        puts $file_writer "                \}"
        puts $file_writer "                if ((timeout % 1000) ==0)\{"
        puts $file_writer "                    System.out.println(\"timing out in \" + timeout/1000 + \"s\");"
        puts $file_writer "                \}\n"

        puts $file_writer "                try \{"
        puts $file_writer "                    Thread.sleep(1);"
        puts $file_writer "                \}"
        puts $file_writer "                catch(InterruptedException e) \{"
        puts $file_writer "                    e.printStackTrace();"
        puts $file_writer "                \}"
        puts $file_writer "            \}"
        puts $file_writer "            System.out.println(\"=== [set subsys]_[set alias] end of topic ===\");"

        

        puts $file_writer "        \}"
    }

    puts $file_writer "    mgr.salShutdown();"
    puts $file_writer "  \}"
    puts $file_writer "\}"
}
