#!/usr/bin/env tclsh
#
# Generate SALDDS methods for getSample and putSample for all types
# and generate salTypeSupport routine
#  

source $env(SAL_DIR)/geneventaliascode.tcl
source $env(SAL_DIR)/gencmdaliascode.tcl
source $env(SAL_DIR)/gengenericreader.tcl

proc insertcfragments { fout base name } {
global SAL_WORK_DIR
   if { $name == "command" || $name == "ackcmd" || $name == "logevent" } {return}
   puts $fout "
salReturn SAL_[set base]::putSample_[set name]([set base]_[set name]C *data)
\{
#ifdef SAL_BUILD_FOR_PYTHON
  Py_BEGIN_ALLOW_THREADS
#endif
  int actorIdx = SAL__[set base]_[set name]_ACTOR;
  if ( sal\[actorIdx\].isWriter == false ) \{
    createWriter(actorIdx);
    sal\[actorIdx\].isWriter = true;
  \}
  DataWriter_var dwriter = getWriter(actorIdx);
  [set base]::[set name]DataWriter_var SALWriter = [set base]::[set name]DataWriter::_narrow(dwriter.in());
  [set base]::[set name] Instance;

  Instance.private_revCode = DDS::string_dup(\"LSST TEST REVCODE\");
  Instance.private_sndStamp = getCurrentTime();
  Instance.private_origin = 1;
  Instance.private_seqNum = sndSeqNum;
  Instance.private_host = 1;
   "
  set frag [open $SAL_WORK_DIR/include/SAL_[set base]_[set name]Cput.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  puts $fout "

  sndSeqNum++;
  if (debugLevel > 0) \{
    cout << \"=== \[putSample\] [set base]::[set name] writing a message containing :\" << endl;
    cout << \"    revCode  : \" << Instance.private_revCode << endl;
  \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   Instance.[set base]ID = subsystemID;
   InstanceHandle_t dataHandle = SALWriter->register_instance(Instance);
#else
   InstanceHandle_t dataHandle = HANDLE_NIL;
#endif
  Instance.private_sndStamp = getCurrentTime();
  ReturnCode_t status = SALWriter->write(Instance, dataHandle);
  checkStatus(status, \"[set base]::[set name]DataWriter::write\");  
#ifdef SAL_BUILD_FOR_PYTHON
  Py_END_ALLOW_THREADS
#endif
  return status;
\}

salReturn SAL_[set base]::getSample_[set name]([set base]_[set name]C *data)
\{
  [set base]::[set name]Seq Instances;
  SampleInfoSeq_var info = new SampleInfoSeq;
  ReturnCode_t status = -1;
  salReturn istatus = -1;
  unsigned int numsamp = 0;

#ifdef SAL_BUILD_FOR_PYTHON
  Py_BEGIN_ALLOW_THREADS
#endif
  int actorIdx = SAL__[set base]_[set name]_ACTOR;
  if ( sal\[actorIdx\].isReader == false ) \{
    createReader(actorIdx,false);
    sal\[actorIdx\].isReader = true;
  \}
  DataReader_var dreader = getReader(actorIdx);
  [set base]::[set name]DataReader_var SALReader = [set base]::[set name]DataReader::_narrow(dreader.in());
  checkHandle(SALReader.in(), \"[set base]::[set name]DataReader::_narrow\");
  status = SALReader->take(Instances, info, sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples , ANY_SAMPLE_STATE, ANY_VIEW_STATE, ALIVE_INSTANCE_STATE);
  checkStatus(status, \"[set base]::[set name]DataReader::take\");
  numsamp = Instances.length();
  for (DDS::ULong j = 0; j < numsamp; j++)
  \{
    rcvdTime = getCurrentTime();
    if (debugLevel > 8) \{
      cout << \"=== \[GetSample\] message received :\" << numsamp << endl;
      cout << \"    revCode  : \" << Instances\[j\].private_revCode << endl;
      cout << \"    sndStamp  : \" << Instances\[j\].private_sndStamp << endl;
      cout << \"    origin  : \" << Instances\[j\].private_origin << endl;
      cout << \"    host  : \" << Instances\[j\].private_host << endl;
    \}
    if ( (rcvdTime - Instances\[j\].private_sndStamp) < sal\[actorIdx\].sampleAge && (Instances\[j\].private_origin != 0)) \{
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
  checkStatus(status, \"[set base]::[set name]DataReader::return_loan\");
#ifdef SAL_BUILD_FOR_PYTHON
  Py_END_ALLOW_THREADS
#endif
  if ( numsamp == 0 ) \{
     istatus = SAL__NO_UPDATES;
     return istatus;
  \}
  return istatus;
\}

salReturn SAL_[set base]::getNextSample_[set name]([set base]_[set name]C *data)
\{
    salReturn istatus = -1;
    sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples = 1;
    istatus = getSample_[set name](data);
    return istatus;
\}

salReturn SAL_[set base]::flushSamples_[set name]([set base]_[set name]C *data)
\{
    salReturn istatus;
    sal\[SAL__[set base]_[set name]_ACTOR\].maxSamples = LENGTH_UNLIMITED;
    sal\[SAL__[set base]_[set name]_ACTOR\].sampleAge = -1.0;
    istatus = getSample_[set name](data);
    if (debugLevel > 8) \{
        cout << \"===	\[flushSamples\] getSample returns :\" << istatus << endl;
    \}
    sal\[SAL__[set base]_[set name]_ACTOR\].sampleAge = 100.0;
    return SAL__OK;
\}
"
}

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

proc addActorIndexesCPP { idlfile base fout } {
global SAL_WORK_DIR
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   set idx 0
   set fact [open $SAL_WORK_DIR/[set base]/cpp/src/SAL_actors.h w]
   foreach j $ptypes {
      set name [lindex $j 2]
      puts $fout "#define SAL__[set base]_[set name]_ACTOR		$idx"
      puts $fact "#define SAL__[set base]_[set name]_ACTOR		$idx"
      incr idx 1 
   }
   close $fact
   set tuneableQos true
###   if { $base == "m1m3" } {set tuneableQos false}
   puts $fout "
void SAL_SALData::initSalActors ()
\{
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
      sal\[i\].sampleAge = 100.0;
      sal\[i\].historyDepth = 10000;
      sal\[i\].tuneableQos = [set tuneableQos];
    \}
"
   set idx 0
   foreach j $ptypes {
      set name [lindex $j 2]
      puts $fout "    strcpy(sal\[$idx\].topicName,\"[set base]_[set name]\");"
      incr idx 1 
   }  
  puts $fout "
\}"
}

proc addActorIndexesJava { idlfile base fout } {
   set ptypes [lsort [split [exec grep pragma $idlfile] \n]]
   set idx 0
   foreach j $ptypes {
      set name [lindex $j 2]
      puts $fout "	public static final int SAL__[set base]_[set name]_ACTOR = $idx;"
      incr idx 1 
   }
   puts $fout "	public static final int SAL__ACTORS_MAXCOUNT = $idx;"
   puts $fout "
	public void initSalActors ()
	\{
"
   set idx 0
   foreach j $ptypes {
      set name [lindex $j 2]
      puts $fout "		sal\[$idx\]=new salActor();" 
      puts $fout "		sal\[$idx\].topicName=\"[set base]_[set name]\";"
      incr idx 1 
   }  
  puts $fout "
	\}"
}


proc addSALDDStypes { idlfile id lang base } {
global env SAL_DIR SAL_WORK_DIR SYSDIC TLMS EVTS
 set atypes $idlfile
 if { $lang == "java" } {
  exec cp $SAL_DIR/code/templates/salActor.java [set id]/java/src/org/lsst/sal/.
  exec cp $SAL_DIR/code/templates/salActor.java [set base]/java/src/org/lsst/sal/.
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
        puts $fout "        public int salTypeSupport(String topicName) \{
		String\[\] parts = topicName.split(\"_\");"
        foreach i $atypes {
           puts $fout "                if (\"[set base]\".equals(parts\[0\]) ) \{"
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
               set name [lindex $j 2]
               puts $fout "
                    if ( \"[set base]_$name\".equals(topicName) ) \{
			[set name]TypeSupport [set name]TS = new [set name]TypeSupport();
			registerType([set name]TS);
                        return SAL__OK;
		    \}"
           }
           puts $fout "	 \}"
        }
        puts $fout "
  return SAL__ERR;
\}"
        puts $fout "        public int salTypeSupport(int actorIdx) \{"
        foreach i $atypes {
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
               set name [lindex $j 2]
               puts stdout "	for $base $name"
               puts $fout "
                    if ( actorIdx == SAL__[set base]_[set name]_ACTOR ) \{
			[set name]TypeSupport [set name]TS = new [set name]TypeSupport();
			registerType(actorIdx,[set name]TS);
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
               set alias [string range $name 9 end]
puts $fout "
	public int putSample([set base].[set name] data)
	\{
          int status = SAL__OK;
	  int actorIdx = SAL__[set base]_[set name]_ACTOR;
	  if ( sal\[actorIdx\].isWriter == false ) \{
	    createWriter(actorIdx,false);
	    sal\[actorIdx\].isWriter = true;
	  \}
	  DataWriter dwriter = getWriter(actorIdx);
	  [set name]DataWriter SALWriter = [set name]DataWriterHelper.narrow(dwriter);
	  data.private_revCode = \"LSST TEST REVCODE\";
          data.private_sndStamp = getCurrentTime();
          data.private_origin = 1;
	  if (debugLevel > 0) \{
	    System.out.println(\"=== \[putSample $name\] writing a message containing :\");
	    System.out.println(\"    revCode  : \" + data.private_revCode);
	    System.out.println(\"    sndStamp  : \" + data.private_sndStamp);
	  \}"
        if { [info exists SYSDIC($base,keyedID)] } { 
          puts $fout "
           data.[set base]ID = subsystemID;
           long dataHandle = SALWriter.register_instance(data);
	   SALWriter.register_instance(data);
	   status = SALWriter.write(data, dataHandle);
	   checkStatus(status, \"[set name]DataWriter.write\");
           SALWriter.dispose(data, dataHandle);"
        } else { 
          puts $fout "
           long dataHandle = HANDLE_NIL.value;
	   status = SALWriter.write(data, dataHandle);
	   checkStatus(status, \"[set name]DataWriter.write\");"
        }
        puts $fout "
	  return status;
	\}


	public int getSample([set base].[set name] data)
	\{
	  int status =  -1;
          int last = SAL__NO_UPDATES;
          int numsamp;
          [set name]SeqHolder SALInstance = new [set name]SeqHolder();
	  int actorIdx = SAL__[set base]_[set name]_ACTOR;
	  if ( sal\[actorIdx\].isReader == false ) \{"
        if { [info exists SYSDIC($base,keyedID)] } { 
          puts $fout "  		// Filter expr
                String expr\[\] = new String\[0\];
                String sFilter = \"[set base]ID = \" + subsystemID;
    		createContentFilteredTopic(actorIdx,\"filteredtopic\", sFilter, expr);
		// create DataReader
 		createReader(actorIdx,true);"
        } else {
          puts $fout "	    createReader(actorIdx,false);"
        }
         puts $fout "
	    sal\[actorIdx\].isReader = true;
	  \}
	  DataReader dreader = getReader(actorIdx);
	  [set name]DataReader SALReader = [set name]DataReaderHelper.narrow(dreader);
  	  SampleInfoSeqHolder infoSeq = new SampleInfoSeqHolder();
	  SALReader.take(SALInstance, infoSeq, sal\[actorIdx\].maxSamples,
					NOT_READ_SAMPLE_STATE.value, ANY_VIEW_STATE.value,
					ALIVE_INSTANCE_STATE.value);
          numsamp = SALInstance.value.length;
          if (numsamp > 0) \{
 	    if (debugLevel > 0) \{
		for (int i = 0; i < numsamp; i++) \{
				System.out.println(\"=== \[getSample $name \] message received :\" + i);
				System.out.println(\"    revCode  : \"
						+ SALInstance.value\[i\].private_revCode);
			        System.out.println(\"     sndStamp  : \" + SALInstance.value\[i\].private_sndStamp);
				System.out.println(\"  sample_state : \" + infoSeq.value\[i\].sample_state);
				System.out.println(\"    view_state : \" + infoSeq.value\[i\].view_state);
				System.out.println(\"instance_state : \" + infoSeq.value\[i\].instance_state);
		\}
	    \}
            int j=numsamp-1;
            if (infoSeq.value\[j\].valid_data) \{
    		double rcvdTime = getCurrentTime();
		double dTime = rcvdTime - SALInstance.value\[j\].private_sndStamp;
    		if ( dTime < sal\[actorIdx\].sampleAge ) \{
                   data.private_sndStamp = SALInstance.value\[j\].private_sndStamp;"
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
    		      puts $fout "                      System.arraycopy(SALInstance.value\[j\].$apar,0,data.$apar,0,$arr);"
    		    } else {
    		      puts $fout "                      data.$apar = SALInstance.value\[j\].$apar;"
    		    }
    		  }
    		}
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
    		      puts $fout "                      System.arraycopy(SALInstance.value\[j\].$apar,0,data.$apar,0,$arr);"
    		    } else {
    		      puts $fout "                      data.$apar = SALInstance.value\[j\].$apar;"
    		    }
    		  }
    		}
         puts $fout "                   last = SAL__OK;
                \} else \{
                   last = SAL__NO_UPDATES;
                \}
            \}
          \} else \{
              last = SAL__NO_UPDATES;
          \}
          status = SALReader.return_loan (SALInstance, infoSeq);
	  return last;
	\}

	public int getNextSample([set base].[set name] data)
	\{
	  int status = -1;
	  int actorIdx = SAL__[set base]_[set name]_ACTOR;
          sal\[actorIdx\].maxSamples = 1;
          status = getSample(data);
          return status;
	\}

	public int flushSamples([set base].[set name] data)
	\{
          int status = -1;
	  int actorIdx = SAL__[set base]_[set name]_ACTOR;
          sal\[actorIdx\].maxSamples = DDS.LENGTH_UNLIMITED.value;
          sal\[actorIdx\].sampleAge = -1.0;
          status = getSample(data);
          sal\[actorIdx\].sampleAge = 100.0;
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
#ifdef SAL_BUILD_FOR_PYTHON
#include \"Python.h\"
#endif
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
        puts $fout " salReturn SAL_[set base]::salTypeSupport(char *topicName) 
\{"
        foreach i $atypes {
           puts $fout "    if (strncmp(\"$base\",topicName,[string length $base]) == 0) \{"
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
               set name [lindex $j 2]
               puts $fout "
       if ( strcmp(\"[set base]_[set name]\",topicName) == 0) \{
	  [set base]::[set name]TypeSupport_var mt = new [set base]::[set name]TypeSupport();
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
               puts $fout "
       if ( actorIdx == SAL__[set base]_[set name]_ACTOR ) \{
	  [set base]::[set name]TypeSupport_var mt = new [set base]::[set name]TypeSupport();
	  registerType(actorIdx,mt.in());
          return SAL__OK;
       \}"
           }
        }
        puts $fout "  return SAL__ERR;
\}"
        foreach i $atypes {
           set ptypes [split [exec grep pragma $i] \n]
           foreach j $ptypes {
              set name [lindex $j 2]        
puts $fout "
salReturn SAL_[set base]::putSample([set base]::[set name] data)
\{
  DataWriter_var dwriter = getWriter();
  [set base]::[set name]DataWriter_var SALWriter = [set base]::[set name]DataWriter::_narrow(dwriter.in());
  data.private_revCode = DDS::string_dup(\"LSST TEST REVCODE\");
  if (debugLevel > 0) \{
    cout << \"=== \[putSample\] [set base]::[set name] writing a message containing :\" << endl;
    cout << \"    revCode  : \" << data.private_revCode << endl;
  \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   data.[set base]ID = subsystemID;
   InstanceHandle_t dataHandle = SALWriter->register_instance(data);
#else
   InstanceHandle_t dataHandle = HANDLE_NIL;
#endif
  data.private_sndStamp = getCurrentTime();
  ReturnCode_t status = SALWriter->write(data, dataHandle);
  checkStatus(status, \"[set base]::[set name]DataWriter::write\");  
  return status;
\}

salReturn SAL_[set base]::getSample([set base]::[set name]Seq data)
\{
  SampleInfoSeq_var infoSeq = new SampleInfoSeq;
  ReturnCode_t status =  - 1;
  unsigned int numsamp = 0;
  DataReader_var dreader = getReader();
  [set base]::[set name]DataReader_var SALReader = [set base]::[set name]DataReader::_narrow(dreader.in());
  checkHandle(SALReader.in(), \"[set base]::[set name]DataReader::_narrow\");
  status = SALReader->take(data, infoSeq, LENGTH_UNLIMITED, ANY_SAMPLE_STATE, ANY_VIEW_STATE, ALIVE_INSTANCE_STATE);
  checkStatus(status, \"[set base]::[set name]DataReader::take\");
  numsamp = data.length();
  for (DDS::ULong j = 0; j < numsamp; j++)
  \{
    rcvdTime = getCurrentTime();
    if (data\[j\].private_origin != 0) \{
      cout << \"=== \[GetSample\] message received :\" << endl;
      cout << \"    revCode  : \" << data\[j\].private_revCode << endl;
    \}
  \}
  status = SALReader->return_loan(data, infoSeq);
  checkStatus(status, \"[set base]::[set name]DataReader::return_loan\");
  if (numsamp == 0) \{
     status = SAL__NO_UPDATES;
  \}
  return status;
\}"
               puts $fouth "
      salReturn putSample([set base]::[set name] data);
      salReturn getSample([set base]::[set name]Seq data);
      salReturn putSample_[set name]([set base]_[set name]C *data);
      salReturn getSample_[set name]([set base]_[set name]C *data);
      salReturn getNextSample_[set name]([set base]_[set name]C *data);
      salReturn flushSamples_[set name]([set base]_[set name]C *data);
"
               insertcfragments $fout $base $name
           }
        }
        gencmdaliascode $base include $fouth
        gencmdaliascode $base cpp $fout
        geneventaliascode $base include $fouth
        geneventaliascode $base cpp $fout
        gengenericreader $fout $base 
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
}

proc modpubsubexamples { id } {
global SAL_DIR SAL_WORK_DIR
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
}




