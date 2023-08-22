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
  [set subsys]::command_[set i] Instance;
  int actorIdx = SAL__SALData_command_[set i]_ACTOR;
  // create DataWriter :
  if (sal\[actorIdx\].isCommand == false) \{
     throw std::runtime_error(\"No commander for issueCommand_[set i]\");
  \}

  Instance.private_revCode =  \"[string trim $revcode _]\";
  Instance.private_sndStamp = getCurrentTime();
  Instance.private_efdStamp = getCurrentUTC();
  Instance.private_kafkaStamp = getCurrentTime();
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
  Instance.private_sndStamp = getCurrentTime();
  Instance.private_efdStamp = getCurrentUTC();
  Instance.private_kafkaStamp = getCurrentTime();"
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
   int status = 0;
   [set subsys]::command_[set i] Instance;
   SALData::ackcmd ackdata;
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
    ackdata.private_efdStamp = getCurrentUTC();
    ackdata.private_kafkaStamp = getCurrentTime();
    ackdata.cmdtype = actorIdx;
    ackdata.error = 0;
    ackdata.result = \"SAL ACK\";
    status = Instance.private_seqNum;
    ackdata.private_revCode = \"[string trim $ACKREVCODE _]\";
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
       actorIdx = SAL__SALData_ackcmd_ACTOR;"
       writerFragmentAck $fout $subsys ackcmd
      puts $fout "    \}
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
   double start = getCurrentTime();
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
      usleep(SAL__FASTPOLL);
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
   double end = getCurrentTime();
   if (debugLevel > 0) \{
      cout << \"Command roundtrip was \" << std::setprecision (8) << (end-start)*1000 << \" millseconds\" << endl;
   \}
   return status;
\}
"
   puts $fout "
salReturn SAL_SALData::getResponse_[set i](SALData::ackcmd data)
\{
  int numSamples = 0;
  int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;
  int actorIdx = SAL__SALData_ackcmd_ACTOR;
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
  int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;
  int actorIdx = SAL__SALData_ackcmd_ACTOR;
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
   int actorIdx = SAL__SALData_ackcmd_ACTOR;

   SALData::ackcmd Instance;

   Instance.private_seqNum = cmdId;
   Instance.private_identity = CSC_identity;
   Instance.error = error;
   Instance.ack = ack;
   Instance.result = result;
   Instance.origin = sal\[actorIdx\].activeorigin;
   Instance.identity = sal\[actorIdx\].activeidentity.c_str();
   Instance.cmdtype = actorIdx;
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
   Instance.private_sndStamp = getCurrentTime();
   Instance.private_efdStamp = getCurrentUTC();
   Instance.private_kafkaStamp = getCurrentTime();"
   writerFragment $fout $subsys ackcmd
   puts $fout "   return SAL__OK;
\}
"
   puts $fout "
salReturn SAL_SALData::ackCommand_[set i]C(SALData_ackcmdC *response )
\{
   int actorIdx = SAL__SALData_ackcmd_ACTOR;
   if ( response == NULL ) \{
      throw std::runtime_error(\"NULL pointer for ackCommand_[set i]\");
   \}

   SALData::ackcmd Instance;

   Instance.private_seqNum = sal\[actorIdx\].activecmdid;
   Instance.private_origin = getpid();
   Instance.private_identity = CSC_identity;
   Instance.error = response->error;
   Instance.ack = response->ack;
   Instance.result = response->result.c_str();
   Instance.origin = sal\[actorIdx\].activeorigin;
   Instance.identity = sal\[actorIdx\].activeidentity.c_str();
   Instance.cmdtype = actorIdx;
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
   Instance.private_sndStamp = getCurrentTime();
   Instance.private_efdStamp = getCurrentUTC();
   Instance.private_kafkaStamp = getCurrentTime();"
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
global CMD_ALIASES CMDS SYSDIC ACKREVCODE AVRO_PREFIX
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
	public long issueCommand_[set i]( [getAvroNamespace][set subsys].command_[set i] data )
	\{
          Random randGen = new java.util.Random();
          command_[set i] Instance = new command_[set i]();
          long status;
          int actorIdx = SAL__SALData_command_[set i]_ACTOR;
	  Instance.set[getAvroMethod private_revCode](\"[string trim $revcode _]\");
	  Instance.set[getAvroMethod private_seqNum](sal\[actorIdx\].sndSeqNum);
          Instance.set[getAvroMethod private_identity](CSC_identity);
          Instance.set[getAvroMethod private_origin](origin);
          Instance.set[getAvroMethod private_sndStamp](getCurrentTime());
          Instance.set[getAvroMethod private_efdStamp](getCurrentUTC());
          Instance.set[getAvroMethod private_kafkaStamp](getCurrentTime());"
      if { [info exists SYSDIC($subsys,keyedID)] } {
        puts $fout "	  Instance.set[getAvroMethod salIndex](subsystemID);"
      }
      copytojavasample $fout $subsys command_[set i]
      puts $fout "
	  if (debugLevel > 0) \{
	    System.out.println( \"=== issueCommand $i writing a command\");
	  \}"
          writerFragmentJava $fout $subsys command_[set i]
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
	public long acceptCommand_[set i]( [getAvroNamespace]SALData.command_[set i] data )
	\{
    		long status = 0;
   		int numsamp = 0;
   		int istatus =  -1;
                String dummy=\"\";
                int actorIdx = SAL__SALData_command_[set i]_ACTOR;
"
      if { $i != "setAuthList" } { 
         puts $fout "		checkAuthList(dummy);"
      }
      puts $fout "
  		// create processor :"
      readerFragmentJava $fout SALData command_[set i]
      puts $fout "
		if (Instance != null) \{
    		     if (debugLevel > 8) \{
      			System.out.println(  \"=== acceptCommand $i reading a command containing :\" );
      			System.out.println(  \"    seqNum   : \" + Instance.get[getAvroMethod private_seqNum]());
    		    \}
    		    status = Instance.get[getAvroMethod private_seqNum]();
    		    double rcvdTime = getCurrentTime();
		    double dTime = rcvdTime - Instance.get[getAvroMethod private_sndStamp]();
    		    if ( dTime < sal\[actorIdx\].sampleAge ) \{
                      sal\[actorIdx\].activeorigin = Instance.get[getAvroMethod private_origin]();
                      sal\[actorIdx\].activeidentity = String.valueOf(Instance.get[getAvroMethod private_identity]());
                      sal\[actorIdx\].activecmdid = Instance.get[getAvroMethod private_seqNum]();
                      [getAvroNamespace]SALData.ackcmd ackdata = new [getAvroNamespace]SALData.ackcmd();"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "	              ackdata.set[getAvroMethod salIndex](subsystemID);"
      }
      puts $fout "		      ackdata.set[getAvroMethod private_identity](Instance.get[getAvroMethod private_identity]());
		      ackdata.set[getAvroMethod private_origin](Instance.get[getAvroMethod private_origin]());
		      ackdata.set[getAvroMethod private_seqNum](Instance.get[getAvroMethod private_seqNum]());
                      ackdata.set[getAvroMethod private_revCode](\"[string trim $ACKREVCODE _]\");
                      ackdata.set[getAvroMethod private_sndStamp](getCurrentTime());
                      ackdata.set[getAvroMethod private_efdStamp](getCurrentUTC());
                      ackdata.set[getAvroMethod private_kafkaStamp](getCurrentTime());
		      ackdata.setError(0);
		      ackdata.setResult(\"SAL ACK\");"
           copyfromjavasample $fout $subsys command_[set i]
           puts $fout "
		      status = Instance.get[getAvroMethod private_seqNum]();
		      long rcvSeqNum = status;
		      long rcvOrigin = Instance.get[getAvroMethod private_origin]();
		      rcvIdentity = String.valueOf(Instance.get[getAvroMethod private_identity]());
		      ackdata.setAck(SAL__CMD_ACK);
"
           if { $subsys != "LOVE" } {
              puts $fout "
                      if ( actorIdx != SAL__SALData_command_setAuthList_ACTOR ) \{
		        if (checkAuthList(sal\[actorIdx\].activeidentity) != SAL__OK) \{
       			  ackdata.setAck(SAL__CMD_NOPERM);
       			  ackdata.setError(1);
       			  ackdata.setResult(\"Commanding not permitted by authList setting\");
       			  status = 0;
    		        \}
                       \}
"
           }
      puts $fout "
                 if ( ackdata.getAck() != SAL__CMD_ACK ) \{"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "		      ackdata.setSalIndex(subsystemID);"
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
	public long waitForCompletion_[set i]( int cmdSeqNum , int timeout )
	\{
	   long status = 0;
           int actorIdx = SAL__SALData_command_[set i]_ACTOR;
	   [getAvroNamespace]SALData.ackcmd ackcmd = new [getAvroNamespace]SALData.ackcmd();
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
	public long waitForAck_[set i]( int timeout , [getAvroNamespace]SALData.ackcmd ack)
	\{
	   long status = 0;
           int actorIdx = SAL__SALData_ackcmd_ACTOR;
	   [getAvroNamespace]SALData.ackcmd ackcmd = new [getAvroNamespace]SALData.ackcmd();
           long finishBy = System.currentTimeMillis() + timeout*1000;

	   while (status == SAL__CMD_NOACK && System.currentTimeMillis() < finishBy ) \{
	      status = getResponse_[set i](ackcmd);
	      if (status != SAL__CMD_NOACK) \{
  		ack.set[getAvroMethod private_seqNum](sal\[actorIdx\].rcvSeqNum);
   		ack.setError(sal\[actorIdx\].error);
   		ack.setAck(sal\[actorIdx\].ack);
   		ack.setResult(sal\[actorIdx\].result);
                ack.setOrigin(sal\[actorIdx\].activeorigin);
                ack.setIdentity(sal\[actorIdx\].activeidentity);
                ack.setCmdtype(sal\[actorIdx\].activecmdid);
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
	public long getResponse_[set i]([getAvroNamespace]SALData.ackcmd data)
	\{
	  long status =  -1;
          int lastsample = 0;
          int numsamp = 0;
          int actorIdx = SAL__SALData_ackcmd_ACTOR;
          int actorIdxCmd = SAL__SALData_command_[set i]_ACTOR;"
  readerFragmentJava $fout SALData command_[set i]
  puts $fout "
	  if (numsamp > 0) \{
                if ( debugLevel > 8) \{
			System.out.println(\"=== getResponse_[set i] message received :\");
			System.out.println(\"    revCode  : \" + data.getPrivateRevCode());
                \}
                lastsample = 1;
	 	status = data.getAck();
	  	sal\[actorIdxCmd\].rcvOrigin = data.getPrivateOrigin();
	  	sal\[actorIdxCmd\].rcvSeqNum = data.getPrivateSeqNum();
	  	sal\[actorIdxCmd\].rcvIdentity = String.valueOf(data.getPrivateIdentity());
	  	sal\[actorIdxCmd\].activeorigin = data.getOrigin();
	  	sal\[actorIdxCmd\].activeidentity = String.valueOf(data.getIdentity());
	  	sal\[actorIdxCmd\].activecmdid = data.getCmdtype();
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
	public int ackCommand_[set i]( long cmdId, long ack, long error, String result )
	\{
   		int istatus = -1;
   		long ackHandle = 0;
                int actorIdx = SAL__SALData_command_[set i]_ACTOR;
                int actorIdx2 = SAL__SALData_ackcmd_ACTOR;

                ackcmd Instance = new ackcmd();
    		Instance.setPrivateSeqNum(cmdId);
   		Instance.setError(error);
   		Instance.setAck(ack);
                Instance.setOrigin(sal\[actorIdx\].activeorigin);
                Instance.setIdentity(sal\[actorIdx\].activeidentity);
                Instance.setPrivateOrigin(origin);
                Instance.setPrivateIdentity(CSC_identity);
                Instance.setPrivateRevCode(\"[string trim $ACKREVCODE _]\");
                Instance.setPrivateSndStamp(getCurrentTime());
                Instance.setPrivateEfdStamp(getCurrentUTC());
                Instance.setPrivateKafkaStamp(getCurrentTime());
   		Instance.setResult(result);"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "   		Instance.setSalIndex(subsystemID);"
      }
      puts $fout "
   		if (debugLevel > 0) \{
      			System.out.println(  \"=== ackCommand_[set i] acknowledging a command with :\");
      			System.out.println(  \"    seqNum   : \" + Instance.getPrivateSeqNum());
      			System.out.println(  \"    ack      : \" + Instance.getAck());
      			System.out.println(  \"    error    : \" + Instance.getError());
      			System.out.println(  \"    origin : \" + Instance.getOrigin());
      			System.out.println(  \"    identity : \" + Instance.getIdentity());
      			System.out.println(  \"    result   : \" + Instance.getResult());
   		\}"
      if { [info exists SYSDIC($subsys,keyedID)] } {
         puts $fout "   		Instance.setSalIndex(subsystemID);"
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
global SYSDIC AVRO_PREFIX
   puts $fout "
	public void salCommand(String cmdAlias)
	\{
          int actorIdx = getActorIndex(cmdAlias);
	  String stopic1=\"keyedCommand\";
	  String stopic2=\"keyedResponse\";
	  String sresponse=\"SALData_ackcmd\";

	  //create types
	  salTypeSupport(actorIdx);

	  //create Topics
	  createTopic(actorIdx,cmdAlias);
	  sal\[actorIdx\].isWriter = true;
	  sal\[actorIdx\].isCommand = true;
          sal\[SAL__SALData_ackcmd_ACTOR\].sampleAge = 1.0;
          sal\[actorIdx\].sndSeqNum = (int)getCurrentTime() + 32768*actorIdx;
	
          if ( sal\[SAL__SALData_ackcmd_ACTOR\].isReader == false ) \{
	    createTopic2(SAL__SALData_ackcmd_ACTOR,sresponse);
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
          long cmdId;
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
            [getAvroNamespace]SALData.logevent_authList myData = new [getAvroNamespace]SALData.logevent_authList();
     	    authorizedUsers = \"\";
     	    nonAuthorizedCSCs = \"\";
     	    myData.set[getAvroMethod authorizedUsers](authorizedUsers);
     	    myData.set[getAvroMethod nonAuthorizedCSCs](nonAuthorizedCSCs);
     	    logEvent_authList(myData, 1);
  	  \}
          [getAvroNamespace]SALData.command_setAuthList Instance_setAuthList = new [getAvroNamespace]SALData.command_setAuthList();
          [getAvroNamespace]SALData.logevent_authList myData = new [getAvroNamespace]SALData.logevent_authList();
  	  cmdId = acceptCommand_setAuthList(Instance_setAuthList);
  	  if (cmdId > 0) \{
      	    if (debugLevel > 0) \{
              System.out.println( \"=== command setAuthList received = \");
              System.out.println( \"    authorizedUsers : \" + Instance_setAuthList.get[getAvroMethod authorizedUsers]());
              System.out.println( \"    nonAuthorizedCSCs : \" + Instance_setAuthList.get[getAvroMethod nonAuthorizedCSCs]());
            \}
     	    authorizedUsers = String.valueOf(Instance_setAuthList.get[getAvroMethod authorizedUsers]());
     	    authorizedUsers.replaceAll(\"\\\\s+\",\"\");
     	    nonAuthorizedCSCs = String.valueOf(Instance_setAuthList.get[getAvroMethod nonAuthorizedCSCs]());
     	    nonAuthorizedCSCs.replaceAll(\"\\\\s+\",\"\");
     	    myData.set[getAvroMethod authorizedUsers](Instance_setAuthList.get[getAvroMethod authorizedUsers]());
     	    myData.set[getAvroMethod nonAuthorizedCSCs](Instance_setAuthList.get[getAvroMethod nonAuthorizedCSCs]());
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





