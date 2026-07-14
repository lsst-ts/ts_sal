#!/usr/bin/env tclsh
## \file geneventtests.tcl
# \brief This contains procedures to create the SAL API tests 
#  It generates code and tests for C++ Event Topics
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
## Documented proc \c geneventtestscpp .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates the Event handling code for a Subsystem/CSC.
#  Code is generated for a send and a log task
#  per Event Topic type. 
#

proc geneventtestscpp { subsys } {
global EVENT_ALIASES EVTS SAL_WORK_DIR DONE_CMDEVT
 if { [info exists EVENT_ALIASES($subsys)] && $DONE_CMDEVT == 0 } {
   foreach alias $EVENT_ALIASES($subsys) {
     if { [info exists EVTS($subsys,$alias,param)] } {
      stdlog "	: log event test send for = $alias"
      set fevt [open $SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_[set alias]_send.cpp w]
      puts $fevt "

/*
 * This file contains the implementation for the [set subsys]_[set alias] send test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <unistd.h>
#include \"SAL_[set subsys].h\"
#include \"ccpp_sal_[set subsys].h\"
#include \"os.h\"
#include <stdlib.h>

#include \"example_main.h\"

using namespace DDS;
using namespace [set subsys];


int main (int argc, char *argv\[\])
\{ 
  int priority = SAL__EVENT_INFO;
  [set subsys]_logevent_[set alias]C myData;
  if (argc < [expr [llength $EVTS([set subsys],[set alias],plist)] +1]) \{
     printf(\"Usage :  input parameters...\\n\");
"
   set fidl [open $SAL_WORK_DIR/idl-templates/validated/[set subsys]_logevent_[set alias].idl r]
   skipPrivate $fidl
   while { [gets $fidl rec] > -1 } {
      if { [lindex $rec 0] != "#pragma" && [lindex $rec 0]!= "\};" && [lindex $rec 0] != "const" } {
         puts $fevt "     printf(\"$rec\\n\");"
      }
   }
   close $fidl
   puts $fevt "     exit(1);
  \}

#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
  int salIndex = 1;
  if (getenv(\"LSST_[string toupper [set subsys]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set subsys]]_ID\"),\"%d\",&salIndex);
  \} 
  SAL_[set subsys] mgr = SAL_[set subsys](salIndex);
#else
  SAL_[set subsys] mgr = SAL_[set subsys]();
#endif
  mgr.salEventPub(\"[set subsys]_logevent_[set alias]\");
"
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Cargs.tmp r]
  while { [gets $fin rec] > -1 } {
       puts $fevt $rec
  }
  close $fin
  puts $fevt "
  // generate event
  priority = 0;
  mgr.logEvent_[set alias](&myData, priority);
  cout << \"=== Event $alias generated = \" << endl;
  sleep(1);

  /* Remove the DataWriters etc */
  mgr.salShutdown();

  return 0;
\}

"
     close $fevt
      stdlog "	: log event test receive for = $alias"
      set fevt [open $SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_[set alias]_log.cpp w]
      puts $fevt "

/*
 * This file contains the implementation for the [set subsys]_[set alias] receive test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set subsys].h\"
#include \"ccpp_sal_[set subsys].h\"
#include \"os.h\"
#include <stdlib.h>

#include \"example_main.h\"

using namespace DDS;
using namespace [set subsys];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_[set subsys]_[set alias]_Log();
\}

int test_[set subsys]_[set alias]_Log()
\{ 
  os_time delay_10ms = \{ 0, 10000000 \};
  int status = -1;

  [set subsys]_logevent_[set alias]C SALInstance;
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
  int salIndex = 1;
  if (getenv(\"LSST_[string toupper [set subsys]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set subsys]]_ID\"),\"%d\",&salIndex);
  \} 
  SAL_[set subsys] mgr = SAL_[set subsys](salIndex);
#else
  SAL_[set subsys] mgr = SAL_[set subsys]();
#endif
  mgr.salEventSub(\"[set subsys]_logevent_[set alias]\");
  cout << \"=== Event $alias logger ready = \" << endl;

  while (1) \{
  // receive event
    status = mgr.getEvent_[set alias](&SALInstance);
    if (status == SAL__OK) \{
      cout << \"=== Event $alias received = \" << endl;
"
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]Csub.tmp r]
  while { [gets $fin rec] > -1 } {
     puts $fevt $rec
  }
  close $fin
  puts $fevt "
    \}
    os_nanoSleep(delay_10ms);
  \}

  /* Remove the DataWriters etc */
  mgr.salShutdown();

  return 0;
\}

int OSPL_MAIN (int argc, char *argv\[\])
\{
  return test_[set subsys]_[set alias]_Log();
\}
"
     close $fevt
    }
   }
   puts stdout "Generating events test Makefile"
   set fin [open $SAL_WORK_DIR/$subsys/cpp/src/Makefile.sacpp_[set subsys]_testevents r]
   set fout [open /tmp/Makefile.sacpp_[set subsys]_testevents w]
   while { [gets $fin rec] > -1 } {
      if { [string range $rec 0 24] == "## INSERT EVENTS TEST SRC" } {
         set n 2
         set extrasrc "		"
         set allbin "all: "
         foreach alias $EVENT_ALIASES($subsys) {
           if { [info exists EVTS($subsys,$alias,param)] } {
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_send
OBJS$n          =  .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_[set alias]_send.o
"
             set allbin "$allbin \$\(BIN$n\)"
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_log
OBJS$n          =  .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_[set alias]_log.o
"
             set extrasrc "$extrasrc sacpp_[set subsys]_[set alias]_send.cpp sacpp_[set subsys]_[set alias]_log.cpp"
             set allbin "$allbin \$\(BIN$n\)"
           }
         }
         set nbin $n
         puts $fout "
SRC           = ../src/SAL_[set subsys].cpp $extrasrc"
      }
      if { [string range $rec 0 24] == "## INSERT EVENTS TEST BIN" } {
         set n 2
         puts $fout "$allbin"
         while { $n <= $nbin } {
            incr n 1
            puts $fout "
\$\(BIN$n\): \$(OBJS$n\)
	@\$\(TESTDIRSTART\) \"\$\(BTARGETDIR\)\" \$\(TESTDIREND\) \$\(MKDIR\) \"\$\(BTARGETDIR\)\"
	\$\(LINK.cc\) \$\(OBJS$n\) \$\(LDLIBS\) \$\(OUTPUT_OPTION\)

"
         }
         foreach alias $EVENT_ALIASES($subsys) {
           if { [info exists EVTS($subsys,$alias,param)] } {
            incr n 1
            puts $fout "
.obj/sacpp_[set subsys]_[set alias]_send.o: ../src/sacpp_[set subsys]_[set alias]_send.cpp
	@\$\(TESTDIRSTART\) \".obj/../src\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/../src\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) ../src/sacpp_[set subsys]_[set alias]_send.cpp
.obj/sacpp_[set subsys]_[set alias]_log.o: ../src/sacpp_[set subsys]_[set alias]_log.cpp
	@\$\(TESTDIRSTART\) \".obj/../src\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/../src\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) ../src/sacpp_[set subsys]_[set alias]_log.cpp
"
           }
         }
      }
      puts $fout $rec
   }
   close $fin
   close $fout
   exec cp /tmp/Makefile.sacpp_[set subsys]_testevents $SAL_WORK_DIR/$subsys/cpp/src/Makefile.sacpp_[set subsys]_testevents
 }
}

 
