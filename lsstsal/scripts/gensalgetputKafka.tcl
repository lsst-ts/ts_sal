#!/usr/bin/env tclsh
## \file gensalgetputKafka.tcl
# \brief Generate SALKAFKA methods for getSample and putSample for all types
# and generate salTypeSupport routine
#
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

source $env(SAL_DIR)/geneventaliascodeKafka.tcl
source $env(SAL_DIR)/gencmdaliascodeKafka.tcl
source $env(SAL_DIR)/gengenericreaderKafka.tcl
source $env(SAL_DIR)/gensalintrospectKafka.tcl
source $env(SAL_DIR)/activaterevcodesKafka.tcl
source $env(SAL_DIR)/gentelemetrytestssinglefileKafka.tcl
source $env(SAL_DIR)/gentelemetrytestssinglefilejavaKafka.tcl

#
## Documented proc \c insertcfragments .
# \param[in] fout File handle of output file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Name of SAL Topic
#
#  Generate the include file code for the SAL C++ API
#
proc insertcfragments { fout base name } {
global SAL_WORK_DIR OPTIONS
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> insertcfragments $fout $base $name"}
   if { $name == "command" || $name == "ackcmd" || $name == "logevent" || $name == "notused" } {return}
   set revcode [getRevCode [set base]_[set name] short]
   puts stdout "Processing topic $name , revcode = $revcode"
   puts $fout "
salReturn SAL_[set base]::putSample_[set name]([set base]_[set name]C *data)
\{
  int actorIdx = SAL__[set base]_[set name]_ACTOR;
  [set base]::[set name] Instance;
  if ( data == NULL ) \{
     throw std::runtime_error(\"NULL pointer for putSample_[set name]\");
  \}"
  set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]Cchk.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  puts $fout "
  Instance.private_revCode = \"[string trim $revcode _]\";
  Instance.private_sndStamp = getCurrentTime();
  Instance.private_efdStamp = getCurrentUTC();
  Instance.private_kafkaStamp = getCurrentTime();
  sal\[actorIdx\].sndStamp = Instance.private_sndStamp;
  Instance.private_identity = CSC_identity;
  Instance.private_origin = getpid();
  Instance.private_seqNum = sal\[actorIdx\].sndSeqNum;
  sal\[actorIdx\].sndSeqNum++;
   "
  set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]Cput.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  puts $fout "

  if (debugLevel > 0) \{
    cout << \"=== \[putSample\] [set base].[set name] writing a message containing :\" << endl;
    cout << \"    revCode  : \" << Instance.private_revCode << endl;
  \}
  Instance.private_sndStamp = getCurrentTime();
  Instance.private_efdStamp = getCurrentUTC();
  Instance.private_kafkaStamp = getCurrentTime();"
    writerFragment $fout $base [set base]_[set name]
      puts $fout "
  return status;
\}

salReturn SAL_[set base]::getSample_[set name]([set base]_[set name]C *data)
\{
  int numSamples = 0;
  salReturn istatus = -1;
  [set base]::[set name] Instance;

  if ( data == NULL ) \{
     throw std::runtime_error(\"NULL pointer for getSample_[set name]\");
  \}
  int actorIdx = SAL__[set base]_[set name]_ACTOR;"
     readerFragment $fout $base $name
     puts $fout "
  for (int j = 0; j < numSamples; j++)
  \{
    rcvdTime = getCurrentTime();
    sal\[actorIdx\].rcvStamp = rcvdTime;
    sal\[actorIdx\].sndStamp = Instance.private_sndStamp;
    if (debugLevel > 8) \{
      cout << \"=== \[GetSample\] message received :\" << numSamples << endl;
      cout << \"    revCode  : \" << Instance.private_revCode << endl;
      cout << \"    sndStamp  : \" << Instance.private_sndStamp << endl;
      cout << \"    origin  : \" << Instance.private_origin << endl;
      cout << \"    identity  : \" << Instance.private_identity << endl;
      double latency = (rcvdTime - Instance.private_sndStamp)*1000.0;
      cout << \"    latency (ms)  : \" << latency << endl;
    \}
    if ( (rcvdTime - Instance.private_sndStamp) < sal\[actorIdx\].sampleAge && Instance.private_origin != 0 ) \{
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
    data->salIndex = Instance.salIndex;
    data->private_rcvStamp = rcvdTime;
#endif
"
  set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]Cget.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  if { [lindex [split $name _] 0] == "command" } {
    puts $fout "     istatus = Instance.private_seqNum;"
  } else {
    puts $fout "     istatus = SAL__OK;"
  }
  puts $fout "
   \} else \{
     istatus = SAL__NO_UPDATES;
   \}
  \}
  if ( numSamples == 0 ) \{
     istatus = SAL__NO_UPDATES;
     return istatus;
  \}
  return istatus;
\}

salReturn SAL_[set base]::getNextSample_[set name]([set base]_[set name]C *data)
\{
    int saveMax = sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples;
    salReturn istatus = -1;
    sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples = 1;
    istatus = getSample_[set name](data);
    sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples = saveMax;
    return istatus;
\}

salReturn SAL_[set base]::getLastSample_[set name]([set base]_[set name]C *data)
\{
    salReturn istatus = -1;
    istatus = getSample_[set name](data);
    if (istatus == SAL__NO_UPDATES) \{"
  set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]LCget.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  puts $fout "
    \}
    return SAL__OK;
\}


salReturn SAL_[set base]::flushSamples_[set name]([set base]_[set name]C *data)
\{
    salReturn istatus;
    sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples = 1000;
    sal\[SAL__[set base]_[set name]_ACTOR\].sampleAge = -1.0;
    istatus = getSample_[set name](data);
    if (debugLevel > 8) \{
        cout << \"=== \[flushSamples\] getSample returns :\" << istatus << endl;
    \}
    sal\[SAL__[set base]_[set name]_ACTOR\].sampleAge = 1.0e20;
    return SAL__OK;
\}
"
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< insertcfragments $fout $base $name"}
}

#
## Documented proc \c testifdef .
#
#  Process a Java file to replace #ifdef regions
#
proc testifdef { } {
global SYSDIC
  set SYSDIC(hexapod,keyedID) 1
  set fin [open SALKAFKA.java.template r]
  set fout [open SALKAFKA.java.ifdefd w]
  while { [gets $fin rec] > -1 } {
     if { [string range $rec 0 31] == "#ifdef SAL_SUBSYSTEM_ID_IS_KEYED" } {
         processifdefregion $fin $fout hexapod
     } else {
         puts $fout $rec
     }
  }
  close $fin
  close $fout
}


#
## Documented proc \c processifdefregion .
# \param[in] fin File handle of input file
# \param[in] fout File handle of output file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Process a Java file to replace #ifdef regions by
#  adding code for the sections required to process
#  Topics with key's (ie more than one instance is allowed)
#
proc processifdefregion { fin fout base } {
global SYSDIC
   if { [info exists SYSDIC($base,keyedID)] } {
      gets $fin rec
      while { $rec != "#endif" && $rec != "#else" } {
           puts $fout $rec
           gets $fin rec
      }
      while { $rec != "#endif" } {gets $fin rec}
   } else {
      gets $fin rec
      while { $rec != "#endif" && $rec != "#else" } {gets $fin rec}
      while { $rec != "#endif" } {
          gets $fin rec
          if { $rec != "#endif" } {puts $fout $rec}
      }
   }
}

#
## Documented proc \c addSWVersionsCPP .
# \param[in] fout File handle of output file
#
#  Add software versioning routines to CPP API for
#  getSALVersion,getXMLVersion,getKAFKAVersion
#
proc addSWVersionsCPP { fout } {
global SALVERSION XMLVERSION AVRO_RELEASE OSPL_RELEASE env
  puts $fout "
string SAL_SALData::getSALVersion()
\{
    return \"$SALVERSION\";
\}

string SAL_SALData::getXMLVersion()
\{
    return \"$XMLVERSION\";
\}

string SAL_SALData::getKAFKAVersion()
\{
     string kafkaversion;
     char *kafkarelease = getenv(\"KAFKA_RELEASE\");
     if (kafkarelease == NULL) \{
        throw std::runtime_error(\"getKAFKAVersion failed: KAFKA_RELEASE environment not setup\");
     \}
     kafkaversion = kafkarelease;
     return kafkaversion;
\}

string SAL_SALData::getOSPLVersion()
\{
    return \"$OSPL_RELEASE\";
\}

string SAL_SALData::getAVROVersion()
\{
    return \"$AVRO_RELEASE\";
\}
"
}

#
## Documented proc \c addSWVersionsJava .
# \param[in] fout File handle of output file
#
#  Add software versioning routines to Java API for
#  getSALVersion,getXMLVersion,getKAFKAVersion
#
proc addSWVersionsJava { fout } {
global SALVERSION XMLVERSION AVRO_RELEASE OSPL_RELEASE env
  puts $fout "
/// Returns the current SAL version e.g. \"4.1.0\"
public String getSALVersion()
\{
    return \"$SALVERSION\";
\}

/// Returns the current XML version e.g. \"5.0.0\"
public String getXMLVersion()
\{
    return \"$XMLVERSION\";
\}

/// Returns the current Kafka version e.g. \"2.0.0\"
public String getKAFKAVersion()
\{
  String kafkarelease = System.getenv(\"KAFKA_RELEASE\");
    if (kafkarelease == null) \{
      System.out.println(\"Error in getKafkaVersion: KAFKA_RELEASE environment not setup\");
      System.exit(-1);
    \}
    return kafkarelease;
\}

public String getOSPLVersion()
\{
    return \"$OSPL_RELEASE\";
\}

public String getAVROVersion()
\{
    return \"$AVRO_RELEASE\";
\}
"
}



#
## Documented proc \c addActorIndexesCPP .
# \param[in] jsonfile Name of input schema definition file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#   Add code to support salActor data structure initialization in C++
#
proc addActorIndexesCPP { base fout } {
global SAL_WORK_DIR ACTIVETOPICS AVRO_PREFIX
   set idx 0
   set fact [open $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base]_actors.h w]
   foreach name $ACTIVETOPICS {
      puts $fact "#define SAL__[set base]_[set name]_ACTOR  $idx"
      incr idx 1
   }
   close $fact
   puts $fout "void SAL_SALData::initSalActors ()"
   puts $fout "\{"
   puts $fout "    for (int i=0; i<SAL__ACTORS_MAXCOUNT;i++) \{"
   puts $fout "      sal\[i\].isReader = false;"
   puts $fout "      sal\[i\].isWriter = false;"
   puts $fout "      sal\[i\].isCommand = false;"
   puts $fout "      sal\[i\].isEventReader = false;"
   puts $fout "      sal\[i\].isProcessor = false;"
   puts $fout "      sal\[i\].isEventReader = false;"
   puts $fout "      sal\[i\].isEventWriter = false;"
   puts $fout "      sal\[i\].isActive = false;"
   puts $fout "      sal\[i\].maxSamples = 1000;"
   puts $fout "      sal\[i\].sampleAge = 1.0e20;"
   puts $fout "      sal\[i\].hasSchema = true;"
   puts $fout "      sal\[i\].historyDepth = 100;" 
   puts $fout "    \}"
   set idx 0
   foreach name $ACTIVETOPICS {
      set type [lindex [split $name _] 0]
      set revcode [getRevCode [set base]_[set name] short]
      puts $fout "    strcpy(sal\[$idx\].topicHandle,\"[set base]_[set name][set revcode]\");"
      puts $fout "    strcpy(sal\[$idx\].topicName,\"[set base]_[set name]\");"
      puts $fout "    sal\[$idx\].avroName = \"[getAvroNamespace][set base].[set name]\";"
      if { $type == "logevent" } {
        puts $fout "   sal\[$idx\].historyDepth=1;"
      }
      if { $base == "Test" } {
        puts $fout "   sal\[$idx\].historyDepth=5000;"
      }
      incr idx 1
   }
  puts $fout "\}"
}

#
## Documented proc \c addActorIndexesJava .
# \param[in] jsonfile Name of input schema definition file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#   Add code to support salActor data structure initialization in Java
#
proc addActorIndexesJava { base fout } {
global ACTIVETOPICS env AVRO_PREFIX
   set idx 0
   foreach name $ACTIVETOPICS {
      set type [lindex [split $name _] 0]
      puts $fout "  public static final int SAL__[set base]_[set name]_ACTOR = $idx;"
      incr idx 1
   }
   puts $fout " public static final int SAL__ACTORS_MAXCOUNT = $idx;"
   puts $fout ""
   puts $fout "  public void initSalActors ()"
   puts $fout "  \{"
   puts $fout "     int status=-1;"
   puts $fout "     int idx;"
   puts $fout ""
   set idx 0
   foreach name $ACTIVETOPICS {
      set type [lindex [split $name _] 0]
      set revcode [getRevCode [set base]_[set name] short]
      puts $fout "    sal\[$idx\]=new salActor();" 
      puts $fout "    sal\[$idx\].topicHandle=\"[set base]_[set name][set revcode]\";"
      puts $fout "    sal\[$idx\].topicName=\"[set base]_[set name]\";"
      puts $fout "    sal\[$idx\].avroName = \"[getAvroNamespace][set base].[set name]\";"
      if { $type == "logevent" || $type == "command" || $type == "ackcmd" } {
        puts $fout "    sal\[$idx\].topicType=\"[set type]\";"
      } else {
        puts $fout "    sal\[$idx\].topicType=\"telemetry\";"
      }
      if { $type == "logevent" } {
        puts $fout "   sal\[$idx\].historyDepth=1;"
      }
      if { $base == "Test" } {
        puts $fout "   sal\[$idx\].historyDepth=5000;"
      }
      incr idx 1
   }
   puts $fout "  \}"
}

#
## Documented proc \c copyfromjavasample .
# \param[in] fout File handle of output file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Name of of SAL Topic
#
#   Add code to copy data from Java Kafka sample
#
proc copyfromjavasample { fout base name } {
global CMDS TLMS EVTS
        set ctype [string range $name 0 7]
        if { $ctype != "logevent" && $ctype != "command_" } {
         if { [info exists TLMS($base,$name,param)] } {
          foreach p $TLMS($base,$name,param) {
             set tpar [lindex [string trim $p "\{\}"]]
             if { [lindex $tpar 0] == "unsigned" } {
             set apar [lindex [split [lindex $tpar 2] "()"] 0]
               } else {
             set apar [lindex [split [lindex $tpar 1] "()"] 0]
               }
             set arr [lindex [split $p "()"] 1]
             set avgname get[getAvroMethod $apar]()
             set avsname set[getAvroMethod $apar]
             if { $arr != "" } {
               puts $fout "           data.$avsname\(Instance.$avgname\);"
             } else {
                puts $fout "          data.$avsname\(Instance.$avgname\);"
             }
          }
         }
        }
        set alias [string range $name 9 end]
        if { $ctype == "logevent" } {
         if { [info exists EVTS($base,$alias,param)] } {
          foreach p $EVTS($base,$alias,param) {
                    set tpar [lindex [string trim $p "\{\}"]]
                    if { [lindex $tpar 0] == "unsigned" } {
                set apar [lindex [split [lindex $tpar 2] "()"] 0]
                    } else {
                set apar [lindex [split [lindex $tpar 1] "()"] 0]
                    }
            set arr [lindex [split $p "()"] 1]
            set avgname get[getAvroMethod $apar]()
            set avsname set[getAvroMethod $apar]
            if { $arr != "" } {
               puts $fout "           data.$avsname\(Instance.$avgname\);"
            } else {
               puts $fout "           data.$avsname\(Instance.$avgname\);"
            }
          }
         }
        }
        set alias [string range $name 8 end]
        if { $ctype == "command_" } {
         if { [info exists CMDS($base,$alias,param)] } {
          foreach p $CMDS($base,$alias,param) {
                    set tpar [lindex [string trim $p "\{\}"]]
                    if { [lindex $tpar 0] == "unsigned" } {
                set apar [lindex [split [lindex $tpar 2] "()"] 0]
                    } else {
                set apar [lindex [split [lindex $tpar 1] "()"] 0]
                    }
            set avgname get[getAvroMethod $apar]()
            set avsname set[getAvroMethod $apar]
            set arr [lindex [split $p "()"] 1]
            if { $arr != "" } {
               puts $fout "           data.$avsname\(Instance.$avgname\);"
            } else {
               puts $fout "           data.$avsname\(Instance.$avgname\);"
            }
          }
         }
        }
}

#
## Documented proc \c copytojavasample .
# \param[in] fout File handle of output file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Name of of SAL Topic
#
#   Add code to copy data into Java Kafka sample
#
proc copytojavasample { fout base name } {
global CMDS TLMS EVTS
        set ctype [string range $name 0 7]
         if { $ctype != "logevent" && $ctype != "command_" } {
         if { [info exists TLMS($base,$name,param)] } {
          foreach p $TLMS($base,$name,param) {
                    set tpar [lindex [string trim $p "\{\}"]]
                    if { [lindex $tpar 0] == "unsigned" } {
                set apar [lindex [split [lindex $tpar 2] "()"] 0]
                    } else {
                set apar [lindex [split [lindex $tpar 1] "()"] 0]
                    }
            set avgname get[getAvroMethod $apar]()
            set avsname set[getAvroMethod $apar]
            set arr [lindex [split $p "()"] 1]
            if { $arr != "" } {
              puts $fout "           Instance.$avsname\(data.$avgname\);"
            } else {
              puts $fout "           Instance.$avsname\(data.$avgname\);"
            }
          }
         }
        }
        set alias [string range $name 9 end]
        if { $ctype == "logevent" } {
         if { [info exists EVTS($base,$alias,param)] } {
          foreach p $EVTS($base,$alias,param) {
                    set tpar [lindex [string trim $p "\{\}"]]
                    if { [lindex $tpar 0] == "unsigned" } {
                set apar [lindex [split [lindex $tpar 2] "()"] 0]
                    } else {
                set apar [lindex [split [lindex $tpar 1] "()"] 0]
                    }
            set avgname get[getAvroMethod $apar]()
            set avsname set[getAvroMethod $apar]
            set arr [lindex [split $p "()"] 1]
            if { $arr != "" } {
              puts $fout "           Instance.$avsname\(data.$avgname\);"
            } else {
              puts $fout "           Instance.$avsname\(data.$avgname\);"
            }
          }
         }
        }
        set alias [string range $name 8 end]
        if { $ctype == "command_" } {
         if { [info exists CMDS($base,$alias,param)] } {
          foreach p $CMDS($base,$alias,param) {
                    set tpar [lindex [string trim $p "\{\}"]]
                    if { [lindex $tpar 0] == "unsigned" } {
                set apar [lindex [split [lindex $tpar 2] "()"] 0]
                    } else {
                set apar [lindex [split [lindex $tpar 1] "()"] 0]
                    }
            set avgname get[getAvroMethod $apar]()
            set avsname set[getAvroMethod $apar]
            set arr [lindex [split $p "()"] 1]
            if { $arr != "" } {
              puts $fout "          Instance.$avsname\(data.$avgname\);"
            } else {
              puts $fout "          Instance.$avsname\(data.$avgname\);"
            }
          }
         }
        }
}

proc javaTypeSupport { fout base } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS OPTIONS ACTIVETOPICS AVRO_PREFIX
   puts $fout "/** Configure AVRO type support for [set base] Kafka topics."
   puts $fout "  * @param topicName The Kafka topic name"
   puts $fout "  */"
   puts $fout "public int salTypeSupport(String topicName) \{"
   puts $fout "  String\[\] parts = topicName.split(\"_\");"
   puts $fout "  int actorIdx = getActorIndex(topicName);"
   puts $fout "  if (\"[set base]\".equals(parts\[0\]) ) \{"
   foreach name $ACTIVETOPICS {
     set revcode [getRevCode [set base]_[set name] short]
     puts $fout "   if ( \"$name\".equals(topicName) ) \{"
     puts $fout "//     sal\[actorIdx\].avroSchema = avroMapper.schemaFor([set base]_[set name].class);"
     puts $fout "     return SAL__OK;"
     puts $fout "   \}"
   }
   puts $fout "  \}"
   puts $fout "  return SAL__ERR;"
   puts $fout "\}"
   puts $fout ""
   puts $fout "public int salTypeSupport(int actorIdx) \{"
   foreach name $ACTIVETOPICS {
     set revcode [getRevCode [set base]_[set name] short]
     puts $fout "  if ( actorIdx == SAL__[set base]_[set name]_ACTOR ) \{"
     puts $fout "//    sal\[actorIdx\].avroSchema = avroMapper.schemaFor([set base]_[set name].class);"
     puts $fout "    return SAL__OK;"
     puts $fout "  \}"
   }
   puts $fout "  return SAL__ERR;"
   puts $fout "\}"
   puts $fout ""
}

proc javaputSample { fout base } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS OPTIONS ACTIVETOPICS AVRO_PREFIX
  foreach name $ACTIVETOPICS {
   if { $name != "ackcmd" } {
    set revcode [getRevCode [set base]_[set name] short]
    set alias [string range $name 9 end]
    set turl [getTopicURL $base $name]
    puts $fout "/** Publish a sample of the $turl Kafka topic. A publisher must already have been set up"
    puts $fout "  * @param data The payload of the sample as defined in the XML for SALData"
    puts $fout "  */"
    puts $fout "  public int putSample([getAvroNamespace][set base].[set name] data)"
    puts $fout "  \{"
    puts $fout "    int status = SAL__OK;"
    puts $fout "    [set name] Instance = new [set name]();"
    puts $fout "    int actorIdx = SAL__[set base]_[set name]_ACTOR;"
    puts $fout "    if ( sal\[actorIdx\].isWriter == false ) \{"
    puts $fout "      sal\[actorIdx\].isWriter = true;"
    puts $fout "    \}"
    puts $fout "//   Instance = new GenericData.Record(sal\[actorIdx\].avroSchema);"
    puts $fout "   Instance.set[getAvroMethod private_revCode](\"[string trim $revcode _]\");"
    puts $fout "   Instance.set[getAvroMethod private_sndStamp](getCurrentTime());"
    puts $fout "   Instance.set[getAvroMethod private_efdStamp](getCurrentUTC());"
    puts $fout "   Instance.set[getAvroMethod private_kafkaStamp](getCurrentTime());"
    puts $fout "   Instance.set[getAvroMethod private_identity](CSC_identity);"
    puts $fout "   Instance.set[getAvroMethod private_origin](origin);"
    puts $fout "   Instance.set[getAvroMethod private_SeqNum](sal\[actorIdx\].sndSeqNum);"
    puts $fout "   sal\[actorIdx\].sndSeqNum++;"
    puts $fout "   if (debugLevel > 0) \{"
    puts $fout "     System.out.println(\"=== putSample $name writing a message containing :\");"
    puts $fout "     System.out.println(\"  revCode  : \" + Instance.get[getAvroMethod private_revCode]());"
    puts $fout "     System.out.println(\"  sndStamp  : \" + Instance.get[getAvroMethod private_sndStamp]());"
    puts $fout "     System.out.println(\"  identity : \" + Instance.get[getAvroMethod private_identity]());"
    puts $fout "   \}"
    copytojavasample $fout $base $name
    if { [info exists SYSDIC($base,keyedID)] } {
      puts $fout "    Instance.set[getAvroMethod salIndex](subsystemID);"
    }
    writerFragmentJava $fout $base $name
    puts $fout "    return status;"
    puts $fout "  \}"
   }
  }
}

proc javagetSample { fout base } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS OPTIONS ACTIVETOPICS AVRO_PREFIX
  foreach name $ACTIVETOPICS {
   if { $name != "ackcmd" } {
    set revcode [getRevCode [set base]_[set name] short]
    set alias [string range $name 9 end]
    set turl [getTopicURL $base $name]
    puts $fout "/** Receive the latest sample of the $turl Kafka topic. A subscriber must already have been set up."
    puts $fout "  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned."
    puts $fout "  * If there are multiple samples in the history cache, they are skipped over and only the most recent is supplied."
    puts $fout "  * @param data The payload of the sample as defined in the XML for SALData"
    puts $fout "  */"
    puts $fout "  public int getSample([getAvroNamespace][set base].[set name] data)"
    puts $fout "  \{"
    puts $fout "    int status =  -1;"
    puts $fout "    int last = SAL__NO_UPDATES;"
    puts $fout "    int numsamp = 0;"
    puts $fout "    int actorIdx = SAL__[set base]_[set name]_ACTOR;"
    puts $fout "    if ( sal\[actorIdx\].isReader == false ) \{"
    puts $fout "	    sal\[actorIdx\].isReader = true;"
    puts $fout "    \}"
    readerFragmentJava $fout $base $name
    puts $fout "    if (numsamp > 0) \{"
    puts $fout "       if (debugLevel > 0) \{"
    puts $fout "        for (int i = 0; i < numsamp; i++) \{"
    puts $fout "          System.out.println(\"=== getSample $name message received :\" + i);"
    puts $fout "          System.out.println(\"  revCode  : \" + Instance.get[getAvroMethod private_revCode]());"
    puts $fout "          System.out.println(\"  identity : \" + Instance.get[getAvroMethod private_identity]());"
    puts $fout "          System.out.println(\"  sndStamp  : \" + Instance.get[getAvroMethod private_sndStamp]());"
    puts $fout "        \}"
    puts $fout "       \}"
    puts $fout "       int j=numsamp-1;"
    puts $fout "       double rcvdTime = getCurrentTime();"
    puts $fout "       double dTime = rcvdTime - Instance.get[getAvroMethod private_sndStamp]();"
    puts $fout "       if ( dTime < sal\[actorIdx\].sampleAge ) \{"
    puts $fout "          data.set[getAvroMethod private_sndStamp](Instance.get[getAvroMethod private_sndStamp]());"
    copyfromjavasample $fout $base $name
    puts $fout "          last = SAL__OK;"
    puts $fout "       \} else \{"
    puts $fout "          System.out.println(\"dropped sample : \" + rcvdTime + \" \" + Instance.get[getAvroMethod private_sndStamp]());"
    puts $fout "          last = SAL__NO_UPDATES;"
    puts $fout "       \}"
    puts $fout "    \} else \{"
    puts $fout "          last = SAL__NO_UPDATES;"
    puts $fout "    \}"
    puts $fout "   return last;"
    puts $fout "\}"
   }
  }
}

proc javagetNextFlushSample { fout base } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS OPTIONS ACTIVETOPICS AVRO_PREFIX
  foreach name $ACTIVETOPICS {
   if { $name != "ackcmd" } {
    set revcode [getRevCode [set base]_[set name] short]
    set alias [string range $name 9 end]
    set turl [getTopicURL $base $name]
    puts $fout "/** Receive the next sample of the  Kafka topic from the history cache. "
    puts $fout "  * A subscriber must already have been set up"
    puts $fout "  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned."
    puts $fout "  * If there are multiple samples in the history cache, they are iterated over by consecutive"
    puts $fout "  * calls to getNextSample_[set name]"
    puts $fout "  * @param data The payload of the sample as defined in the XML for SALData"
    puts $fout "  */"
    puts $fout "  public int getNextSample([getAvroNamespace][set base].[set name] data)"
    puts $fout "  \{"
    puts $fout "    int status = -1;"
    puts $fout "    int actorIdx = SAL__[set base]_[set name]_ACTOR;"
    puts $fout "    int saveMax = sal\[actorIdx\].maxSamples;"
    puts $fout "    sal\[actorIdx\].maxSamples = 1;"
    puts $fout "    status = getSample(data);"
    puts $fout "    sal\[actorIdx\].maxSamples = saveMax;"
    puts $fout "    return status;"
    puts $fout "  \}"
    puts $fout ""
    puts $fout "/** Empty the history cache of samples. After this only newly published samples"
    puts $fout "  * will be available to getSample_[set name] or getNextSample_[set name]"
    puts $fout "  */"
    puts $fout "  public int flushSamples([getAvroNamespace][set base].[set name] data)"
    puts $fout "  \{"
    puts $fout "    int status = -1;"
    puts $fout "    int actorIdx = SAL__[set base]_[set name]_ACTOR;"
    puts $fout "    sal\[actorIdx\].maxSamples = 500;"
    puts $fout "    sal\[actorIdx\].sampleAge = -1.0;"
    puts $fout "    status = getSample(data);"
    puts $fout "    sal\[actorIdx\].sampleAge = 1.0e20;"
    puts $fout "    return SAL__OK;"
    puts $fout "  \}"
   }
  }
}

proc cpptypeSupport  { fout base } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS OPTIONS ACTIVETOPICS
  puts $fout " salReturn SAL_[set base]::salTypeSupport(char *topicName)"
  puts $fout " \{"
  foreach name $ACTIVETOPICS {
     puts $fout "  if (strncmp(\"$base\",topicName,[string length $base]) == 0) \{"
     if { $OPTIONS(verbose) } {stdlog "###TRACE--- Processing topic $name"}
     set revcode [getRevCode [set base]_[set name] short]
     puts $fout "    if ( strcmp(\"[set base]_[set name]\",topicName) == 0) \{"
     puts $fout "       return SAL__OK;"
     puts $fout "     \}"
     puts $fout "  \}"
  }
  puts $fout "    return SAL__ERR;"
  puts $fout "  \}"
  puts $fout " salReturn SAL_[set base]::salTypeSupport(int actorIdx)"
  puts $fout "  \{"
  foreach name $ACTIVETOPICS {
    set revcode [getRevCode [set base]_[set name] short]
    puts $fout "    if ( actorIdx == SAL__[set base]_[set name]_ACTOR ) \{"
    puts $fout "      return SAL__OK;"
    puts $fout "    \}"
  }
  puts $fout "  return SAL__ERR;"
  puts $fout "\}"
}

proc cppHeaders  { fouth base name } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS OPTIONS ACTIVETOPICS
  puts $fouth ""
  puts $fouth "/** Publish a sample of the  Kafka topic. A publisher must already have been set up"
  puts $fouth "  * @param data The payload of the sample as defined in the XML for SALData"
  puts $fouth "  */"
  puts $fouth "      salReturn putSample_[set name]([set base]_[set name]C *data);"
  puts $fouth ""
  puts $fouth "/** Receive the latest sample of the Kafka topic. A subscriber must already have been set up."
  puts $fouth "  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned."
  puts $fouth "  * If there are multiple samples in the history cache, they are skipped over and only the most recent is supplied."
  puts $fouth "  * @param data The payload of the sample as defined in the XML for SALData"
  puts $fouth "  */"
  puts $fouth "      salReturn getSample_[set name]([set base]_[set name]C *data);"
  puts $fouth ""
  puts $fouth "/** Receive the next sample of the Kafka topic from the history cache. A subscriber must already have been set up"
  puts $fouth "  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned."
  puts $fouth "  * If there are multiple samples in the history cache, they are iterated over by consecutive calls to getNextSample_[set name]"
  puts $fouth "  * @param data The payload of the sample as defined in the XML for SALData"
  puts $fouth "  */"
  puts $fouth "      salReturn getNextSample_[set name]([set base]_[set name]C *data);"
  puts $fouth ""
  puts $fouth "/** Empty the history cache of samples. After this only newly published samples will be available to getSample_[set name] or "
  puts $fouth "  * getNextSample_[set name]"
  puts $fouth "  */"
  puts $fouth "      salReturn flushSamples_[set name]([set base]_[set name]C *data);"
  puts $fouth ""
  puts $fouth "/** Provides the data from the most recently received sample. This may be a new sample that has not been read before"
  puts $fouth "  * by the caller, or it may be a copy of the last received sample if no new data has since arrived."
  puts $fouth "  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned."
  puts $fouth " * @param data The payload of the sample as defined in the XML for SALData"
  puts $fouth "  */"
  puts $fouth "      salReturn getLastSample_[set name]([set base]_[set name]C *data);"
  puts $fouth "      [set base]_[set name]C lastSample_[set base]_[set name];"
  puts $fouth ""
}


#
## Documented proc \c addSALKAFKAtypes .
# \param[in] id Subsystem identity
# \param[in] lang Language to generate code for (cpp,java)
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates code to publish and subscribe to samples of each type of 
#  SAL Topic for a Subsystem/CSC, getSample,putSample,getNextSample,flushSamples
#  and also code to manage the low level Kafka topic registration and management
#
proc addSALKAFKAtypes { id lang base } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS OPTIONS ACTIVETOPICS
 if { $OPTIONS(verbose) } {stdlog "###TRACE>>>  addSALKAFKAtypes $id $lang $base "}
 if { $lang == "java" } {
  exec cp $SAL_DIR/code/templates/salActorKafka.java [set id]/java/src/org/lsst/sal/salActor.java
  exec cp $SAL_DIR/code/templates/salActorKafka.java [set base]/java/src/org/lsst/sal/salActor.java
  exec cp $SAL_DIR/code/templates/salUtils.java [set id]/java/src/org/lsst/sal/.
  exec cp $SAL_DIR/code/templates/salUtils.java [set base]/java/src/org/lsst/sal/.
  set fin [open $SAL_DIR/code/templates/SALKAFKA.java.template r]
  set fout [open [set base]/java/src/org/lsst/sal/SAL_[set base].java w]
  puts stdout "Configuring [set base]/java/src/org/lsst/sal/SAL_[set base].java"
  while { [gets $fin rec] > -1 } {
     if { [string range $rec 0 20] == "// INSERT SAL IMPORTS" } {
        puts $fout "import org.lsst.sal.SAL_[set base];"
        puts $fout "import org.lsst.sal.salActor;"
        puts $fout "import org.lsst.sal.salUtils;"
        puts $fout "import [getAvroNamespace][set base].*;"
     }
     if { [string range $rec 0 31] == "#ifdef SAL_SUBSYSTEM_ID_IS_KEYED" } {
         processifdefregion $fin $fout $base
     }
     if { [string range $rec 0 21] == "// INSERT TYPE SUPPORT" } {
        addActorIndexesJava $base $fout
        addSWVersionsJava $fout
        javaTypeSupport $fout $base
        javaputSample $fout $base
        javagetSample $fout $base
        javagetNextFlushSample $fout $base
        gencmdaliascode $base java $fout
        geneventaliascode $base java $fout
     } else {
        if { [string range $rec 0 5] != "#ifdef" } {
          puts $fout $rec
        }
     }
  }
  close $fin
  close $fout
  exec cp [set base]/java/src/org/lsst/sal/SAL_[set base].java [set id]/java/src/org/lsst/sal/SAL_[set base].java 
 }
 if { $lang == "cpp" } {
  set finh [open $SAL_DIR/code/templates/SALKAFKA.h.template r]
  set fouth [open $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base].h w]
  set rec ""
  while { [string range $rec 0 21] != "// INSERT TYPE SUPPORT" } {
     if { [string range $rec 0 22] == "// INSERT TYPE INCLUDES" } {
       gets $finh rec ; puts $fouth $rec
###       puts $fouth "using namespace avro"
       foreach name $ACTIVETOPICS {
          puts $fouth "#include \"[set base]_[set name].hh\""
       }
     } else {
       gets $finh rec
       puts $fouth $rec
     }
  }
  set fin [open $SAL_DIR/code/templates/SALKAFKA.cpp.template r]
  puts stdout "Configuring [set id]/cpp/src/SAL_[set base].cpp"
  set fout [open $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base].cpp w]
  while { [gets $fin rec] > -1 } {
     if { [string range $rec 0 21] == "// INSERT TYPE SUPPORT" } {
        addActorIndexesCPP $base $fout
        addSWVersionsCPP $fout
        cpptypeSupport $fout $base
        generatetypelists $base $fout
        foreach name $ACTIVETOPICS {
           if { $OPTIONS(verbose) } {stdlog "###TRACE------ Processing topic $name"}
           set revcode [getRevCode [set base]_[set name] short]
           set turl [getTopicURL $base $name]
           cppHeaders $fouth $base $name
           insertcfragments $fout $base $name
        }
        puts stdout "=============================done ACTIVETOPICS"
        gencmdaliascode $base include $fouth
        gencmdaliascode $base cpp $fout
        geneventaliascode $base include $fouth
        geneventaliascode $base cpp $fout
        flush $fout
        flush $fouth
###        gengenericreader $fout $base
     } else {
        puts $fout $rec
     }
  }
  close $fin
  close $fout
  while { [gets $finh rec] > -1 } {puts $fouth $rec}
  close $finh
  close $fouth
 }
 if { $OPTIONS(verbose) } {stdlog "###TRACE<<<  addSALKAFKAtypes $id $lang $base "}
}

proc writerFragmentJava { fout base name } {
global AVRO_PREFIX OPTIONS
 if { $OPTIONS(verbose) } {stdlog "###TRACE>>> writerFragmentJava $base $name "}
   set avroname [set base]_[set name]
   if { $name == "ackcmd" } {
     set avroname "ackcmd"
   }
   puts $fout "  if (sal\[actorIdx\].publisher == null ) \{"
   puts $fout "    Properties props = new Properties();"
   puts $fout "     KafkaProducer<String, [set name]> producer = new KafkaProducer<String, [set name]>(props);"
   puts $fout "     sal\[actorIdx\].publisher = producer;"
   puts $fout "  \}"
   puts $fout "  try \{"
   puts $fout "     publisher.send(new ProducerRecord<String,[set name]>(\"[getAvroNamespace][set base].[set name]\", \"LSST\", Instance));"
   puts $fout "  \} catch (Exception e) \{"
   puts $fout "     System.out.println(\"An error occurred: \" + e.getMessage());"
   puts $fout "  \}"
   puts $fout "  publisher.flush();"
 if { $OPTIONS(verbose) } {stdlog "###TRACE<<< writerFragmentJava $base $name "}
}

proc readerFragmentJava { fout base name } {
global AVRO_PREFIX
   set avroname [set base]_[set name]
   if { $name == "[set base]_ackcmd" } {
     set avroname "ackcmd"
   }
   puts $fout "  String avroTopic = \"[getAvroNamespace][set base].[set name]\";"
    puts $fout "//  if (sal\[actorIdx\].subscriber == null ) \{"
    puts $fout "//     AvroMapper avroMapper = new AvroMapper();"
    puts $fout "//     Schema salschema = avroMapper.schemaFor([set name].class);"
    puts $fout "//     sal\[actorIdx\].avroSchema = salschema;"
    puts $fout "     Properties cprops = new Properties();"
    puts $fout "     KafkaConsumer<String, [set name]> consumer = new KafkaConsumer<>(cprops);"
    puts $fout "     consumer.subscribe(Collections.singletonList(\"[getAvroNamespace][set base].[set name]\"));"
    puts $fout "     sal\[actorIdx\].subscriber = consumer;"
    puts $fout "//  \} else \{"
    puts $fout "//     KafkaConsumer<String, [set name]> consumer = sal\[actorIdx\].subscriber;"
    puts $fout "//  \}"
    puts $fout "  [set name] Instance = new [set name]();"
    puts $fout "  ConsumerRecords<String, [set name]> records = consumer.poll(100);"
    puts $fout "  for (final ConsumerRecord<String, [set name]> record : records) \{"
    puts $fout "    numsamp++;"
    puts $fout "    String key = record.key();"
    puts $fout "    Instance = record.value();"
    puts $fout "    if (debugLevel > 0) \{"
    puts $fout "       System.out.printf(\"key = %s, [set name]\", key);"
    puts $fout "    \}"
    puts $fout "  \}"
}

  
#
## Documented proc \c modpubsubexamples .
# \param[in] id Subsystem identity
#
#  Generate test applcation to publish and subscribe to each type 
#  of SAL Topic defined for a Subsystem/CSC
#
proc modpubsubexamples { id } {
global SAL_DIR SAL_WORK_DIR OPTIONS
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> modpubsubexamples $id"}
  set fin [open $SAL_DIR/code/templates/SALKafkaDataPublisher.cpp.template r]
  set fout [open $SAL_WORK_DIR/[set id]/cpp/src/[set id]DataPublisher.cpp w]
  while { [gets $fin rec] > -1 } {
      puts $fout $rec
      if { [string range $rec 0 17] == "// INSERT_SAL_PUBC" } {
         set frag [open $SAL_WORK_DIR/include/SAL_[set id]Cpub.tmp r]
         while { [gets $frag r2] > -1 } {puts $fout $r2}
         close $frag
      }
  }
  close $fin
  close $fout
  set fin [open $SAL_DIR/code/templates/SALKafkaDataSubscriber.cpp.template r]
  set fout [open $SAL_WORK_DIR/[set id]/cpp/src/[set id]DataSubscriber.cpp w]
  while { [gets $fin rec] > -1 } {
      puts $fout $rec
      if { [string range $rec 0 17] == "// INSERT_SAL_SUBC" } {
         set frag [open $SAL_WORK_DIR/include/SAL_[set id]Csub.tmp r]
         while { [gets $frag r2] > -1 } {puts $fout $r2}
         close $frag
      }
  }
  close $fin
  close $fout
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< modpubsubexamples $id"}
}

