#!/usr/bin/env tclsh
## \file gengenericreaderKafka.tcl
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
  ReturnCode_t status = -1;
  DataReader_var dreader = NULL;
  unsigned int numsamp = 0;
  int actorIdx = 0;
  int lastActor_[set ACTORTYPE] = 0;
"
   }
   if { $ctype == "init" } {
      puts $fout "
  const RdKafka::Headers *headers;
  c::[set name] Instances_[set name];
  avro::DecoderPtr Instance = avro::binaryDecoder();
  Instance->init(*in);
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
      readerFragment $fout $base $name
   }
   if { $ctype == "final" } {
      puts $fout ""
      puts $fout "  lastActor_[set ACTORTYPE] = 0;"
      puts $fout "  return SAL__NO_UPDATES;"
      puts $fout "\}"
   }
}


proc readerFragment { fout base name } {
global ACTORTYPE
     puts $fout "  numSamples = 0"
     puts $fout "  actorIdx = SAL__[set base]_[set name]_ACTOR;"
     puts $fout "  if (actorIdx > lastActor_[set ACTORTYPE]) \{"
     puts $fout "   RdKafka::Message *msg = sal\[actorIdx\].subscriber->consume(sal\[actorIdx\].topicHandle, partition, 1000);"
     puts $fout "   switch (message->err()) \{"
     puts $fout "   case RdKafka::ERR__TIMED_OUT:"
     puts $fout "    break;"
     puts $fout ""
     puts $fout "   case RdKafka::ERR_NO_ERROR:"
     puts $fout "    /* Read message */"
     puts $fout "   if (debugLevel > 1) \{" 
     puts $fout "     std::cout << \"Read msg at offset \" << message->offset() << std::endl;"
     puts $fout "     if (message->key()) \{"
     puts $fout "       std::cout << \"Key: \" << *message->key() << std::endl;"
     puts $fout "     \}"
     puts $fout "   \}"
     puts $fout "   headers = message->headers();"
     puts $fout "   if (headers) \{"
     puts $fout "      std::vector<RdKafka::Headers::Header> hdrs = headers->get_all();"
     puts $fout "     for (size_t i = 0; i < hdrs.size(); i++) \{"
     puts $fout "        const RdKafka::Headers::Header hdr = hdrs\[i\];"
     puts $fout ""
     puts $fout "      if (debugLevel > 1) \{" 
     puts $fout "       if (hdr.value() != NULL)"
     puts $fout "         printf(\" Header: %s = \"%.*s\"\n\", hdr.key().c_str(),"
     puts $fout "                (int)hdr.value_size(), (const char *)hdr.value());"
     puts $fout "        else"
     puts $fout "         printf(\" Header:  %s = NULL\n\", hdr.key().c_str());"
     puts $fout "      \}"
     puts $fout "     \}"
     puts $fout "   \}"
     puts $fout "    printf(\"%.*s\n\", static_cast<int>(message->len()),"
     puts $fout "           static_cast<const char *>(message->payload()));"
     puts $fout "    std::unique_ptr<avro::InputStream> in = avro::memoryInputStream(message->payload());"
     puts $fout "    avro::DecoderPtr d = avro::validatingDecoder(c::[set name], avro::binaryDecoder());"
     puts $fout "    Instance_[set name]->init(*in);"
     puts $fout "    avro::decode(*d, Instance_[set name]);
     puts $fout "    numSamples = 1;"
     puts $fout "    break;"
     puts $fout ""
     puts $fout "    case RdKafka::ERR__UNKNOWN_TOPIC:"
     puts $fout "    case RdKafka::ERR__UNKNOWN_PARTITION:"
     puts $fout "     std::cerr << \"Consume failed: \" << message->errstr() << std::endl;"
     puts $fout "     run = 0;"
     puts $fout "     break;"
     puts $fout ""
     puts $fout "    default:"
     puts $fout "     /* Errors */"
     puts $fout "      std::cerr << \"Consume failed: \" << message->errstr() << std::endl;"
     puts $fout "     run = 0;"
     puts $fout "  \}"
     puts $fout ""
     puts $fout "   if (numSamples > 0) \{"
     puts $fout "      lastActor_[set ACTORTYPE] = actorIdx;"
     puts $fout "       return lastActor_[set ACTORTYPE];"
     puts $fout "    \}"
     puts $fout "  \}"
}

proc writerFragment { fout base name } {
global ACTORTYPE
  puts $fout "     std::unique_ptr<avro::OutputStream> out = avro::memoryOutputStream();"
  puts $fout "     avro::EncoderPtr e = avro::binaryEncoder();"
  puts $fout "     e->init(*out);"
  puts $fout "     avro::encode(*e, NewInstance_[set name]);"
  puts $fout "     RdKafka::Headers *headers = NULL;"
  puts $fout "     RdKafka::ErrorCode resp ="
  puts $fout "           publisher->produce(\"lsst.sal.[set base]_[set name]\", partition,"
  puts $fout "                                 RdKafka::Producer::RK_MSG_COPY /* Copy payload */,"
  puts $fout "                                 out, out.size(),"
  puts $fout "                                 NULL, 0,"
  puts $fout "                                 0,"
  puts $fout "                                 headers,"
  puts $fout "                                 NULL);"
  puts $fout "     if (resp != RdKafka::ERR_NO_ERROR) \{"
  puts $fout "       std::cerr << \"% Produce failed: \" << RdKafka::err2str(resp)"
  puts $fout "                 << std::endl;"
  puts $fout "       delete headers; /* Headers are automatically deleted on produce()"
  puts $fout "                              * success. */"
  puts $fout "     \} else \{"
  puts $fout "       if (debugLevel >1) \{"
  puts $fout "         std::cerr << \"% Produced message (\" << NewInstance_[set name].size() << \" bytes)\""
  puts $fout "                 << std::endl;"
  puts $fout "       \}"
  puts $fout "     \}"
  puts $fout "     publisher.poll(0);"
}


#
## Documented proc \c genericreader .
# \param[in] fout File handle of output C++ file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates an application to use the SAL API to read Topic data
#
proc gengenericreader { fout base } {
global SAL_WORK_DIR ACTIVETOPICS
   genericreaderfragment $fout $base "" telemetry
   foreach fragment "init subscriber reader" {
     foreach topic $ACTIVETOPICS {
       set type [lindex [split $topic _] 0] 
       if { $type != "command" && $type != "logevent" && $type != "ackcmd" } {
          genericreaderfragment $fout $base $topic $fragment
       }
     }
   }
   genericreaderfragment $fout $base "" final
   genericreaderfragment $fout $base "" command
   foreach fragment "init processor reader" {
     foreach topic $ACTIVETOPICS {
       set type [lindex [split $topic _] 0] 
       if { $type == "command" } {
          genericreaderfragment $fout $base $topic $fragment
       }
     }
   }
   genericreaderfragment $fout $base "" final
   genericreaderfragment $fout $base "" event
   foreach fragment "init subscriber reader" {
     foreach topic $ACTIVETOPICS {
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
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic Telemetry reader.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <time.h>
#include \"SAL_[set base].h\"
#include \"ccpp_sal_[set base].h\"
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  int test_[set base]_telemetry_reader();
\}

int test_[set base]_telemetry reader()
\{ "
  if { [info exists SYSDIC($base,keyedID)] } {
    puts $fout "
  int salIndex = 1;
  if (getenv(\"LSST_[string toupper [set base]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set base]]_ID\"),\"%d\",&salIndex);
  \}
  SAL_[set base] mgr = SAL_[set base](salIndex);"
  } else {
    puts $fout "  SAL_[set base] mgr = SAL_[set base]();"
  }
  puts $fout "
  struct timespec delay_10ms;
  delay_1s.tv_sec = 0;
  delay_1s.tv_nsec = 10000000;
  int status=0;

  while (1) \{
     status = mgr.telemetryAvailable();
     if (status != SAL__NO_UPDATES) \{ 
"
   foreach topic $ACTIVETOPICS {
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
     nanosleep(&delay_10ms,NULL);
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
global SAL_WORK_DIR SYSDIC ACTIVETOPICS
   set fout [open $SAL_WORK_DIR/$base/cpp/src/sacpp_[set base]_event_reader.cpp w]
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic event reader.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <time.h>
#include \"SAL_[set base].h\"
#include \"ccpp_sal_[set base].h\"
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  int test_[set base]_event_reader();
\}

int test_[set base]_event_reader()
\{ "
  if { [info exists SYSDIC($base,keyedID)] } {
    puts $fout "
  int salIndex = 1;
  if (getenv(\"LSST_[string toupper [set base]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set base]]_ID\"),\"%d\",&salIndex);
  \}
  SAL_[set base] mgr = SAL_[set base](salIndex);"
  } else {
    puts $fout "  SAL_[set base] mgr = SAL_[set base]();"
  }

  puts $fout "
  struct timespec delay_10ms;
  delay_1s.tv_sec = 0;
  delay_1s.tv_nsec = 10000000;
  int status=0;

  while (1) \{
     status = mgr.eventAvailable();
     if (status != SAL__NO_UPDATES) \{ 
"
   foreach topic $ACTIVETOPICS {
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
     nanosleep(&delay_10ms,NULL);
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
global SAL_WORK_DIR SYSDIC ACTIVETOPICS
   set fout [open $SAL_WORK_DIR/$base/cpp/src/sacpp_[set base]_command_reader.cpp w]
   puts $fout "
/*
 * This file contains the implementation for the [set base] generic command reader.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include <time.h>
#include \"SAL_[set base].h\"
#include \"ccpp_sal_[set base].h\"
using namespace [set base];

/* entry point exported and demangled so symbol can be found in shared library */
extern \"C\"
\{
  int test_[set base]_command_reader();
\}

int test_[set base]_command_reader()
\{ "
  if { [info exists SYSDIC($base,keyedID)] } {
    puts $fout "
  int salIndex = 1;
  if (getenv(\"LSST_[string toupper [set base]]_ID\") != NULL) \{
     sscanf(getenv(\"LSST_[string toupper [set base]]_ID\"),\"%d\",&salIndex);
  \}
  SAL_[set base] mgr = SAL_[set base](salIndex);"
  } else {
    puts $fout "  SAL_[set base] mgr = SAL_[set base]();"
  }
  puts $fout "
  struct timespec delay_10ms;
  delay_1s.tv_sec = 0;
  delay_1s.tv_nsec = 10000000;
  int status=0;

  while (1) \{
     status = mgr.commandAvailable();
     if (status != SAL__NO_UPDATES) \{ 
"
   foreach topic $ACTIVETOPICS {
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
     nanosleep(&delay_10m,NULLs);
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



