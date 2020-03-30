#
#  add to .h and change m2ms_shmem to shmemIO
#     struct m2ms_shmem {
#        shmemIO client[50];
#     };
#
# add inUse flag to client struct
#
# in cpp change all m2ms_memIO->  to m2ms_memIO->client[cid].
#
# in connect look for unused inUse slot and clear all flags in it
# store returned slot number in global var in LV library
# in disconnect , clear all flags and reset inUse flag
#
# change monitor syncInit to a routine and call on connect/disconnect
#


set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)
source $SAL_DIR/add_system_dictionary.tcl 
source $SAL_DIR/gencommandlabviewtests.tcl 
source $SAL_DIR/geneventlabviewtests.tcl 
source $SAL_DIR/gentelemetrylabviewtests.tcl 
source $SAL_DIR/utilities.tcl 

proc genshmemlabview { subsys } {
global SAL_DIR SAL_WORK_DIR
  exec mkdir -p $SAL_WORK_DIR/[set subsys]/labview
  set idlfile $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl
  set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
  set base $subsys
  genlabviewidl  $base
###  updateLabVIEWTypes $base
  genlabviewincl $base $ptypes
  genlabviewcpp  $base $ptypes
  genlabviewmake $base
  gencommandlabviewtests $base
  geneventlabviewtests $base
  gentelemetrylabviewtests $base
  cd $SAL_WORK_DIR/[set subsys]/labview
  exec ln -sf ../cpp/src/SAL_[set subsys].cpp .
  exec ln -sf ../cpp/src/SAL_actors.h .
  exec ln -sf ../../../lsstsal/include/SAL_defines.h .
  exec rm -fr lib
  set bad [catch {exec make -f Makefile.sacpp_[set subsys]_labview} result]
  removeshmem [calcshmid $base]
}

proc genlabviewidl { subsys } {
global SAL_WORK_DIR EVENT_ENUMS
   if { [file exists $SAL_WORK_DIR/idl-templates/validated/[set subsys]_evtdef.tcl] } { 
      source  $SAL_WORK_DIR/idl-templates/validated/[set subsys]_evtdef.tcl
   }
   set fin  [open $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl r]
   set fout [open $SAL_WORK_DIR/[set subsys]/labview/sal_[set subsys].idl w]
   set topic none
   set addedSummaryEnum 1
   while { [gets $fin rec] > -1 } {
      set it [string trim $rec "\{\}"]
      if { [lindex $it 0] == "struct" } {
         set ttype [lindex [split [lindex $it 1] "_"] 0]
         if { $ttype == "command" || $ttype == "logevent" } {
            set topic [join [lrange [split [lindex $it 1] "_"] 1 end] "_"]
         } else {
            set topic [lindex $it 1]
         }
      }
      if { [lsearch "ack\;" [lindex $it 1]] > -1 } {
         puts $fout "      long	cmdSeqNum;"
      }
      if { [string range [lindex $it 1] 0 7] != "private_" && [lindex $it 1] != "[set subsys]ID;" } {
       if { [lsearch "device\; property\; action\; itemValue\;" [lindex $it 1]] < 0 } {
         set name [string trim [lindex $it 1] ";"]
         if { [info exists EVENT_ENUMS($topic,$name)] } {
           puts $fout "$rec	// enum : $EVENT_ENUMS($topic,$name)"
         } else {
           puts $fout $rec
         }
       }
      }
      if { $addedSummaryEnum == 1 } {
	   #add the generic summary state constants:
	   set i 1
	   foreach id "DisabledState EnabledState FaultState OfflineState StandbyState" {
	       puts $fout "	 const long [set subsys]_shared_SummaryState_[string trim $id " "]=$i;"
	       incr i 1
	   }
	   set addedSummaryEnum 0
      }
   }
   close $fin
   close $fout
}



proc genlabviewmake { subsys } {
global SAL_DIR SAL_WORK_DIR SYSDIC env
  if { [info exists env(LABVIEW_HOME)] } {
     set lvv [file tail [glob $env(LABVIEW_HOME)/LabVIEW*64]]
  } else {
     set lvv [file tail [glob /usr/local/natinst/LabVIEW*64]]
  }
  set frep [open /tmp/sreplace4_[set subsys]lv.sal w]
  puts $frep "#!/bin/sh"
  exec touch $SAL_WORK_DIR/[set subsys]/labview/.depend.Makefile.sacpp_SALData_labview
  exec cp  $SAL_DIR/code/templates/Makefile.sacpp_SAL_labview.template $SAL_WORK_DIR/[set subsys]/labview/Makefile.sacpp_[set subsys]_labview
  puts $frep "perl -pi -w -e 's/_SAL_/_[set subsys]_/g;' $SAL_WORK_DIR/[set subsys]/labview/Makefile.sacpp_[set subsys]_labview"
  puts $frep "perl -pi -w -e 's/SALSubsys/[set subsys]/g;' $SAL_WORK_DIR/[set subsys]/labview/Makefile.sacpp_[set subsys]_labview"
  puts $frep "perl -pi -w -e 's/SALData/[set subsys]/g;' $SAL_WORK_DIR/[set subsys]/labview/Makefile.sacpp_[set subsys]_labview"
  puts $frep "perl -pi -w -e 's/LabVIEW-2015-64/[set lvv]/g;' $SAL_WORK_DIR/[set subsys]/labview/Makefile.sacpp_[set subsys]_labview"
  if { [info exists SYSDIC($subsys,keyedID)] } {
     puts $frep "perl -pi -w -e 's/#-DSAL_SUBSYSTEM/-DSAL_SUBSYSTEM/g;' $SAL_WORK_DIR/[set subsys]/labview/Makefile.sacpp_[set subsys]_labview"
  }
  close $frep
  exec chmod 755 /tmp/sreplace4_[set subsys]lv.sal
  catch { set result [exec /tmp/sreplace4_[set subsys]lv.sal] } bad
  if { $bad != "" } {puts stdout $bad}
}



proc genlabviewincl { base ptypes } {
global SAL_DIR SAL_WORK_DIR SYSDIC TELEMETRY_ALIASES LVSTRINGS CMD_ALIASES
  set idarg ""
  if { [info exists SYSDIC($base,keyedID)] } {
     set idarg "unsigned int [set base]ID"
  }
  set fout [open $SAL_WORK_DIR/[set base]/labview/SAL_[set base]_shmem.h w]
  set fhlv [open $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base]LV.h r]
  puts $fout "#ifdef BUILD_FOR_LV"
  while  { [gets $fhlv rec] > -1 } {
     if { [string range $rec 0 13] == "typedef struct" } {
        set sname [lindex [string trim $rec "\{"] 2]
     }
     set crec [string trim $rec "\{\}"]
     if { [lindex $crec 0] == "StrHdl" && $sname != "" } {
       set param [string trim [lindex $crec 1] "*;"]
       set slen [lindex $crec 3]
       if { [lsearch "device property action itemValue" $param] < 0 } {
         set LVSTRINGS([set sname]_[set param]) $slen
         puts $fout $rec
       }
     } else {
       puts $fout $rec
     }
 }
 puts $fout "#endif
"
  close $fhlv
  puts $fout "
#define salLONG long
     struct shmemIO \{
         bool  inUse;
         bool  initialized;
         bool  shutdown;
         int   activeCommand;"
  foreach j $ptypes {
     set name [lindex $j 2]
     set type [lindex [split $name _] 0]
     puts $fout "	bool  syncI_[set base]_[set name];"	
     puts $fout "	bool  syncO_[set base]_[set name];"	
     puts $fout "	bool  flush_[set base]_[set name];"	
     puts $fout "	bool  skipOld_[set base]_[set name];"	
     puts $fout "	bool  hasIncoming_[set base]_[set name];"	
     puts $fout "	bool  hasOutgoing_[set base]_[set name];"
     puts $fout "	bool  hasCallback_[set base]_[set name];"	
     puts $fout "	int   callbackHdl_[set base]_[set name];"	
     puts $fout "	bool  hasReader_[set base]_[set name];"	
     puts $fout "	bool  hasWriter_[set base]_[set name];"	
     if { $name != "command" && $name != "logevent" } {
       puts $fout "	[set base]_[set name]C  shmemIncoming_[set base]_[set name];"	
       puts $fout "	[set base]_[set name]C  shmemOutgoing_[set base]_[set name];"
     }
     if { $type == "command" && $name != "command" } {
        puts $fout "    bool syncI_[set base]_[set name]_ackcmd;"
        puts $fout "    bool syncO_[set base]_[set name]_ackcmd;"
        puts $fout "	bool skipOld_[set base]_[set name]_ackcmd;"	
        puts $fout "	bool hasIncoming_[set base]_[set name]_ackcmd;"	
        puts $fout "	bool hasOutgoing_[set base]_[set name]_ackcmd;"
        puts $fout "	bool hasCallback_[set base]_[set name]_ackcmd;"	
        puts $fout "	bool ackIt_[set base]_[set name];"	
        puts $fout "	int  callbackHdl_[set base]_[set name]_ackcmd;"	
        puts $fout "	int  shmemOutgoing_[set base]_[set name]_cmdSeqNum;"
        puts $fout "	int  shmemIncoming_[set base]_[set name]_rcvSeqNum;"
        puts $fout "	int  shmemOutgoing_[set base]_[set name]_cmdStatus;"
        puts $fout "	int  shmemOutgoing_[set base]_[set name]_errorCode;"
        puts $fout "	int  shmemIncoming_[set base]_[set name]_cmdStatus;"
        puts $fout "	int  shmemIncoming_[set base]_[set name]_errorCode;"
        puts $fout "	int  shmemIncoming_[set base]_[set name]_waitForSeqNum;"
        puts $fout "	char shmemOutgoing_[set base]_[set name]_resultCode\[128\];"
        puts $fout "	char shmemIncoming_[set base]_[set name]_resultCode\[128\];"
     }
#puts stdout "reading  $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmstr.tmp"
#     if { $name != "ackcmd" && $name != "command" && $name != "logevent" } {
#       set fstrb [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmstr.tmp r]
#       while { [gets $fstrb rec] > -1 } {
#          puts $fout $rec
#       }
#       close $fstrb
#     }
  }
  foreach lvs [lsort [array names LVSTRINGS]] {
     set slen $LVSTRINGS([set lvs])
     puts $fout "
      char [set lvs]_bufferOut\[[set slen]\];
      char [set lvs]_bufferIn\[[set slen]\];
    "
  }
  if { [info exists CMD_ALIASES($base)] } {
    puts $fout "	[set base]_ackcmdC shmemIncoming_ackcmd;"
    puts $fout "  [set base]_ackcmdC shmemOutgoing_ackcmd;"
  }
  puts $fout "    \};

     struct [set base]_shmem \{
        shmemIO client\[20\];
     \};

     int shmSize = sizeof([set base]_shmem);
     int lShmId;
     bool shutdown_shmem;
     int iverbose;
     int [set base]_shmid = 0x[calcshmid $base];
  
        int [set base]_salShmMonitor($idarg);
        int [set base]_salShmConnect($idarg);
        int [set base]_salShmRelease();
        void [set base]_shm_checkCallbacksLV();
        void [set base]_shm_initFlags();
        double [set base]_shm_getCurrentTimeLV();
"
  foreach j $ptypes {
     set name [lindex $j 2]
     set n2 [join [lrange [split $name _] 1 end] _]
     set type [lindex [split $name _] 0]
     if { $type == "command" && $name != "command" } {
       puts $fout "
        int [set base]_shm_salProcessor_[set n2]LV();
        int [set base]_shm_salCommander_[set n2]LV();
        int [set base]_shm_issueCommand_[set n2]LV([set base]_[set name]LV *[set name]_Ctl );
        int [set base]_shm_acceptCommand_[set n2]LV([set base]_[set name]LV *[set name]_Ctl );
        int [set base]_shm_ackCommand_[set n2]LV([set base]_ackcmdLV *ackcmd_Ctl);
        int [set base]_shm_monitorCommand_[set n2]LV([set base]_[set name]LV *[set name]_Ctl );
        int [set base]_shm_waitForCompletion_[set n2]LV([set base]_waitCompleteLV *waitComplete_Ctl);
        int [set base]_shm_getResponse_[set n2]LV([set base]_ackcmdLV *ackcmd_Ctl);"
     } else {
        if { $type == "logevent" && $name != "logevent" } {
           puts $fout "
        int [set base]_shm_salEvent_[set n2]LV();
	int [set base]_shm_flushSamplesEvent_[set n2]LV();
	int [set base]_shm_getEvent_[set n2]LV([set base]_[set name]LV *[set name]_Ctl );
	int [set base]_shm_logEvent_[set n2]LV([set base]_[set name]LV *[set name]_Ctl );"
        } else {
           if { $name != "ackcmd" && $name != "command" && $name != "logevent" } {
              lappend TELEMETRY_ALIASES($base) $name
           }
           if { $name != "command" && $name != "logevent" } {
             puts $fout "
        int [set base]_shm_salTelemetrySub_[set name]LV();
        int [set base]_shm_getSample_[set name]LV([set base]_[set name]LV *[set name]_Ctl );
        int [set base]_shm_getNextSample_[set name]LV([set base]_[set name]LV *[set name]_Ctl );
        int [set base]_shm_putSample_[set name]LV([set base]_[set name]LV *[set name]_Ctl );"
           }
        }
     }   
     puts $fout "        int [set base]_shm_registerCallback_[set name]LV(int handle, bool skipOld);"
     puts $fout "        int [set base]_shm_cancelCallback_[set name]LV();"
     if { $name != "command" && $name != "logevent" } {
        puts $fout "        int [set base]_shm_registerCallback_[set name]_ackcmdLV(int handle, bool skipOld);"
        puts $fout "        int [set base]_shm_cancelCallback_[set name]_ackcmdLV();"
     }
   }
  close $fout
}

proc updateLabVIEWTypes { subsys } {
global SAL_DIR SAL_WORK_DIR
   set fin [open $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set subsys].idl r]
   set fout [open $SAL_DIR/../../ts_SALLabVIEW/SALTypeGenerator/IDLs/sal_[set subsys].idl w]
   while { [gets $fin rec] > -1 } {
      set t [string trim $rec "\{\}"]
      if { [string range [lindex $t 1] 0 7] != "private_" } {
         puts $fout $rec
      }
   }
   close $fin
   close $fout
}

proc genlabviewcpp { base ptypes } {
global SAL_DIR SAL_WORK_DIR SYSDIC LVSTRINGS REVCODE CMD_ALIASES
  set idarg ""
  set idarg2 ""
  set idarg3 "     unsigned int [set base]ID = 0;"
  set idoff "[set base]ID"
  if { [info exists SYSDIC($base,keyedID)] } {
     set idarg "unsigned int [set base]ID"
     set idarg2 "[set base]ID"
  }
  set fout [open $SAL_WORK_DIR/[set base]/labview/SAL_[set base]_salShmMonitor.cpp w]
  puts $fout "
#include <sys/ipc.h>
#include <sys/shm.h>
#include \"SAL_[set base].h\"
#define BUILD_FOR_LV
#include \"SAL_[set base]_shmem.h\"
#include \"SAL_actors.h\"
using namespace [set base];
"
  puts $fout "
    int main (int argc, char *argv\[\]) \{
      int status = 0;
      int lpriority = 0;
      int [set idoff] = 0;
      int ipollusecs = 100;
      int LVClient = 0;

      if (argc > 1) \{
         sscanf(argv\[1\], \"%d\", &[set idoff]);
      \}
      if (getenv(\"LSST_[string toupper [set base]]_LVPOLL\") != NULL) \{
         sscanf(getenv(\"LSST_[string toupper [set base]]_LVPOLL\"),\"%d\",&ipollusecs);
      \}
      if (getenv(\"LSST_[string toupper [set base]]_LVDEBUG\") != NULL) \{
         sscanf(getenv(\"LSST_[string toupper [set base]]_LVDEBUG\"),\"%d\",&iverbose);
      \}
      shutdown_shmem = false;
      int actorIdx = 0;
      [set base]_shmem *[set base]_memIO;
      lShmId = shmget([set base]_shmid + [set idoff], shmSize , IPC_CREAT|0666);
      [set base]_memIO  = ([set base]_shmem *) shmat(lShmId, NULL, 0);"
   if { [info exists SYSDIC($base,keyedID)] } {
     puts $fout "
      SAL_[set base] mgr\[20\] = \{
		SAL_[set base]([set idoff]), SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),
		SAL_[set base]([set idoff]), SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),
		SAL_[set base]([set idoff]), SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),
		SAL_[set base]([set idoff]), SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),
		SAL_[set base]([set idoff]), SAL_[set base]([set idoff]),SAL_[set base]([set idoff]),SAL_[set base]([set idoff]) \};"
   } else {
     puts $fout "
      SAL_[set base] mgr\[20\];"
  }
  foreach j $ptypes {
     set name [lindex $j 2]
     monitorsyncinit $fout $base $name
  }
  if { [info exists CMD_ALIASES($base)] } {
    set revcode [getRevCode [set base]_ackcmd short]
    puts $fout "      [set base]::ackcmd[set revcode]Seq [set base]_ackcmdSeq;"
  }
  puts $fout "      cout << \"LabVIEW SAL Monitor for [set base] is ready\" << endl;"
  puts $fout "      while ( !shutdown_shmem ) \{
                     for (LVClient=0;LVClient<20;LVClient++) \{
                      if ([set base]_memIO->client\[LVClient\].inUse && [set base]_memIO->client\[LVClient\].initialized == false) \{
                          mgr\[LVClient\] = SAL_[set base]($idarg2);
                          [set base]_memIO->client\[LVClient\].initialized = true;
                      \}
                      if ([set base]_memIO->client\[LVClient\].inUse) \{
"
 
  foreach j $ptypes {
     set name [lindex $j 2]
     set type [lindex [split $name _] 0]
     if { $type == "command" && $name != "command" } {
       monitorcommand $fout $base $name
     } else {
        if { $type == "logevent" && $name != "logevent" } {
           monitorlogevent $fout $base $name
        } else {
           if { $name != "ackcmd" && $name != "command" && $name != "logevent" } {
              monitortelemetry $fout $base $name
           }
        }
     }   
   }
  puts $fout "
        if ([set base]_memIO->client\[LVClient\].shutdown) \{
            mgr\[LVClient\].salShutdown();
            [set base]_memIO->client\[LVClient\].inUse = false;
            [set base]_memIO->client\[LVClient\].initialized = false;
            [set base]_memIO->client\[LVClient\].shutdown = false;
            if (iverbose) \{
               cout << \"Client \" << LVClient << \" shutdown\" << endl;
            \}
        \}
       \}
      \}
      usleep(ipollusecs);
      \}
      shmdt([set base]_memIO);
      exit(0);
    \}
"
  close $fout
  set fout [open $SAL_WORK_DIR/[set base]/labview/SAL_[set base]_salShm.cpp w]
  puts $fout "
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/syscall.h>
#include <sys/time.h>
#include <time.h>
#include <thread>
#include \"extcode.h\"
#include \"SAL_[set base].h\"
extern \"C\" \{
#include \"SAL_defines.h\"
#define BUILD_FOR_LV
#include \"SAL_[set base]_shmem.h\"
#include \"SAL_actors.h\"
#define ReturnCode_t int

"
  puts $fout "
    [set idarg3]
    [set base]_shmem *[set base]_memIO;
    __thread int LVClient;
    int [set base]_salShmConnect ([set idarg]) \{
      LVClient = 0;
      lShmId = shmget([set base]_shmid + [set idoff], shmSize , IPC_CREAT|0666);
      [set base]_memIO  = ([set base]_shmem *) shmat(lShmId, NULL, 0);
      while ([set base]_memIO->client\[LVClient\].inUse == true && LVClient < 20) \{
         LVClient = LVClient + 1;
      \}
      if (LVClient == 20) \{ return SAL__ERROR; \}
      [set base]_shm_initFlags();
      [set base]_memIO->client\[LVClient\].inUse = true;
      if (getenv(\"LSST_[string toupper [set base]]_LVDEBUG\") != NULL) \{
         sscanf(getenv(\"LSST_[string toupper [set base]]_LVDEBUG\"),\"%d\",&iverbose);
      \}
      if (iverbose) \{
         cout << \"Client \" << LVClient << \" connected\" << endl;
      \}
      return syscall(SYS_gettid);
    \}

    int [set base]_salShmRelease() \{
      [set base]_memIO->client\[LVClient\].shutdown = true;
      [set base]_shm_initFlags();
      shmdt([set base]_memIO);
      if (iverbose) \{
         cout << \"Client \" << LVClient << \" shmdt\" << endl;
      \}
      return SAL__OK;
    \}

    double [set base]_shm_getCurrentTimeLV() \{
      struct timex tx;
      struct timespec now;
      double taiTime;

      memset(&tx, 0, sizeof(tx));
      adjtimex(&tx);
      clock_gettime(CLOCK_TAI,&now);
      taiTime = (double)now.tv_sec + (double)now.tv_nsec/1000000000.;
      return taiTime;
    \}

"
  foreach j $ptypes {
     set name [lindex $j 2]
     set type [lindex [split $name _] 0]
     if { $type == "command" && $name != "command" } {
       genlvcommand $fout $base $name
     }
     if { $type == "logevent" && $name != "logevent"} {
       genlvlogevent $fout $base $name
     }
     if { $name != "ackcmd" && $type != "command" && $type != "logevent" } {
       genlvtelemetry $fout $base $name
     }
     genlvcallback $fout $base $name  
   }
   genlvlaunchcallbacks $fout $base $ptypes
   puts $fout "
    void [set base]_shm_initFlags () \{
"
   foreach j $ptypes {
     set name [lindex $j 2]
     shmemsyncinit $fout $base $name
   }
   puts $fout "    \}
\}
"
  close $fout
}


#
#  Sample callback usage
#
#  1. Get a LV handle for the callback
#  2. xxx_shm_registerCallback_yyy(handle)
#  3. Receive and process LVUserEvent
#  4. Call xxx_shm_getSample/acceptCommand/getEvent
#  5. Goto step 3
#
#

proc genlvcallback { fout base name } {
   puts $fout "
    int [set base]_shm_registerCallback_[set name]LV(int handle, bool skipOld) \{
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = true;
        [set base]_memIO->client\[LVClient\].skipOld_[set base]_[set name] = skipOld;
        while ([set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] == false) \{
            usleep(1000);
            if (iverbose) \{
               cout << \"Client \" << LVClient << \" registerCallback in wait for reader [set name]\" << endl;
            \}
        \}
        [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] = true;
        [set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name] = handle;
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" registerCallback done [set name]\" << endl;
        \}
        return SAL__OK;
    \}
    int [set base]_shm_cancelCallback_[set name]LV() \{
        [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] = false;
        [set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name] = 0;
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" cancelCallback done [set name]\" << endl;
        \}
        return SAL__OK;
    \}
"
    set type [lindex [split $name _] 0]
    if { $type == "command" && $name != "command" } {
   puts $fout "
    int [set base]_shm_registerCallback_[set name]_ackcmdLV(int handle, bool skipOld) \{
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name]_ackcmd = true;
        [set base]_memIO->client\[LVClient\].skipOld_[set base]_[set name]_ackcmd = skipOld;
        [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name]_ackcmd = true;
        [set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name]_ackcmd = handle;
        if (iverbose) \{
            cout << \"Client \" << LVClient << \" registerCallback ackcmd\" << endl;
        \}
        return SAL__OK;
    \}
    int [set base]_shm_cancelCallback_[set name]_ackcmdLV() \{
        [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name]_ackcmd = false;
        [set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name]_ackcmd = 0;
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" cancelCallback done ackcmd\" << endl;
        \}
        return SAL__OK;
    \}
"
    }
}


proc genlvlaunchcallbacks { fout base ptypes } {
   puts $fout "
    void [set base]_shm_checkCallbacksLV() \{
       int salActorIdx=0;"
   foreach j $ptypes {
     set name [lindex $j 2]
     set type [lindex [split $name _] 0]
     puts $fout "
        if ( [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] ) \{
           if ( [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] ) \{
              [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] = false;
              salActorIdx=SAL__[set base]_[set name]_ACTOR;
              if (iverbose) \{
                 cout << \"Client \" << LVClient << \" doing postUserEvent [set name]\" << endl;
              \}
              PostLVUserEvent([set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name], &salActorIdx);
           \}
        \}"
        if { $type == "command" && $name != "command" } {
           puts $fout "
        if ( [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name]_ackcmd ) \{
           if ( [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name]_ackcmd ) \{
              [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name]_ackcmd = false;
              salActorIdx=SAL__[set base]_[set name]_ACTOR;
              if (iverbose) \{
                 cout << \"Client \" << LVClient << \" doing postUserEvent [set name]_ackcmd\" << endl;
              \}
              PostLVUserEvent([set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name]_ackcmd, &salActorIdx);
           \}
        \}"
        }
   }
   puts $fout "
   \}
"
}




proc genlvtelemetry { fout base name } {
global SAL_WORK_DIR LVSTRINGS
   puts $fout "
    int [set base]_shm_salTelemetrySub_[set name]LV() \{
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] == false) \{
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" telemetrySub waiting for reader [set name]\" << endl;
        \}
           usleep(1000);
        \}
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" telemetrySub has reader [set name]\" << endl;
        \}
        return SAL__OK;
    \}

    int [set base]_shm_getSample_[set name]LV([set base]_[set name]LV *data ) \{
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] == false) \{
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" getSample waiting for reader [set name]\" << endl;
        \}
           usleep(1000);
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" getSample has reader [set name]\" << endl;
        \}
        \}
        if ([set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name] != 0) \{
           [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] = true;
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" getSample setting hasCallback [set name]\" << endl;
           \}
        \}
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" getSample hasIncoming [set name]\" << endl;
        \}
        if ( [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] ) \{"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmin.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
           [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = false;
        \} else \{
           [set base]_memIO->client\[LVClient\].skipOld_[set base]_[set name] = true;
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" getSample skipping old [set name]\" << endl;
           \}
           return SAL__NO_UPDATES;
        \}
        [set base]_memIO->client\[LVClient\].skipOld_[set base]_[set name] = true;
        return SAL__OK;
    \}

    int [set base]_shm_getNextSample_[set name]LV([set base]_[set name]LV *data ) \{
        int status = SAL__NO_UPDATES;
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = true;
        [set base]_memIO->client\[LVClient\].skipOld_[set base]_[set name] = false;
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" getNextSample [set name]\" << endl;
        \}
	status = [set base]_shm_getSample_[set name]LV(data);
        return status;
    \}

    int [set base]_shm_putSample_[set name]LV([set base]_[set name]LV *data ) \{
        [set base]_memIO->client\[LVClient\].syncO_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasWriter_[set base]_[set name] == false) \{
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" putSample waiting for writer [set name]\" << endl;
        \}
           usleep(1000);
        \}
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" putSample has writer [set name]\" << endl;
        \}
        if ([set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name]) \{ 
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" putSample already have outGoing - error [set name]\" << endl;
           \}
           return SAL__ERROR;
        \}"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmout.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
        [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] == true) \{
            if (iverbose) \{
               cout << \"Client \" << LVClient << \" putSample waiting for written [set name]\" << endl;
            \}
            usleep(1000);
        \}
        return SAL__OK;
    \}
"
}


proc genlvcommand { fout base name } {
global SAL_WORK_DIR LVSTRINGS
   set n2 [join [lrange [split $name _] 1 end] _]
   puts $fout "
    int [set base]_shm_issueCommand_[set n2]LV([set base]_[set name]LV *data ) \{
        int cmdId = 0;
        [set base]_memIO->client\[LVClient\].syncO_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasWriter_[set base]_[set name] == false) \{
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" issueCommand waiting for writer [set name]\" << endl;
            \}
           usleep(1000);
        \}"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmout.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
       if (iverbose) \{
            cout << \"Client \" << LVClient << \" issueCommand has writer [set name]\" << endl;
       \}
       [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] = true;
        [set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_cmdSeqNum = 0;
        while (cmdId == 0) \{
          if (iverbose) \{
               cout << \"Client \" << LVClient << \" issueCommand waiting for cmdId [set name]\" << endl;
          \}
          cmdId = [set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_cmdSeqNum;
           usleep(1000);
        \}
        [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_waitForSeqNum = cmdId;
        [set base]_memIO->client\[LVClient\].activeCommand = SAL__[set base]_[set name]_ACTOR;
        [set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_cmdSeqNum = 0;
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" issueCommand got cmdId \" << cmdId << \" [set name]\" << endl;
        \}
        return cmdId;
    \}"
   puts $fout "

    int [set base]_shm_salProcessor_[set n2]LV() \{
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] == false) \{
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" processor waiting for reader [set name]\" << endl;
           \}
           usleep(1000);
        \}
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" processor has reader [set name]\" << endl;
        \}
        return SAL__OK;
    \}

    int [set base]_shm_salCommander_[set n2]LV() \{
        [set base]_memIO->client\[LVClient\].syncO_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasWriter_[set base]_[set name] == false) \{
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" commander waiting for writer [set name]\" << endl;
           \}
           usleep(1000);
        \}
        if (iverbose) \{
              cout << \"Client \" << LVClient << \" commander has writer [set name]\" << endl;
        \}
        return SAL__OK;
    \}

    int [set base]_shm_monitorCommand_[set n2]LV([set base]_[set name]LV *data ) \{
        int cmdId;
        if ( [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] ) \{"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmin.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
           cmdId = [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum;
           [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = false;
           [set base]_memIO->client\[LVClient\].ackIt_[set base]_[set name] = false;
           if ([set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name] != 0) \{
              [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] = true;
           \}
           if (cmdId != 0) \{
//              [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum = 0;
//   cout << \"monitored a command \" << cmdId << endl;
              if (iverbose) \{
               cout << \"Client \" << LVClient << \" monitorCommand got cmdId \" << cmdId << \" [set name]\" << endl;
              \}
              return cmdId;
           \}
        \} else \{
           return SAL__NO_UPDATES;
        \}
        return SAL__OK;
    \}

    int [set base]_shm_acceptCommand_[set n2]LV([set base]_[set name]LV *data ) \{
        int cmdId;
        [set base]_memIO->client\[LVClient\].ackIt_[set base]_[set name] = true;
        if ( [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] ) \{"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmin.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
           cmdId = [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum;
           [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = false;
           if ([set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name] != 0) \{
              [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] = true;
           \}
           if (cmdId != 0) \{
//              [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum = 0;
//   cout << \"accepted a command \" << cmdId << endl;
              if (iverbose) \{
               cout << \"Client \" << LVClient << \" acceptCommand got cmdId \" << cmdId << \" [set name]\" << endl;
              \}
              return cmdId;
           \}
        \} else \{
           return SAL__NO_UPDATES;
        \}
        return SAL__OK;
    \}"
   puts $fout "
    int [set base]_shm_ackCommand_[set n2]LV([set base]_ackcmdLV *theack) \{
        [set base]_memIO->client\[LVClient\].syncO_[set base]_[set name]_ackcmd = true;
        while ([set base]_memIO->client\[LVClient\].hasWriter_[set base]_ackcmd == false) \{
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" ackcmd waiting for writer [set name]\" << endl;
           \}
           usleep(1000);
        \}"
   puts $fout "
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" ackcmd has writer [set name]\" << endl;
        \}
        [set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_cmdSeqNum = theack->cmdSeqNum;
        [set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_cmdStatus = theack->ack;
        [set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_errorCode = theack->error;
        int resultSize = (*(theack->result))->size;
        strncpy([set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_resultCode, (*(theack->result))->data, resultSize);
        [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name]_ackcmd = true;
        while ([set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name]_ackcmd == true) \{
          if (iverbose) \{
               cout << \"Client \" << LVClient << \" waiting for written [set name]\" << endl;
           \}
           usleep(1000);
        \}
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" ackcmd written [set name]\" << endl;
        \}
        return SAL__OK;
    \}"
   puts $fout "
    int [set base]_shm_waitForCompletion_[set n2]LV([set base]_waitCompleteLV *waitStatus ) \{
      int debugLevel = 1;
      salReturn status = SAL__OK;
      int countdown = waitStatus->timeout;
      [set base]_ackcmdLV response;

   response.result=0;     
   [set base]_memIO->client\[LVClient\].activeCommand = SAL__[set base]_[set name]_ACTOR;
   [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_waitForSeqNum = waitStatus->cmdSeqNum;
   status = SAL__CMD_NOACK;
   while (status != SAL__CMD_COMPLETE && countdown != 0) \{
      status = [set base]_shm_getResponse_[set n2]LV(&response);
      if (iverbose) \{
           cout << \"Client \" << LVClient << \" waitForCompletion status=\" << status << \" [set name]\" << endl;
      \}
      usleep(SAL__SLOWPOLL);
      countdown--;
   \}
   [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name]_ackcmd = false;
   return status;
    \}
"
  puts $fout "
    int [set base]_shm_getResponse_[set n2]LV([set base]_ackcmdLV *data) \{
        ReturnCode_t status = SAL__CMD_NOACK;
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name]_ackcmd = true;
        while ([set base]_memIO->client\[LVClient\].hasReader_[set base]_ackcmd == false) \{
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" waiting for reader [set name]\" << endl;
           \}
           usleep(1000);
        \}
        if (iverbose) \{
               cout << \"Client \" << LVClient << \" has reader [set name]\" << endl;
        \}
        if ([set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name]_ackcmd ) \{
        if ([set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum != 0) \{
        if ([set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_waitForSeqNum != 0) \{
        if ([set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum ==
             [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_waitForSeqNum) \{
           if ([set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name]_ackcmd != 0) \{
              [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name]_ackcmd = true;
           \}
           data->ack = [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_cmdStatus;
           data->error = [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_errorCode;
           data->cmdSeqNum = [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum;
           if (iverbose) \{
               cout << \"Client \" << LVClient << \" got response cmdId=\" << data->cmdSeqNum << \" [set name]\" << endl;
           \}
           int resultSize = strlen([set base]_memIO->client\[LVClient\].[set base]_ackcmdLV_result_bufferIn);
           NumericArrayResize(5, 1, (UHandle*)(&(data->result)), resultSize);
           (*(data->result))->size = resultSize;
           for (int i=0;i<resultSize;i++)\{(*(data->result))->data\[i\] = [set base]_memIO->client\[LVClient\].[set base]_ackcmdLV_result_bufferIn\[i\];\}
           printf(\"client %ld - got ack = %d, error = %d id = %d\\n\",LVClient,data->ack,data->error,data->cmdSeqNum);
           status = [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_cmdStatus;
           if (data->ack == SAL__CMD_COMPLETE) \{
              if (iverbose) \{
                  cout << \"Client \" << LVClient << \" ack = COMPLETE [set name]\" << endl;
              \}
              [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_waitForSeqNum = 0;
              [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum = 0;
              [set base]_memIO->client\[LVClient\].activeCommand = 0;
           \}
         \}
        \}
        \}
        [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name]_ackcmd = false;
        \}
        return status;
    \}
"
}




proc genlvlogevent { fout base name } {
global SAL_WORK_DIR LVSTRINGS
   set n2 [join [lrange [split $name _] 1 end] _]
   puts $fout "
    int [set base]_shm_salEvent_[set n2]LV() \{
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] == false) \{
           if (iverbose) \{
               cout << \"Client \" << LVClient << \"salEvent waiting for reader [set name]\" << endl;
           \}
           usleep(1000);
        \}
        if (iverbose) \{
            cout << \"Client \" << LVClient << \"salEvent got reader [set name]\" << endl;
        \}
        return SAL__OK;
    \}

    int [set base]_shm_getEvent_[set n2]LV([set base]_[set name]LV *data ) \{
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] == false) \{
          if (iverbose) \{
               cout << \"Client \" << LVClient << \"getEvent waiting for reader [set name]\" << endl;
           \}
           usleep(1000);
        \}
        if (iverbose) \{
            cout << \"Client \" << LVClient << \"getEvent got reader [set name]\" << endl;
        \}
        if ([set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name] != 0) \{
           [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] = true;
        \}
        if ( [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] ) \{
          if ([set base]_memIO->client\[LVClient\].flush_[set base]_[set name]) \{
             [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = false;
             [set base]_memIO->client\[LVClient\].flush_[set base]_[set name] = false;
             if (iverbose) \{
                 cout << \"Client \" << LVClient << \"getEvent flushed [set name]\" << endl;
             \}
             return SAL__NO_UPDATES;
          \}"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmin.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
           if (iverbose) \{
              cout << \"Client \" << LVClient << \"getEvent got event [set name]\" << endl;
           \}
           [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = false;
        \} else \{
           return SAL__NO_UPDATES;
        \}
        return SAL__OK;
    \}

    int [set base]_shm_logEvent_[set n2]LV([set base]_[set name]LV *data ) \{
        [set base]_memIO->client\[LVClient\].syncO_[set base]_[set name] = true;
        if ([set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name]) \{ 
           return SAL__ERROR;
        \}"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]shmout.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
        [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] = true;
        while ([set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] == true) \{
          if (iverbose) \{
               cout << \"Client \" << LVClient << \"logEvent waiting for writer [set name]\" << endl;
          \}
          usleep(1000);
        \}
          if (iverbose) \{
               cout << \"Client \" << LVClient << \"logEvent has writer [set name]\" << endl;
          \}
        return SAL__OK;
    \}

    int [set base]_shm_flushSamplesEvent_[set n2]LV() \{
        int status;
        [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = true;
        [set base]_memIO->client\[LVClient\].skipOld_[set base]_[set name] = true;
        [set base]_memIO->client\[LVClient\].flush_[set base]_[set name] = true;
        if (iverbose) \{
               cout << \"Client \" << LVClient << \"flushSamples [set name]\" << endl;
        \}
        return SAL__OK;
    \}
"
}


proc monitortelemetry { fout base name } {
global SAL_DIR SAL_WORK_DIR
   puts $fout "
       if ([set base]_memIO->client\[LVClient\].syncI_[set base]_[set name]) \{
          actorIdx = SAL__[set base]_[set name]_ACTOR;
          if (mgr\[LVClient\].actorReader(actorIdx) == false) \{
            if (iverbose) \{
                cout << \"Client \" << LVClient << \" salTelemetrySub [set name]\" << endl;
            \}
            mgr\[LVClient\].salTelemetrySub(actorIdx);
             [set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] = true;
          \}
          if ( [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] == false ) \{
            if ( [set base]_memIO->client\[LVClient\].skipOld_[set base]_[set name] == true ) \{
                mgr\[LVClient\].setMaxSamples(actorIdx,-1);
                status = mgr\[LVClient\].getSample_[set name](Incoming_[set base]_[set name]);
             \} else \{
               status = mgr\[LVClient\].getNextSample_[set name](Incoming_[set base]_[set name]);
             \}
             if (status == SAL__OK) \{"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]monin.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
                if (iverbose) \{
                   cout << \"Client \" << LVClient << \" getSample got a sample [set name]\" << endl;
                \}
                [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = true;
             \}
          \}
       \}
       if ([set base]_memIO->client\[LVClient\].syncO_[set base]_[set name]) \{
          actorIdx = SAL__[set base]_[set name]_ACTOR;
          if (mgr\[LVClient\].actorWriter(actorIdx) == false) \{
             if (iverbose) \{
                 cout << \"Client \" << LVClient << \" salTelemetryPub [set name]\" << endl;
              \}
             mgr\[LVClient\].salTelemetryPub(actorIdx);
             [set base]_memIO->client\[LVClient\].hasWriter_[set base]_[set name] = true;
          \}
       \}
       if ( [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] ) \{"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]monout.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
         if (iverbose) \{
              cout << \"Client \" << LVClient << \" putSample [set name]\" << endl;
         \}
         status = mgr\[LVClient\].putSample_[set name](Outgoing_[set base]_[set name]);
          [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] = false;
       \}
"
}




proc monitorcommand { fout base name } {
global SAL_DIR SAL_WORK_DIR REVCODE
   set n2 [join [lrange [split $name _] 1 end] _]
   puts $fout "
       if ([set base]_memIO->client\[LVClient\].syncI_[set base]_[set name]) \{
          actorIdx = SAL__[set base]_[set name]_ACTOR;
          if (mgr\[LVClient\].actorProcessor(actorIdx) == false) \{
             if (iverbose) \{
                cout << \"Client \" << LVClient << \" salProcessor [set name]\" << endl;
             \}
             mgr\[LVClient\].salProcessor(\"[set base]_[set name]\");
             [set base]_memIO->client\[LVClient\].hasWriter_[set base]_ackcmd = true;
             [set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] = true;
          \}
          if ([set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] == false) \{
            if ( [set base]_memIO->client\[LVClient\].ackIt_[set base]_[set name] ) \{
                status = mgr\[LVClient\].acceptCommand_[set n2](Incoming_[set base]_[set name]);
            \} else \{
                status = mgr\[LVClient\].getNextSample_[set name](Incoming_[set base]_[set name]);
            \}
            if (status > 0) \{"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]monin.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   set revcode [getRevCode [set base]_ackcmd short]
   puts  $fout "
             [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = true;
             [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum = status;
             if (iverbose) \{
                  cout << \"Client \" << LVClient << \" got a command cmdId=\" << status << \" [set name]\" << endl;
              \}
            \}
          \}
       \}
       if ([set base]_memIO->client\[LVClient\].activeCommand == SAL__[set base]_[set name]_ACTOR) \{
       if ([set base]_memIO->client\[LVClient\].syncI_[set base]_[set name]_ackcmd) \{
       if ([set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name]_ackcmd == false) \{
          [set base]::ackcmd[set revcode]Seq response;
          actorIdx = SAL__[set base]_ackcmd_ACTOR;
          status = mgr\[LVClient\].getResponse_[set n2](response);
          if (iverbose && status != SAL__CMD_NOACK) \{
               cout << \"Client \" << LVClient << \" got a response \" << status << \" [set name]\" << endl;
          \}
          [set base]_memIO->client\[LVClient\].hasReader_[set base]_ackcmd = true;
          if (status != SAL__CMD_NOACK) \{
             [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum = mgr\[LVClient\].getIntProperty(SAL__[set base]_[set name]_ACTOR , \"rcvSeqNum\");
             [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_cmdStatus = mgr\[LVClient\].getIntProperty(SAL__[set base]_[set name]_ACTOR , \"ack\");
             [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_errorCode = mgr\[LVClient\].getIntProperty(SAL__[set base]_[set name]_ACTOR , \"error\");
             [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name]_ackcmd = true;
             if (iverbose) \{
                 cout << \"Client \" << LVClient << \" command ack cmdId= \" << [set base]_memIO->client\[LVClient\].shmemIncoming_[set base]_[set name]_rcvSeqNum << \" [set name]\" << \"status = \" << status << endl;
            \}
          \}
        \}
       \}
       \}
       if ([set base]_memIO->client\[LVClient\].syncO_[set base]_[set name]) \{
          actorIdx = SAL__[set base]_[set name]_ACTOR;
          if (mgr\[LVClient\].actorCommand(actorIdx) == false) \{
             if (iverbose) \{
                  cout << \"Client \" << LVClient << \" salCommand [set name]\" << endl;
              \}
             mgr\[LVClient\].salCommand(\"[set base]_[set name]\");
             [set base]_memIO->client\[LVClient\].hasReader_[set base]_ackcmd = true;
             [set base]_memIO->client\[LVClient\].hasWriter_[set base]_[set name] = true;
          \}
       \}
       if ( [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] ) \{"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]monout.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
          status = mgr\[LVClient\].issueCommand_[set n2](Outgoing_[set base]_[set name]);
          [set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_cmdSeqNum = status;
          [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] = false;
          [set base]_memIO->client\[LVClient\].hasWriter_[set base]_[set name] = true;
          if (iverbose) \{
              cout << \"Client \" << LVClient << \" issueCommand cmdId=\" << status << \" [set name]\" << endl;
          \}
       \}
       if ([set base]_memIO->client\[LVClient\].syncO_[set base]_[set name]_ackcmd) \{
            actorIdx = SAL__[set base]_[set name]_ACTOR;
            if (mgr\[LVClient\].actorProcessor(actorIdx) == false) \{
              if (iverbose) \{
                  cout << \"Client \" << LVClient << \" salProcessor [set name]\" << endl;
              \}
             mgr\[LVClient\].salProcessor(\"[set base]_[set name]\");
              [set base]_memIO->client\[LVClient\].hasWriter_[set base]_ackcmd = true;
              [set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] = true;
            \}
       \}
       if ( [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name]_ackcmd ) \{
          if (iverbose) \{
              cout << \"Client \" << LVClient << \" ackCommand [set name]\" << endl;
          \}
          status = mgr\[LVClient\].ackCommand_[set n2](
				[set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_cmdSeqNum,
				[set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_cmdStatus,
				[set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_errorCode,
				[set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name]_resultCode
                                          );
          [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name]_ackcmd = false;
       \}
"
}




proc monitorlogevent { fout base name } {
global SAL_DIR SAL_WORK_DIR
   set n2 [join [lrange [split $name _] 1 end] _]
   puts $fout "
       if ([set base]_memIO->client\[LVClient\].syncI_[set base]_[set name]) \{
          actorIdx = SAL__[set base]_[set name]_ACTOR;
          if (mgr\[LVClient\].actorEventReader(actorIdx) == false) \{
             if (iverbose) \{
                 cout << \"Client \" << LVClient << \" salEventSub [set name]\" << endl;
            \}
            mgr\[LVClient\].salEventSub(\"[set base]_[set name]\");
             [set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] = true;
          \}
          if ( [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] == false ) \{
           status = mgr\[LVClient\].getEvent_[set n2](Incoming_[set base]_[set name]);
           if (status == SAL__OK) \{"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]monin.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
             [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = true;
             if (iverbose) \{
                 cout << \"Client \" << LVClient << \" got an event [set name]\" << endl;
             \}
           \}
          \}
       \}
       if ([set base]_memIO->client\[LVClient\].syncO_[set base]_[set name]) \{
          actorIdx = SAL__[set base]_[set name]_ACTOR;
          if (mgr\[LVClient\].actorEventWriter(actorIdx) == false) \{
             if (iverbose) \{
                 cout << \"Client \" << LVClient << \" salEventPub [set name]\" << endl;
             \}
             mgr\[LVClient\].salEventPub(\"[set base]_[set name]\");
             [set base]_memIO->client\[LVClient\].hasWriter_[set base]_[set name] = true;
          \}
       \}
       if ( [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] ) \{
          lpriority = [set base]_memIO->client\[LVClient\].shmemOutgoing_[set base]_[set name].priority;"
   set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]monout.tmp r]
   while { [gets $frag rec] > -1} {puts $fout $rec}
   close $frag
   puts $fout "
         if (iverbose) \{
            cout << \"Client \" << LVClient << \" publish an event [set name]\" << endl;
         \}
         status = mgr\[LVClient\].logEvent_[set n2](Outgoing_[set base]_[set name],lpriority);
          [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] = false;
       \}
"
}


proc shmemsyncinit { fout base name } {
global SAL_DIR SAL_WORK_DIR
   set n2 [join [lrange [split $name _] 1 end] _]
   set type [lindex [split $name _] 0]
   puts $fout "
       [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name] = false;
       [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name] = false;
       [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name] = false;
       [set base]_memIO->client\[LVClient\].syncO_[set base]_[set name] = false;
       [set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name] = 0;
       [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name] = false;
       [set base]_memIO->client\[LVClient\].skipOld_[set base]_[set name] = false;
       [set base]_memIO->client\[LVClient\].hasReader_[set base]_[set name] = false;
       [set base]_memIO->client\[LVClient\].hasWriter_[set base]_[set name] = false;
       [set base]_[set name]C *Incoming_[set base]_[set name] = new [set base]_[set name]C;
       [set base]_[set name]C *Outgoing_[set base]_[set name] = new [set base]_[set name]C;"
     if { $type == "command" && $name != "command" } {
       puts $fout "    
       [set base]_memIO->client\[LVClient\].syncI_[set base]_[set name]_ackcmd = false;
       [set base]_memIO->client\[LVClient\].syncO_[set base]_[set name]_ackcmd = false;
       [set base]_memIO->client\[LVClient\].hasIncoming_[set base]_[set name]_ackcmd = false;
       [set base]_memIO->client\[LVClient\].hasOutgoing_[set base]_[set name]_ackcmd = false;
       [set base]_memIO->client\[LVClient\].hasCallback_[set base]_[set name]_ackcmd = false;
       [set base]_memIO->client\[LVClient\].callbackHdl_[set base]_[set name]_ackcmd = 0;
       [set base]_memIO->client\[LVClient\].ackIt_[set base]_[set name] = true;
       [set base]_memIO->client\[LVClient\].activeCommand = 0;
"
     }
}


proc monitorsyncinit { fout base name } {
global SAL_DIR SAL_WORK_DIR
   set n2 [join [lrange [split $name _] 1 end] _]
   set type [lindex [split $name _] 0]
   puts $fout "
       [set base]_[set name]C *Incoming_[set base]_[set name] = new [set base]_[set name]C;
       [set base]_[set name]C *Outgoing_[set base]_[set name] = new [set base]_[set name]C;"
}


proc modlabviewpubsubexamples { id } {
global SAL_DIR SAL_WORK_DIR
  set fin [open $SAL_DIR/code/templates/SALLVDataPublisher.cpp.template r]
  set fout [open $SAL_WORK_DIR/[set id]/labview/[set id]LVDataPublisher.cpp w]
  while { [gets $fin rec] > -1 } {
      puts $fout $rec
      if { [string range $rec 0 19] == "// INSERT_SAL_SHMOUT" } {
         set frag [open $SAL_WORK_DIR/include/SAL_[set id]shmout.tmp r]
         while { [gets $frag r2] > -1 } {puts $fout $r2}
         close $frag         
      }
  }
  close $fin
  close $fout
  set fin [open $SAL_DIR/code/templates/SALLVDataSubscriber.cpp.template r]
  set fout [open $SAL_WORK_DIR/[set id]/labview/[set id]LVDataSubscriber.cpp w]
  while { [gets $fin rec] > -1 } {
      puts $fout $rec
      if { [string range $rec 0 18] == "// INSERT_SAL_SHMIN" } {
         set frag [open $SAL_WORK_DIR/include/SAL_[set id]shmin.tmp r]
         while { [gets $frag r2] > -1 } {puts $fout $r2}
         close $frag         
      }
  }
  close $fin
  close $fout
}


proc removeshmem { id } {
  set lid "0x[format %8.8x 0x[set id]]"
  set ipcs [exec ipcs -a]
  set shmpos [lsearch $ipcs $lid]
  if { $shmpos > -1 } {
     exec ipcrm -m [lindex $ipcs [expr $shmpos +1]]
  } else {
     puts stdout "Shared memory segment not present : OK"
     return
  }
  set ipcs [exec ipcs -a]
  set shmpos [lsearch $ipcs $lid]
  if { $shmpos > -1} {
     puts stdout "WARNING : Failed to remove shared memory segment"
  } else {
     puts stdout "Shared memory segment removed : OK"
  }
}






