#!/usr/bin/env tclsh

proc doddsgen { sublist publist } {
global scriptdir
puts stdout "doddsgen sublist = $sublist"
#   parsesub $sublist
#puts stdout "doddsgen publist = $publist"
#   parsepub $publist
#  parsemakefile  $sublist $publist
}

proc doortegen { sublist publist } {
  puts stdout "<P><HR><H2>ORTE code generation not available yet</H2><HR><P>"
}


proc doicegen { sublist publist } {
  puts stdout "<P><HR><H2>ICE code generation not available yet</H2><HR><P>"
}


proc doamqgen { sublist publist } {
  puts stdout "<P><HR><H2>ActiveMQ code generation not available yet</H2><HR><P>"
}


proc calcshmid { subsys } {
  set fout [open /tmp/subsys.tmp w]
  puts $fout "$subsys"
  close $fout
  set id [string range [exec md5sum /tmp/subsys.tmp] 0 3]
  return $id
}


proc addshmempub { topiclist fid } {
global VPROPS
  foreach subsys $topiclist {
    puts $fid "
   int [set subsys]_salHandle;
   svcSAL_cachehandle svcSAL_handle_[set subsys];
   [set subsys]_cache *[set subsys]_ref;"
  }
  foreach subsys $topiclist {
    puts $fid "
    [set subsys]_salHandle = svcSAL_connect1 (\"[set subsys]\", &svcSAL_handle_[set subsys] );
   if ( [set subsys]_salHandle != SAL__OK ) \{
      return(SAL__NOT_DEFINED);
   \}
   [set subsys]_ref  = ([set subsys]_cache *) svcSAL_handle_[set subsys].ref;

"
  }
  puts $fid "
	while (1) \{
		svcSAL_sleep(1000);"
  foreach subsys $topiclist {
    puts $fid "
		if ([set subsys]_ref->syncO == 1) \{
			[set subsys]_count++;"
     set fin [open ../shmem-[set subsys]/[set subsys]_putstub.txt r]
     while { [gets $fin rec] > -1 } {
       puts $fid $rec
     }
     close $fin
     puts $fid "		\}"
  }
  puts $fid "	\}"
}


proc shcoder { topiclist } {
global SHC TOPICPROPS
 foreach subsys $topiclist {
  set fcod [open shmem_[set subsys].h w]
  puts $fcod $SHC(genericshmem.h)
  close $fcod
  set fcod [open shmem_[set subsys]_server.cpp w]
  puts $fcod $SHC(genericshmem.cpp)
  close $fcod
  set fcod [open test_shmem_[set subsys].cpp w]
  puts $fcod $SHC(genericshclient.cpp)
  close $fcod
  exec g++ -shared -g shmem_[set subsys]_server.cpp -o libshm_[set subsys]_server.so -lstdc++
  exec gcc -g test_shmem_[set subsys].cpp -o test_[set subsys] -lpthread -L. -lshm_[set subsys]_server
 }
}





if { [info exists JUSTTESTING] } {
  set PUBS(camera_BEE_biases) "yes"
  set PUBS(camera_BEE_clocks) "yes"
  set PUBS(camera_BEE_thermal) "yes"
  set PROC(camera_BEE_biases) "yes"
  set PROC(camera_BEE_clocks) "yes"
  set PROC(camera_BEE_thermal) "yes"
  set SUBS(camera_CCS) "yes"
}

set scriptdir /usr/local/scripts/tcl
 
source $scriptdir/ndds_version.tcl
source $scriptdir/streamutils.tcl


set basedir $WORKING
cd $basedir
source $scriptdir/managetypes.tcl
source $basedir/stream_frequencies.tcl 

if { [info exists FormData(GenerateALL)] } {
  set all [glob $subsys*.idl]
  set topiclist ""
  foreach t [lsort $all] {
    lappend topiclist [file rootname $t]
  }
} else {
  set publist ""
  set sublist ""
  foreach t [array names ISSU] {
     set s [lindex [split $t ._] 0]
     set PUBS([set s]_command)  1
     set SUBS([set s]_ackcmd) 1
  }
  foreach t [array names PROC] {
     set s [lindex [split $t ._] 0]
     set SUBS([set s]_command)  1
     set PUBS([set s]_ackcmd) 1
  }
#  foreach t [array names PUBS] {
#     set id [join [split $t .] _]
#     set publist "$publist $id"
#  }
#  foreach t [array names SUBS] {
#     set sublist "$sublist $id"
#  }
}

set publist [array names PUBS]
set sublist [array names SUBS]

set subsys [lindex [split [lindex "$sublist $publist" 0] _.] 0]
set basename [lindex [split $subsys _.] 0]
source $basedir/revCodes.tcl
exec rm -fr  $basedir/shmem-$basename
exec mkdir -p  $basedir/shmem-$basename

#printformdata
#puts stdout "basedir = $basedir"

puts stdout "<HTML><HEAD><TITLE>Service Abstraction Layer API generator</TITLE></HEAD>
<BODY BGCOLOR=White><H1>
<IMG SRC=\"/LSST_logo.gif\" ALIGN=CENTER>
<IMG SRC=\"/salg.gif\" ALIGN=CENTER><P><HR><P>
<H1>Code generation phase</H1>
<P><HR><P>"

flush stdout

puts stdout "<PRE>"
catch {unset DONE}

foreach t "$sublist $publist" {
  if { [info exists DONE($t)] == 0 } {
    puts stdout "Processing $t"
    if { [info exists FormData(mw_ndds)] } {
      catch {exec $scriptdir/genshmem.tcl $t $basedir +dds} result
    } else {
      catch {exec $scriptdir/genshmem.tcl $t $basedir} result
    }
    puts stdout "$result"
    set res [glob ./shmem-$t/*]
    foreach f $res { exec cp $f ./shmem-$basename/. }
    puts stdout "Done $t\n"
    flush stdout
    set DONE($t) 1
  }
}

puts stdout "Building shmem interfaces"
puts stdout "Processing $sublist $publist"
set workdir $basedir/shmem-$basename
cd $workdir
#source $scriptdir/genshmem-rtidds.tcl
#doddsgen "$sublist" "$publist"

if { [info exists FormData(mw_orte)] } {
  source $scriptdir/genshmem-orte.tcl
  doortegen $sublist $publist
}
if { [info exists FormData(mw_ice)] } {
  source $scriptdir/genshmem-ice.tcl
  doicegen $sublist $publist
}
if { [info exists FormData(mw_activemq)] } {
  source $scriptdir/genshmem-activemq.tcl
  doamqgen $sublist $publist
}
if { [info exists FormData(langlv)] } {
  source $scriptdir/genshmem-labview.tcl
  dolvgen $sublist $publist
 }

set code [glob $scriptdir/code/*.c]
foreach f $code { exec cp $f . }
exec cp $scriptdir/code/version.mak .
exec cp $scriptdir/code/makefile.sal .
exec cp $scriptdir/code/makefile.saltcl .
exec cp /usr/local/scripts/include/svcSAL.h .

source $scriptdir/genshmtclpersubsys.tcl
puts stdout "</PRE><P><HR><P><H1>Compilation phase</H1><P><PRE>"

source $scriptdir/accesspersubsystem.tcl
set res [ catch { exec $scriptdir/ddsmake -f makefile.sal } op]
puts stdout "$op"
set res [ catch { exec $scriptdir/ddsmake -f makefile.saltcl } op]
exec ln -sf libshmSALtcl_linux.so.$SALVERSION libshmSALtcl.so
puts stdout "$op"
if { [info exists FormData(mw_ndds)] } {
  set res [ catch { exec $scriptdir/ddsmake } op]
  puts stdout "$op"
}

if { [info exists FormData(mw_orte)] } {
  set res [ catch { exec $scriptdir/ortemake } op]
  puts stdout "$op"
}

if { [info exists FormData(mw_activemq)] } {
  set res [ catch { exec $scriptdir/activemqmake } op]
  puts stdout "$op"
}

if { [info exists FormData(mw_ice)] } {
  set res [ catch { exec $scriptdir/icemake } op]
  puts stdout "$op"
}

if { [info exists FormData(langlv)] } {
  set res [ catch { exec $scriptdir/lvmake } op]
  puts stdout "$op"
}


puts stdout "</PRE><P><HR><P><H1>Generating distribution</H1><P>"






