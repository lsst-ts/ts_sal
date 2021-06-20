#!/usr/bin/env tclsh
## \file gengenericreader.tcl
# \brief This contains procedures to create SAL Topic reader applications
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
## Documented proc \c genericreaderfragment .
# \param[in] fout File handle of output C++ file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Topic name
# \param[in] ctype Topic type (command,event,telemetry)
#
#  Generates a code fragment to use the SAL API to read Topic data
#
proc genericreaderfragment { fout base name ctype } {
global ACTORTYPE
   if { $ctype == "command" || $ctype == "event" || $ctype == "telemetry" } {
      set ACTORTYPE $ctype
      puts $fout "
salReturn SAL_[set base]::[set ctype]Available () \{
  SampleInfoSeq_var infoSeq = new SampleInfoSeq;
  ReturnCode_t status = -1;
  DataReader_var dreader = NULL;
  unsigned int numsamp = 0;
  int actorIdx = 0;
  int lastActor_[set ACTORTYPE] = 0;
"
   }
   if { $ctype == "init" } {
      puts $fout "
  [set base]::[set name]Seq Instances_[set name];
  [set base]::[set name]DataReader_var SALReader_[set name]=NULL;
"
   }
   if { $ctype == "subscriber" } {
      puts $fout "
  actorIdx = SAL__[set base]_[set name]_ACTOR;
  if ( sal\[actorIdx\].isReader == false ) \{
     salTelemetrySub(\"[set base]_[set name]\");
  \}
"
   }
   if { $ctype == "processor" } {
      puts $fout "
  actorIdx = SAL__[set base]_[set name]_ACTOR;
  if ( sal\[actorIdx\].isProcessor == false ) \{
     salProcessor(\"[set base]_[set name]\");
  \}
"
   }
   if { $ctype == "reader" } {
      puts $fout "
  actorIdx = SAL__[set base]_[set name]_ACTOR;
  if (actorIdx > lastActor_[set ACTORTYPE]) \{
    DataReader_var dreader = getReader(actorIdx);
    [set base]::[set name]DataReader_var SALReader_[set name] = [set base]::[set name]DataReader::_narrow(dreader.in());
    checkHandle(SALReader_[set name].in(), \"[set base]::[set name]DataReader::_narrow\");
    status = SALReader_[set name]->read(Instances_[set name], infoSeq, sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples , ANY_SAMPLE_STATE, ANY_VIEW_STATE, ANY_INSTANCE_STATE);
    checkStatus(status, \"[set base]::[set name]DataReader::read\");
    numsamp = Instances_[set name].length();
    status = SALReader_[set name]->return_loan (Instances_[set name], infoSeq);
    if (numsamp > 0) \{
       lastActor_[set ACTORTYPE] = actorIdx;
       return lastActor_[set ACTORTYPE];
    \}
  \}
"
   }
   if { $ctype == "final" } {
      puts $fout "
  lastActor_[set ACTORTYPE] = 0;
  return SAL__NO_UPDATES;
\}
"
   }
}

#
## Documented proc \c genericreader .
# \param[in] fout File handle of output C++ file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates an application to use the SAL API to read Topic data
#
proc gengenericreader { fout base } {
global SAL_WORK_DIR
   set idlfile $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set base].idl
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   genericreaderfragment $fout $base "" telemetry
   foreach fragment "init subscriber reader" {
     foreach j $ptypes {
       set topic [lindex $j 2]
       set type [lindex [split $topic _] 0] 
       if { $type != "command" && $type != "logevent" && $type != "ackcmd" } {
          genericreaderfragment $fout $base $topic $fragment
       }
     }
   }
   genericreaderfragment $fout $base "" final
   genericreaderfragment $fout $base "" command
   foreach fragment "init processor reader" {
     foreach j $ptypes {
       set topic [lindex $j 2]
       set type [lindex [split $topic _] 0] 
       if { $type == "command" } {
          genericreaderfragment $fout $base $topic $fragment
       }
     }
   }
   genericreaderfragment $fout $base "" final
   genericreaderfragment $fout $base "" event
   foreach fragment "init subscriber reader" {
     foreach j $ptypes {
       set topic [lindex $j 2]
       set type [lindex [split $topic _] 0] 
       if { $type == "logevent" } {
          genericreaderfragment $fout $base $topic $fragment
       }
     }
   }
   genericreaderfragment $fout $base "" final
}

#
## Documented proc \c gentelemetryreader .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates a code fragment to use the SAL API to read telemetry Topic data
#
proc gentelemetryreader { base } {
global SAL_WORK_DIR SYSDIC
   set fout [open $SAL_WORK_DIR/$base/cpp/src/sacpp_[set base]_telemetry_reader.cpp w]
   set idlfile $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set base].idl
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic Telemetry reader.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set base].h\"
#include \"ccpp_sal_[set base].h\"
#include \"os.h\"
using namespace DDS;
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_[set base]_telemetry_reader();
\}

int test_[set base]_telemetry reader()
\{ "
  if { [info exists SYSDIC($base,keyedID)] } {
    puts $fout "
  int [set base]ID = 1;
  if (getenv(\"LSST_[string toupper [set base]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set base]]_ID\"),\"%d\",&[set base]ID);
  \}
  SAL_[set base] mgr = SAL_[set base]([set base]ID);"
  } else {
    puts $fout "  SAL_[set base] mgr = SAL_[set base]();"
  }
  puts $fout "
  os_time delay_10ms = \{ 0, 10000000 \};
  int status=0;

  while (1) \{
     status = mgr.telemetryAvailable();
     if (status != SAL__NO_UPDATES) \{ 
"
   foreach j $ptypes {
     set topic [lindex $j 2]
     set type [lindex [split $topic _] 0] 
     if { $type != "command" && $type != "logevent" && $type != "ackcmd" } {
        puts $fout "
       if (status == SAL__[set base]_[set topic]_ACTOR) \{
         [set base]_[set topic]C myData_[set topic];
         mgr.getSample_[set topic](&myData_[set topic]);
         cout << \"Got $base $topic sample\" << endl;
       \}
"
     }
   }
   puts $fout "
     \}
     os_nanoSleep(delay_10ms);
  \}

  /* Remove the DataWriters etc */
  mgr.salShutdown();

  return 0;
\}

int main (int argc, char *argv[])
\{
  return test_[set base]_telemetry_reader();
\}
"
   close $fout
}



#
## Documented proc \c geneventreader .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates a code fragment to use the SAL API to read event Topic data
#
proc geneventreader { base } {
global SAL_WORK_DIR SYSDIC
   set fout [open $SAL_WORK_DIR/$base/cpp/src/sacpp_[set base]_event_reader.cpp w]
   set idlfile $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set base].idl
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic event reader.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set base].h\"
#include \"ccpp_sal_[set base].h\"
#include \"os.h\"
using namespace DDS;
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_[set base]_event_reader();
\}

int test_[set base]_event_reader()
\{ "
  if { [info exists SYSDIC($base,keyedID)] } {
    puts $fout "
  int [set base]ID = 1;
  if (getenv(\"LSST_[string toupper [set base]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set base]]_ID\"),\"%d\",&[set base]ID);
  \}
  SAL_[set base] mgr = SAL_[set base]([set base]ID);"
  } else {
    puts $fout "  SAL_[set base] mgr = SAL_[set base]();"
  }

  puts $fout "
  os_time delay_10ms = \{ 0, 10000000 \};
  int status=0;

  while (1) \{
     status = mgr.eventAvailable();
     if (status != SAL__NO_UPDATES) \{ 
"
   foreach j $ptypes {
     set topic [lindex $j 2]
     set type [lindex [split $topic _] 0] 
     if { $type == "logevent" && $topic != "logevent" } {
        set name [string range $topic 9 end]
        puts $fout "
       if (status == SAL__[set base]_[set topic]_ACTOR) \{
         [set base]_[set topic]C myData_[set topic];
         mgr.getEvent_[set name](&myData_[set topic]);
         cout << \"Got $base $topic sample\" << endl;
       \}
"
     }
   }
   puts $fout "
     \}
     os_nanoSleep(delay_10ms);
  \}

  /* Remove the DataWriters etc */
  mgr.salShutdown();

  return 0;
\}

int main (int argc, char *argv[])
\{
  return test_[set base]_event_reader();
\}
"
   close $fout
}


#
## Documented proc \c gencommandreader .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates a code fragment to use the SAL API to read command Topic data
#
proc gencommandreader { base } {
global SAL_WORK_DIR SYSDIC
   set fout [open $SAL_WORK_DIR/$base/cpp/src/sacpp_[set base]_command_reader.cpp w]
   set idlfile $SAL_WORK_DIR/idl-templates/validated/sal/sal_[set base].idl
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic command reader.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include \"SAL_[set base].h\"
#include \"ccpp_sal_[set base].h\"
#include \"os.h\"
using namespace DDS;
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  OS_API_EXPORT
  int test_[set base]_command_reader();
\}

int test_[set base]_command_reader()
\{ "
  if { [info exists SYSDIC($base,keyedID)] } {
    puts $fout "
  int [set base]ID = 1;
  if (getenv(\"LSST_[string toupper [set base]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set base]]_ID\"),\"%d\",&[set base]ID);
  \}
  SAL_[set base] mgr = SAL_[set base]([set base]ID);"
  } else {
    puts $fout "  SAL_[set base] mgr = SAL_[set base]();"
  }
  puts $fout "
  os_time delay_10ms = \{ 0, 10000000 \};
  int status=0;

  while (1) \{
     status = mgr.commandAvailable();
     if (status != SAL__NO_UPDATES) \{ 
"
   foreach j $ptypes {
     set topic [lindex $j 2]
     set type [lindex [split $topic _] 0] 
     if { $type == "command" && $topic != "command" } {
        set name [string range $topic 8 end]
        puts $fout "
       if (status == SAL__[set base]_[set topic]_ACTOR) \{
         [set base]_[set topic]C myData_[set topic];
         status=mgr.acceptCommand_[set name](&myData_[set topic]);
         mgr.ackCommand_[set name](status, SAL__CMD_COMPLETE, 0, \"Done : OK\");
         cout << \"Got $base $topic sample\" << endl;
       \}
"
     }
   }
   puts $fout "
     \}
     os_nanoSleep(delay_10ms);
  \}

  /* Remove the DataWriters etc */
  mgr.salShutdown();

  return 0;
\}

int main (int argc, char *argv[])
\{
  return test_[set base]_command_reader();
\}
"
   close $fout
}


#
## Documented proc \c creategenericreaders .
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates applications to read Subsystem/CSC Topic data
#
proc creategenericreaders { base } {
   gentelemetryreader $base
   gencommandreader   $base
   geneventreader     $base
}



