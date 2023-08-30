#!/usr/bin/env tclsh
## \file gencmdaliascode.tcl
# \brief This contains procedures to create the SAL API code
#  to manager the Command Topics. It generates code and tests
#  for C++, and Java APIs
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, V3 
#\n
# Copyright 2012-2021 Association of Universities for Research in Astronomy, Inc. (AURA)
#\n
#
#
#\code

source $SAL_DIR/gencommandtests.tcl
source $SAL_DIR/gencommandtestssinglefile.tcl 
source $SAL_DIR/gencommandtestsjava.tcl
source $SAL_DIR/gencommandtestssinglefilejava.tcl
source $SAL_DIR/activaterevcodes.tcl 

#
## Documented proc \c addgenericcmdcode .
# \param[in] fout File handle of output file
# \param[in] lang Target language to generate code for
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Copy the generic DDS code to manage command Topics
#  using the template in code/templates/SALDDS.lang.template
#  where lang = cpp,java
#
proc addgenericcmdcode { fout lang subsys } {
global OPTIONS SAL_DIR
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> addgenericcmdcode $lang $fout $subsys"}
  stdlog "Generate command generic support for $lang"
  set fin [open  $SAL_DIR/code/templates/SALDDS.[set lang]-cmd.template r]
  if { $subsys == "LOVE" } {
     set done 0
     while { [gets $fin rec] > -1 && $done == 0} {
       if { $rec == "// NOT FOR LOVE CSC" } {
          set done 1
       } else {
         puts $fout $rec
       }
     }
  } else {
     while { [gets $fin rec] > -1 } {
       puts $fout $rec
     }
  }
  close $fin
  if { $OPTIONS(verbose) } {stdlog "###TRACE<<< addgenericcmdcode $lang $fout $subsys"}
}


#
## Documented proc \c gencmdaliascode .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] lang Target language to generate code for
# \param[in] fout File handle of output file
#
#  Generates the Command handling code for a Subsystem/CSC.
#  Code is generated for issueCommand,acceptCommand,waitForCompletion,ackCommand,getResponse
#  per-command Topic type. This routine generates header code, and then calls 
#  per language routines to generate the rest.
#
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
         set turl [getTopicURL $subsys $i]
         puts $fout "
/** Issue the [set i] command to the SALData subsystem
  * @param data is the command payload $turl
  * @returns the sequence number aka command id
  */
      int issueCommand_[set i]( SALData_command_[set i]C *data );

/** Accept the [set i] command. The
  * unless commanding is currently blocked by the authList setting (in which case the command will be ack = SAL__CMD_NOPERM
  * and no cmdId will be returned to the caller (=0)
  * @param data is the command payload $turl
  */
      int acceptCommand_[set i]( SALData_command_[set i]C *data );

/** Wait for the arrival of command ack. If no instance arrives before the timeout then return SAL__CMD_NOACK
  * else returns SAL__OK if a command message has been received.
  * @param cmdSeqNum is the sequence number of the command involved, as returned by issueCommand
  */
      salReturn waitForCompletion_[set i]( int cmdSeqNum , unsigned int timeout );

/** Acknowledge a command by sending an ackCmd message
  * @param cmdSeqNum is the sequence number of the command involved as obtained from private_seqNum in the command message
  * @param ack is the status , one of the SAL__CMD_ACK/NOACK/INPROGRESS/STALLED/NOPERM/FAILED/ABORTED/TIMEOUT/COMPLETE codes
  * @param error is a more detailed per subssystem specific error code for failed commands
  * @param result is an informative message to be displayed to the operator,stored in the EFD etc
  */
      salReturn ackCommand_[set i]( int cmdSeqNum, salLONG  ack, salLONG error, char *result, double timeout=0.0 );

/** Acknowledge a command by sending an ackCmd message, this time with access to all the ackCmd message payload
  * @param data is the ackCmd topic data
  */
      salReturn ackCommand_[set i]C( SALData_ackcmdC *data );

      salReturn getResponse_[set i]( SALData::ackcmd[set ACKREVCODE]Seq data );

/** Get the response (ack) from a command transaction. It is up to the application to validate against the 
  * command sequence number and command type if multiple commands may be in-progress simultaneously
  * @param data is the ackCmd payload
  * @returns SAL__CMD_NOACK if no ackCmd is available, or SAL__OK if there is
  */
      salReturn getResponse_[set i]C (SALData_ackcmdC *data );"
       }
     }
  }
  if { $lang == "cpp" } {
     addgenericcmdcode $fout $lang $subsys
     set result none
     catch { set result [gencmdaliascpp $subsys $fout] } bad
     if { $result == "none" } {stdlog $bad ; errorexit "failure in gencmdaliascpp" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       set result none
       catch { set result [gencommandtestscpp $subsys] } bad
       if { $result == "none" } {stdlog $bad ; errorexit "failure in gencommandtestscpp" }
       stdlog "$result"
       set result none
       catch { set result [genauthlisttestscpp $subsys] } bad
       if { $result == "none" } {stdlog $bad ; errorexit "failure in genauthlisttestscpp" }
       stdlog "$result"
     }
  }
  if { $lang == "java" }  {
     set result none
     gencmdgenericjava $subsys $fout
     catch { set result [gencmdaliasjava $subsys $fout] } bad
     if { $result == "none" } {stdlog $bad ; errorexit "failure in gencmdaliasjava" }
     stdlog "$result"
     if { $DONE_CMDEVT == 0} {
       set result none
       catch { set result [gencommandtestsjava $subsys] } bad
       stdlog "$result"
       if { $result == "none" } {stdlog $bad ; errorexit "failure in gencommandtestsjava" }
     }
  }
  if { $lang == "isocpp" } {
     set result none
     if { $result == "none" } {stdlog $bad ; errorexit "failure in addgenericcmdcode" }
     addgenericcmdcode $fout $lang $subsys
     catch { set result [gencmdaliasisocpp $subsys $fout] } bad
     if { $result == "none" } {stdlog $bad ; errorexit "failure in gencmdaliasisocpp" }
     stdlog "$result"
  }
 }
 if { $OPTIONS(verbose) } {stdlog "###TRACE<<< gencmdaliascode $subsys $lang $fout"}
}


#
## Documented proc \c gencmdaliascpp .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Generates the Command handling code for a Subsystem/CSC.
#  Code is generated for issueCommand,acceptCommand,waitForCompletion,ackCommand,getResponse
#  per-command Topic type. This routine generates C++ code.
#
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
  \}"
  set frag [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set i]Cchk.tmp r]
  while { [gets $frag rec] > -1} {puts $fout $rec}
  close $frag
  puts $fout "
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
  Instance.salIndex = subsystemID;
  cmdHandle = SALWriter->register_instance(Instance);
#endif

  Instance.private_revCode =  DDS::string_dup(\"[string trim $revcode _]\");
  Instance.private_sndStamp = getCurrentTime();
  Instance.private_origin = getpid();
  Instance.private_identity = DDS::string_dup(CSC_identity);
  Instance.private_seqNum =   sal\[actorIdx\].sndSeqNum;"
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
  \}"
  if { $i != "setAuthList" } {
     puts $fout "	checkAuthList(sal\[actorIdx\].activeidentity);"
  }
  puts $fout "
  DataWriter_var dwriter = getWriter2(SAL__SALData_ackcmd_ACTOR);
  SALData::ackcmd[set ACKREVCODE]DataWriter_var SALWriter = SALData::ackcmd[set ACKREVCODE]DataWriter::_narrow(dwriter.in());
  DataReader_var dreader = getReader(actorIdx);
  SALData::command_[set i][set revcode]DataReader_var SALReader = SALData::command_[set i][set revcode]DataReader::_narrow(dreader.in());
  checkHandle(SALReader.in(), \"SALData::command_[set i][set revcode]DataReader::_narrow\");
  istatus = SALReader->take(Instances, info, 1,NOT_READ_SAMPLE_STATE, ANY_VIEW_STATE, ANY_INSTANCE_STATE);
  checkStatus(istatus, \"SALData::command_[set i][set revcode]DataReader::take\");
  if (Instances.length() > 0) \{
   j = Instances.length()-1;
   if (info\[j\].valid_data) \{
    if (debugLevel > 8) \{
      cout << \"=== \[acceptCommandC $i\] reading a command containing :\" << endl;
      cout << \"    seqNum   : \" << Instances\[j\].private_seqNum << endl;
      cout << \"    origin   : \" << Instances\[j\].private_origin << endl;
      cout << \"    identity   : \" << Instances\[j\].private_identity << endl;
      cout << \"    sample-state   : \" << info\[j\].sample_state << endl;
      cout << \"    view-state     : \" << info\[j\].view_state << endl;
      cout << \"    instance-state : \" << info\[j\].instance_state << endl;
    \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
    ackdata.salIndex = subsystemID;
#endif
    ackdata.identity = Instances\[j\].private_identity;
    ackdata.origin = Instances\[j\].private_origin;
    ackdata.private_seqNum = Instances\[j\].private_seqNum;
    ackdata.private_revCode = DDS::string_dup(\"[string trim $ACKREVCODE _]\");
    ackdata.private_sndStamp = getCurrentTime();
    ackdata.cmdtype = actorIdx;
    ackdata.error = 0;
    ackdata.result = DDS::string_dup(\"SAL ACK\");
    status = Instances\[j\].private_seqNum;
    ackdata.private_revCode =  DDS::string_dup(\"[string trim $ACKREVCODE _]\");
    ackdata.private_sndStamp = getCurrentTime();
    rcvdTime = getCurrentTime();
    sal\[actorIdx\].rcvStamp = rcvdTime;
    sal\[actorIdx\].sndStamp = Instances\[j\].private_sndStamp;
    if ( (rcvdTime - Instances\[j\].private_sndStamp) < sal\[actorIdx\].sampleAge ) \{
      rcvSeqNum = status;
      rcvOrigin = Instances\[j\].private_origin;
      rcvIdentity = Instances\[j\].private_identity;
      sal\[actorIdx\].activeorigin = Instances\[j\].private_origin;
      sal\[actorIdx\].activeidentity = Instances\[j\].private_identity;
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
    ackdata.salIndex = subsystemID;
#endif
    ackdata.private_sndStamp = getCurrentTime();
"
     if { $subsys != "LOVE" } {
       puts $fout "
    if ( actorIdx != SAL__SALData_command_setAuthList_ACTOR ) \{
      if (checkAuthList(sal\[actorIdx\].activeidentity) != SAL__OK) \{
        ackdata.ack = SAL__CMD_NOPERM;
        ackdata.error = 1;
        ackdata.result = DDS::string_dup(\"Commanding not permitted by authList setting\");
        status = 0;
      \}
    \}
"
     }
     puts $fout "    
    if ( ackdata.ack != SAL__CMD_ACK ) \{
       istatus = SALWriter->write(ackdata, ackHandle);
       checkStatus(istatus, \"SALData::ackcmd[set ACKREVCODE]DataWriter::write\");
    \}
"
   puts $fout "
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
      if (status == SAL__CMD_NOPERM) \{
        if (debugLevel > 0) \{
          cout << \"=== \[waitForCompletion_[set i]\] command \" << cmdSeqNum <<  \" Not permitted by authList\" << endl;
        \}
        return status;
      \}
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
  sal\[actorIdxCmd\].rcvIdentity = \"\";
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
// check identity, cmdtype here
    status = data\[j\].ack;
    rcvdTime = getCurrentTime();
    sal\[actorIdxCmd\].rcvStamp = rcvdTime;
    sal\[actorIdxCmd\].sndStamp = data\[j\].private_sndStamp;
    sal\[actorIdxCmd\].rcvSeqNum = data\[j\].private_seqNum;
    sal\[actorIdxCmd\].rcvOrigin = data\[j\].private_origin;
    sal\[actorIdxCmd\].rcvIdentity = data\[j\].private_identity;
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
  sal\[actorIdxCmd\].rcvIdentity = \"\";
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
// check identity, cmdtype here
    status = data\[j\].private_seqNum;;
    rcvdTime = getCurrentTime();
    sal\[actorIdxCmd\].rcvStamp = rcvdTime;
    sal\[actorIdxCmd\].sndStamp = data\[j\].private_sndStamp;
    sal\[actorIdxCmd\].rcvSeqNum = data\[j\].private_seqNum;
    sal\[actorIdxCmd\].rcvOrigin = data\[j\].private_origin;
    sal\[actorIdxCmd\].rcvIdentity = data\[j\].private_identity;
    sal\[actorIdxCmd\].ack = data\[j\].ack;
    sal\[actorIdxCmd\].error = data\[j\].error;
    strcpy(sal\[actorIdxCmd\].result,DDS::string_dup(data\[j\].result));
    response->ack = data\[j\].ack;
    response->error = data\[j\].error;
    response->origin = data\[j\].origin;
    response->identity = data\[j\].identity;
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
salReturn SAL_SALData::ackCommand_[set i]( int cmdId, salLONG ack, salLONG error, char *result, double timeout )
\{
   ReturnCode_t istatus = -1;
   InstanceHandle_t ackHandle = DDS::HANDLE_NIL;
   int actorIdx = SAL__SALData_ackcmd_ACTOR;
   int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;

   SALData::ackcmd[set ACKREVCODE] ackdata;
   DataWriter_var dwriter = getWriter2(actorIdx);
   SALData::ackcmd[set ACKREVCODE]DataWriter_var SALWriter = SALData::ackcmd[set ACKREVCODE]DataWriter::_narrow(dwriter.in());

   ackdata.private_seqNum = cmdId;
   ackdata.private_identity = DDS::string_dup(CSC_identity);
   ackdata.error = error;
   ackdata.ack = ack;
   ackdata.result = DDS::string_dup(result);
   ackdata.origin = sal\[actorIdxCmd\].activeorigin;
   ackdata.identity = DDS::string_dup(sal\[actorIdxCmd\].activeidentity.c_str());
   ackdata.cmdtype = actorIdxCmd;
   ackdata.timeout = timeout;
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   ackdata.salIndex = subsystemID;
#endif
   if (debugLevel > 0) \{
      cout << \"=== \[ackCommand_[set i]\] acknowledging a command with :\" << endl;
      cout << \"    seqNum   : \" << ackdata.private_seqNum << endl;
      cout << \"    ack      : \" << ackdata.ack << endl;
      cout << \"    error    : \" << ackdata.error << endl;
      cout << \"    origin    : \" << ackdata.origin << endl;
      cout << \"    identity    : \" << ackdata.identity << endl;
      cout << \"    result   : \" << ackdata.result << endl;
      cout << \"    timeout  : \" << ackdata.timeout << endl;
   \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   ackHandle = SALWriter->register_instance(ackdata);
   ackdata.salIndex = subsystemID;
#endif
   ackdata.private_revCode = DDS::string_dup(\"[string trim $ACKREVCODE _]\");
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

   ackdata.private_seqNum = sal\[actorIdxCmd\].activecmdid;
   ackdata.private_origin = getpid();
   ackdata.private_identity = DDS::string_dup(CSC_identity);
   ackdata.error = response->error;
   ackdata.ack = response->ack;
   ackdata.result = DDS::string_dup(response->result.c_str());
   ackdata.origin = sal\[actorIdxCmd\].activeorigin;
   ackdata.identity = DDS::string_dup(sal\[actorIdxCmd\].activeidentity.c_str());
   ackdata.cmdtype = actorIdxCmd;
   ackdata.timeout = response->timeout;
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   ackdata.salIndex = subsystemID;
#endif
   if (debugLevel > 0) \{
      cout << \"=== \[ackCommand_[set i]\] acknowledging a command with :\" << endl;
      cout << \"    seqNum   : \" << ackdata.private_seqNum << endl;
      cout << \"    ack      : \" << ackdata.ack << endl;
      cout << \"    error    : \" << ackdata.error << endl;
      cout << \"    origin    : \" << ackdata.origin << endl;
      cout << \"    identity    : \" << ackdata.identity << endl;
      cout << \"    result   : \" << ackdata.result << endl;
      cout << \"    timeout  : \" << ackdata.timeout << endl;
   \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   ackHandle = SALWriter->register_instance(ackdata);
   ackdata.salIndex = subsystemID;
#endif
   ackdata.private_revCode = DDS::string_dup(\"[string trim $ACKREVCODE _]\");
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



#
## Documented proc \c gencmdaliasjava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Generates the Command handling code for a Subsystem/CSC.
#  Code is generated for issueCommand,acceptCommand,waitForCompletion,ackCommand,getResponse
#  per-command Topic type. This routine generates Java code.
#
proc gencmdaliasjava { subsys fout } {
global CMD_ALIASES CMDS SYSDIC ACKREVCODE
  if { [info exists CMD_ALIASES($subsys)] } {
   foreach i $CMD_ALIASES($subsys) {
    set revcode [getRevCode [set subsys]_command_[set i] short]
    stdlog "	: alias = $i , revCode = $revcode"
    if { [info exists CMDS($subsys,$i,param)] } {
      set turl [getTopicURL $subsys $i]
      puts $fout "
/** Issue the [set i] command to the SALData subsystem
  * @param data is the command payload $turl
  * @returns the sequence number aka command id
  */
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
          SALInstance.private_identity = CSC_identity;
          SALInstance.private_origin = origin;
          SALInstance.private_sndStamp = getCurrentTime();"
      if { [info exists SYSDIC($subsys,keyedID)] } {
        puts $fout "	  SALInstance.salIndex = subsystemID;
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
/** Accept the [set i] command.
    unless commanding is currently blocked by the authList setting, in which case the command will be ack = SAL__CMD_NOPERM
    and no cmdId will be returned to the caller (=0)
  * @param data is the command payload $turl
  */
	public int acceptCommand_[set i]( SALData.command_[set i] data )
	\{
                command_[set i][set revcode]SeqHolder SALInstance = new command_[set i][set revcode]SeqHolder();
                SALData.ackcmd[set ACKREVCODE] ackdata;
   		SampleInfoSeqHolder info;
   		int status = 0;
                int j=0;
   		int istatus =  -1;
                String dummy=\"\";
   		long ackHandle = HANDLE_NIL.value;
                int actorIdx = SAL__SALData_command_[set i]_ACTOR;
"
      if { $i != "setAuthList" } { 
         puts $fout "		checkAuthList(dummy);"
      }
      puts $fout "
  		// create DataWriter :
  		DataWriter dwriter = getWriter2(SAL__SALData_ackcmd_ACTOR);
  		ackcmd[set ACKREVCODE]DataWriter SALWriter = ackcmd[set ACKREVCODE]DataWriterHelper.narrow(dwriter);
  		DataReader dreader = getReader(actorIdx);
  		command_[set i][set revcode]DataReader SALReader = command_[set i][set revcode]DataReaderHelper.narrow(dreader);
                info = new SampleInfoSeqHolder();
  		istatus = SALReader.take(SALInstance, info, 1, NOT_READ_SAMPLE_STATE.value, ANY_VIEW_STATE.value, ANY_INSTANCE_STATE.value);
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
                      sal\[actorIdx\].activeorigin = SALInstance.value\[0\].private_origin;
                      sal\[actorIdx\].activeidentity = SALInstance.value\[0\].private_identity;
                      sal\[actorIdx\].activecmdid = SALInstance.value\[0\].private_seqNum;
                      ackdata = new SALData.ackcmd[set ACKREVCODE]();"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "	              ackdata.salIndex = subsystemID;"
      }
      puts $fout "		      ackdata.private_identity = SALInstance.value\[0\].private_identity;
		      ackdata.private_origin = SALInstance.value\[0\].private_origin;
		      ackdata.private_seqNum = SALInstance.value\[0\].private_seqNum;
                      ackdata.private_revCode = \"[string trim $ACKREVCODE _]\";
                      ackdata.private_sndStamp = getCurrentTime();
		      ackdata.error  = 0;
		      ackdata.result = \"SAL ACK\";"
           copyfromjavasample $fout $subsys command_[set i]
           puts $fout "
		      status = SALInstance.value\[0\].private_seqNum;
		      rcvSeqNum = status;
		      rcvOrigin = SALInstance.value\[0\].private_origin;
		      rcvIdentity = SALInstance.value\[0\].private_identity;
		      ackdata.ack = SAL__CMD_ACK;
"
           if { $subsys != "LOVE" } {
              puts $fout "
                      if ( actorIdx != SAL__SALData_command_setAuthList_ACTOR ) \{
		        if (checkAuthList(sal\[actorIdx\].activeidentity) != SAL__OK) \{
       			  ackdata.ack = SAL__CMD_NOPERM;
       			  ackdata.error = 1;
       			  ackdata.result = \"Commanding not permitted by authList setting\";
       			  status = 0;
    		        \}
                       \}
"
           }
      puts $fout "
                 if ( ackdata.ack != SAL__CMD_ACK ) \{"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "		      ackdata.salIndex = subsystemID;
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
		 \}
                \} else \{
  	           status = 0;
                \}
                SALReader.return_loan(SALInstance, info);
	        return status;
	\}
"
   puts $fout "
/** Wait for the arrival of command ack. If no instance arrives before the timeout then return SAL__CMD_NOACK
  * else returns SAL__OK if a command message has been received.
  * @param cmdSeqNum is the sequence number of the command involved, as returned by issueCommand
  */
	public int waitForCompletion_[set i]( int cmdSeqNum , int timeout )
	\{
	   int status = 0;
           int actorIdx = SAL__SALData_command_[set i]_ACTOR;
	   ackcmd[set ACKREVCODE]SeqHolder ackcmd = new ackcmd[set ACKREVCODE]SeqHolder();
           long finishBy = System.currentTimeMillis() + timeout*1000;

	   while (status != SAL__CMD_COMPLETE && System.currentTimeMillis() < finishBy ) \{
	      status = getResponse_[set i](ackcmd);
              if (status == SAL__CMD_NOPERM) \{
                if (debugLevel > 0) \{
                  System.out.println( \"=== \[waitForCompletion_[set i]\] command \" + cmdSeqNum +  \" Not permitted by authList\");
                \}
                return status;
              \}
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
                ack.origin = sal\[actorIdx\].activeorigin;
                ack.identity = sal\[actorIdx\].activeidentity;
                ack.cmdtype = sal\[actorIdx\].activecmdid;
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
/** Get the response (ack) from a command transaction. It is up to the application to validate against the 
  * command sequence number and command type if multiple commands may be in-progress simultaneously
  * @param data is the ackCmd payload
  * @returns SAL__CMD_NOACK if no ackCmd is available, or SAL__OK if there is
  */
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
	  	sal\[actorIdxCmd\].rcvOrigin = data.value\[lastsample\].private_origin;
	  	sal\[actorIdxCmd\].rcvSeqNum = data.value\[lastsample\].private_seqNum;
	  	sal\[actorIdxCmd\].rcvIdentity = data.value\[lastsample\].private_identity;
	  	sal\[actorIdxCmd\].activeorigin = data.value\[lastsample\].origin;
	  	sal\[actorIdxCmd\].activeidentity = data.value\[lastsample\].identity;
	  	sal\[actorIdxCmd\].activecmdid = data.value\[lastsample\].cmdtype;
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
/** Acknowledge a command by sending an ackCmd message, this time with access to all the ackCmd message payload
  * @param data is the ackCmd topic data
  */
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
   		ackdata.private_seqNum = cmdId;
   		ackdata.error = error;
   		ackdata.ack = ack;
                ackdata.origin = sal\[actorIdx\].activeorigin;
                ackdata.identity = sal\[actorIdx\].activeidentity;
                ackdata.private_origin = origin;
                ackdata.private_identity = CSC_identity;
                ackdata.private_revCode = \"[string trim $ACKREVCODE _]\";
                ackdata.private_sndStamp = getCurrentTime();
   		ackdata.result = result;"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "   		ackdata.salIndex = subsystemID;"
      }
      puts $fout "
   		if (debugLevel > 0) \{
      			System.out.println(  \"=== \[ackCommand_[set i]\] acknowledging a command with :\" );
      			System.out.println(  \"    seqNum   : \" + ackdata.private_seqNum );
      			System.out.println(  \"    ack      : \" + ackdata.ack );
      			System.out.println(  \"    error    : \" + ackdata.error );
      			System.out.println(  \"    origin : \" + ackdata.origin );
      			System.out.println(  \"    identity : \" + ackdata.identity );
      			System.out.println(  \"    result   : \" + ackdata.result );
   		\}"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "   		ackdata.salIndex = subsystemID;
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





#
## Documented proc \c gencmdaliasisocpp .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Generates the Command handling code for a Subsystem/CSC.
#  Code is generated for issueCommand,acceptCommand,waitForCompletion,ackCommand,getResponse
#  per-command Topic type. This routine generates ISO C++ wrapper code.
#  NOT YET IMPLEMENTED
#
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


#
## Documented proc \c gencmdgenericjava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Create the generic DDS code to manage command Topics for Java
#
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
            String sFilter = \"salIndex = \" + subsystemID;
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
          String sFilter = \"salIndex = \" + subsystemID;
          String fCmd = \"filteredCmd_\" + sal\[actorIdx\].topicHandle;
    	  createContentFilteredTopic(actorIdx,fCmd, sFilter, expr);
 	  createReader(actorIdx,false);
"
   } else {
       puts $fout "
	  createReader(actorIdx,false);
"
   }
#   set cmdrevcode [getRevCode [set subsys]_command_setAuthList short]
#   set evtrevcode [getRevCode [set subsys]_logevent_authList short]
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
   if { $subsys == "LOVE" } {
      puts $fout "
	public int checkAuthList(String private_identity);
	\{
             return SAL__OK;
        \}
"
   } else {
      puts $fout "
	public int checkAuthList(String private_identity)
	\{
          int cmdId;
          int iat = 0;
  	  String my_identity = CSC_identity;

          if ( !authListEnabled ) \{
             return SAL__OK;
          \}

          boolean defaultCheck = private_identity.equals(CSC_identity);
          if (defaultCheck) \{
             return SAL__OK;
          \}

	  if ( sal\[SAL__SALData_command_setAuthList_ACTOR\].isProcessor == false ) \{
     	    salProcessor(\"SALData_command_setAuthList\");
     	    salEventPub(\"SALData_logevent_authList\");
            logevent_authList myData = new logevent_authList();
     	    authorizedUsers = \"\";
     	    nonAuthorizedCSCs = \"\";
     	    myData.authorizedUsers = authorizedUsers;
     	    myData.nonAuthorizedCSCs = nonAuthorizedCSCs;
     	    logEvent_authList(myData, 1);
  	  \}
          command_setAuthList SALInstance = new command_setAuthList();
          logevent_authList myData = new logevent_authList();
  	  cmdId = acceptCommand_setAuthList(SALInstance);
  	  if (cmdId > 0) \{
      	    if (debugLevel > 0) \{
              System.out.println( \"=== command setAuthList received = \");
              System.out.println( \"    authorizedUsers : \" + SALInstance.authorizedUsers);
              System.out.println( \"    nonAuthorizedCSCs : \" + SALInstance.nonAuthorizedCSCs);
            \}
     	    authorizedUsers = SALInstance.authorizedUsers.replaceAll(\"\\\\s+\",\"\");
     	    nonAuthorizedCSCs = SALInstance.nonAuthorizedCSCs.replaceAll(\"\\\\s+\",\"\");
     	    myData.authorizedUsers = SALInstance.authorizedUsers;
     	    myData.nonAuthorizedCSCs = SALInstance.nonAuthorizedCSCs;
            ackCommand_setAuthList( cmdId, SAL__CMD_COMPLETE, 0, \"OK\" );
     	    logEvent_authList(myData, 1);
          \}
          boolean ignoreCheck = private_identity.equals(\"\");
          if (ignoreCheck == false) \{
           StringTokenizer tokenizer2 = new StringTokenizer(nonAuthorizedCSCs, \",\");        
           while (tokenizer2.hasMoreTokens()) \{
            String next2 = tokenizer2.nextToken();
            boolean ok1 = next2.equals(my_identity);
            if (ok1) \{ 
              if ( debugLevel > 1) \{ System.out.println(\"authList check : \" + next2 + \" allowed\"); \}
              return SAL__OK;
            \} else \{
              boolean ok2 = next2.equals(private_identity);
              if (ok2) \{ 
                if ( debugLevel > 1) \{ System.out.println(\"authList check : \" + next2 + \" forbidden\"); \}
                return SAL__CMD_NOPERM;
              \}
              StringTokenizer tokenizer3 = new StringTokenizer(private_identity, \":\");        
              while (tokenizer3.hasMoreTokens()) \{
                String next3 = tokenizer3.nextToken();
                boolean ok3 = next3.equals(next2);
                if ( debugLevel > 1) \{ System.out.println(\"authList check : \" + next3 + \" \" + ok3); \}
                if (ok3) \{ 
                  if ( debugLevel > 1) \{ System.out.println(\"authList check : \" + next3 + \" forbidden\"); \}
                  return SAL__CMD_NOPERM;
                \}
              \}
            \}
           \}
           StringTokenizer tokenizer4 = new StringTokenizer(authorizedUsers, \",\");        
           while (tokenizer4.hasMoreTokens()) \{
            String next = tokenizer4.nextToken();
            boolean ok = next.equals(private_identity);
            if (ok) \{ 
              if ( debugLevel > 1) \{ System.out.println(\"authList check : \" + next + \" allowed\"); \}
              return SAL__OK;
            \}
           \}        
           StringTokenizer tokenizer5 = new StringTokenizer(private_identity, \"@\");        
           while (tokenizer5.hasMoreTokens()) \{
            iat++;
            if (iat > 1) \{
              return SAL__CMD_NOPERM;
            \}
           \}
          \}
          return SAL__OK;      
        \}
"
   }
}





