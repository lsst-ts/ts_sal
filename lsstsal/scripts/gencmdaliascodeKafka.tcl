#!/usr/bin/env tclsh
## \file gencmdaliascodeKafka.tcl
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

set SAL_DIR $env(SAL_DIR)
source $SAL_DIR/gencommandtestsKafka.tcl
source $SAL_DIR/gencommandtestssinglefileKafka.tcl 
source $SAL_DIR/gencommandtestsjava.tcl
source $SAL_DIR/gencommandtestssinglefilejavaKafka.tcl
source $SAL_DIR/activaterevcodesKafka.tcl 

#
## Documented proc \c addgenericcmdcode .
# \param[in] fout File handle of output file
# \param[in] lang Target language to generate code for
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
#
#  Copy the generic Kafka code to manage command Topics
#  using the template in code/templates/SALKAFKA.lang.template
#  where lang = cpp,java
#
proc addgenericcmdcode { fout lang subsys } {
global OPTIONS SAL_DIR
  if { $OPTIONS(verbose) } {stdlog "###TRACE>>> addgenericcmdcode $lang $fout $subsys"}
  stdlog "Generate command generic support for $lang"
  set fin [open  $SAL_DIR/code/templates/SALKAFKA.[set lang]-cmd.template r]
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
 source $SAL_WORK_DIR/avro-templates/[set subsys]_revCodes.tcl
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
      salReturn ackCommand_[set i]( int cmdSeqNum, salLONG  ack, salLONG error, char *result );

/** Acknowledge a command by sending an ackCmd message, this time with access to all the ackCmd message payload
  * @param data is the ackCmd topic data
  */
      salReturn ackCommand_[set i]C( SALData_ackcmdC *data );

      salReturn getResponse_[set i]( SALData::ackcmd data );

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
  [set subsys]::[set subsys]_command_[set i] Instance;
  int actorIdx = SAL__SALData_command_[set i]_ACTOR;
  // create DataWriter :
  if (sal\[actorIdx\].isCommand == false) \{
     throw std::runtime_error(\"No commander for issueCommand_[set i]\");
  \}

  Instance.private_revCode =  \"[string trim $revcode _]\";
  Instance.private_sndStamp = getCurrentTime();
  Instance.private_origin = getpid();
  Instance.private_identity = CSC_identity;
  Instance.private_seqNum =   sal\[actorIdx\].sndSeqNum;"
        set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set i]Cput.tmp r]
        while { [gets $fin rec] > -1 } {
           puts $fout $rec
        }
        close $fin
        puts $fout "
  if (debugLevel > 0) \{
    cout << \"=== issueCommand_[set i] writing a command containing :\" << endl;"
        set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set i]Cout.tmp r]
        while { [gets $fin rec] > -1 } {
           puts $fout $rec
        }
        close $fin
        puts $fout "
  \}
  Instance.private_sndStamp = getCurrentTime();"
        writerFragment $fout $subsys [set subsys]_command_[set i]
        puts $fout "
  sal\[actorIdx\].sndSeqNum++;
  if (debugLevel >= SAL__LOG_ROUTINES) \{
      logError(status);
  \}
  return (sal\[actorIdx\].sndSeqNum-1);
\}
"
      puts $fout "
int SAL_SALData::acceptCommand_[set i]( SALData_command_[set i]C *data )
\{
//   long istatus =  -1;
   int numSamples = 0;
   [set subsys]::SALData_command_[set i] Instance;
   SALData::ackcmd ackdata;
//   long ackHandle = NULL;
   int actorIdx = SAL__SALData_command_[set i]_ACTOR;
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
  readerFragment $fout SALData command_[set i] 
  puts $fout "  
   if ( numSamples > 0) \{
    if (debugLevel > 8) \{
      cout << \"=== acceptCommandC $i reading a command containing :\" << endl;
      cout << \"    seqNum   : \" << Instance.private_seqNum << endl;
      cout << \"    origin   : \" << Instance.private_origin << endl;
      cout << \"    identity   : \" << Instance.private_identity << endl;
    \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
    ackdata.salIndex = subsystemID;
#endif
    ackdata.identity = Instance.private_identity;
    ackdata.origin = Instance.private_origin;
    ackdata.private_seqNum = Instance.private_seqNum;
    ackdata.private_revCode = \"[string trim $ACKREVCODE _]\";
    ackdata.private_sndStamp = getCurrentTime();
    ackdata.cmdtype = actorIdx;
    ackdata.error = 0;
    ackdata.result = \"SAL ACK\";
    status = Instance.private_seqNum;
    ackdata.private_revCode = \"[string trim $ACKREVCODE _]\";
    ackdata.private_sndStamp = getCurrentTime();
    rcvdTime = getCurrentTime();
    sal\[actorIdx\].rcvStamp = rcvdTime;
    sal\[actorIdx\].sndStamp = Instance.private_sndStamp;
    if ( (rcvdTime - Instance.private_sndStamp) < sal\[actorIdx\].sampleAge ) \{
      rcvSeqNum = status;
      rcvOrigin = Instance.private_origin;
      rcvIdentity = Instance.private_identity;
      sal\[actorIdx\].activeorigin = Instance.private_origin;
      sal\[actorIdx\].activeidentity = Instance.private_identity;
      sal\[actorIdx\].activecmdid = Instance.private_seqNum;
      ackdata.ack = SAL__CMD_ACK;"
        set fin [open $SAL_WORK_DIR/include/SAL_[set subsys]_command_[set i]Cget.tmp r]
        while { [gets $fin rec] > -1 } {
           puts $fout $rec
        }
        close $fin
        puts $fout "
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
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
        ackdata.result = \"Commanding not permitted by authList setting\";
        status = 0;
      \}
    \}
"
     }
     puts $fout "    
    if ( ackdata.ack != SAL__CMD_ACK ) \{
//       istatus = SALWriter->write(ackdata, ackHandle);
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
    return status;
\}
"
   puts $fout "
salReturn SAL_SALData::waitForCompletion_[set i]( int cmdSeqNum , unsigned int timeout )
\{
     salReturn status = SAL__OK;
   int countdown = timeout*100;
   SALData::ackcmd response;
   int actorIdx = SAL__SALData_command_[set i]_ACTOR;

   while (status != SAL__CMD_COMPLETE && countdown != 0) \{
      status = getResponse_[set i](response);
      if (status == SAL__CMD_NOPERM) \{
        if (debugLevel > 0) \{
          cout << \"=== waitForCompletion_[set i] command \" << cmdSeqNum <<  \" Not permitted by authList\" << endl;
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
         cout << \"=== waitForCompletion_[set i] command \" << cmdSeqNum <<  \" timed out :\" << endl;
      \} 
   \} else \{
      if (debugLevel > 0) \{
         cout << \"=== waitForCompletion_[set i] command \" << cmdSeqNum << \" completed ok :\" << endl;
      \} 
   \}
     return status;
\}
"
   puts $fout "
salReturn SAL_SALData::getResponse_[set i](SALData::ackcmd data)
\{
  int numSamples = 0;
  int actorIdx = SAL__SALData_ackcmd_ACTOR;
  int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;
  long status = SAL__CMD_NOACK;
  SALData::ackcmd Instance;"
  readerFragment $fout SALData ackcmd
  puts $fout "
  if (numSamples > 0) \{
  sal\[actorIdxCmd\].rcvSeqNum = 0;
  sal\[actorIdxCmd\].rcvOrigin = 0;
  sal\[actorIdxCmd\].rcvIdentity = \"\";
  if (Instance.private_seqNum > 0) \{
    if (debugLevel > 8) \{
      cout << \"=== getResponse_[set i] reading a message containing :\" << endl;
      cout << \"    seqNum   : \" << Instance.private_seqNum << endl;
      cout << \"    error    : \" << Instance.error << endl;
      cout << \"    ack      : \" << Instance.ack << endl;
      cout << \"    result   : \" << Instance.result << endl;
    \}
// check identity, cmdtype here
    status = Instance.ack;
    rcvdTime = getCurrentTime();
    sal\[actorIdxCmd\].rcvStamp = rcvdTime;
    sal\[actorIdxCmd\].sndStamp = Instance.private_sndStamp;
    sal\[actorIdxCmd\].rcvSeqNum = Instance.private_seqNum;
    sal\[actorIdxCmd\].rcvOrigin = Instance.private_origin;
    sal\[actorIdxCmd\].rcvIdentity = Instance.private_identity;
    sal\[actorIdxCmd\].ack = Instance.ack;
    sal\[actorIdxCmd\].error = Instance.error;
    sal\[actorIdxCmd\].result = Instance.result;
    \} else \{
      if (debugLevel > 8) \{
         cout << \"=== getResponse_[set i] No ack yet!\" << endl;
      \}
      status = SAL__CMD_NOACK;
    \}
  \}
  return status;
\}
"
   puts $fout "
salReturn SAL_SALData::getResponse_[set i]C(SALData_ackcmdC *response)
\{
  int numSamples = 0;
  int actorIdx = SAL__SALData_ackcmd_ACTOR;
  int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;
  SALData::ackcmd Instance;
  long status = SAL__CMD_NOACK;
  if ( response == NULL ) \{
     throw std::runtime_error(\"NULL pointer for getResponse_[set i]\");
  \}"
  readerFragment $fout SALData command_[set i]
  puts $fout "
  if (numSamples > 0) \{
  sal\[actorIdxCmd\].rcvSeqNum = 0;
  sal\[actorIdxCmd\].rcvOrigin = 0;
  sal\[actorIdxCmd\].rcvIdentity = \"\";
   if (Instance.private_seqNum > 0) \{
    if (debugLevel > 8) \{
      cout << \"=== getResponse_[set i] reading a message containing :\" << endl;
      cout << \"    seqNum   : \" << Instance.private_seqNum << endl;
      cout << \"    error    : \" << Instance.error << endl;
      cout << \"    ack      : \" << Instance.ack << endl;
      cout << \"    result   : \" << Instance.result << endl;
     \}
// check identity, cmdtype here
    status = Instance.private_seqNum;;
    rcvdTime = getCurrentTime();
    sal\[actorIdxCmd\].rcvStamp = rcvdTime;
    sal\[actorIdxCmd\].sndStamp = Instance.private_sndStamp;
    sal\[actorIdxCmd\].rcvSeqNum = Instance.private_seqNum;
    sal\[actorIdxCmd\].rcvOrigin = Instance.private_origin;
    sal\[actorIdxCmd\].rcvIdentity = Instance.private_identity;
    sal\[actorIdxCmd\].ack = Instance.ack;
    sal\[actorIdxCmd\].error = Instance.error;
    sal\[actorIdxCmd\].result = Instance.result;
    response->ack = Instance.ack;
    response->error = Instance.error;
    response->origin = Instance.origin;
    response->identity = Instance.identity;
    response->cmdtype = Instance.cmdtype;
    response->timeout = Instance.timeout;
    response->result= Instance.result;
   \} else \{
      if (debugLevel > 8) \{
         cout << \"=== getResponse_[set i]C No ack yet!\" << endl;
      \}
      status = SAL__CMD_NOACK;
   \}
  \}
  return status;
\}
"
   puts $fout "
salReturn SAL_SALData::ackCommand_[set i]( int cmdId, salLONG ack, salLONG error, char *result )
\{
//   long istatus = -1;
//   long ackHandle = 0;
//   int actorIdx = SAL__SALData_ackcmd_ACTOR;
   int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;

   SALData::ackcmd Instance;

   Instance.private_seqNum = cmdId;
   Instance.private_identity = CSC_identity;
   Instance.error = error;
   Instance.ack = ack;
   Instance.result = result;
   Instance.origin = sal\[actorIdxCmd\].activeorigin;
   Instance.identity = sal\[actorIdxCmd\].activeidentity.c_str();
   Instance.cmdtype = actorIdxCmd;
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   Instance.salIndex = subsystemID;
#endif
   if (debugLevel > 0) \{
      cout << \"=== ackCommand_[set i] acknowledging a command with :\" << endl;
      cout << \"    seqNum   : \" << Instance.private_seqNum << endl;
      cout << \"    ack      : \" << Instance.ack << endl;
      cout << \"    error    : \" << Instance.error << endl;
      cout << \"    origin    : \" << Instance.origin << endl;
      cout << \"    identity    : \" << Instance.identity << endl;
      cout << \"    result   : \" << Instance.result << endl;
   \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   Instance.salIndex = subsystemID;
#endif
   Instance.private_revCode = \"[string trim $ACKREVCODE _]\";
   Instance.private_sndStamp = getCurrentTime();"
   writerFragment $fout $subsys ackcmd
   puts $fout "   return SAL__OK;
\}
"
   puts $fout "
salReturn SAL_SALData::ackCommand_[set i]C(SALData_ackcmdC *response )
\{
//   long istatus = -1;
//   long ackHandle = NULL;
//   int actorIdx = SAL__SALData_ackcmd_ACTOR;
   int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;
   if ( response == NULL ) \{
      throw std::runtime_error(\"NULL pointer for ackCommand_[set i]\");
   \}

   SALData::ackcmd Instance;

   Instance.private_seqNum = sal\[actorIdxCmd\].activecmdid;
   Instance.private_origin = getpid();
   Instance.private_identity = CSC_identity;
   Instance.error = response->error;
   Instance.ack = response->ack;
   Instance.result = response->result.c_str();
   Instance.origin = sal\[actorIdxCmd\].activeorigin;
   Instance.identity = sal\[actorIdxCmd\].activeidentity.c_str();
   Instance.cmdtype = actorIdxCmd;
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   Instance.salIndex = subsystemID;
#endif
   if (debugLevel > 0) \{
      cout << \"=== ackCommand_[set i] acknowledging a command with :\" << endl;
      cout << \"    seqNum   : \" << Instance.private_seqNum << endl;
      cout << \"    ack      : \" << Instance.ack << endl;
      cout << \"    error    : \" << Instance.error << endl;
      cout << \"    origin    : \" << Instance.origin << endl;
      cout << \"    identity    : \" << Instance.identity << endl;
      cout << \"    result   : \" << Instance.result << endl;
   \}
#ifdef SAL_SUBSYSTEM_ID_IS_KEYED
   Instance.salIndex = subsystemID;
#endif
   Instance.private_revCode = \"[string trim $ACKREVCODE _]\";
   Instance.private_sndStamp = getCurrentTime();"
   writerFragment $fout $subsys ackcmd
   puts $fout "return SAL__OK;
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
	public int issueCommand_[set i]( SALData.command_[set i] data )
	\{
          Random randGen = new java.util.Random();
  	  long cmdHandle = HANDLE_NIL.value;
          SALData.SALData_command_[set i] Instance = new SALData_command_[set i]();
          int status;
          int actorIdx = SAL__SALData_command_[set i]_ACTOR;
	  Instance.private_revCode = \"[string trim $revcode _]\";
	  Instance.private_seqNum = sal\[actorIdx\].sndSeqNum;
          Instance.private_identity = CSC_identity;
          Instance.private_origin = origin;
          Instance.private_sndStamp = getCurrentTime();"
      if { [info exists SYSDIC($subsys,keyedID)] } {
        puts $fout "	  Instance.salIndex = subsystemID;"
      }
      copytojavasample $fout $subsys command_[set i]
      puts $fout "
	  if (debugLevel > 0) \{
	    System.out.println( \"=== issueCommand $i writing a command\");
	  \}"
          writerFragmentJava $fout $subsys [set subsys]_command_[set i]
      puts $fout "
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
                SALData.SALData_command_[set i] Instance = new SALData_command_[set i]();
                SALData.ackcmd ackdata;
   		int status = 0;
   		int numSamples = 0;
   		int istatus =  -1;
                String dummy=\"\";
   		long ackHandle = NULL;
                int actorIdx = SAL__SALData_command_[set i]_ACTOR;
"
      if { $i != "setAuthList" } { 
         puts $fout "		checkAuthList(dummy);"
      }
      puts $fout "
  		// create processor :"
      readerFragmentJava $fout SALData command_[set i]
      puts $fout "
		if (Instance != NULL) \{
    		     if (debugLevel > 8) \{
      			System.out.println(  \"=== acceptCommand $i reading a command containing :\" );
      			System.out.println(  \"    seqNum   : \" + Instance.private_seqNum );
    		    \}
    		    status = Instance.private_seqNum;
    		    double rcvdTime = getCurrentTime();
		    double dTime = rcvdTime - Instance.private_sndStamp;
    		    if ( dTime < sal\[actorIdx\].sampleAge ) \{
                      sal\[actorIdx\].activeorigin = Instance.private_origin;
                      sal\[actorIdx\].activeidentity = Instance.private_identity;
                      sal\[actorIdx\].activecmdid = Instance.private_seqNum;
                      ackdata = new SALData.ackcmd();"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "	              ackdata.salIndex = subsystemID;"
      }
      puts $fout "		      ackdata.private_identity = Instance.private_identity;
		      ackdata.private_origin = Instance.private_origin;
		      ackdata.private_seqNum = Instance.private_seqNum;
                      ackdata.private_revCode = \"[string trim $ACKREVCODE _]\";
                      ackdata.private_sndStamp = getCurrentTime();
		      ackdata.error  = 0;
		      ackdata.result = \"SAL ACK\";"
           copyfromjavasample $fout $subsys command_[set i]
           puts $fout "
		      status = Instance.private_seqNum;
		      rcvSeqNum = status;
		      rcvOrigin = Instance.private_origin;
		      rcvIdentity = Instance.private_identity;
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
         puts $fout "		      ackdata.salIndex = subsystemID;"
      }
      puts $fout "
    		     if (debugLevel > 8) \{
      			System.out.println(  \"    Old command ignored :   \" + dTime );
                     \}
                    \}
		 \}
                \} else \{
  	           status = 0;
                \}
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
	   SALData.ackcmd ackcmd = new SALData.ackcmd();
           long finishBy = System.currentTimeMillis() + timeout*1000;

	   while (status != SAL__CMD_COMPLETE && System.currentTimeMillis() < finishBy ) \{
	      status = getResponse_[set i](ackcmd);
              if (status == SAL__CMD_NOPERM) \{
                if (debugLevel > 0) \{
                  System.out.println( \"=== waitForCompletion_[set i] command \" + cmdSeqNum +  \" Not permitted by authList\");
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
	         System.out.println( \"=== waitForCompletion_[set i] command \" + cmdSeqNum +  \" timed out\");
	      \} 
	      logError(status);
	   \} else \{
	      if (debugLevel > 0) \{
	         System.out.println( \"=== waitForCompletion_[set i] command \" + cmdSeqNum +  \" completed ok\");
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
	   SALData.ackcmd ackcmd = new SALData.ackcmd();
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
	      System.out.println( \"=== waitForAck_[set i] ack \" + status);
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
	public int getResponse_[set i](SALData.ackcmd data)
	\{
	  int status =  -1;
          int lastsample = 0;
          int numSamples = 0;
          int actorIdx = SAL__SALData_ackcmd_ACTOR;
          int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;"
  readerFragmentJava $fout SALData command_[set i]
  puts $fout "
	  if (numSamples > 0) \{
 		for (int i = 0; i < data.value.length; i++) \{
                     if ( debugLevel > 8) \{
				System.out.println(\"=== getResponse_[set i] message received :\");
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
	            System.out.println(\"=== getResponse_[set i] No ack yet!\"); 
                \}
	        status = SAL__CMD_NOACK;
	  \}
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
   		long ackHandle = 0;
                int actorIdx = SAL__SALData_command_[set i]_ACTOR;
                int actorIdx2 = SAL__SALData_ackcmd_ACTOR;

   		SALData.ackcmd Instance_ackcmd;
    		ackdata.private_seqNum = cmdId;
   		Instance_ackcmd.error = error;
   		Instance_ackcmd.ack = ack;
                Instance_ackcmd.origin = sal\[actorIdx\].activeorigin;
                Instance_ackcmd.identity = sal\[actorIdx\].activeidentity;
                Instance_ackcmd.private_origin = origin;
                Instance_ackcmd.private_identity = CSC_identity;
                Instance_ackcmd.private_revCode = \"[string trim $ACKREVCODE _]\";
                Instance_ackcmd.private_sndStamp = getCurrentTime();
   		Instance_ackcmd.result = result;"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "   		Instance_ackcmd.salIndex = subsystemID;"
      }
      puts $fout "
   		if (debugLevel > 0) \{
      			System.out.println(  \"=== ackCommand_[set i] acknowledging a command with :\" );
      			System.out.println(  \"    seqNum   : \" + Instance_ackcmd.private_seqNum );
      			System.out.println(  \"    ack      : \" + Instance_ackcmd.ack );
      			System.out.println(  \"    error    : \" + Instance_ackcmd.error );
      			System.out.println(  \"    origin : \" + Instance_ackcmd.origin );
      			System.out.println(  \"    identity : \" + Instance_ackcmd.identity );
      			System.out.println(  \"    result   : \" + Instance_ackcmd.result );
   		\}"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "   		Instance_ackcmd.salIndex = subsystemID;"
       }
      writerFragmentJava $fout $subsys ackcmd
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
## Documented proc \c gencmdgenericjava .
# \param[in] subsys Name of CSC/SUbsystem as defined in SALSubsystems.xml
# \param[in] fout File handle of output file
#
#  Create the generic Kafka code to manage command Topics for Java
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
	  sal\[actorIdx\].isWriter = true;
	  sal\[actorIdx\].isCommand = true;
          sal\[SAL__SALData_ackcmd_ACTOR\].sampleAge = 1.0;
          sal\[actorIdx\].sndSeqNum = (int)getCurrentTime() + 32768*actorIdx;
	
          if ( sal\[SAL__SALData_ackcmd_ACTOR\].isReader == false ) \{
	    createSubscriber(SAL__SALData_ackcmd_ACTOR);
	    createTopic2(SAL__SALData_ackcmd_ACTOR,sresponse);
	    //create a reader for responses
"
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
#   set cmdrevcode [getRevCode [set subsys]_command_setAuthList short]
#   set evtrevcode [getRevCode [set subsys]_logevent_authList short]
   puts $fout "
          if (sal\[actorIdx\].isProcessor == false) \{
  	    //create Publisher
	    createPublisher(SAL__SALData_ackcmd_ACTOR);
	    createTopic2(SAL__SALData_ackcmd_ACTOR,sresponse);
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
          command_setAuthList Instance = new command_setAuthList();
          logevent_authList myData = new logevent_authList();
  	  cmdId = acceptCommand_setAuthList(Instance_setAuthList);
  	  if (cmdId > 0) \{
      	    if (debugLevel > 0) \{
              System.out.println( \"=== command setAuthList received = \");
              System.out.println( \"    authorizedUsers : \" + Instance_setAuthList.authorizedUsers);
              System.out.println( \"    nonAuthorizedCSCs : \" + Instance_setAuthList.nonAuthorizedCSCs);
            \}
     	    authorizedUsers = Instance_setAuthList.authorizedUsers.replaceAll(\"\\\\s+\",\"\");
     	    nonAuthorizedCSCs = Instance_setAuthList.nonAuthorizedCSCs.replaceAll(\"\\\\s+\",\"\");
     	    myData.authorizedUsers = Instance_setAuthList.authorizedUsers;
     	    myData.nonAuthorizedCSCs = Instance_setAuthList.nonAuthorizedCSCs;
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





