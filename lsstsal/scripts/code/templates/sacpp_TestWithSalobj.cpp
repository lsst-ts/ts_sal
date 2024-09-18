/*
 * This file contains the implementation for the TestWithSalobj test.
 *
 *
 * This file is part of ts_sal.
 *
 * Developed for the Rubin Observatory Telescope and Site System.
 * This product includes software developed by the LSST Project
 * (https://www.lsst.org).
 * See the COPYRIGHT file at the top-level directory of this distribution
 * for details of code ownership.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 ***/

#include <string>
#include <sstream>
#include <iostream>
#include "SAL_Test.h"
#include <stdlib.h>
#include <time.h>

using namespace Test;

int test_TestWithSalobj(int index, int logLevel)
{ 
  int cmdid;
  struct timespec delay_10ms;
  delay_10ms.tv_sec = 0;
  delay_10ms.tv_nsec = 10000000;

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
        nanosleep(&delay_10ms,NULL);
        cout << "SALController: writing logLevel=" << SALCommand.level << " event and the same value in scalars.int0 telemetry" << endl;
        SALTelemetry.int0 = SALCommand.level;
        SALEvent.level = SALCommand.level;
        mgr.logEvent_logLevel(&SALEvent,1);
        mgr.putSample_scalars(&SALTelemetry);
        nanosleep(&delay_10ms,NULL);
        if (SALCommand.level == 0) break;
      }
    }
    nanosleep(&delay_10ms,NULL);
  }

  // Remove the DataWriters etc
  cout << "SALController: completed" << endl;
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




