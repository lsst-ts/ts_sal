
source $SAL_DIR/gencommandtests.tcl
source $SAL_DIR/gencommandtestssinglefile.tcl 
source $SAL_DIR/gencommandtestsjava.tcl
source $SAL_DIR/gencommandtestssinglefilejava.tcl
source $SAL_DIR/gentestspython.tcl 
source $SAL_DIR/activaterevcodes.tcl 

proc addgenericcmdcode { fout lang } {
global OPTIONS SAL_DIR
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> addgenericcmdcode $lang $fout"}
  stdlog "Generate command generic support for $lang"
  set fin [open  $SAL_DIR/code/templates/SALDDS.[set lang]-cmd.template r]
  while { [gets $fin rec] > -1 } {
    puts $fout $rec
  }
  close $fin
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< addgenericcmdcode $lang $fout"}
}


proc gencmdaliascode { subsys lang fout } {
global CMD_ALIASES CMDS DONE_CMDEVT ACKREVCODE REVCODE SAL_WORK_DIR OPTIONS
 if { $OPTIONS(verbose) } {stdlog "###TRACE>>> gencmdaliascode $subsys $lang $fout"}
 source $SAL_WORK_DIR/idl-templates/validated/[set subsys]_revCodes.tcl
 if { [info exists CMD_ALIASES($subsys)] } {
  set ACKREVCODE [getRevCode [set subsys]_ackcmd short]
  stdlog "Generate command alias support for $lang"
  if { $lang == "include" } {
     foreach i $CMD_ALIASES($subsys) { 
       if { [info exists CMDS($subsys,$i,param)] } {
         puts $fout "
      int issueCommand_[set i]( SALData_command_[set i]C *data );
      int acceptCommand_[set i]( SALData_command_[set i]C *data );
      salReturn waitForCompletion_[set i]( int cmdSeqNum , unsigned int timeout );
      salReturn ackCommand_[set i]( int cmdSeqNum, salLONG  ack, salLONG error, char *result );
      salReturn ackCommand_[set i]C( SALData_ackcmdC *data );
      salReturn getResponse_[set i]( SALData::ackcmd[set ACKREVCODE]Seq data );
      salReturn getResponse_[set i]C (SALData_ackcmdC *data );"
       }
     }
  }
  if { $lang == "cpp" } {
     addgenericcmdcode $fout $lang
     set result none
     catch { set result [gencmdaliascpp $subsys $fout] } bad
     if { $result == "none" } {errorexit "failure in gencmdaliascpp" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       set result none
       catch { set result [gencommandtestscpp $subsys] } bad
       if { $result == "none" } {errorexit "failure in gencommandtestscpp" }
       stdlog "$result"
     }
  }
  if { $lang == "java" }  {
     set result none
     gencmdgenericjava $subsys $fout
     catch { set result [gencmdaliasjava $subsys $fout] } bad
     if { $result == "none" } {errorexit "failure in gencmdaliasjava" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       catch { set result [gencommandtestsjava $subsys] } bad
       stdlog "$result"
     }
  }
  if { $lang == "python" } {
     set result none
     catch { set result [gencmdaliaspython $subsys $fout] } bad
     if { $result == "none" } {errorexit "failure in gencmdaliaspython" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       catch { set result [gencommandtestspython $subsys] } bad
       stdlog "$result"
     }
  }
  if { $lang == "isocpp" } {
     set result none
     if { $result == "none" } {errorexit "failure in addgenericcmdcode" }
     addgenericcmdcode $fout $lang
     catch { set result [gencmdaliasisocpp $subsys $fout] } bad
     stdlog "$result"
  }
 }
 if { $OPTIONS(verbose) } {stdlog "###TRACE<<< gencmdaliascode $subsys $lang $fout"}
}


proc gencmdaliascpp { subsys fout } {
global CMD_ALIASES CMDS SAL_WORK_DIR ACKREVCODE OPTIONS
   if { $OPTIONS(verbose) } {stdlog "###TRACE>>> gencmdaliascpp $subsys $fout"}
   if { [info exists CMD_ALIASES($subsys)] } {
    foreach i $CMD_ALIASES($subsys) {
    if { [info exists CMDS($subsys,$i,param)] } {
      set revcode [getRevCode [set subsys]_command_[set i] short]
      stdlog "	: command alias = $i , revcode = $revcode"
      puts $fout "
int SAL_SALData::issueCommand_[set i]( SALData_command_[set i]C *data )
\{
  
  if ( data == NULL ) \{
     throw std::runtime_error(\"NULL pointer for issueCommand_[set i]\");
  \}
  InstanceHandle_t cmdHandle = DDS::HANDLE_NIL;
  SALData::command_[set i][set revcode] Instance;
  int actorIdx = SAL__SALData_command_[set i]_ACTOR;
  // create DataWriter :
  if (sal\[actorIdx\].isCommand == false) \{
     throw std::runtime_error(\"No commander for issueCommand_[set i]\");
  \}
  DataWriter_var dwriter = getWriter(actorIdx);
  SALData::command_[set i][set revcode]DataWriter_var SALWriter = SALData::command_[set i][set revcode]DataWriter::_narrow(dwriter.in());

#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
  Instance.SALDataID = subsystemID;
  cmdHandle = SALWriter->register_instance(Instance);
#endif

  Instance.private_revCode =  DDS::string_dup(\"[string trim $revcode _]\");
  Instance.private_sndStamp = getCurrentTime();
  Instance.private_origin =   getpid();
  Instance.private_seqNum =   sal\[actorIdx\].sndSeqNum;
  Instance.private_host =     ddsIPaddress;"
        set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set i]Cput.tmp r]
        while { [gets $fin rec] > -1 } {
           puts $fout $rec
        }
        close $fin
        puts $fout "
  if (debugLevel > 0) \{
    cout << \"=== \[issueCommand_[set i]\] writing a command containing :\" << endl;"
        set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set i]Cout.tmp r]
        while { [gets $fin rec] > -1 } {
           puts $fout $rec
        }
        close $fin
        puts $fout "
  \}
  Instance.private_sndStamp = getCurrentTime();
  ReturnCode_t status = SALWriter->write(Instance, cmdHandle);
  sal\[actorIdx\].sndSeqNum++;
//  if(sal\[actorIdx\].sndSeqNum >= 32768*(actorIdx+1) ) \{
//     sal\[actorIdx\].sndSeqNum = 32768*actorIdx + 1;
//  \}
  checkStatus(status, \"SALData::command_[set i][set revcode]DataWriter::write\");  
//    SALWriter->unregister_instance(Instance, cmdHandle);
  if (status != SAL__OK) \{
      if (debugLevel >= SAL__LOG_ROUTINES) \{
          logError(status);
      \}
  \}
  return (sal\[actorIdx\].sndSeqNum-1);
\}
"
      puts $fout "
int SAL_SALData::acceptCommand_[set i]( SALData_command_[set i]C *data )
\{
   SampleInfoSeq info;
   ReturnCode_t status = 0;
   ReturnCode_t istatus =  -1;
   SALData::command_[set i][set revcode]Seq Instances;
   SALData::ackcmd[set ACKREVCODE] ackdata;
   InstanceHandle_t ackHandle = DDS::HANDLE_NIL;
   int actorIdx = SAL__SALData_command_[set i]_ACTOR;
   int j=0;
   if ( data == NULL ) \{
      throw std::runtime_error(\"NULL pointer for acceptCommand_[set i]\");
   \}

  // create DataWriter :
  if (sal\[actorIdx\].isProcessor == false) \{
      throw std::runtime_error(\"No controller for acceptCommand_[set i]\");
  \}
  DataWriter_var dwriter = getWriter2(SAL__SALData_ackcmd_ACTOR);
  SALData::ackcmd[set ACKREVCODE]DataWriter_var SALWriter = SALData::ackcmd[set ACKREVCODE]DataWriter::_narrow(dwriter.in());
  DataReader_var dreader = getReader(actorIdx);
  SALData::command_[set i][set revcode]DataReader_var SALReader = SALData::command_[set i][set revcode]DataReader::_narrow(dreader.in());
  checkHandle(SALReader.in(), \"SALData::command_[set i][set revcode]DataReader::_narrow\");
  istatus = SALReader->take(Instances, info, 1,NOT_READ_SAMPLE_STATE, ANY_VIEW_STATE, ALIVE_INSTANCE_STATE);
  checkStatus(istatus, \"SALData::command_[set i][set revcode]DataReader::take\");
  if (Instances.length() > 0) \{
   j = Instances.length()-1;
   if (info\[j\].valid_data) \{
    if (debugLevel > 8) \{
      cout << \"=== \[acceptCommandC $i\] reading a command containing :\" << endl;
      cout << \"    seqNum   : \" << Instances\[j\].private_seqNum << endl;
      cout << \"    host     : \" << Instances\[j\].private_host << endl;
      cout << \"    origin   : \" << Instances\[j\].private_origin << endl;
      cout << \"    sample-state   : \" << info\[j\].sample_state << endl;
      cout << \"    view-state     : \" << info\[j\].view_state << endl;
      cout << \"    instance-state : \" << info\[j\].instance_state << endl;
    \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
    ackdata.SALDataID = subsystemID;
#endif
    ackdata.origin = Instances\[j\].private_origin;
    ackdata.host = Instances\[j\].private_host;
    ackdata.private_seqNum = Instances\[j\].private_seqNum;
    ackdata.cmdtype = actorIdx;
    ackdata.error = 0;
    ackdata.result = DDS::string_dup(\"SAL ACK\");
    status = Instances\[j\].private_seqNum;
    rcvdTime = getCurrentTime();
    sal\[actorIdx\].rcvStamp = rcvdTime;
    sal\[actorIdx\].sndStamp = Instances\[j\].private_sndStamp;
    if ( (rcvdTime - Instances\[j\].private_sndStamp) < sal\[actorIdx\].sampleAge ) \{
      rcvSeqNum = status;
      rcvOrigin = Instances\[j\].private_origin;
      sal\[actorIdx\].activehost = Instances\[j\].private_host;
      sal\[actorIdx\].activeorigin = Instances\[j\].private_origin;
      sal\[actorIdx\].activecmdid = Instances\[j\].private_seqNum;
      ackdata.ack = SAL__CMD_ACK;"
        set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set i]Cget.tmp r]
        while { [gets $fin rec] > -1 } {
           puts $fout $rec
        }
        close $fin
        puts $fout "
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
    ackHandle = SALWriter->register_instance(ackdata);
    ackdata.SALDataID = subsystemID;
#endif
    ackdata.private_sndStamp = getCurrentTime();"
     puts $fout "    istatus = SALWriter->write(ackdata, ackHandle);"
     puts $fout "    checkStatus(istatus, \"SALData::ackcmd[set ACKREVCODE]DataWriter::write\");"
   puts $fout "
//    SALWriter->unregister_instance(ackdata, ackHandle);
     \} else \{
        if (debugLevel > 8) \{
          cout << \"    Old command ignored : \" << status << \":\" << int(rcvdTime) << endl;
        \}
        status = 0;
     \}
   \}
  \} else \{
    status = 0;
  \}
  istatus = SALReader->return_loan(Instances, info);
  checkStatus(istatus, \"SALData::command_[set i][set revcode]DataReader::return_loan\");
  return status;
\}
"
   puts $fout "
salReturn SAL_SALData::waitForCompletion_[set i]( int cmdSeqNum , unsigned int timeout )
\{
   salReturn status = SAL__OK;
   int countdown = timeout*100;
   SALData::ackcmd[set ACKREVCODE]Seq response;
   int actorIdx = SAL__SALData_command_[set i]_ACTOR;

   while (status != SAL__CMD_COMPLETE && countdown != 0) \{
      status = getResponse_[set i](response);
      if (status != SAL__CMD_NOACK) \{
        if (sal\[actorIdx\].rcvSeqNum != cmdSeqNum) \{ 
           status = SAL__CMD_NOACK;
        \}
      \}
      usleep(SAL__SLOWPOLL);
      countdown--;
   \}
   if (status != SAL__CMD_COMPLETE) \{
      if (debugLevel >= SAL__LOG_ROUTINES) \{
          logError(status);
      \}
      if (debugLevel > 0) \{
         cout << \"=== \[waitForCompletion_[set i]\] command \" << cmdSeqNum <<  \" timed out :\" << endl;
      \} 
   \} else \{
      if (debugLevel > 0) \{
         cout << \"=== \[waitForCompletion_[set i]\] command \" << cmdSeqNum << \" completed ok :\" << endl;
      \} 
   \}
   return status;
\}
"
   puts $fout "
salReturn SAL_SALData::getResponse_[set i](SALData::ackcmd[set ACKREVCODE]Seq data)
\{
  int actorIdx = SAL__SALData_ackcmd_ACTOR;
  int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;
  SampleInfoSeq info;
  ReturnCode_t status = SAL__CMD_NOACK;
  ReturnCode_t istatus =  -1;
  int j=0;
  DataReader_var dreader = getReader2(actorIdx);
  SALData::ackcmd[set ACKREVCODE]DataReader_var SALReader = SALData::ackcmd[set ACKREVCODE]DataReader::_narrow(dreader.in());
  checkHandle(SALReader.in(), \"SALData::ackcmd[set ACKREVCODE]DataReader::_narrow\");
  istatus = SALReader->take(data, info, 1, NOT_READ_SAMPLE_STATE, ANY_VIEW_STATE, ALIVE_INSTANCE_STATE);
  sal\[actorIdxCmd\].rcvSeqNum = 0;
  sal\[actorIdxCmd\].rcvOrigin = 0;
  checkStatus(istatus, \"SALData::ackcmd[set ACKREVCODE]DataReader::take\");
  if (data.length() > 0) \{
   j = data.length()-1;
   if (data\[j\].private_seqNum > 0) \{
    if (debugLevel > 8) \{
      cout << \"=== \[getResponse_[set i]\] reading a message containing :\" << endl;
      cout << \"    seqNum   : \" << data\[j\].private_seqNum << endl;
      cout << \"    error    : \" << data\[j\].error << endl;
      cout << \"    ack      : \" << data\[j\].ack << endl;
      cout << \"    result   : \" << data\[j\].result << endl;
      cout << \"    sample-state : \" << info\[j\].sample_state << endl;
      cout << \"    view-state : \" << info\[j\].view_state << endl;
      cout << \"    instance-state : \" << info\[j\].instance_state << endl;
    \}
// check origin, host , cmdtype here
    status = data\[j\].ack;
    rcvdTime = getCurrentTime();
    sal\[actorIdxCmd\].rcvStamp = rcvdTime;
    sal\[actorIdxCmd\].sndStamp = data\[j\].private_sndStamp;
    sal\[actorIdxCmd\].rcvSeqNum = data\[j\].private_seqNum;
    sal\[actorIdxCmd\].rcvOrigin = data\[j\].private_origin;
    sal\[actorIdxCmd\].ack = data\[j\].ack;
    sal\[actorIdxCmd\].error = data\[j\].error;
    strcpy(sal\[actorIdxCmd\].result,DDS::string_dup(data\[j\].result));
   \} else \{
      if (debugLevel > 8) \{
         cout << \"=== \[getResponse_[set i]\] No ack yet!\" << endl;
      \}
      status = SAL__CMD_NOACK;
   \}
  \}
  istatus = SALReader->return_loan(data, info);
  checkStatus(istatus, \"SALData::ackcmd[set ACKREVCODE]DataReader::return_loan\");
  return status;
\}
"
   puts $fout "
salReturn SAL_SALData::getResponse_[set i]C(SALData_ackcmdC *response)
\{
  int actorIdx = SAL__SALData_ackcmd_ACTOR;
  int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;
  SampleInfoSeq info;
  SALData::ackcmd[set ACKREVCODE]Seq data;
  ReturnCode_t status = SAL__CMD_NOACK;
  ReturnCode_t istatus =  -1;
  int j=0;
  if ( response == NULL ) \{
     throw std::runtime_error(\"NULL pointer for getResponse_[set i]\");
  \}
  DataReader_var dreader = getReader2(actorIdx);
  SALData::ackcmd[set ACKREVCODE]DataReader_var SALReader = SALData::ackcmd[set ACKREVCODE]DataReader::_narrow(dreader.in());
  checkHandle(SALReader.in(), \"SALData::ackcmdDataReader::_narrow\");
  istatus = SALReader->take(data, info, 1, NOT_READ_SAMPLE_STATE, ANY_VIEW_STATE, ALIVE_INSTANCE_STATE);
  sal\[actorIdxCmd\].rcvSeqNum = 0;
  sal\[actorIdxCmd\].rcvOrigin = 0;
  checkStatus(istatus, \"SALData::ackcmd[set ACKREVCODE]DataReader::take\");
  if (data.length() > 0) \{
   j = data.length()-1;
   if (data\[j\].private_seqNum > 0) \{
    if (debugLevel > 8) \{
      cout << \"=== \[getResponse_[set i]\] reading a message containing :\" << endl;
      cout << \"    seqNum   : \" << data\[j\].private_seqNum << endl;
      cout << \"    error    : \" << data\[j\].error << endl;
      cout << \"    ack      : \" << data\[j\].ack << endl;
      cout << \"    result   : \" << data\[j\].result << endl;
      cout << \"    sample-state : \" << info\[j\].sample_state << endl;
      cout << \"    view-state : \" << info\[j\].view_state << endl;
      cout << \"    instance-state : \" << info\[j\].instance_state << endl;
    \}
// check origin, host , cmdtype here
    status = data\[j\].private_seqNum;;
    rcvdTime = getCurrentTime();
    sal\[actorIdxCmd\].rcvStamp = rcvdTime;
    sal\[actorIdxCmd\].sndStamp = data\[j\].private_sndStamp;
    sal\[actorIdxCmd\].rcvSeqNum = data\[j\].private_seqNum;
    sal\[actorIdxCmd\].rcvOrigin = data\[j\].private_origin;
    sal\[actorIdxCmd\].ack = data\[j\].ack;
    sal\[actorIdxCmd\].error = data\[j\].error;
    strcpy(sal\[actorIdxCmd\].result,DDS::string_dup(data\[j\].result));
    response->ack = data\[j\].ack;
    response->error = data\[j\].error;
    response->host = data\[j\].host;
    response->origin = data\[j\].origin;
    response->cmdtype = data\[j\].cmdtype;
    response->timeout = data\[j\].timeout;
    response->result= DDS::string_dup(data\[j\].result);
   \} else \{
      if (debugLevel > 8) \{
         cout << \"=== \[getResponse_[set i]C\] No ack yet!\" << endl;
      \}
      status = SAL__CMD_NOACK;
   \}
  \}
  istatus = SALReader->return_loan(data, info);
  checkStatus(istatus, \"SALData::ackcmd[set ACKREVCODE]DataReader::return_loan\");
  return status;
\}
"
   puts $fout "
salReturn SAL_SALData::ackCommand_[set i]( int cmdId, salLONG ack, salLONG error, char *result )
\{
   ReturnCode_t istatus = -1;
   InstanceHandle_t ackHandle = DDS::HANDLE_NIL;
   int actorIdx = SAL__SALData_ackcmd_ACTOR;
   int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;

   SALData::ackcmd[set ACKREVCODE] ackdata;
   DataWriter_var dwriter = getWriter2(actorIdx);
   SALData::ackcmd[set ACKREVCODE]DataWriter_var SALWriter = SALData::ackcmd[set ACKREVCODE]DataWriter::_narrow(dwriter.in());

   ackdata.private_origin = getpid();
   ackdata.private_seqNum = cmdId;
   ackdata.private_host = ddsIPaddress;
   ackdata.error = error;
   ackdata.ack = ack;
   ackdata.result = DDS::string_dup(result);
   ackdata.host = sal\[actorIdxCmd\].activehost;
   ackdata.origin = sal\[actorIdxCmd\].activeorigin;
   ackdata.cmdtype = actorIdxCmd;
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   ackdata.SALDataID = subsystemID;
#endif
   if (debugLevel > 0) \{
      cout << \"=== \[ackCommand_[set i]\] acknowledging a command with :\" << endl;
      cout << \"    seqNum   : \" << ackdata.private_seqNum << endl;
      cout << \"    ack      : \" << ackdata.ack << endl;
      cout << \"    error    : \" << ackdata.error << endl;
      cout << \"    host     : \" << ackdata.host << endl;
      cout << \"    origin    : \" << ackdata.origin << endl;
      cout << \"    result   : \" << ackdata.result << endl;
   \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   ackHandle = SALWriter->register_instance(ackdata);
   ackdata.SALDataID = subsystemID;
#endif
   ackdata.private_sndStamp = getCurrentTime();
   istatus = SALWriter->write(ackdata, ackHandle);
   checkStatus(istatus, \"SALData::ackcmd[set ACKREVCODE]DataWriter::return_loan\");
//    SALWriter->unregister_instance(ackdata, ackHandle);
   return SAL__OK;
\}
"
   puts $fout "
salReturn SAL_SALData::ackCommand_[set i]C(SALData_ackcmdC *response )
\{
   ReturnCode_t istatus = -1;
   InstanceHandle_t ackHandle = DDS::HANDLE_NIL;
   int actorIdx = SAL__SALData_ackcmd_ACTOR;
   int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;
   if ( response == NULL ) \{
      throw std::runtime_error(\"NULL pointer for ackCommand_[set i]\");
   \}

   SALData::ackcmd[set ACKREVCODE] ackdata;
   DataWriter_var dwriter = getWriter2(actorIdx);
   SALData::ackcmd[set ACKREVCODE]DataWriter_var SALWriter = SALData::ackcmd[set ACKREVCODE]DataWriter::_narrow(dwriter.in());

   ackdata.private_origin = getpid();
   ackdata.private_seqNum = sal\[actorIdxCmd\].activecmdid;
   ackdata.private_host = ddsIPaddress;
   ackdata.error = response->error;
   ackdata.ack = response->ack;
   ackdata.result = DDS::string_dup(response->result.c_str());
   ackdata.host = sal\[actorIdxCmd\].activehost;
   ackdata.origin = sal\[actorIdxCmd\].activeorigin;
   ackdata.cmdtype = actorIdxCmd;
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   ackdata.SALDataID = subsystemID;
#endif
   if (debugLevel > 0) \{
      cout << \"=== \[ackCommand_[set i]\] acknowledging a command with :\" << endl;
      cout << \"    seqNum   : \" << ackdata.private_seqNum << endl;
      cout << \"    ack      : \" << ackdata.ack << endl;
      cout << \"    error    : \" << ackdata.error << endl;
      cout << \"    host     : \" << ackdata.host << endl;
      cout << \"    origin    : \" << ackdata.origin << endl;
      cout << \"    result   : \" << ackdata.result << endl;
   \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   ackHandle = SALWriter->register_instance(ackdata);
   ackdata.SALDataID = subsystemID;
#endif
   ackdata.private_sndStamp = getCurrentTime();
   istatus = SALWriter->write(ackdata, ackHandle);
   checkStatus(istatus, \"SALData::ackcmd[set ACKREVCODE]DataWriter::return_loan\");
//    SALWriter->unregister_instance(ackdata, ackHandle);
   return SAL__OK;
\}
"
     } else {
#      stdlog "Alias $i has no parameters - uses standard [set subsys]_command"
     }
    }
   }
   if { $OPTIONS(verbose) } {stdlog "###TRACE<<< gencmdaliascpp $subsys $fout"}
}



proc gencmdaliasjava { subsys fout } {
global CMD_ALIASES CMDS SYSDIC ACKREVCODE
  if { [info exists CMD_ALIASES($subsys)] } {
   foreach i $CMD_ALIASES($subsys) {
    set revcode [getRevCode [set subsys]_command_[set i] short]
    stdlog "	: alias = $i , revCode = $revcode"
    if { [info exists CMDS($subsys,$i,param)] } {
      puts $fout "
	public int issueCommand_[set i]( command_[set i] data )
	\{
          Random randGen = new java.util.Random();
  	  long cmdHandle = HANDLE_NIL.value;
          command_[set i][set revcode] SALInstance = new command_[set i][set revcode]();
          int status;
          int actorIdx = SAL__SALData_command_[set i]_ACTOR;
	  DataWriter dwriter = getWriter(actorIdx);	
	  command_[set i][set revcode]DataWriter SALWriter = command_[set i][set revcode]DataWriterHelper.narrow(dwriter);
	  SALInstance.private_revCode = \"[string trim $revcode _]\";
	  SALInstance.private_seqNum = sal\[actorIdx\].sndSeqNum;
          SALInstance.private_origin = origin;
          SALInstance.private_host = ddsIPaddress;
          SALInstance.private_sndStamp = getCurrentTime();"
      if { [info exists SYSDIC($subsys,keyedID)] } {
        puts $fout "	  SALInstance.SALDataID = subsystemID;
	  cmdHandle = SALWriter.register_instance(SALInstance);"
      } else {
        puts $fout "	  SALWriter.register_instance(SALInstance);"
      }
      copytojavasample $fout $subsys command_[set i]
      puts $fout "
	  if (debugLevel > 0) \{
	    System.out.println( \"=== \[issueCommand\] $i writing a command\");
	  \}
	  status = SALWriter.write(SALInstance, cmdHandle);
	  sal\[actorIdx\].sndSeqNum++;
	  return (sal\[actorIdx\].sndSeqNum-1);
	\}
"
      puts $fout "
	public int acceptCommand_[set i]( SALData.command_[set i] data )
	\{
                command_[set i][set revcode]SeqHolder SALInstance = new command_[set i][set revcode]SeqHolder();
                SALData.ackcmd[set ACKREVCODE] ackdata;
   		SampleInfoSeqHolder info;
   		int status = 0;
                int j=0;
   		int istatus =  -1;
   		long ackHandle = HANDLE_NIL.value;
                int actorIdx = SAL__SALData_command_[set i]_ACTOR;

  		// create DataWriter :
  		DataWriter dwriter = getWriter2(SAL__SALData_ackcmd_ACTOR);
  		ackcmd[set ACKREVCODE]DataWriter SALWriter = ackcmd[set ACKREVCODE]DataWriterHelper.narrow(dwriter);
  		DataReader dreader = getReader(actorIdx);
  		command_[set i][set revcode]DataReader SALReader = command_[set i][set revcode]DataReaderHelper.narrow(dreader);
                info = new SampleInfoSeqHolder();
  		istatus = SALReader.take(SALInstance, info, 1, NOT_READ_SAMPLE_STATE.value, ANY_VIEW_STATE.value, ALIVE_INSTANCE_STATE.value);
		if (SALInstance.value.length > 0) \{
   		  if (info.value\[0\].valid_data) \{
    		     if (debugLevel > 8) \{
      			System.out.println(  \"=== \[acceptCommand\] $i reading a command containing :\" );
      			System.out.println(  \"    seqNum   : \" + SALInstance.value\[0\].private_seqNum );
    		    \}
    		    status = SALInstance.value\[0\].private_seqNum;
    		    double rcvdTime = getCurrentTime();
		    double dTime = rcvdTime - SALInstance.value\[0\].private_sndStamp;
    		    if ( dTime < sal\[actorIdx\].sampleAge ) \{
                      sal\[actorIdx\].activehost = SALInstance.value\[0\].private_host;
                      sal\[actorIdx\].activeorigin = SALInstance.value\[0\].private_origin;
                      sal\[actorIdx\].activecmdid = SALInstance.value\[0\].private_seqNum;
                      ackdata = new SALData.ackcmd[set ACKREVCODE]();"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "	              ackdata.SALDataID = subsystemID;"
      }
      puts $fout "		      ackdata.private_origin = SALInstance.value\[0\].private_origin;
		      ackdata.private_seqNum = SALInstance.value\[0\].private_seqNum;
		      ackdata.error  = 0;
		      ackdata.result = \"SAL ACK\";"
           copyfromjavasample $fout $subsys command_[set i]
           puts $fout "
		      status = SALInstance.value\[0\].private_seqNum;
		      rcvSeqNum = status;
		      rcvOrigin = SALInstance.value\[0\].private_origin;
		      ackdata.ack = SAL__CMD_ACK;"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "		      ackdata.SALDataID = subsystemID;
		      ackHandle = SALWriter.register_instance(ackdata);"
      }
      puts $fout "
		      istatus = SALWriter.write(ackdata, ackHandle);
"
      puts $fout "
    		     if (debugLevel > 8) \{
      			System.out.println(  \"    Old command ignored :   \" + dTime );
                     \}
                   \}
		 \}
                \} else \{
  	           status = 0;
                \}
                SALReader.return_loan(SALInstance, info);
	        return status;
	\}
"
   puts $fout "
	public int waitForCompletion_[set i]( int cmdSeqNum , int timeout )
	\{
	   int status = 0;
           int actorIdx = SAL__SALData_command_[set i]_ACTOR;
	   ackcmd[set ACKREVCODE]SeqHolder ackcmd = new ackcmd[set ACKREVCODE]SeqHolder();
           long finishBy = System.currentTimeMillis() + timeout*1000;

	   while (status != SAL__CMD_COMPLETE && System.currentTimeMillis() < finishBy ) \{
	      status = getResponse_[set i](ackcmd);
	      if (status != SAL__CMD_NOACK) \{
	        if (sal\[actorIdx\].rcvSeqNum != cmdSeqNum) \{ 
	           status = SAL__CMD_NOACK;
	        \}
	      \}
	      try
		\{
	 	  Thread.sleep(1);
		\}
		catch(InterruptedException ie)
		\{
			// nothing to do
	      \}
	   \}
	   if (status != SAL__CMD_COMPLETE) \{
	      if (debugLevel > 0) \{
	         System.out.println( \"=== \[waitForCompletion_[set i]\] command \" + cmdSeqNum +  \" timed out\");
	      \} 
	      logError(status);
	   \} else \{
	      if (debugLevel > 0) \{
	         System.out.println( \"=== \[waitForCompletion_[set i]\] command \" + cmdSeqNum +  \" completed ok\");
	      \} 
           \}
 	   return status;
	\}
"
    puts $fout "
	public int waitForAck_[set i]( int timeout , ackcmd ack)
	\{
	   int status = 0;
           int actorIdx = SAL__SALData_ackcmd_ACTOR;
	   ackcmd[set ACKREVCODE]SeqHolder ackcmd = new ackcmd[set ACKREVCODE]SeqHolder();
           long finishBy = System.currentTimeMillis() + timeout*1000;

	   while (status == SAL__CMD_NOACK && System.currentTimeMillis() < finishBy ) \{
	      status = getResponse_[set i](ackcmd);
	      if (status != SAL__CMD_NOACK) \{
  		ack.private_seqNum = sal\[actorIdx\].rcvSeqNum;
   		ack.error = sal\[actorIdx\].error;
   		ack.ack = sal\[actorIdx\].ack;
   		ack.result = sal\[actorIdx\].result;
	      \}
	      try
		\{
	 	  Thread.sleep(1);
		\}
		catch(InterruptedException ie)
		\{
			// nothing to do
	      \}
	   \}
	   if (debugLevel > 0) \{
	      System.out.println( \"=== \[waitForAck_[set i]\] ack \" + status);
	   \} 
 	   return status;
	\}
"
  puts $fout "
	public int getResponse_[set i](ackcmd[set ACKREVCODE]SeqHolder data)
	\{
	  int status =  -1;
          int lastsample = 0;
          int actorIdx = SAL__SALData_ackcmd_ACTOR;
          int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;

	  DataReader dreader = getReader2(actorIdx);
	  ackcmd[set ACKREVCODE]DataReader SALReader = ackcmd[set ACKREVCODE]DataReaderHelper.narrow(dreader);
  	  SampleInfoSeqHolder infoSeq = new SampleInfoSeqHolder();
	  SALReader.take(data, infoSeq, 1, 
					NOT_READ_SAMPLE_STATE.value,
					ANY_VIEW_STATE.value,
					ALIVE_INSTANCE_STATE.value);
	  if (data.value.length > 0) \{
 		for (int i = 0; i < data.value.length; i++) \{
                     if ( debugLevel > 8) \{
				System.out.println(\"=== \[getResponse_[set i]\] message received :\");
				System.out.println(\"    revCode  : \"
						+ data.value\[i\].private_revCode);
		    \}
                    lastsample = i;
		\}
	 	status = data.value\[lastsample\].ack;
	  	sal\[actorIdxCmd\].rcvSeqNum = data.value\[lastsample\].private_seqNum;
	  	sal\[actorIdxCmd\].rcvOrigin = data.value\[lastsample\].private_origin;
	  \} else \{
                if ( debugLevel > 8) \{
	            System.out.println(\"=== \[getResponse_[set i]\] No ack yet!\"); 
                \}
	        status = SAL__CMD_NOACK;
	  \}
    	  SALReader.return_loan(data, infoSeq);
	  return status;
	\}
"
   puts $fout "
	public int ackCommand_[set i]( int cmdId, int ack, int error, String result )
	\{
   		int istatus = -1;
   		long ackHandle = HANDLE_NIL.value;
                int actorIdx = SAL__SALData_command_[set i]_ACTOR;
                int actorIdx2 = SAL__SALData_ackcmd_ACTOR;

   		SALData.ackcmd[set ACKREVCODE] ackdata;
   		DataWriter dwriter = getWriter2(actorIdx2);
   		ackcmd[set ACKREVCODE]DataWriter SALWriter = ackcmd[set ACKREVCODE]DataWriterHelper.narrow(dwriter);
                ackdata = new SALData.ackcmd[set ACKREVCODE]();
   		ackdata.private_origin = sal\[actorIdx\].rcvOrigin;
   		ackdata.private_seqNum = cmdId;
   		ackdata.error = error;
   		ackdata.ack = ack;
                ackdata.origin = sal\[actorIdx\].activeorigin;
                ackdata.host = sal\[actorIdx\].activehost;
                ackdata.private_host = ddsIPaddress;
                ackdata.private_origin = origin;
   		ackdata.result = result;"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "   		ackdata.SALDataID = subsystemID;"
      }
      puts $fout "
   		if (debugLevel > 0) \{
      			System.out.println(  \"=== \[ackCommand_[set i]\] acknowledging a command with :\" );
      			System.out.println(  \"    seqNum   : \" + ackdata.private_seqNum );
      			System.out.println(  \"    ack      : \" + ackdata.ack );
      			System.out.println(  \"    error    : \" + ackdata.error );
      			System.out.println(  \"    host     : \" + ackdata.host );
      			System.out.println(  \"    origin   : \" + ackdata.origin );
      			System.out.println(  \"    result   : \" + ackdata.result );
   		\}"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "   		ackdata.SALDataID = subsystemID;
   		ackHandle = SALWriter.register_instance(ackdata);"
      }
      puts $fout "   		istatus = SALWriter.write(ackdata, ackHandle);"
      puts $fout "
   		return SAL__OK;
	\}
"
    } else {
#      stdlog "Alias $i has no parameters - uses standard [set subsys]_command"
    }
  }
 }
}



proc gencmdaliaspython { subsys fout } {
global CMD_ALIASES CMDS
  if { [info exists CMD_ALIASES($subsys)] } {
   puts $fout "
        .def( 
            \"salCommand\"
            , (::salReturn ( ::SAL_SALData::* )( char * ) )( &::SAL_SALData::salCommand )
            , ( py::arg(\"topicName\") ) )    
        .def( 
            \"salProcessor\"
            , (::salReturn ( ::SAL_SALData::* )( char * ) )( &::SAL_SALData::salProcessor )
            , ( py::arg(\"topicName\") ) )    
"
   foreach i $CMD_ALIASES($subsys) {
    if { [info exists CMDS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
      puts $fout "
        .def( \"issueCommand_[set i]\",       &SAL_SALData::issueCommand_[set i] )
        .def( \"acceptCommand_[set i]\",      &SAL_SALData::acceptCommand_[set i] )
        .def( \"ackCommand_[set i]\",         &SAL_SALData::ackCommand_[set i] )
        .def( \"ackCommand_[set i]C\",         &SAL_SALData::ackCommand_[set i]C )
        .def( \"waitForCompletion_[set i]\",  &SAL_SALData::waitForCompletion_[set i] )
        .def( \"getResponse_[set i]\",        &SAL_SALData::getResponse_[set i]C )
      "
    } else {
      stdlog "Alias $i has no parameters - uses standard [set subsys]_command"
    }
   }
  }
}



proc gencmdaliasisocpp { subsys fout } {
global CMD_ALIASES CMDS
  if { [info exists CMD_ALIASES($subsys)] } {
   foreach i $CMD_ALIASES($subsys) { 
    if { [info exists CMDS($subsys,$i,param)] } {
      stdlog "	: alias = $i"
    } else {
      stdlog "Alias $i has no parameters - uses standard [set subsys]_command"
    }
   }
  }
}


proc gencmdgenericjava { subsys fout } {
global SYSDIC
   puts $fout "
	public void salCommand(String cmdAlias)
	\{
          int actorIdx = getActorIndex(cmdAlias);
	  String stopic1=\"keyedCommand\";
	  String stopic2=\"keyedResponse\";
	  String sresponse=\"SALData_ackcmd\";

	  // create domain participant
	  createParticipant(domainName);

	  //create Publisher
	  createPublisher(actorIdx);

	  //create types
	  salTypeSupport(actorIdx);

	  //create Topics
	  createTopic(actorIdx,cmdAlias);
	  boolean autodispose_unregistered_instances = true;
	  createWriter(actorIdx,autodispose_unregistered_instances);
	  sal\[actorIdx\].isWriter = true;
	  sal\[actorIdx\].isCommand = true;
          sal\[SAL__SALData_ackcmd_ACTOR\].sampleAge = 1.0;
          sal\[actorIdx\].sndSeqNum = (int)getCurrentTime() + 32768*actorIdx;
	
          if ( sal\[SAL__SALData_ackcmd_ACTOR\].isReader == false ) \{
	    createSubscriber(SAL__SALData_ackcmd_ACTOR);
	    SALResponseTypeSupport mtr = new SALResponseTypeSupport();
	    registerType2(SAL__SALData_ackcmd_ACTOR,mtr);
	    createTopic2(SAL__SALData_ackcmd_ACTOR,sresponse);
	    //create a reader for responses
"
   if { [info exists SYSDIC($subsys,keyedID)] } {
      puts $fout "
  	    // Filter expr
            String expr\[\] = new String\[0\];
            String sFilter = \"SALDataID = \" + subsystemID;
    	    createContentFilteredTopic2(SAL__SALData_ackcmd_ACTOR,\"filteredResponse\", sFilter, expr);

	    // create DataReader
 	    createReader2(SAL__SALData_ackcmd_ACTOR,false);
"
   } else {
      puts $fout "
	    createReader2(SAL__SALData_ackcmd_ACTOR,false);
"
   }
   puts $fout "
 	    sal\[SAL__SALData_ackcmd_ACTOR\].isReader = true;
          \}

	\}

	public void salProcessor(String cmdAlias)
	\{
          int actorIdx = getActorIndex(cmdAlias);
	  String stopic1=\"keyedCommand\";
	  String stopic2=\"keyedResponse\";
	  String sresponse=\"SALData_ackcmd\";

	  // create domain participant
	  createParticipant(domainName);

	  createSubscriber(actorIdx);

	  //create types
	  salTypeSupport(actorIdx);

	  //create Topics
	  createTopic(actorIdx,cmdAlias);

	  //create a reader for commands
"
   if { [info exists SYSDIC($subsys,keyedID)] } {
      puts $fout "
  	  // Filter expr
          String expr\[\] = new String\[0\];
          String sFilter = \"SALDataID = \" + subsystemID;
          String fCmd = \"filteredCmd\" + sal\[actorIdx\].topicHandle;
    	  createContentFilteredTopic(actorIdx,fCmd, sFilter, expr);
 	  createReader(actorIdx,false);
"
   } else {
       puts $fout "
	  createReader(actorIdx,false);
"
   }
   puts $fout "
          if (sal\[actorIdx\].isProcessor == false) \{
  	    //create Publisher
	    createPublisher(SAL__SALData_ackcmd_ACTOR);
	    SALResponseTypeSupport mtr = new SALResponseTypeSupport();
	    registerType2(SAL__SALData_ackcmd_ACTOR,mtr);
	    createTopic2(SAL__SALData_ackcmd_ACTOR,sresponse);
   	    boolean autodispose_unregistered_instances = true;
	    createWriter2(SAL__SALData_ackcmd_ACTOR,autodispose_unregistered_instances);
	    sal\[SAL__SALData_ackcmd_ACTOR\].isWriter = true;
          \}
	  sal\[actorIdx\].isProcessor = true;
          sal\[actorIdx\].sampleAge = 1.0;
	\}
"
}





