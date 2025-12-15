#!/usr/bin/env tclsh
## \file gencommandlabviewtests.tcl
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
## Documented proc \c gencommandlabviewtests .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generate C++ code to test the LabVIEW SAL shared library routines
#  This tests the interaction with the SAL LabVIEW Monitor for the Subsystem.
#
proc gencommandlabviewtests { subsys } {
global CMD_ALIASES CMDS SAL_DIR SAL_WORK_DIR SYSDIC
 if { [info exists CMD_ALIASES($subsys)] } {
   foreach alias $CMD_ALIASES($subsys) {
    if { [info exists CMDS($subsys,$alias,param)] } {
      stdlog "	: LabVIEW API command test send for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/labview/sacpp_[set subsys]_[set alias]_LVcommander.cpp w]
      puts $fcmd "

/*
 * This file contains the implementation for the [set subsys]_[set alias]  LabVIEW API commander test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set subsys]_shmem.h\"
#include \"os.h\"
using namespace [set subsys];

int main (int argc, char *argv\[\])
\{ 
  int cmdId;
  int timeout=10;
  int status=0;

  [set subsys]_command_[set alias]C myData;
  if (argc < [expr [llength $CMDS([set subsys],[set alias],plist)] +1] ) \{
     printf(\"Usage :  input parameters...\\n\");"
   set fidl [open $SAL_WORK_DIR/idl-templates/validated/[set subsys]_command_[set alias].idl r]
   skipPrivate $fidl
   while { [gets $fidl rec] > -1 } {
      if { [lindex $rec 0] != "#pragma" && [lindex $rec 0]!= "\};" } {
         puts $fcmd "     printf(\"$rec\\n\");"
      }
   }
   close $fidl
   puts $fcmd "     exit(1);
  \}
   SAL_[set subsys]_shmem mgr = SAL_[set subsys]_shmem();"
   if { [info exists SYSDIC($subsys,keyedID)] } {
      puts $fcmd "
  int salIndex = 1;
  mgr.salShmConnect(salIndex);"
   } else {
      puts $fcmd "  mgr.salShmConnect();"
   }
   puts $fcmd "
"
  set cpars $CMDS($subsys,$alias)
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set alias]shmout.tmp r]
  while { [gets $fin rec] > -1 } {
     puts $fcmd $rec
  }
  close $fin
  puts $fcmd "
  // generate command
  cmdId = mgr.issueCommand_[set alias](&myData);
  cout << \"=== command $alias issued = \" << endl;
  status = mgr.waitForCompletion_[set alias](cmdId, timeout);

  /* Remove the DataWriters etc */
  mgr.salShmRelease();

  return status;
\}

"
     close $fcmd
      stdlog "	: LabVIEW API controller test receive for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/labview/sacpp_[set subsys]_[set alias]_LVcontroller.cpp w]
      puts $fcmd "

/*
 * This file contains the implementation for the LabVIEW API [set subsys]_[set alias] controller test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set subsys]_shmem.h\"
#include \"os.h\"
using namespace [set subsys];

int main (int argc, char *argv\[\])
\{ 
  os_time delay_10ms = \{ 0, 10000000 \};
  int cmdId = -1;
  int timeout = 1;
  [set subsys]_command_[set alias]C SALInstance;
  SAL_[set subsys]_shmem mgr = SAL_[set subsys]_shmem();"
   if { [info exists SYSDIC($subsys,keyedID)] } {
      puts $fcmd "
  int salIndex = 1;
  mgr = salShmConnect(salIndex);"
   } else {
      puts $fcmd "  mgr.salShmConnect();"
   }
   puts $fcmd "

  while (1) \{
    // receive command
    cmdId = mgr.acceptCommand_[set alias](&SALInstance);
    if (cmdId > 0) \{
       cout << \"=== command $alias received = \" << endl;
"
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set alias]shmin.tmp r]
  while { [gets $fin rec] > -1 } {
     puts $fcmd "    $rec"
  }
  close $fin
  puts $fcmd "
       if (timeout > 0) \{
          mgr.ackCommand_[set alias](cmdId, SAL__CMD_INPROGRESS, 0, \"Ack : OK\");
          os_nanoSleep(delay_10ms);
       \}       
       mgr.ackCommand_[set alias](cmdId, SAL__CMD_COMPLETE, 0, \"Done : OK\");
    \}
    os_nanoSleep(delay_10ms);
  \}

  /* Remove the DataWriters etc */
  mgr.salShmRelease();

  return 0;
\}

int main (int argc, char *argv\[\])
\{
  return test_[set subsys]_[set alias]_controller();
\}
"
     close $fcmd
    }
   }
   puts stdout "Generating LabVIEW API commands test Makefile"
   set fin [open $SAL_DIR/code/templates/Makefile.sacpp_SAL_testcommands.template r]
   set fout [open /tmp/Makefile.sacpp_[set subsys]_testcommands w]
   while { [gets $fin rec] > -1 } {
      if { [string range $rec 0 26] == "## INSERT COMMANDS TEST SRC" } {
         set n 2
         set extrasrc "		"
         set allbin "all: \$\(BIN1\) \$\(BIN2\)"
         foreach alias $CMD_ALIASES($subsys) {
           if { [info exists CMDS($subsys,$alias,param)] } {
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_LVcommander
OBJS$n          = .obj/SAL_[set subsys]_shem.o .obj/sacpp_[set subsys]_[set alias]_LVcommander.o
"
             set allbin "$allbin \$\(BIN$n\)"
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_LVcontroller
OBJS$n          = .obj/SAL_[set subsys]_shmem.o .obj/sacpp_[set subsys]_[set alias]_LVcontroller.o
"
             set extrasrc "$extrasrc sacpp_[set subsys]_[set alias]_LVcommander.cpp sacpp_[set subsys]_[set alias]_LVcontroller.cpp"
             set allbin "$allbin \$\(BIN$n\)"
           }
         }
         set nbin $n
         puts $fout "
SRC           = SAL_[set subsys]_shmem.cpp $extrasrc"
      }
      if { [string range $rec 0 26] == "## INSERT COMMANDS TEST BIN" } {
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
         foreach alias $CMD_ALIASES($subsys) {
          if { [info exists CMDS($subsys,$alias,param)] } {
            incr n 1
            puts $fout "
.obj/sacpp_[set subsys]_[set alias]_LVcommander.o: sacpp_[set subsys]_[set alias]_LVcommander.cpp
	@\$\(TESTDIRSTART\) \".obj/\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) sacpp_[set subsys]_[set alias]_LVcommander.cpp
.obj/sacpp_[set subsys]_[set alias]_LVcontroller.o: sacpp_[set subsys]_[set alias]_LVcontroller.cpp
	@\$\(TESTDIRSTART\) \".obj\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) sacpp_[set subsys]_[set alias]_LVcontroller.cpp
"
          }
         }
      }
      puts $fout $rec
   }
   close $fin
   close $fout
   exec mv /tmp/Makefile.sacpp_[set subsys]_testcommands $SAL_WORK_DIR/$subsys/labview/Makefile.sacpp_[set subsys]_testcommands
 }
}

 
