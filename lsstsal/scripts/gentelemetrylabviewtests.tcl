#!/usr/bin/env tclsh
## \file gentelemetrylabviewtests.tcl
# \brief Generate C++ code to test the LabVIEW SAL shared library routines
#  This tests the interaction with the SAL LabVIEW Monitor for the Subsystem.
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
## Documented proc \c gentelemetrylabviewtests .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate C++ code to test the LabVIEW SAL shared library routines
#  This tests the interaction with the SAL LabVIEW Monitor for the Subsystem.
#

proc gentelemetrylabviewtests { subsys } {
global TELEMETRY_ALIASES SAL_WORK_DIR SAL_DIR
 if { [info exists TELEMETRY_ALIASES($subsys)] } {
   foreach alias $TELEMETRY_ALIASES($subsys) {
      stdlog "	: LabVIEW API publisher testfor = $alias"
      set fevt [open $SAL_WORK_DIR/$subsys/labview/sacpp_[set subsys]_[set alias]_LVputSample.cpp w]
      puts $fevt "

/*
 * This file contains the implementation for the LabVIEW API [set subsys]_[set alias] publisher test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <unistd.h>
#include \"SAL_[set subsys]_shmem.h\"
#include \"os.h\"

#include \"example_main.h\"

using namespace [set subsys];


int main (int argc, char *argv\[\])
\{ 
  [set subsys]_[set alias]C myData;
  if (argc < 2) \{
     printf(\"Usage :  input parameters...\\n\");
"
   set fidl [open $SAL_WORK_DIR/idl-templates/validated/[set subsys]_[set alias].idl r]
   skipPrivate $fidl
   while { [gets $fidl rec] > -1 } {
      if { [lindex $rec 0] != "#pragma" && [lindex $rec 0]!= "\};" } {
         puts $fevt "     printf(\"$rec\\n\");"
      }
   }
   close $fidl
   puts $fevt "     exit(1);
  \}

   SAL_[set subsys]_shmem mgr = SAL_[set subsys]_shmem();
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
  int [set subsys]ID = 1;
  mgr.salShmConnect([set subsys]ID);
#else
  mgr.salShmConnect();
#endif
"
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set alias]shmout.tmp r]
  while { [gets $fin rec] > -1 } {
       puts $fevt $rec
  }
  close $fin
  puts $fevt "
  // generate event
  mgr.putSample_[set alias]LV(&myData);
  cout << \"=== Telemetry $alias generated = \" << endl;
  sleep(1);

  /* Remove the DataWriters etc */
  mgr.salShmRelease();

  return 0;
\}

"
     close $fevt
      stdlog "	: LabVIEW API telemetry subscriber for = $alias"
      set fevt [open $SAL_WORK_DIR/$subsys/labview/sacpp_[set subsys]_[set alias]_LVgetSample.cpp w]
      puts $fevt "

/*
 * This file contains the implementation for the LabVIEW API [set subsys]_[set alias] subscriber test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set subsys]_shmem.h\"
#include \"os.h\"

#include \"example_main.h\"

using namespace [set subsys];

int main (int argc, char *argv\[\])
\{ 
  os_time delay_10ms = \{ 0, 10000000 \};
  int status = -1;

  [set subsys]_[set alias]C SALInstance;
   SAL_[set subsys]_shmem mgr = SAL_[set subsys]_shmem();
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
  int [set subsys]ID = 1;
  mgr.salShmConnect([set subsys]ID);
#else
  mgr.salShmConnect();
#endif

  while (1) \{
  // receive telemetry
    status = mgr.getSample_[set alias]LV(&SALInstance);
    if (status == SAL__OK) \{
      cout << \"=== Event $alias received = \" << endl;
"
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_[set alias]shmin.tmp r]
  while { [gets $fin rec] > -1 } {
     puts $fevt $rec
  }
  close $fin
  puts $fevt "
    \}
    os_nanoSleep(delay_10ms);
  \}

  /* Remove the DataWriters etc */
  mgr.salShmRelease();

  return 0;
\}

"
     close $fevt
   }
   puts stdout "Generating LabVIEW API events test Makefile"
   set fin [open $SAL_DIR/code/templates/Makefile.sacpp_SAL_testevents.template r]
   set fout [open /tmp/Makefile.sacpp_[set subsys]_testtelemetry w]
   while { [gets $fin rec] > -1 } {
      if { [string range $rec 0 24] == "## INSERT EVENTS TEST SRC" } {
         set n 2
         set extrasrc "		"
         set allbin "all: \$\(BIN1\) \$\(BIN2\)"
         foreach alias $TELEMETRY_ALIASES($subsys) {
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_LVputSample
OBJS$n          = .obj/SAL_[set subsys]_shmem.o .obj/sacpp_[set subsys]_[set alias]_LVputSample.o
"
             set allbin "$allbin \$\(BIN$n\)"
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_LVgetSample
OBJS$n          = .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_[set alias]_LVgetSample.o
"
             set extrasrc "$extrasrc sacpp_[set subsys]_[set alias]_LVputSample.cpp sacpp_[set subsys]_[set alias]_LVgetSample.cpp"
             set allbin "$allbin \$\(BIN$n\)"
         }
         set nbin $n
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
         foreach alias $TELEMETRY_ALIASES($subsys) {
            incr n 1
            puts $fout "
.obj/sacpp_[set subsys]_[set alias]_LVputSample.o: sacpp_[set subsys]_[set alias]_LVputSample.cpp
	@\$\(TESTDIRSTART\) \".obj/\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) sacpp_[set subsys]_[set alias]_LVputSample.cpp
.obj/sacpp_[set subsys]_[set alias]_LVgetSample.o: sacpp_[set subsys]_[set alias]_LVgetSample.cpp
	@\$\(TESTDIRSTART\) \".obj/\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) sacpp_[set subsys]_[set alias]_LVgetSample.cpp
"
         }
      }
      puts $fout $rec
   }
   close $fin
   close $fout
   exec mv /tmp/Makefile.sacpp_[set subsys]_testtelemetry $SAL_WORK_DIR/$subsys/labview/Makefile.sacpp_[set subsys]_testtelemetry
 }
}

 
