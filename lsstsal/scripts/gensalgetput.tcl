#!/usr/bin/env tclsh
## \file gensalgetput.tcl
# \brief Generate SALDDS methods for getSample and putSample for all types
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

source $env(SAL_DIR)/geneventaliascode.tcl
source $env(SAL_DIR)/gencmdaliascode.tcl
source $env(SAL_DIR)/gengenericreader.tcl
source $env(SAL_DIR)/gensalintrospect.tcl
source $env(SAL_DIR)/activaterevcodes.tcl
source $env(SAL_DIR)/gentelemetrytestssinglefile.tcl
source $env(SAL_DIR)/gentelemetrytestssinglefilejava.tcl

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
  if ( data == NULL ) \{
     throw std::runtime_error(\"NULL pointer for putSample_[set name]\");
  \}
  DataWriter_var dwriter = getWriter(actorIdx);
  if ( dwriter == NULL ) \{
     throw std::runtime_error(\"No DataWriter for putSample_[set name]\");
  \}"
  set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]Cchk.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  puts $fout "
  [set base]::[set name][set revcode]DataWriter_var SALWriter = [set base]::[set name][set revcode]DataWriter::_narrow(dwriter.in());
  [set base]::[set name][set revcode] Instance;

  Instance.private_revCode = DDS::string_dup(\"[string trim $revcode _]\");
  Instance.private_sndStamp = getCurrentTime();
  sal\[actorIdx\].sndStamp = Instance.private_sndStamp;
  Instance.private_identity = DDS::string_dup(CSC_identity);
  Instance.private_origin = getpid();
  Instance.private_seqNum = sal\[actorIdx\].sndSeqNum;
  sal\[actorIdx\].sndSeqNum++;
   "
  set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]Cput.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  puts $fout "

  if (debugLevel > 0) \{
    cout << \"=== \[putSample\] [set base]::[set name][set revcode] writing a message containing :\" << endl;
    cout << \"    revCode  : \" << Instance.private_revCode << endl;
  \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   Instance.salIndex = subsystemID;
   InstanceHandle_t dataHandle = SALWriter->register_instance(Instance);
#else
   InstanceHandle_t dataHandle = HANDLE_NIL;
#endif
  Instance.private_sndStamp = getCurrentTime();
  ReturnCode_t status = SALWriter->write(Instance, dataHandle);
  checkStatus(status, \"[set base]::[set name][set revcode]DataWriter::write\");
  return status;
\}

salReturn SAL_[set base]::getSample_[set name]([set base]_[set name]C *data)
\{
  [set base]::[set name][set revcode]Seq Instances;
  SampleInfoSeq_var info = new SampleInfoSeq;
  ReturnCode_t status = -1;
  salReturn istatus = -1;
  unsigned int numsamp = 0;

  if ( data == NULL ) \{
     throw std::runtime_error(\"NULL pointer for getSample_[set name]\");
  \}
  int actorIdx = SAL__[set base]_[set name]_ACTOR;
  DataReader_var dreader = getReader(actorIdx);
  if ( dreader == NULL ) \{
     throw std::runtime_error(\"No DataReader for getSample_[set name]\");
  \}
  [set base]::[set name][set revcode]DataReader_var SALReader = [set base]::[set name][set revcode]DataReader::_narrow(dreader.in());
  checkHandle(SALReader.in(), \"[set base]::[set name][set revcode]DataReader::_narrow\");
  status = SALReader->take(Instances, info, sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples , NOT_READ_SAMPLE_STATE, ANY_VIEW_STATE, ANY_INSTANCE_STATE);
  checkStatus(status, \"[set base]::[set name][set revcode]DataReader::take\");
  numsamp = Instances.length();
  for (DDS::ULong j = 0; j < numsamp; j++)
  \{
    rcvdTime = getCurrentTime();
    sal\[actorIdx\].rcvStamp = rcvdTime;
    sal\[actorIdx\].sndStamp = Instances\[j\].private_sndStamp;
    if (debugLevel > 8) \{
      cout << \"=== \[GetSample\] message received :\" << numsamp << endl;
      cout << \"    revCode  : \" << Instances\[j\].private_revCode << endl;
      cout << \"    sndStamp  : \" << Instances\[j\].private_sndStamp << endl;
      cout << \"    origin  : \" << Instances\[j\].private_origin << endl;
      cout << \"    identity  : \" << Instances\[j\].private_identity << endl;
    \}
    if ( (rcvdTime - Instances\[j\].private_sndStamp) < sal\[actorIdx\].sampleAge && Instances\[j\].private_origin != 0 ) \{
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
    data->salIndex = Instances\[j\].salIndex;
    data->private_rcvStamp = rcvdTime;
#endif
"
  set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]Cget.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  if { [lindex [split $name _] 0] == "command" } {
    puts $fout "     istatus = Instances\[j\].private_seqNum;"
  } else {
    puts $fout "     istatus = SAL__OK;"
  }
  puts $fout "
   \} else \{
     istatus = SAL__NO_UPDATES;
   \}
  \}
  status = SALReader->return_loan(Instances, info);
  checkStatus(status, \"[set base]::[set name][set revcode]DataReader::return_loan\");
  if ( numsamp == 0 ) \{
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
    sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples = LENGTH_UNLIMITED;
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
  set fin [open SALDDS.java.template r]
  set fout [open SALDDS.java.ifdefd w]
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
#  getSALVersion,getXMLVersion,getOSPLVersion
#
proc addSWVersionsCPP { fout } {
global SALVERSION XMLVERSION env
  puts $fout "
string SAL_SALData::getSALVersion()
\{
    return \"$SALVERSION\";
\}

string SAL_SALData::getXMLVersion()
\{
    return \"$XMLVERSION\";
\}

string SAL_SALData::getOSPLVersion()
\{
     string osplversion;
     char *osplrelease = getenv(\"OSPL_RELEASE\");
     if (osplrelease == NULL) \{
        throw std::runtime_error(\"getOSPLVersion failed: OSPL_RELEASE environment not setup\");
     \}
     osplversion = osplrelease;
     return osplversion;
\}
"
}

#
## Documented proc \c addSWVersionsJava .
# \param[in] fout File handle of output file
#
#  Add software versioning routines to Java API for
#  getSALVersion,getXMLVersion,getOSPLVersion
#
proc addSWVersionsJava { fout } {
global SALVERSION XMLVERSION env
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

/// Returns the current OpenSpliceDDS version e.g. \"6.9.181127OSS\"
public String getOSPLVersion()
\{
  String osplrelease = System.getenv(\"OSPL_RELEASE\");
    if (osplrelease == null) \{
      System.out.println(\"Error in getOSPLVersion: OSPL_RELEASE environment not setup\");
      System.exit(-1);
    \}
    return osplrelease;\}
"
}



#
## Documented proc \c addActorIndexesCPP .
# \param[in] idlfile Name of input IDL definition file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#   Add code to support salActor data structure initialization in C++
#
proc addActorIndexesCPP { idlfile base fout } {
global SAL_WORK_DIR
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   set idx 0
   set fact [open $SAL_WORK_DIR/[set base]/cpp/src/SAL_[set base]_actors.h w]
   foreach j $ptypes {
      set name [lindex $j 2]
      puts $fact "#define SAL__[set base]_[set name]_ACTOR    $idx"
      incr idx 1
   }
   close $fact
   puts $fout "
void SAL_SALData::initSalActors ()
\{
    char *pname = (char *)malloc(256);
    for (int i=0; i<SAL__ACTORS_MAXCOUNT;i++) \{
      sal\[i\].isReader = false;
      sal\[i\].isWriter = false;
      sal\[i\].isCommand = false;
      sal\[i\].isEventReader = false;
      sal\[i\].isProcessor = false;
      sal\[i\].isEventReader = false;
      sal\[i\].isEventWriter = false;
      sal\[i\].isActive = false;
      sal\[i\].maxSamples = LENGTH_UNLIMITED;
      sal\[i\].sampleAge = 1.0e20;
      sal\[i\].historyDepth = 100;
    \}
"
   set idx 0
   foreach j $ptypes {
      set name [lindex $j 2]
      set type [lindex [split $name _] 0]
      set revcode [getRevCode [set base]_[set name] short]
      puts $fout "    strcpy(sal\[$idx\].topicHandle,\"[set base]_[set name][set revcode]\");"
      puts $fout "    strcpy(sal\[$idx\].topicName,\"[set base]_[set name]\");"
      if { $type == "logevent" } {
        puts $fout "    status = eventQos->get_topic_qos(sal\[$idx\].topic_qos, NULL);"
        puts $fout "    if ( status != 0 ) {throw std::runtime_error(\"ERROR : Cannot find EventProfile in QoS\"); }"
        puts $fout "    status = eventQos->get_datareader_qos(sal\[$idx\].dr_qos, NULL);"
        puts $fout "    status = eventQos->get_datawriter_qos(sal\[$idx\].dw_qos, NULL);"
        puts $fout "    status = eventQos->get_publisher_qos(sal\[$idx\].pub_qos, NULL);"
        puts $fout "    status = eventQos->get_subscriber_qos(sal\[$idx\].sub_qos, NULL);"
      } else {
        if { $type == "command" } {
          puts $fout "    status = commandQos->get_topic_qos(sal\[$idx\].topic_qos, NULL);"
          puts $fout "    if ( status != 0 ) {throw std::runtime_error(\"ERROR : Cannot find CommandProfile in QoS\"); }"
          puts $fout "    status = commandQos->get_datareader_qos(sal\[$idx\].dr_qos, NULL);"
          puts $fout "    status = commandQos->get_datawriter_qos(sal\[$idx\].dw_qos, NULL);"
          puts $fout "    status = commandQos->get_publisher_qos(sal\[$idx\].pub_qos, NULL);"
          puts $fout "    status = commandQos->get_subscriber_qos(sal\[$idx\].sub_qos, NULL);"
          puts $fout "    status = commandQos->get_topic_qos(sal\[$idx\].topic_qos2, NULL);"
        } else {
          if { $type == "ackcmd" } {
            puts $fout "    status = ackcmdQos->get_topic_qos(sal\[$idx\].topic_qos, NULL);"
            puts $fout "    if ( status != 0 ) {throw std::runtime_error(\"ERROR : Cannot find AckcmdProfile in QoS\"); }"
            puts $fout "    status = ackcmdQos->get_datareader_qos(sal\[$idx\].dr_qos, NULL);"
            puts $fout "    status = ackcmdQos->get_datawriter_qos(sal\[$idx\].dw_qos, NULL);"
            puts $fout "    status = ackcmdQos->get_publisher_qos(sal\[$idx\].pub_qos, NULL);"
            puts $fout "    status = ackcmdQos->get_subscriber_qos(sal\[$idx\].sub_qos, NULL);"
            puts $fout "    status = ackcmdQos->get_topic_qos(sal\[$idx\].topic_qos2, NULL);"
          } else {
            puts $fout "    status = telemetryQos->get_topic_qos(sal\[$idx\].topic_qos, NULL);"
            puts $fout "    if ( status != 0 ) {throw std::runtime_error(\"ERROR : Cannot find TelemetryProfile in QoS\"); }"
            puts $fout "    status = telemetryQos->get_datareader_qos(sal\[$idx\].dr_qos, NULL);"
            puts $fout "    status = telemetryQos->get_datawriter_qos(sal\[$idx\].dw_qos, NULL);"
            puts $fout "    status = telemetryQos->get_publisher_qos(sal\[$idx\].pub_qos, NULL);"
            puts $fout "    status = telemetryQos->get_subscriber_qos(sal\[$idx\].sub_qos, NULL);"
          }
        }
      }
      if { $type == "command" } {
         puts $fout "
      sprintf(pname,\"%s.[set base].cmd\",partitionPrefix);
      sal\[$idx\].partition = DDS::string_dup(pname);
      if (debugLevel > 2) \{ cout << \"[set base]_[set name] partition is \" << pname << endl;\}
"
      } else {
         puts $fout "
      sprintf(pname,\"%s.[set base].data\",partitionPrefix);
      sal\[$idx\].partition = DDS::string_dup(pname);
      if (debugLevel > 2) \{ cout << \"[set base]_[set name] partition is \" << pname << endl;\}
"
      }
      incr idx 1
   }
  puts $fout "
\}"
}

#
## Documented proc \c addActorIndexesJava .
# \param[in] idlfile Name of input IDL definition file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#   Add code to support salActor data structure initialization in Java
#
proc addActorIndexesJava { idlfile base fout } {
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   set idx 0
   foreach j $ptypes {
      set name [lindex $j 2]
      set type [lindex [split $name _] 0]
      puts $fout "  public static final int SAL__[set base]_[set name]_ACTOR = $idx;"
      incr idx 1
   }
   puts $fout " public static final int SAL__ACTORS_MAXCOUNT = $idx;"
   puts $fout "
  public void initSalActors ()
  \{
     String pname;
     int status=-1;
     int idx;
"
   set idx 0
   foreach j $ptypes {
      set name [lindex $j 2]
      set type [lindex [split $name _] 0]
      set revcode [getRevCode [set base]_[set name] short]
      puts $fout "    sal\[$idx\]=new salActor();" 
      puts $fout "    sal\[$idx\].topicHandle=\"[set base]_[set name][set revcode]\";"
      puts $fout "    sal\[$idx\].topicName=\"[set base]_[set name]\";"
      if { $type == "logevent" || $type == "command" || $type == "ackcmd" } {
        puts $fout "    sal\[$idx\].topicType=\"[set type]\";"
      } else {
        puts $fout "    sal\[$idx\].topicType=\"telemetry\";"
      }
      incr idx 1
   }
   puts $fout "    for (idx=0; idx<SAL__ACTORS_MAXCOUNT; idx++) \{"
   puts $fout "      if (sal\[idx\].topicType.equals(\"logevent\")) \{"
   puts $fout "        status = eventQos.get_topic_qos(sal\[idx\].topicQos, null);"
   puts $fout "        if ( status != 0 ) {throw new RuntimeException(\"ERROR : Cannot find EventProfile in QoS\"); }"
   puts $fout "        status = eventQos.get_datareader_qos(sal\[idx\].RQosH, null);"
   puts $fout "        status = eventQos.get_datawriter_qos(sal\[idx\].WQosH, null);"
   puts $fout "        status = eventQos.get_publisher_qos(sal\[idx\].pubQos, null);"
   puts $fout "        status = eventQos.get_subscriber_qos(sal\[idx\].subQos, null);"
   puts $fout "        pname = partitionPrefix + \".[set base].data\";"
   puts $fout "        sal\[idx\].partition = pname;"
   puts $fout "     \}"
   puts $fout "      if (sal\[idx\].topicType.equals(\"command\")) \{"
   puts $fout "        status = commandQos.get_topic_qos(sal\[idx\].topicQos, null);"
   puts $fout "        if ( status != 0 ) {throw new RuntimeException(\"ERROR : Cannot find CommandProfile in QoS\"); }"
   puts $fout "        status = commandQos.get_datareader_qos(sal\[idx\].RQosH, null);"
   puts $fout "        status = commandQos.get_datawriter_qos(sal\[idx\].WQosH, null);"
   puts $fout "        status = commandQos.get_publisher_qos(sal\[idx\].pubQos, null);"
   puts $fout "        status = commandQos.get_subscriber_qos(sal\[idx\].subQos, null);"
   puts $fout "        status = commandQos.get_topic_qos(sal\[idx\].topicQos2, null);"
   puts $fout "        pname = partitionPrefix + \".[set base].cmd\";"
   puts $fout "        sal\[idx\].partition = pname;"
   puts $fout "      \}"
   puts $fout "       if (sal\[idx\].topicType.equals(\"ackcmd\")) \{"
   puts $fout "         status = ackcmdQos.get_topic_qos(sal\[idx\].topicQos, null);"
   puts $fout "         if ( status != 0 ) {throw new RuntimeException(\"ERROR : Cannot find AckcmdProfile in QoS\"); }"
   puts $fout "         status = ackcmdQos.get_datareader_qos(sal\[idx\].RQosH, null);"
   puts $fout "         status = ackcmdQos.get_datawriter_qos(sal\[idx\].WQosH, null);"
   puts $fout "         status = ackcmdQos.get_publisher_qos(sal\[idx\].pubQos, null);"
   puts $fout "         status = ackcmdQos.get_subscriber_qos(sal\[idx\].subQos, null);"
   puts $fout "         status = ackcmdQos.get_topic_qos(sal\[idx\].topicQos2, null);"
   puts $fout "         pname = partitionPrefix + \".[set base].data\";"
   puts $fout "         sal\[idx\].partition = pname;"
   puts $fout "      \}"
   puts $fout "      if (sal\[idx\].topicType.equals(\"telemetry\")) \{"  
   puts $fout "         status = telemetryQos.get_topic_qos(sal\[idx\].topicQos, null);"
   puts $fout "         if ( status != 0 ) {throw new RuntimeException(\"ERROR : Cannot find TelemetryProfile in QoS\"); }"
   puts $fout "         status = telemetryQos.get_datareader_qos(sal\[idx\].RQosH, null);"
   puts $fout "         status = telemetryQos.get_datawriter_qos(sal\[idx\].WQosH, null);"
   puts $fout "         status = telemetryQos.get_publisher_qos(sal\[idx\].pubQos, null);"
   puts $fout "         status = telemetryQos.get_subscriber_qos(sal\[idx\].subQos, null);"
   puts $fout "         pname = partitionPrefix + \".[set base].data\";"
   puts $fout "         sal\[idx\].partition = pname;"
   puts $fout "      \}"
   puts $fout "     \}"
   puts $fout "  \}"
}

#
## Documented proc \c copyfromjavasample .
# \param[in] fout File handle of output file
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] name Name of of SAL Topic
#
#   Add code to copy data from Java DDS sample
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
            if { $arr != "" } {
              puts $fout "           System.arraycopy(SALInstance.value\[j\].$apar,0,data.$apar,0,$arr);"
            } else {
              puts $fout "           data.$apar = SALInstance.value\[j\].$apar;"
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
            if { $arr != "" } {
              puts $fout "           System.arraycopy(SALInstance.value\[j\].$apar,0,data.$apar,0,$arr);"
            } else {
              puts $fout "           data.$apar = SALInstance.value\[j\].$apar;"
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
            set arr [lindex [split $p "()"] 1]
            if { $arr != "" } {
              puts $fout "           System.arraycopy(SALInstance.value\[j\].$apar,0,data.$apar,0,$arr);"
            } else {
              puts $fout "           data.$apar = SALInstance.value\[j\].$apar;"
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
#   Add code to copy data into Java DDS sample
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
            set arr [lindex [split $p "()"] 1]
            if { $arr != "" } {
              puts $fout "           System.arraycopy(data.$apar,0,SALInstance.$apar,0,$arr);"
            } else {
              puts $fout "           SALInstance.$apar = data.$apar;"
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
            if { $arr != "" } {
              puts $fout "           System.arraycopy(data.$apar,0,SALInstance.$apar,0,$arr);"
            } else {
              puts $fout "           SALInstance.$apar = data.$apar;"
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
            set arr [lindex [split $p "()"] 1]
            if { $arr != "" } {
              puts $fout "          System.arraycopy(data.$apar,0,SALInstance.$apar,0,$arr);"
            } else {
              puts $fout "          SALInstance.$apar = data.$apar;"
            }
          }
         }
        }
}


#
## Documented proc \c addSALDDStypes .
# \param[in] idlfile Name of input IDL definition file
# \param[in] id Subsystem identity
# \param[in] lang Language to generate code for (cpp,java)
# \param[in] base Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Generates code to publish and subscribe to samples of each type of 
#  SAL Topic for a Subsystem/CSC, getSample,putSample,getNextSample,flushSamples
#  and also code to manage the low level DDS Topic registration and management
#
proc addSALDDStypes { idlfile id lang base } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS OPTIONS
 if { $OPTIONS(verbose) } {stdlog "###TRACE>>>  addSALDDStypes $idlfile $id $lang $base "}
 set atypes $idlfile
 if { $lang == "java" } {
  exec cp $SAL_DIR/code/templates/salActor.java [set id]/java/src/org/lsst/sal/.
  exec cp $SAL_DIR/code/templates/salActor.java [set base]/java/src/org/lsst/sal/.
  exec cp $SAL_DIR/code/templates/salUtils.java [set id]/java/src/org/lsst/sal/.
  exec cp $SAL_DIR/code/templates/salUtils.java [set base]/java/src/org/lsst/sal/.
  set fin [open $SAL_DIR/code/templates/SALDDS.java.template r]
  set fout [open [set id]/java/src/org/lsst/sal/SAL_[set base].java w]
  puts stdout "Configuring [set id]/java/src/org/lsst/sal/SAL_[set base].java"
  while { [gets $fin rec] > -1 } {
     if { [string range $rec 0 20] == "// INSERT SAL IMPORTS" } {
        puts $fout "import [set base].*;"
     }
     if { [string range $rec 0 31] == "#ifdef SAL_SUBSYSTEM_ID_IS_KEYED" } {
         processifdefregion $fin $fout $base
     }
     if { [string range $rec 0 21] == "// INSERT TYPE SUPPORT" } {
        addActorIndexesJava $idlfile $base $fout
        addSWVersionsJava $fout
        puts $fout "
/** Configure DDS type support for [set base] DDS topics. 
  * @param topicName The DDS topic name
  */
        public int salTypeSupport(String topicName) \{
    String\[\] parts = topicName.split(\"_\");"
        foreach i $atypes {
           puts $fout "                if (\"[set base]\".equals(parts\[0\]) ) \{"
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
               set name [lindex $j 2]
               set revcode [getRevCode [set base]_[set name] short]
               puts $fout "
                    if ( \"[set base]_$name\".equals(topicName) ) \{
      [set name][set revcode]TypeSupport [set name][set revcode]TS = new [set name][set revcode]TypeSupport();
      registerType([set name][set revcode]TS);
                        return SAL__OK;
        \}"
           }
           puts $fout "  \}"
        }
        puts $fout "
  return SAL__ERR;
\}"
        puts $fout "        public int salTypeSupport(int actorIdx) \{"
        foreach i $atypes {
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
               set name [lindex $j 2]
               set revcode [getRevCode [set base]_[set name] short]
               puts stdout "  for $base $name"
               puts $fout "
                    if ( actorIdx == SAL__[set base]_[set name]_ACTOR ) \{
      [set name][set revcode]TypeSupport [set name][set revcode]TS = new [set name][set revcode]TypeSupport();
      registerType(actorIdx,[set name][set revcode]TS);
                        return SAL__OK;
        \}"
           }
        }
        puts $fout "
  return SAL__ERR;
\}"
        foreach i $atypes {
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
               set name [lindex $j 2]
               set revcode [getRevCode [set base]_[set name] short]
               set alias [string range $name 9 end]
               set turl [getTopicURL $base $name]
               puts $fout "
/** Publish a sample of the $turl DDS topic. A publisher must already have been set up
  * @param data The payload of the sample as defined in the XML for SALData
  */
  public int putSample([set base].[set name] data)
  \{
          int status = SAL__OK;
          [set name][set revcode] SALInstance = new [set name][set revcode]();
    int actorIdx = SAL__[set base]_[set name]_ACTOR;
    if ( sal\[actorIdx\].isWriter == false ) \{
      createWriter(actorIdx,false);
      sal\[actorIdx\].isWriter = true;
    \}
    DataWriter dwriter = getWriter(actorIdx);
    [set name][set revcode]DataWriter SALWriter = [set name][set revcode]DataWriterHelper.narrow(dwriter);
    SALInstance.private_revCode = \"[string trim $revcode _]\";
    SALInstance.private_sndStamp = getCurrentTime();
    SALInstance.private_identity = CSC_identity;
    SALInstance.private_origin = origin;
    SALInstance.private_seqNum = sal\[actorIdx\].sndSeqNum;
    sal\[actorIdx\].sndSeqNum++;
    if (debugLevel > 0) \{
      System.out.println(\"=== \[putSample $name\] writing a message containing :\");
      System.out.println(\"  revCode  : \" + SALInstance.private_revCode);
      System.out.println(\"  sndStamp  : \" + SALInstance.private_sndStamp);
      System.out.println(\"  identity : \" + SALInstance.private_identity);
    \}"
        copytojavasample $fout $base $name
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $fout "
           SALInstance.salIndex = subsystemID;
           long dataHandle = SALWriter.register_instance(SALInstance);
     status = SALWriter.write(SALInstance, dataHandle);
     checkStatus(status, \"[set name][set revcode]DataWriter.write\");
           SALWriter.dispose(SALInstance, dataHandle);"
        } else {
          puts $fout "
           long dataHandle = HANDLE_NIL.value;
     status = SALWriter.write(SALInstance, dataHandle);
     checkStatus(status, \"[set name][set revcode]DataWriter.write\");"
        }
        puts $fout "
    return status;
  \}


/** Receive the latest sample of the $turl DDS topic. A subscriber must already have been set up.
  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned.
  * If there are multiple samples in the history cache, they are skipped over and only the most recent is supplied.
  * @param data The payload of the sample as defined in the XML for SALData
  */
  public int getSample([set base].[set name] data)
  \{
    int status =  -1;
          int last = SAL__NO_UPDATES;
          int numsamp;
          [set name][set revcode]SeqHolder SALInstance = new [set name][set revcode]SeqHolder();
    int actorIdx = SAL__[set base]_[set name]_ACTOR;
    if ( sal\[actorIdx\].isReader == false ) \{"
        if { [info exists SYSDIC($base,keyedID)] } {
          puts $fout "      // Filter expr
                String expr\[\] = new String\[0\];
                String sFilter = \"salIndex = \" + subsystemID;
        createContentFilteredTopic(actorIdx,\"filteredtopic\", sFilter, expr);
    // create DataReader
    createReader(actorIdx,true);"
        } else {
          puts $fout "      createReader(actorIdx,false);"
        }
        puts $fout "
	    sal\[actorIdx\].isReader = true;
	  \}
	  DataReader dreader = getReader(actorIdx);
	  [set name][set revcode]DataReader SALReader = [set name][set revcode]DataReaderHelper.narrow(dreader);
  	  SampleInfoSeqHolder infoSeq = new SampleInfoSeqHolder();
	  SALReader.take(SALInstance, infoSeq, sal\[actorIdx\].maxSamples,
					NOT_READ_SAMPLE_STATE.value, ANY_VIEW_STATE.value,
					ANY_INSTANCE_STATE.value);
          numsamp = SALInstance.value.length;
          if (numsamp > 0) \{
      if (debugLevel > 0) \{
    for (int i = 0; i < numsamp; i++) \{
        System.out.println(\"=== \[getSample $name \] message received :\" + i);
        System.out.println(\"  revCode  : \" + SALInstance.value\[i\].private_revCode);
        System.out.println(\"  identity : \" + SALInstance.value\[i\].private_identity);
        System.out.println(\"  sndStamp  : \" + SALInstance.value\[i\].private_sndStamp);
        System.out.println(\"  sample_state : \" + infoSeq.value\[i\].sample_state);
        System.out.println(\"  view_state : \" + infoSeq.value\[i\].view_state);
        System.out.println(\"  instance_state : \" + infoSeq.value\[i\].instance_state);
    \}
      \}
            int j=numsamp-1;
            if (infoSeq.value\[j\].valid_data) \{
        double rcvdTime = getCurrentTime();
        double dTime = rcvdTime - SALInstance.value\[j\].private_sndStamp;
        if ( dTime < sal\[actorIdx\].sampleAge ) \{
                   data.private_sndStamp = SALInstance.value\[j\].private_sndStamp;"
                copyfromjavasample $fout $base $name
         puts $fout "                   last = SAL__OK;
                \} else \{
                   System.out.println(\"dropped sample : \" + rcvdTime + \" \" + SALInstance.value\[j\].private_sndStamp);
                   last = SAL__NO_UPDATES;
                \}
            \}
          \} else \{
              last = SAL__NO_UPDATES;
          \}
          status = SALReader.return_loan (SALInstance, infoSeq);
    return last;
  \}

/** Receive the next sample of the $turl DDS topic from the history cache. 
  * A subscriber must already have been set up
  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned.
  * If there are multiple samples in the history cache, they are iterated over by consecutive 
  * calls to getNextSample_[set name]
  * @param data The payload of the sample as defined in the XML for SALData
  */
  public int getNextSample([set base].[set name] data)
  \{
    int status = -1;
    int actorIdx = SAL__[set base]_[set name]_ACTOR;
          int saveMax = sal\[actorIdx\].maxSamples; 
          sal\[actorIdx\].maxSamples = 1;
          status = getSample(data);
          sal\[actorIdx\].maxSamples = saveMax;
          return status;
  \}

/** Empty the history cache of samples. After this only newly published samples
  * will be available to getSample_[set name] or getNextSample_[set name]
  */
  public int flushSamples([set base].[set name] data)
  \{
          int status = -1;
    int actorIdx = SAL__[set base]_[set name]_ACTOR;
          sal\[actorIdx\].maxSamples = DDS.LENGTH_UNLIMITED.value;
          sal\[actorIdx\].sampleAge = -1.0;
          status = getSample(data);
          sal\[actorIdx\].sampleAge = 1.0e20;
          return SAL__OK;
  \}
"
           }
        }
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
  exec cp [set id]/java/src/org/lsst/sal/SAL_[set base].java [set base]/java/src/org/lsst/sal/.
 }
 if { $lang == "cpp" } {
  set finh [open $SAL_DIR/code/templates/SALDDS.h.template r]
  set fouth [open [set base]/cpp/src/SAL_[set base].h w]
  set rec ""
  while { [string range $rec 0 21] != "// INSERT TYPE SUPPORT" } {
     if { [string range $rec 0 22] == "// INSERT TYPE INCLUDES" } {
       puts $fouth "  #include \"ccpp_sal_[lindex [split $id _] 0].h\"
"
       gets $finh rec ; puts $fouth $rec
     } else {
       gets $finh rec
       puts $fouth $rec
     }
  }
  set fin [open $SAL_DIR/code/templates/SALDDS.cpp.template r]
  puts stdout "Configuring [set id]/cpp/src/SAL_[set base].cpp"
  set fout [open [set base]/cpp/src/SAL_[set base].cpp w]
  while { [gets $fin rec] > -1 } {
     if { [string range $rec 0 21] == "// INSERT TYPE SUPPORT" } {
        addActorIndexesCPP $idlfile $base $fout
        addSWVersionsCPP $fout
        puts $fout " salReturn SAL_[set base]::salTypeSupport(char *topicName)
\{"
        foreach i $atypes {
           puts $fout "    if (strncmp(\"$base\",topicName,[string length $base]) == 0) \{"
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
               if { $OPTIONS(verbose) } {stdlog "###TRACE--- Processing topic $j"}
               set name [lindex $j 2]
               set revcode [getRevCode [set base]_[set name] short]
                 puts $fout "
       if ( strcmp(\"[set base]_[set name]\",topicName) == 0) \{
    [set base]::[set name][set revcode]TypeSupport_var mt = new [set base]::[set name][set revcode]TypeSupport();
    registerType(mt.in());
          return SAL__OK;
       \}"
           }
           puts $fout "  \}"
        }
        puts $fout "  return SAL__ERR;
\}"
        puts $fout " salReturn SAL_[set base]::salTypeSupport(int actorIdx)
\{"
        foreach i $atypes {
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
               set name [lindex $j 2]
               set revcode [getRevCode [set base]_[set name] short]
                 puts $fout "
       if ( actorIdx == SAL__[set base]_[set name]_ACTOR ) \{
    [set base]::[set name][set revcode]TypeSupport_var mt = new [set base]::[set name][set revcode]TypeSupport();
    registerType(actorIdx,mt.in());
          return SAL__OK;
       \}"
           }
        }
        puts $fout "  return SAL__ERR;
\}"
        generatetypelists $base $fout
        foreach i $atypes {
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
              if { $OPTIONS(verbose) } {stdlog "###TRACE------ Processing topic $j"}
              set name [lindex $j 2]
              set revcode [getRevCode [set base]_[set name] short]
              set turl [getTopicURL $base $name]
puts $fout "
salReturn SAL_[set base]::putSample([set base]::[set name][set revcode] data)
\{
  DataWriter_var dwriter = getWriter();
  if ( dwriter == NULL ) \{
     throw std::runtime_error(\"No DataWriter for putSample_[set name]\");
  \}
  [set base]::[set name][set revcode]DataWriter_var SALWriter = [set base]::[set name][set revcode]DataWriter::_narrow(dwriter.in());
  data.private_revCode = DDS::string_dup(\"[string trim $revcode _]\");
  if (debugLevel > 0) \{
    cout << \"=== \[putSample\] [set base]::[set name][set revcode] writing a message containing :\" << endl;
    cout << \"    revCode  : \" << data.private_revCode << endl;
  \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   data.salIndex = subsystemID;
   InstanceHandle_t dataHandle = SALWriter->register_instance(data);
#else
   InstanceHandle_t dataHandle = HANDLE_NIL;
#endif
  data.private_sndStamp = getCurrentTime();
  ReturnCode_t status = SALWriter->write(data, dataHandle);
  checkStatus(status, \"[set base]::[set name][set revcode]DataWriter::write\");
  return status;
\}

salReturn SAL_[set base]::getSample([set base]::[set name][set revcode]Seq data)
\{
  SampleInfoSeq_var infoSeq = new SampleInfoSeq;
  ReturnCode_t status =  - 1;
  unsigned int numsamp = 0;
  DataReader_var dreader = getReader();
  if ( dreader == NULL ) \{
     throw std::runtime_error(\"No DataReader for getSample_[set name]\");
  \}
  [set base]::[set name][set revcode]DataReader_var SALReader = [set base]::[set name][set revcode]DataReader::_narrow(dreader.in());
  checkHandle(SALReader.in(), \"[set base]::[set name][set revcode]DataReader::_narrow\");
  status = SALReader->take(data, infoSeq, LENGTH_UNLIMITED, NOT_READ_SAMPLE_STATE, ANY_VIEW_STATE, ANY_INSTANCE_STATE);
  checkStatus(status, \"[set base]::[set name][set revcode]DataReader::take\");
  numsamp = data.length();
  for (DDS::ULong j = 0; j < numsamp; j++)
  \{
    rcvdTime = getCurrentTime();
      cout << \"=== \[GetSample\] message received :\" << endl;
      cout << \"    revCode  : \" << data\[j\].private_revCode << endl;
  \}
  status = SALReader->return_loan(data, infoSeq);
  checkStatus(status, \"[set base]::[set name][set revcode]DataReader::return_loan\");
  if (numsamp == 0) \{
     status = SAL__NO_UPDATES;
  \}
  return status;
\}"
               puts $fouth "
      salReturn putSample([set base]::[set name][set revcode] data);
      salReturn getSample([set base]::[set name][set revcode]Seq data);

/** Publish a sample of the $turl DDS topic. A publisher must already have been set up
  * @param data The payload of the sample as defined in the XML for SALData
  */
      salReturn putSample_[set name]([set base]_[set name]C *data);


/** Receive the latest sample of the $turl DDS topic. A subscriber must already have been set up.
  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned.
  * If there are multiple samples in the history cache, they are skipped over and only the most recent is supplied.
  * @param data The payload of the sample as defined in the XML for SALData
  */
      salReturn getSample_[set name]([set base]_[set name]C *data);


/** Receive the next sample of the $turl DDS topic from the history cache. A subscriber must already have been set up
  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned.
  * If there are multiple samples in the history cache, they are iterated over by consecutive calls to getNextSample_[set name]
  * @param data The payload of the sample as defined in the XML for SALData
  */
      salReturn getNextSample_[set name]([set base]_[set name]C *data);

/** Empty the history cache of samples. After this only newly published samples will be available to getSample_[set name] or 
  * getNextSample_[set name]
  */
      salReturn flushSamples_[set name]([set base]_[set name]C *data);

/** Provides the data from the most recently received $turl sample. This may be a new sample that has not been read before
  * by the caller, or it may be a copy of the last received sample if no new data has since arrived.
  * If there are no samples available then SAL__NO_UPDATES is returned, otherwise SAL__OK is returned.
  * @param data The payload of the sample as defined in the XML for SALData
  */
      salReturn getLastSample_[set name]([set base]_[set name]C *data);
      [set base]_[set name]C lastSample_[set base]_[set name];
"
               insertcfragments $fout $base $name
           }
        }
        gencmdaliascode $base include $fouth
        gencmdaliascode $base cpp $fout
        geneventaliascode $base include $fouth
        geneventaliascode $base cpp $fout
###        gengenericreader $fout $base
     } else {
        if { $rec == "using namespace SALData;" } {
          puts $fout "using namespace [set base];"
        } else {
          puts $fout $rec
        }
     }
  }
  close $fin
  close $fout
  while { [gets $finh rec] > -1 } {puts $fouth $rec}
  close $finh
  close $fouth
 }
 if { $OPTIONS(verbose) } {stdlog "###TRACE<<<  addSALDDStypes $idlfile $id $lang $base "}
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
  set fin [open $SAL_DIR/code/templates/SALDataPublisher.cpp.template r]
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
  set fin [open $SAL_DIR/code/templates/SALDataSubscriber.cpp.template r]
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

