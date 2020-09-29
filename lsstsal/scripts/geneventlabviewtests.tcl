
proc geneventlabviewtests { subsys } {
global EVENT_ALIASES EVTS SAL_WORK_DIR SAL_DIR
 if { [info exists EVENT_ALIASES($subsys)] } {
   foreach alias $EVENT_ALIASES($subsys) {
     if { [info exists EVTS($subsys,$alias,param)] } {
      stdlog "	: LabVIEW API log event test send for = $alias"
      set fevt [open $SAL_WORK_DIR/$subsys/labview/sacpp_[set subsys]_[set alias]_LVsend.cpp w]
      puts $fevt "

/*
 * This file contains the implementation for the LabVIEW API [set subsys]_[set alias] send test.
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
  int priority = SAL__EVENT_INFO;
  [set subsys]_logevent_[set alias]C myData;
  if (argc <  [expr [llength $EVTS([set subsys],[set alias],plist)] +1]) \{
     printf(\"Usage :  input parameters...\\n\");
     printf(\"      int priority\\n\");
"
   set fidl [open $SAL_WORK_DIR/idl-templates/validated/[set subsys]_logevent_[set alias].idl r]
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
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]shmout.tmp r]
  while { [gets $fin rec] > -1 } {
       puts $fevt $rec
  }
  close $fin
  puts $fevt "
  // generate event
  priority = myData.priority;
  mgr.logEvent_[set alias](&myData, priority);
  cout << \"=== Event $alias generated = \" << endl;
  sleep(1);

  /* Remove the DataWriters etc */
  mgr.salShmRelease();

  return 0;
\}

"
     close $fevt
      stdlog "	: LabVIEW API log event test receive for = $alias"
      set fevt [open $SAL_WORK_DIR/$subsys/labview/sacpp_[set subsys]_[set alias]_LVlog.cpp w]
      puts $fevt "

/*
 * This file contains the implementation for the LabVIEW API [set subsys]_[set alias] receive test.
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

  [set subsys]_logevent_[set alias]C SALInstance;
   SAL_[set subsys]_shmem mgr = SAL_[set subsys]_shmem();
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
  int [set subsys]ID = 1;
  mgr.salShmConnect([set subsys]ID);
#else
  mgr.salShmConnect();
#endif

  while (1) \{
  // receive event
    status = mgr.getEvent_[set alias](&SALInstance);
    if (status == SAL__OK) \{
      cout << \"=== Event $alias received = \" << endl;
"
  set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_logevent_[set alias]shmin.tmp r]
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
   }
   puts stdout "Generating LabVIEW API events test Makefile"
   set fin [open $SAL_DIR/code/templates/Makefile.sacpp_SAL_testevents.template r]
   set fout [open /tmp/Makefile.sacpp_[set subsys]_testevents w]
   while { [gets $fin rec] > -1 } {
      if { [string range $rec 0 24] == "## INSERT EVENTS TEST SRC" } {
         set n 2
         set extrasrc "		"
         set allbin "all: \$\(BIN1\) \$\(BIN2\)"
         foreach alias $EVENT_ALIASES($subsys) {
           if { [info exists EVTS($subsys,$alias,param)] } {
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_LVsend
OBJS$n          = .obj/SAL_[set subsys]_shmem.o .obj/sacpp_[set subsys]_[set alias]_LVsend.o
"
             set allbin "$allbin \$\(BIN$n\)"
             incr n 1
             puts $fout "
BIN$n           = \$(BTARGETDIR)sacpp_[set subsys]_[set alias]_LVlog
OBJS$n          = .obj/SAL_[set subsys].o .obj/sacpp_[set subsys]_[set alias]_LVlog.o
"
             set extrasrc "$extrasrc sacpp_[set subsys]_[set alias]_LVsend.cpp sacpp_[set subsys]_[set alias]_LVlog.cpp"
             set allbin "$allbin \$\(BIN$n\)"
           }
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
         foreach alias $EVENT_ALIASES($subsys) {
           if { [info exists EVTS($subsys,$alias,param)] } {
            incr n 1
            puts $fout "
.obj/sacpp_[set subsys]_[set alias]_send.o: sacpp_[set subsys]_[set alias]_send.cpp
	@\$\(TESTDIRSTART\) \".obj/\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) sacpp_[set subsys]_[set alias]_send.cpp
.obj/sacpp_[set subsys]_[set alias]_log.o: sacpp_[set subsys]_[set alias]_log.cpp
	@\$\(TESTDIRSTART\) \".obj/\" \$\(TESTDIREND\) \$\(MKDIR\) \".obj/\"
	\$\(COMPILE.cc\) \$\(EXPORTFLAGS\) \$\(OUTPUT_OPTION\) sacpp_[set subsys]_[set alias]_log.cpp
"
           }
         }
      }
      puts $fout $rec
   }
   close $fin
   close $fout
   exec mv /tmp/Makefile.sacpp_[set subsys]_testevents $SAL_WORK_DIR/$subsys/labview/Makefile.sacpp_[set subsys]_testevents
 }
}

 
