

/*
 * This file contains the implementation for the TestWithSalobj test.
 *
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include "SAL_Test.h"
#include "ccpp_sal_Test.h"
#include "os.h"
#include <stdlib.h>


using namespace DDS;
using namespace Test;

int test_TestWithSalobj(int index, int logLevel)
{ 
  int cmdid;
  os_time delay_10ms = { 0, 10000000 };

  Test_logevent_logLevelC SALEvent;
  Test_command_setLogLevelC SALCommand;
  Test_scalarsC SALTelemetry;
  SAL_Test mgr = SAL_Test(index);


  mgr.salEventPub("Test_logevent_logLevel");
  mgr.salTelemetryPub("Test_scalars");
  mgr.salProcessor("Test_command_setLogLevel");

  cout << "SALController: writing initial logLevel.level " << logLevel << endl;
  SALEvent.level = logLevel;
  mgr.logEvent_logLevel(&SALEvent,1);

  while (1) {
  // receive event
    cmdid = mgr.acceptCommand_setLogLevel(&SALCommand);

    if (cmdid < 0) {
      cout << "SALController: error reading setLogLevel command; cmdid=" << cmdid << endl;
    } else {
      if ( cmdid > 0 ) {
        cout << "SALController: read setLogLevel(cmdid=" << cmdid << ";level=" << SALCommand.level << endl;
        mgr.ackCommand_setLogLevel(cmdid, SAL__CMD_COMPLETE, 0, "Done : OK");
        os_nanoSleep(delay_10ms);
        cout << "SALController: writing logLevel=" << SALCommand.level << " event and the same value in scalars.int0 telemetry" << endl;
        SALTelemetry.int0 = SALCommand.level;
        SALEvent.level = SALCommand.level;
        mgr.logEvent_logLevel(&SALEvent,1);
        mgr.putSample_scalars(&SALTelemetry);
        os_nanoSleep(delay_10ms);
        if (SALCommand.level == 0) break;
      }
    }
    os_nanoSleep(delay_10ms);
  }

  // Remove the DataWriters etc
  cout << "SALController: quitting" << endl;
  sleep(1);
  mgr.salShutdown();

  return 0;
}



int main (int argc, char *argv[])
{
  int index, logLevel;

  if ( argc < 2 ) {
    cout << "Arguments required : index logLevel" << endl;
    exit(-1);
  }
  index=strtol(argv[1],NULL,10);
  logLevel=strtol(argv[2],NULL,10);
  cout << "SALController: starting with index=" << index << ", initial_log_level=" << logLevel << endl;
  return test_TestWithSalobj(index,logLevel);
}




