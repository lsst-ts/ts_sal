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
# \param[in] ctype code fragment type
#
#  Generates a code fragment to use the SAL API to read Topic data
#
proc genericreaderfragment { fout base name ctype } {
   puts $fout "
salReturn SAL_[set base]::[set name]Available () \{
  int status = -1;
  DataReader_var dreader = NULL;
  unsigned int numsamp = 0;
  int actorIdx = 0;
"
   if { $ctype == "init" } {
      puts $fout "
  const RdKafka::Headers *headers;
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
      puts $fout "  return SAL__NO_UPDATES;"
      puts $fout "\}"
   }
}


proc readerFragment { fout base name } {
global AVRO_PREFIX
     puts $fout "   numSamples = 0;"
     puts $fout "   std::string errstr;"
     puts $fout "   if ( strcmp(\"[set name]\",\"ackcmd\") == 0) \{"
     puts $fout "      actorIdx = SAL__[set base]_ackcmd_ACTOR;"
     puts $fout "   \} else \{"
     puts $fout "      actorIdx = SAL__[set base]_[set name]_ACTOR;"
     puts $fout "   \}"
     puts $fout "   RdKafka::Message *message = sal\[actorIdx\].subscriber->consume(1);"
     puts $fout "   int len = static_cast<int> (message->len());"
     puts $fout "   switch (message->err()) \{"
     puts $fout "   case RdKafka::ERR__TIMED_OUT:"
     puts $fout "   \{"
     puts $fout "    break;"
     puts $fout "   \}"
     puts $fout ""
     puts $fout "   case RdKafka::ERR_NO_ERROR:"
     puts $fout "   \{"
     puts $fout "    /* Read message */"
     puts $fout "   const uint8_t* payload = (const uint8_t*) message->payload();"
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
     puts $fout "         printf(\" Header: %s = %i, %s\", hdr.key().c_str(),"
     puts $fout "                (int)hdr.value_size(), (const char *)hdr.value());"
     puts $fout "        else"
     puts $fout "         printf(\" Header:  %s = NULL\\n\", hdr.key().c_str());"
     puts $fout "      \}"
     puts $fout "     \}"
     puts $fout "   \}"
     puts $fout "   if (debugLevel > 1) \{" 
     puts $fout "      printf(\"Got message for Actor %d [set name] , length %d\\n\", actorIdx, static_cast<int>(message->len()));"
     puts $fout "   \}"
     puts $fout "    payload += 5;"
     puts $fout "    len -= 5;"
     puts $fout "    auto avro_schema = sal\[actorIdx\].avroSchema->object();"
     puts $fout "    std::unique_ptr<avro::InputStream> in_[set name] = avro::memoryInputStream((const uint8_t*) payload, len);"
     puts $fout "    avro::DecoderPtr bd = avro::validatingDecoder(*avro_schema, avro::binaryDecoder());"
     puts $fout "    bd->init(*in_[set name]);"
     puts $fout "    avro::decode(*bd, Instance);"
     puts $fout "    std::cout << std::setprecision (17)<< \"Private_sndStamp = \" << Instance.private_sndStamp << std::endl;"
     puts $fout "    numSamples = 1;"
     puts $fout "    break;"
     puts $fout ""
     puts $fout "   \}"
     puts $fout ""
     puts $fout "    case RdKafka::ERR__UNKNOWN_TOPIC:"
     puts $fout "   \{"
     puts $fout "   \}"
     puts $fout ""
     puts $fout "    case RdKafka::ERR__UNKNOWN_PARTITION:"
     puts $fout "   \{"
     puts $fout "     std::cerr << \"Consume failed: \" << message->errstr() << std::endl;"
     puts $fout "     break;"
     puts $fout ""
     puts $fout "   \}"
     puts $fout ""
     puts $fout "    default:"
     puts $fout "   \{"
     puts $fout "     /* Errors */"
     puts $fout "      std::cerr << \"Consume failed: \" << message->errstr() << std::endl;"
     puts $fout "     break;"
     puts $fout "   \}"
     puts $fout "  \}"
     puts $fout "  delete message;"
}

proc writerFragment { fout base name } {
global AVRO_PREFIX
  puts $fout "     auto avro_schema = sal\[actorIdx\].avroSchema->object();"
  puts $fout "     avro::EncoderPtr e = avro::validatingEncoder(*avro_schema, avro::binaryEncoder());"
  puts $fout "     const avro::OutputStreamPtr out = avro::memoryOutputStream();"
  puts $fout "     e->init(*out.get());"
  puts $fout "     unsigned long outsize;"
  puts $fout "     avro::encode(*e,Instance);"
  puts $fout "     std::vector<char> buffer;"
  puts $fout "     auto v = avro::snapshot(*out.get());"
  puts $fout "     sal\[actorIdx\].avroSchema->framing_write(buffer);"
  puts $fout "     buffer.insert(buffer.end(), v->begin(), v->end());"
  puts $fout "     outsize = buffer.size();"
  puts $fout "     std::string idname = \"\{\\\"name\\\":\\\"\" + std::string(CSC_identity) + \"\\\",\";"
  puts $fout "     std::string ts = sal\[actorIdx\].topicName;"
  puts $fout "     std::string tname = \"\\\"topic\\\":\\\"\" + ts + \"\\\"\";"
  puts $fout "     std::string cbrk = \"\}\";"
  puts $fout "#ifdef SAL_SUBSYSTEM_IS_KEYED"
  puts $fout "     std::string ixname = \"\\\"index\\\":\\\"\" + std::to_string(salIndex) + \"\\\",\";"
  puts $fout "     std::string topicKey = idname + ixname + tname + cbrk;"
  puts $fout "#else"
  puts $fout "     std::string topicKey = idname + tname + cbrk;"
  puts $fout "#endif"
  puts $fout "     RdKafka::Headers *headers = RdKafka::Headers::create();"
  puts $fout "     RdKafka::ErrorCode resp;"
  puts $fout "     if (sal\[actorIdx\].cmdevt) \{"
  puts $fout "       resp ="
  puts $fout "           publisherCmdEvt->produce(sal\[actorIdx\].avroName, RdKafka::Topic::PARTITION_UA,"
  puts $fout "                                 RdKafka::Producer::RK_MSG_COPY /* Copy payload */,"
  puts $fout "                                 buffer.data(), outsize,"
  puts $fout "                                 topicKey.c_str(), topicKey.size() , 0, headers);"
  puts $fout "     \} else \{"
  puts $fout "       resp ="
  puts $fout "           publisher->produce(sal\[actorIdx\].avroName, RdKafka::Topic::PARTITION_UA,"
  puts $fout "                                 RdKafka::Producer::RK_MSG_COPY /* Copy payload */,"
  puts $fout "                                 buffer.data(), outsize,"
  puts $fout "                                 NULL, 0, 0, headers);"
  puts $fout "     \}"
  puts $fout "     if (resp != RdKafka::ERR_NO_ERROR) \{"
  puts $fout "       std::cerr << \"% Produce failed: \" << RdKafka::err2str(resp)"
  puts $fout "                 << std::endl;"
  puts $fout "       delete headers; /* Headers are automatically deleted on produce()"
  puts $fout "                              * success. */"
  puts $fout "     \} else \{"
  puts $fout "       if (debugLevel >1) \{"
  puts $fout "         std::cout << \"% Produced message (\" << topicKey << \":\" << outsize << \") bytes)\""
  puts $fout "                 << std::endl;"
  puts $fout "       \}"
  puts $fout "     \}"
  puts $fout "     if (sal\[actorIdx\].cmdevt) \{"
  puts $fout "       publisherCmdEvt->poll(0);"
  puts $fout "       if (cmdevtFlushMS > 0) \{"
  puts $fout "         publisherCmdEvt->flush(cmdevtFlushMS);"
  puts $fout "       \}"
  puts $fout "     \} else \{"
  puts $fout "       publisher->poll(0);"
  puts $fout "       if (telemetryFlushMS > 0) \{"
  puts $fout "         publisher->flush(telemetryFlushMS);"
  puts $fout "       \}"
  puts $fout "     \}"
}

proc writerFragmentAck { fout base name } {
global AVRO_PREFIX
  puts $fout "     auto avro_schema = sal\[actorIdx\].avroSchema->object();"
  puts $fout "     avro::EncoderPtr e = avro::validatingEncoder(*avro_schema, avro::binaryEncoder());"
  puts $fout "     const avro::OutputStreamPtr out = avro::memoryOutputStream();"
  puts $fout "     e->init(*out.get());"
  puts $fout "     unsigned long outsize;"
  puts $fout "     avro::encode(*e,ackdata);"
  puts $fout "     std::vector<char> buffer;"
  puts $fout "     auto v = avro::snapshot(*out.get());"
  puts $fout "     sal\[actorIdx\].avroSchema->framing_write(buffer);"
  puts $fout "     buffer.insert(buffer.end(), v->begin(), v->end());"
  puts $fout "     outsize = buffer.size();"
  puts $fout "     std::string idname = \"\{\\\"name\\\":\\\"\" + std::string(CSC_identity) + \"\\\",\";"
  puts $fout "     std::string ts = sal\[actorIdx\].topicName;"
  puts $fout "     std::string tname = \"\\\"topic\\\":\\\"\" + ts + \"\\\"\";"
  puts $fout "     std::string cbrk = \"\}\";"
  puts $fout "#ifdef SAL_SUBSYSTEM_IS_KEYED"
  puts $fout "     std::string ixname = \"\\\"index\\\":\\\"\" + std::to_string(salIndex) + \"\\\",\";"
  puts $fout "     std::string topicKey = idname + ixname + tname + cbrk;"
  puts $fout "#else"
  puts $fout "     std::string topicKey = idname + tname + cbrk;"
  puts $fout "#endif"
  puts $fout "     RdKafka::Headers *headers = RdKafka::Headers::create();"
  puts $fout "     RdKafka::ErrorCode resp ="
  puts $fout "           publisherCmdEvt->produce(sal\[actorIdx\].avroName, RdKafka::Topic::PARTITION_UA,"
  puts $fout "                                 RdKafka::Producer::RK_MSG_COPY /* Copy payload */,"
  puts $fout "                                 buffer.data(), outsize,"
  puts $fout "                                 topicKey.c_str(), topicKey.size() , 0, headers);"
  puts $fout "     if (resp != RdKafka::ERR_NO_ERROR) \{"
  puts $fout "       std::cerr << \"% Produce failed: \" << RdKafka::err2str(resp)"
  puts $fout "                 << std::endl;"
  puts $fout "       delete headers; /* Headers are automatically deleted on produce()"
  puts $fout "                              * success. */"
  puts $fout "     \} else \{"
  puts $fout "       if (debugLevel >1) \{"
  puts $fout "         std::cout << \"% Produced ack message (\" << topicKey << \":\" << outsize << \" bytes)\""
  puts $fout "                 << std::endl;"
  puts $fout "       \}"
  puts $fout "     \}"
  puts $fout "     publisherCmdEvt->poll(0);"
  puts $fout "     if (cmdevtFlushMS > 0) \{"
  puts $fout "        publisherCmdEvt->flush(cmdevtFlushMS);"
  puts $fout "     \}"
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
  delay_10ms.tv_sec = 0;
  delay_10ms.tv_nsec = 10000000;
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
  delay_10ms.tv_sec = 0;
  delay_10ms.tv_nsec = 10000000;
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
  delay_10ms.tv_sec = 0;
  delay_10ms.tv_nsec = 10000000;
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
     nanosleep(&delay_10m,NULL);
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



