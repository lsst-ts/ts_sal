#!/usr/bin/env tclsh
## \file gengenericclient.tcl
# \brief This contains procedures to create applications to 
#  watch sets of DDS Topics and perform predefined actions.
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
## Documented proc \c genericclientfragment .
# \param[in] fout File handle of output C++ file
# \param[in] id A Subsystem identifier
# \param[in] ctype Type of code to generate (subscriber, getsamples, onevent)
#
#  Generate a code fragment to perform a selected SAL function
#  Optionally to subscribe to or publish a topic, read samples, perform arbitrary processing
#
proc genericclientfragment { fout id ctype } {
global ACTORTYPE SAL_WORK_DIR SALCLIENTS
   set ptypes $SALCLIENTS($id,telemetry)
   foreach j $ptypes {
     set subsys  [lindex [split $j _] 0]
     set type [lindex [split $j _] 1]
     set topic [join [lrange [split $j _] 1 end] _]
      if { $ctype == "subscriber" } {
         puts $fout "  mgr_[set subsys].salTelemetrySub(\"[set j]\");"
         if { [info exists SALCLIENTS($id,[set topic])] } {
            if { [lindex $SALCLIENTS($id,[set topic]) 0] == "publish" } {
               puts $fout "  mgr_[set subsys].salTelemetryPub(\"[lindex $SALCLIENTS($id,[set topic]) 1]\");"
            }
         }
      }
      if { $ctype == "getsamples" } {
         if { [info exists SALCLIENTS($id,[set j])] == 0 } {
           puts $fout "    status = mgr_[set subsys].getSample_[set topic](&instanceOf_[set subsys]_[set topic]);"
         }
      }
      if { $ctype == "onevent" } {
         if { [info exists SALCLIENTS($id,[set j])] } {
           puts $fout "  
    status = mgr_[set subsys].getSample_[set topic](&instanceOf_[set subsys]_[set topic]);
    if (status == SAL__OK) \{"
           if { [lindex $SALCLIENTS($id,[set j]) 0] == "publish" } {
              puts $fout "      status = publish_[lindex $SALCLIENTS($id,[set j]) 1]();"
              set fh [open $SAL_WORK_DIR/salClient/cpp/src/SAL_clientProcessors.h a]
              puts $fh "int publish_[lindex $SALCLIENTS($id,[set j]) 1]();"
              close $fh
           } else {
              puts $fout "      status = [set SALCLIENTS($id,[set j])]();"
           }
           puts $fout "    \}"
         }
      }
   }
}

#
## Documented proc \c copyincludefiles .
# \param[in] id A Subsystem identifier
#
#  Copy required include files to the application build directory
#
proc copyincludefiles { id } {
global SAL_WORK_DIR SALCLIENTS
   set ptypes $SALCLIENTS($id,telemetry)
   foreach j $ptypes {
     set s [lindex [split $j _] 0]
     exec cp $SAL_WORK_DIR/$s/cpp/src/SAL_[set s].h $SAL_WORK_DIR/salClient/cpp/src/.
     exec cp $SAL_WORK_DIR/$s/cpp/src/SAL_[set s]C.h $SAL_WORK_DIR/salClient/cpp/src/.
     exec cp $SAL_WORK_DIR/$s/cpp/sal_[set s]Dcps.h $SAL_WORK_DIR/salClient/cpp/src/.
     exec cp $SAL_WORK_DIR/$s/cpp/ccpp_sal_[set s].h $SAL_WORK_DIR/salClient/cpp/src/.
     exec cp $SAL_WORK_DIR/$s/cpp/sal_[set s]Dcps_impl.h $SAL_WORK_DIR/salClient/cpp/src/.
   }
}




#
## Documented proc \c gensalclientmake .
# \param[in] id A Subsystem identifier
#
#  Generate a Makefile for a generic client application
#
proc gensalclientmake { id } {
global SAL_DIR SAL_WORK_DIR env
  set frep [open /tmp/sreplace6.sal w]
  puts $frep "#!/bin/sh"
  exec touch $SAL_WORK_DIR/salClient/cpp/src/.depend.Makefile.sacpp_salClient_[set id]
  exec cp  $SAL_DIR/code/templates/Makefile.sacpp_SAL_client.template $SAL_WORK_DIR/salClient/cpp/src/Makefile.sacpp_salClient_[set id]
  puts $frep "perl -pi -w -e 's/_SALCLIENT/_salClient_[set id]/g;' $SAL_WORK_DIR/salClient/cpp/src/Makefile.sacpp_salClient_[set id]"
  close $frep
  exec chmod 755 /tmp/sreplace6.sal
  catch { set result [exec /tmp/sreplace6.sal] } bad
  if { $bad != "" } {puts stdout $bad}
}


#
## Documented proc \c gentelemetryclient .
# \param[in] id A Subsystem identifier
#
#  Generate a C++ template for a generic client application
#
proc gentelemetryclient { id } {
global SAL_WORK_DIR SYSDIC SALCLIENTS
   exec mkdir -p $SAL_WORK_DIR/salClient/cpp/src
   exec rm -f $SAL_WORK_DIR/salClient/cpp/src/SAL_clientProcessors.h
   set fout [open $SAL_WORK_DIR/salClient/cpp/src/sacpp_salClient_[set id].cpp w]
   puts $fout "
/*
 * This file contains the implementation for the salClient generic Telemetry client.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <stdlib.h>
#include <mysql.h>
#include \"os.h\""
   foreach s $SALCLIENTS($id,subsystems) {
       puts $fout "
#include \"SAL_[set s].h\"
#include \"SAL_actors.h\"
#include \"ccpp_sal_[set s].h\"
using namespace [set s];
"
   }
   puts $fout "
#include \"os.h\"
#include \"SAL_clientProcessors.h\"
using namespace DDS;
"
   foreach t $SALCLIENTS($id,telemetry) {
       puts $fout "[set t]C instanceOf_[set t];"
   }
  puts $fout "
/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_salClient_telemetry_salclient_[set id]();
\}

int test_salClient_telemetry_salclient_[set id]()
\{   
  os_time delay_1ms = \{ 0, 1000000 \};
  int status = 0;
"
  foreach subsys $SALCLIENTS($id,subsystems) {
     puts $fout "  SAL_[set subsys] mgr_[set subsys] = SAL_[set subsys]();"
  }
  genericclientfragment $fout $id subscriber
  puts $fout "
  while (1) \{
"
  genericclientfragment $fout $id getsamples
  genericclientfragment $fout $id onevent
  puts $fout "
    os_nanoSleep(delay_1ms);
  \}

  /* Remove the DataWriters etc */
  return 0;
\}

int main (int argc, char **argv[])
\{
  return test_salClient_telemetry_salclient_[set id]();
\}
"
   genclientpublisher $fout $id
   close $fout
}


#
## Documented proc \c genclientpublisher .
# \param[in] fout File handle of output C++ file
# \param[in] id A Subsystem identifier
#
#  Generate a C++ template for a generic client publisher
#
proc genclientpublisher { fout id } {
global SAL_WORK_DIR SALCLIENTS
   set ptypes $SALCLIENTS($id,telemetry)
   foreach j $ptypes {
      if { [info exists SALCLIENTS($id,[set j]) ] } {
       if { [lindex $SALCLIENTS($id,[set j]) 0] == "publish" } {
         set app [lindex $SALCLIENTS($id,[set j]) 1]
         set subsys [lindex [split $app _] 0]
         puts $fout "
// 
// Example publisher does a Large File Object announcement
//

int publish_[set app]()
\{
  int status;
  int priority;
  [set subsys]_logevent_largeFileObjectAvailableC LFOA_sample;

  strcpy(LFOA_sample.url,\"http://lsst.summit.efd/2017/12/12/1234567/sample_header.fits\");
  strcpy(LFOA_sample.generator,\"DM Header Service\");
  LFOA_sample.version = 1.0;
//  md5sum(&LFOA_sample.checkSum,\"file:///2017/12/12/1234567/sample_header.fits\");
  strcpy(LFOA_sample.mimeType,\"application/fits\");
//  LFOA_sample.byteSize = getFileSize(\"file:///2017/12/12/1234567/sample_header.fits\");
  SAL_[set subsys] mgr = SAL_[set subsys]();
  mgr.salEvent(\"[set subsys]_logevent_largeFileObjectAvailable\");
  priority=1;
  status = mgr.logEvent_largeFileObjectAvailable(&LFOA_sample,priority);
  cout << \"=== Event [set subsys]_logevent_largeFileObjectAvailable generated = \" << endl;
  sleep(1);

  return 0;
\}
"
       } else {
         puts $fout "int [set SALCLIENTS($id,[set j])]()
\{
  int status;
\}
"
       }
     }
   }
}


#
## Documented proc \c startsalclients .
# \param[in] clients List of SAL client applications
#
#  Runtime starter for generic client applications
#
proc startsalclients { clients } { 
global SAL_WORK_DIR
   foreach id $clients {
      if { [file exists $SAL_WORK_DIR/salClients/cpp/src/sacpp_telemetry_salclient_[set id]] == 0 } {
         puts sdout "ERROR : No telemetry client available for $id"
         exit
      }
      set tid($s) [exec $SAL_WORK_DIR/salClients/cpp/src/sacpp_telemetry_salclient_[set id] >& [set id]_telemetry_[clock seconds].log &]
   }
   while { 1 } {
     foreach id $clients {
       set bad [catch {exec ps -F --pid $tid($s)} res]
       if { $bad } {
          set tid($s) [exec $SAL_WORK_DIR/salClients/cpp/src/sacpp_telemetry_salclient_[set id] >& [set id]_telemetry_[clock seconds].log &]
       }
     }
   }
}

#
## Documented proc \c parsesalclients .
# \param[in] clientlist List of SAL client applications
#
#  Runtime parser for generic client applications
#
proc parsesalclients { clientlist } {
global SALCLIENTS
   set client ""
   set fin [open $clientlist r]
   while { [gets $fin rec] > -1 } {
       if { [lindex $rec 0] == "client" } {
          if { $client != "" } {
             set SALCLIENTS($client,subsystems) [lsort [array names subsystems]]
             set SALCLIENTS($client,telemetry) [lsort [array names telemetry]]
          }
          catch {unset subsystems;unset telemetry}
          set client [lindex $rec 1]
          lappend SALCLIENTS(list) $client
       }
       if { [lindex $rec 0] == "subscribe" } {
          set s [lindex [split [lindex $rec 1] _] 0]
          set subsystems($s) 1
          set telemetry([lindex $rec 1]) 1
       }
       if { [lindex $rec 0] == "onevent" } {
          set s [lindex [split [lindex $rec 1] _] 0]
          set subsystems($s) 1
          set telemetry([lindex $rec 1]) 1
          set SALCLIENTS($client,[lindex $rec 1]) [lrange $rec 2 end]
          set s [lindex [split [lindex $rec 3] _] 0]
          set subsystems($s) 1
       }
   }
   if { $client != "" } {
       set SALCLIENTS($client,subsystems) [lsort [array names subsystems]]
       set SALCLIENTS($client,telemetry) [lsort [array names telemetry]]
   }
   close $fin 
}

#
## Documented proc \c exampleclient .
#
#  Create an example SAL client application definition file
#
proc exampleclient { } {
global SALCLIENTS
   set fout [open exampleClient.def w]
   puts $fout "# Example SAL generic client
client anExample
subscribe MTMount_MotionParameters
subscribe camera_Filter
onevent camera_logevent_endReadout publish dmHeaderService_logevent_largeFileObjectAvailable
"
   close $fout
   parsesalclients exampleClient.def
   foreach c $SALCLIENTS(list) {
      gentelemetryclient $c
      gensalclientmake $c
   }
}



set SAL_DIR $env(SAL_DIR)
set SAL_WORK_DIR $env(SAL_WORK_DIR)


source $SAL_DIR/add_system_dictionary.tcl
source $SAL_DIR/revCodes.tcl
source $SAL_WORK_DIR/.salwork/revCodes.tcl
source $SAL_DIR/managetypes.tcl

