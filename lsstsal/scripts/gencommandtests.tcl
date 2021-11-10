#!/usr/bin/env tclsh
## \file gencommandtests.tcl
# \brief This contains procedures to create the SAL API tests 
#  It generates code and tests for C++ Command Topics
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
## Documented proc \c gencommandtestscpp .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates the Command handling code for a Subsystem/CSC.
#  Code is generated for a commander and a controller task
#  per-command Topic type. 
#
proc gencommandtestscpp { subsys } {
global CMD_ALIASES CMDS SAL_WORK_DIR SAL_DIR SYSDIC DONE_CMDEVT OPTIONS
 if { $OPTIONS(verbose) } {stdlog "###TRACE>>> gencommandtestscpp $subsys"}
 if { $subsys == "LOVE" } {return}
 if { [info exists CMD_ALIASES($subsys)] && $DONE_CMDEVT == 0 } {
   foreach alias $CMD_ALIASES($subsys) {
    if { [info exists CMDS($subsys,$alias,param)] } {
      stdlog "	: command test send for = $alias"
      set chk "exec  nl $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set alias]Cargs.tmp | tail -1"
      set ichk [eval $chk]
      set numargs [expr [string range $ichk 0 8] +1]
      set fcmd [open $SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_[set alias]_commander.cpp w]
      puts $fcmd "

/*
 * This file contains the implementation for the [set subsys]_[set alias] commander test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set subsys].h\"
#include \"ccpp_sal_[set subsys].h\"
#include \"os.h\"
#include <stdlib.h>
using namespace DDS;
using namespace [set subsys];

int main (int argc, char *argv\[\])
\{ 
  int cmdId;
  int timeout=10;
  int status=0;

  [set subsys]_command_[set alias]C myData;
  if (argc < $numargs ) \{
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
  \}"
   if { [info exists SYSDIC($subsys,keyedID)] } {
      puts $fcmd "
  int [set subsys]ID = 1;
  char *identity = (char *)malloc(128);
  if (getenv(\"LSST_[string toupper [set subsys]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set subsys]]_ID\"),\"%d\",&[set subsys]ID);
  \} 
  if (getenv(\"LSST_IDENTITY\") != NULL) \{
     char *auth = getenv(\"LSST_IDENTITY\");
     sprintf(identity,\"%s\",auth);
  \} else \{
    sprintf(identity,\"[set subsys]:%d\",[set subsys]ID);
  \}
  SAL_[set subsys] *mgr = new SAL_[set subsys]([set subsys]ID,identity);
"
   } else {
      puts $fcmd "
  char *auth=getenv(\"LSST_IDENTITY\");
  SAL_[set subsys] *mgr = new SAL_[set subsys](auth);
"
   }
   puts $fcmd "
  mgr->salCommand(\"[set subsys]_command_[set alias]\");
"
  set cpars $CMDS($subsys,$alias)
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set alias]Cargs.tmp r]
  while { [gets $fin rec] > -1 } {
     puts $fcmd $rec
  }
  close $fin
  puts $fcmd "
  // generate command
  cmdId = mgr->issueCommand_[set alias](&myData);
  cout << \"=== command $alias issued = \" << endl;"
  if { $alias == "setAuthList" } {
    puts $fcmd "  sleep(2);"
  } else {
    puts $fcmd "  status = mgr->waitForCompletion_[set alias](cmdId, timeout);"
  } 
  puts $fcmd "
  /* Remove the DataWriters etc */
  mgr->salShutdown();
  if (status != SAL__CMD_COMPLETE) \{
     exit(1);
  \}
  exit(0);
\}

"
     close $fcmd
      stdlog "	: controller test receive for = $alias"
      set fcmd [open $SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_[set alias]_controller.cpp w]
      puts $fcmd "

/*
 * This file contains the implementation for the [set subsys]_[set alias] controller test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set subsys].h\"
#include \"ccpp_sal_[set subsys].h\"
#include \"os.h\"
#include <stdlib.h>
using namespace DDS;
using namespace [set subsys];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_[set subsys]_[set alias]_controller();
\}

int test_[set subsys]_[set alias]_controller()
\{ 
  os_time delay_10ms = \{ 0, 10000000 \};
  int cmdId = -1;
  int timeout = 1;
  [set subsys]_command_[set alias]C SALInstance;"
   if { [info exists SYSDIC($subsys,keyedID)] } {
      puts $fcmd "
  int [set subsys]ID = 1;
  if (getenv(\"LSST_[string toupper [set subsys]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set subsys]]_ID\"),\"%d\",&[set subsys]ID);
  \} 
  SAL_[set subsys] mgr = SAL_[set subsys]([set subsys]ID);"
   } else {
      puts $fcmd "  SAL_[set subsys] mgr = SAL_[set subsys]();"
   }
   puts $fcmd "
  mgr.salProcessor(\"[set subsys]_command_[set alias]\");
  cout << \"=== [set subsys]_[set alias] controller ready \" << endl;

  while (1) \{
    mgr.checkAuthList(\"\");
    // receive command
    cmdId = mgr.acceptCommand_[set alias](&SALInstance);
    if (cmdId > 0) \{
       cout << \"=== command $alias received = \" << endl;
"
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set alias]Csub.tmp r]
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
  mgr.salShutdown();

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
   puts stdout "Generating commands test Makefile"
   set fin [open $SAL_WORK_DIR/$subsys/cpp/src/Makefile.sacpp_[set subsys]_testcommands r]
   set fout [open /tmp/Makefile.sacpp_[set subsys]_testcommands w]
   while { [gets $fin rec] > -1 } {
      if { [string range $rec 0 26] == "## INSERT COMMANDS TEST SRC" } {
         set n 2
         set extrasrc "		"
         set allbin "all: "
         foreach alias $CMD_ALIASES($subsys) {
           if { [info exists CMDS($subsys,$alias,param)] } {
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_commander
OBJS$n          = .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_[set alias]_commander.o
"
             set allbin "$allbin \$\(BIN$n\)"
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_controller
OBJS$n          = .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_[set alias]_controller.o
"
             set extrasrc "$extrasrc sacpp_[set subsys]_[set alias]_commander.cpp sacpp_[set subsys]_[set alias]_controller.cpp"
             set allbin "$allbin \$\(BIN$n\)"
           }
         }
         set nbin $n
         puts $fout "
SRC           = ../src/SAL_[set subsys].cpp $extrasrc"
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
.obj/sacpp_[set subsys]_[set alias]_commander.o: ../src/sacpp_[set subsys]_[set alias]_commander.cpp
	@\$\(TESTDIRSTART\) \".obj/../src\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/../src\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) ../src/sacpp_[set subsys]_[set alias]_commander.cpp
.obj/sacpp_[set subsys]_[set alias]_controller.o: ../src/sacpp_[set subsys]_[set alias]_controller.cpp
	@\$\(TESTDIRSTART\) \".obj/../src\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/../src\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) ../src/sacpp_[set subsys]_[set alias]_controller.cpp
"
          }
         }
      }
      puts $fout $rec
   }
   close $fin
   close $fout
   exec cp /tmp/Makefile.sacpp_[set subsys]_testcommands $SAL_WORK_DIR/$subsys/cpp/src/Makefile.sacpp_[set subsys]_testcommands
 }
 if { [lsearch $CMD_ALIASES([set subsys]) "setLogLevel"] > -1 } {
   genauthlisttestscpp $subsys
 }
 if { $OPTIONS(verbose) } {stdlog "###TRACE<<< gencommandtestscpp $subsys"}
}

 
#
## Documented proc \c genauthlisttestscpp .
# \param[in] subsys Name of CSC/Subsystem as defined in SALSubsystems.xml
#
#  Generates the authList test script for a Subsystem/CSC.
#  The test starts a controller, and then sends a set of
#  authList's and tries to issue a command with each.
#
proc genauthlisttestscpp { subsys } {
global CMD_ALIASES CMDS SAL_WORK_DIR SYSDIC DONE_CMDEVT SAL_DIR OPTIONS
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> genauthlisttestscpp $subsys"}
  set fout [open $SAL_WORK_DIR/[set subsys]/cpp/src/testAuthList.sh w]
  set testnoauth "MTM1M3"
  if { $subsys == "MTM1M3" } {set testnoauth "MTRotator"}
  puts $fout "#!/bin/sh
export LSST_DDS_ENABLE_AUTHLIST=1
echo \"=====================================================================\"
echo \"Starting sacpp_[set subsys]_setLogLevel_controller\"
$SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_setLogLevel_controller &
sleep 10
echo \"=====================================================================\"
echo \"Test with authList not set at all, default identity=[set subsys]\"
echo \"Expect : completed ok\"
unset LSST_IDENTITY
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setAuthList_commander   \"\" \"\"
$SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_setLogLevel_commander 1 \"\"
echo \"=====================================================================\"
echo \"Test with authList not set at all, identity=user@host\"
echo \"Expect : Not permitted by authList\"
export LSST_IDENTITY=user@host
$SAL_WORK_DIR/[set subsys]/cpp/src/sacpp_[set subsys]_setLogLevel_commander 1 \"\"
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host, identity=user@host\"
echo \"Expect : completed ok\"
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setAuthList_commander   \"user@host\" \"\"
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setLogLevel_commander 1 \"\"
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, identity=user@host\"
echo \"Expect : completed ok\"
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setAuthList_commander   \"user@host,user2@other\" \"\"
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setLogLevel_commander 1 \"\"
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, identity=user2@other\"
echo \"Expect : completed ok\"
export LSST_IDENTITY=user2@other
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setAuthList_commander   \"user@host,user2@other\" \"\"
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setLogLevel_commander 1 \"\"
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCs=Test identity=user2@other\"
echo \"Expect : completed ok\"
export LSST_IDENTITY=user2@other
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setAuthList_commander   \"user@host,user2@other\" \"Test\"
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setLogLevel_commander 1 \"\"
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCs=Test identity=Test\"
echo \"Expect : Not permitted by authList\"
export LSST_IDENTITY=Test
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setLogLevel_commander 1 \"\"
echo \"=====================================================================\"
echo \"Test with authList authorizedUsers=user@host,user2@other, nonAuthorizedCSCs=[set testnoauth],Test identity=[set testnoauth]\"
echo \"Expect : Not permitted by authList\"
export LSST_IDENTITY=[set testnoauth]
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setAuthList_commander   \"user@host,user2@other\" \"[set testnoauth],Test\"
$SAL_WORK_DIR/$subsys/cpp/src/sacpp_[set subsys]_setLogLevel_commander 1 \"\"
sleep 10
pkill -9 sacpp_[set subsys]
echo \"=====================================================================\"
echo \"Finished testing authList with $subsys\"
echo \"=====================================================================\"
"
  close $fout
  exec chmod 755 $SAL_WORK_DIR/[set subsys]/cpp/src/testAuthList.sh
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< genauthlisttestscpp $subsys"}
}



