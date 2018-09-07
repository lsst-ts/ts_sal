#!/usr/bin/env tclsh
#
#


proc calcshmid { subsys } {
  set fout [open /tmp/subsys.tmp w]
  puts $fout "$subsys"
  close $fout
  set id [string range [exec md5sum /tmp/subsys.tmp] 0 3]
  return $id
}


proc addshmemcode { subsys fid } {
global VPROPS TYPESIZE
  puts $fid "
   int [set subsys]_shmsize;
   int lshmid;
   int [set subsys]_count;
   int [set subsys]_shmid= 0x[calcshmid $subsys];
   [set subsys]_cache *[set subsys]_ref;
   [set subsys]_shmsize = sizeof(struct [set subsys]_cache);
   lshmid = shmget([set subsys]_shmid, [set subsys]_shmsize , IPC_CREAT|0666);
   [set subsys]_ref  = ([set subsys]_cache *) shmat(lshmid, NULL, 0);
   
   send_period.sec = 0;
   send_period.nanosec = 1000000;
   while ([set subsys]_ref->syncO > -1 ) \{
     while ([set subsys]_ref->syncO == 0) \{
        svcSAL_sleep(10);  
     \}

     [set subsys]_count++;
"
  set fin [open [set subsys]_cache.h r]
  gets $fin rec
  gets $fin rec
  gets $fin rec
  while { [gets $fin rec] > -1 } {
   if { [string range $rec 0 0] != "\}" } {
     set v [string trim [lindex $rec 1] ";"]
     if { [llength [split $v "\[\]"]] > 1 } {
        set l [lindex [split $v "\[\]"] 1]
        set v [lindex [split $v "\[\]"] 0]
     } else {
        set l 1
     }
     if { $v != "syncO" } {
       puts $fid "	[transferdata $subsys $v [lindex $rec 0] $l ddsfromcache]"
     }
   }
  }
  puts $fid "
        printf(\"Writing [set subsys], count %d\\n\", count);
        
        /* Write data */
        retcode = [set subsys]DataWriter_write(
            [set subsys]_writer, instance, &instance_handle);
        if (retcode != DDS_RETCODE_OK) \{
            printf(\"write error %d\\n\", retcode);
        \}

        NDDS_Utility_sleep(&send_period);
        [set subsys]_ref->syncO = 0;
        count++;
    \}
"
}

proc shcoder { subsys } {
global SHC TOPICPROPS
  set fcod [open shmem_[set subsys].h w]
  puts $fcod $SHC(genericshmem.h)
  close $fcod
  set fcod [open shmem_[set subsys]_server.cpp w]
  puts $fcod $SHC(genericshmem.cpp)
  close $fcod
  set fcod [open test_shmem_[set subsys].cpp w]
  puts $fcod $SHC(genericshclient.cpp)
  close $fcod
  exec g++ -shared -g -fPIC shmem_[set subsys]_server.cpp -o libshm_[set subsys]_server.so -lstdc++
  exec gcc -g -fPIC test_shmem_[set subsys].cpp -o shm_test1 -lpthread -L. -lshm_[set subsys]_server
}



proc generatestubs { subsys } {
global VPROPS TYPESIZE
  set fput [open [set subsys]_putstub.txt w]
  set fget [open [set subsys]_getstub.txt w]
  set flvput [open [set subsys]_lvputstub.txt w]
  set flvget [open [set subsys]_lvgetstub.txt w]
  set flvpro [open [set subsys]_lvprostub.txt w]
  set lvproput "int LVcomm_send_i[set subsys](int fd,"
  set lvproget "int LVcomm_get_e[set subsys](int fd,"
  set fin [open [set subsys]_cache.h r]
  gets $fin rec
  gets $fin rec
  gets $fin rec
  while { [gets $fin rec] > -1 } {
   if { [string range $rec 0 0] != "\}" } {
     set v [string trim [lindex $rec 1] ";"]
     if { [llength [split $v "\[\]"]] > 1 } {
        set l [lindex [split $v "\[\]"] 1]
        set v [lindex [split $v "\[\]"] 0]
     } else {
        set l 1
     }
     if { $v != "syncO" } {
       puts $fput "		[transferdata $subsys $v [lindex $rec 0] $l ddsfromcache [set subsys]_]"
       puts $fget "		[transferdata $subsys $v [lindex $rec 0] $l ddstocache [set subsys]_]"
       puts $flvget "	[transferdata $subsys $v [lindex $rec 0] $l lvfromcache]"
       puts $flvput "	[transferdata $subsys $v [lindex $rec 0] $l lvtocache]"
       set lvproput [lvtypebuilder $lvproput put $v [lindex $rec 0] $l]
       set lvproget [lvtypebuilder $lvproget get $v [lindex $rec 0] $l]
     } else {
       puts $fput "
        printf(\"Writing [set subsys], count %d\\n\", [set subsys]_count);
        
        /* Write data */
        [set subsys]_retcode = [set subsys]DataWriter_write(
            [set subsys]_writer, [set subsys]_instance, &[set subsys]_instance_handle);
        if ([set subsys]_retcode != DDS_RETCODE_OK) \{
            printf(\"write error %d\\n\", [set subsys]_retcode);
        \}
        [set subsys]_ref->syncO = 0;"
       gets $fin rec
     }
   }
  }
  close $fput
  close $fget
  close $flvput
  close $flvget
  puts $flvpro "[string trim $lvproget ,]);"
  puts $flvpro "[string trim $lvproput ,]);"
  close $flvpro
}

proc shcoder { subsys } {
global SHC TOPICPROPS
  set fcod [open shmem_[set subsys].h w]
  puts $fcod $SHC(genericshmem.h)
  close $fcod
  set fcod [open shmem_[set subsys]_server.cpp w]
  puts $fcod $SHC(genericshmem.cpp)
  close $fcod
  set fcod [open test_shmem_[set subsys].cpp w]
  puts $fcod $SHC(genericshclient.cpp)
  close $fcod
  exec g++ -shared -g -fPIC shmem_[set subsys]_server.cpp -o libshm_[set subsys]_server.so -lstdc++
  exec gcc -g -fPIC test_shmem_[set subsys].cpp -o shm_test1 -lpthread -L. -lshm_[set subsys]_server
}



proc generatetester { subsys } {
global VPROPS
  set fout [open [set subsys]_shmem_tester.c w]
  puts $fout "
/*
  WARNING: THIS FILE IS AUTO-GENERATED. DO NOT MODIFY.

  This file was generated from [set subsys].idl using \"genshmem\".
  The genshmem tool is part of the LSST SAL middleware stack
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/shm.h>
#include \"svcSAL.h\"
#include \"[set subsys]_cache.h\"
extern svcSAL_cachehandle svcSAL_handle\[SAL__MAX_HANDLES\];

int main(int argc, char *argv\[\])
\{
   int icount=0;
   int icurrent;
   int iterator;
   [set subsys]_cache *[set subsys]_ref;
   int salHandle;
   int sample_count = 0; /* infinite loop */
   int sample_wait = 1000; /* 1000msec per sample */

   if (argc >= 2) \{
        icount = atoi(argv\[1\]);
   \}
   if (argc >= 3) \{
        sample_wait = atoi(argv\[2\]);
   \}

   svcSAL_initialize();
   salHandle = svcSAL_connect (\"[set subsys]\");
   if ( salHandle == 0 ) \{
      exit(SAL__NOT_DEFINED);
   \}

   [set subsys]_ref  = ([set subsys]_cache *) svcSAL_handle\[salHandle\].ref;
   icurrent = 1;
   while (icurrent != icount) \{
"
  set fin [open [set subsys]_cache.h r]
  gets $fin rec
  gets $fin rec
  while { [gets $fin rec] > -1 } {
   if { [string range $rec 0 0] != "\}" } {
     set v [string trim [lindex $rec 1] ";"]
     if { $v != "syncO" } {
       set v [lindex [split $v "\[\]"] 0]
       puts $fout "[transferdata $subsys $v [lindex $rec 0] $VPROPS($v) ctest]"
     } else {
       gets $fin rec
     }
   }
  }
  puts $fout "	[set subsys]_ref->syncO = 1;
	icurrent++;
	svcSAL_sleep(sample_wait);
   \}
   exit(0);
\}
"  
  close $fout
}

  
proc generatetcllib { subsys } {
global LVERSION SALVERSION VPROPS
  set fout [open shm_tcl_[set subsys].c w]
  set fo2  [open shmrd_tcl_[set subsys].c w]
  set ftst [open connect_[set subsys].tcl w]
  puts $ftst "load ../lsstsal.$SALVERSION/lib/libshmSALtcl.so"
  puts $fout "
    if (strcmp(subsysid,\"$subsys\") == 0) \{
       [set subsys]_cache *[set subsys]_ref;
       [set subsys]_ref = ([set subsys]_cache *)shmdata_ref;
"
  puts $fo2 "int shm_tcl_get_$subsys ( Tcl_Interp *interp, char *subsysid, int *shmdata_ref ) \{
    char newValue\[128\];
    char newName\[64\];
    int  iterator;
    [set subsys]_cache *[set subsys]_ref;
    [set subsys]_ref = ([set subsys]_cache *)shmdata_ref;
    int ichk;
    ichk=strlen(subsysid);
    if ( [set subsys]_ref->syncI ) \{
"
  set fin [open [set subsys]_cache.h r]
  gets $fin rec
  gets $fin rec
  while { [gets $fin rec] > -1 } {
   if { [string range $rec 0 0] != "\}" } {
     set v [string trim [lindex $rec 1] ";"]
     if { $v != "syncO" } {
       set v [lindex [split $v "\[\]"] 0]
       puts $fout "[transferdata $subsys $v [lindex $rec 0] $VPROPS($v) tcltocache]"
       puts $fo2  "[transferdata $subsys $v [lindex $rec 0] $VPROPS($v) tclfromcache]"
       puts $ftst "[transferdata $subsys $v [lindex $rec 0] $VPROPS($v) tcltest]"
     } else {
       gets $fin rec
     }
   }
  }
  puts $fout "      [set subsys]_ref->syncO = 1;
    \}"
  puts $fo2 "  \}
  return TCL_OK;
\}"
  close $fout
  close $fo2
  close $ftst
  set ftst [open test_[set subsys].tcl w]
  puts $ftst "#!/usr/bin/env tclsh

source ./connect_[set subsys].tcl 
writeshm [set subsys]

"
  close $ftst
  exec chmod 755 test_[set subsys].tcl connect_[set subsys].tcl
  set ftst [open startpubsub-[set subsys] w]
  puts $ftst "#!/bin/sh
gnome-terminal -e ../ospl-[set subsys]/[set subsys]_shmpub &
gnome-terminal -e ../ospl-[set subsys]/[set subsys]_shmsub &
echo \"Use ./test_[set subsys].tcl to test\"
"
  close $ftst
  exec chmod 755 startpubsub-[set subsys]
}

set SAL_DIR $env(SAL_DIR)
source $SAL_DIR/utilities.tcl
stdlog "Generating tcl interface for subsystem $argv"
set REQUIRES(idl) 1
set subsys [lindex $argv 0]
set FormData(workingDir) [lindex $argv 1]
set SAL_WORK_DIR [lindex $argv 1]
set scriptdir $SAL_DIR
set includedir [lindex $argv 1]/include
source $scriptdir/managetypes.tcl
source $scriptdir/streamutils.tcl
source $scriptdir/versioning.tcl


set basedir $SAL_WORK_DIR
cd $basedir
puts stdout "basedir = $basedir"
source .salwork/revCodes.tcl
set workdir $basedir/shmem-$subsys
exec mkdir -p $workdir
cd $workdir
set fin [open $SAL_WORK_DIR/idl-templates/validated/$subsys.idl r]
set fout [open $workdir/[set subsys]_cache.h w]
set TOPICPROPS($subsys) "  int syncI;\n  int syncO;"
set TOPICPROPS(bytesize) 8
set VPROPS(syncI) 1
set VPROPS(syncO) 1
puts $fout "typedef struct [set subsys]_cache \{"
puts $fout "  int cppDummy;"
puts $fout "  int syncI;"
puts $fout "  int syncO;"
gets $fin rec
while { [gets $fin rec] > -1 } {
  if { $rec != "" && [string range $rec 0 6] != "#pragma" } {
   if { [llength [split $rec "/"]] > 1 } {
      set rec [lindex [split $rec "/"] 0]
   }
   if { $rec != "\};" } {
     if { [llength [split [lindex $rec 0] "<>"]] > 1 } {
      set t [lindex [split [lindex $rec 0] "<>"] 0]
      set v [string trim [lindex $rec 1] ";"]
      set l [lindex [split $rec "<>"] 1]
      set VPROPS($v) $l
      incr TOPICPROPS(bytesize) [expr $TYPESIZE($t)*$l]
      puts $fout "  $TYPESUBS($t) $v\[$l\];"
      set TOPICPROPS($subsys) "$TOPICPROPS($subsys)\n  $TYPESUBS($t) $v\[$l\];"
     } else {
      if { [llength [split [lindex $rec 1] "\[\]"]] > 1 } {
         set l [lindex [split [lindex $rec 1] "\[\]"] 1]
         set v [lindex [split [lindex $rec 1] "\[\]"] 0]
      } else {
         set l 1
         set v [string trim [lindex $rec 1] ";"]
      }
      set VPROPS($v) $l
      set t [lindex $rec 0]
      set u ""
      if { $t == "unsigned" } {
          set t [join [lrange $rec 0 1] ""]
          set rec [lrange $rec 1 end]
          set u "unsigned "
      }
      set r [string trim [lrange $rec 1 end] "\{\}"]
      puts $fout "  $u$TYPESUBS($t) $r"
      set TOPICPROPS($subsys) "$TOPICPROPS($subsys)\n  $TYPESUBS($t) $r"
      incr TOPICPROPS(bytesize) [expr $TYPESIZE($t)*$l]
     }
   }
 }
}
puts $fout "\} [set subsys]_cache;"
close $fin
close $fout

###exec cp $workdir/[set subsys]_cache.h $includedir/.

puts stdout "Processing topic $subsys"
source $scriptdir/genericshmem.h.tcl
source $scriptdir/genericshmem.cpp.tcl
source $scriptdir/genericshclient.cpp.tcl
cd $workdir
generatestubs $subsys
shcoder $subsys
generatetcllib $subsys
exit 0

