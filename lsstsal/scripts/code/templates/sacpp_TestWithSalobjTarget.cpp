/*
 * This file contains the implementation for the TestWithSalobjTarget test.
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

#define STD_TIMEOUT 60

using namespace Test;

int test_TestWithSalobjTarget(int index, int logLevel)
{ 
  int cmdid;
  struct timespec delay_10ms;
  delay_10ms.tv_sec = 0;
  delay_10ms.tv_nsec = 10000000;
  int loglevels[] = { 10, 52, 0 };
  int ilevel;
  int itimer;
  int status;

  Test_logevent_logLevelC SALEvent;
  Test_command_setLogLevelC SALCommand;
  Test_ackcmdC SALAckcmd;
  Test_scalarsC SALTelemetry;
  SAL_Test mgr = SAL_Test(index);


  mgr.salEventSub("Test_logevent_logLevel");
  mgr.salTelemetrySub("Test_scalars");
  mgr.salCommand("Test_command_setLogLevel");

  cout << "SALCommmander: wait for initial logLevel" << endl;
  status = mgr.getEvent_logLevel(&SALEvent);
  itimer = 0;
  while (status != SAL__OK) {
    status = mgr.getEvent_logLevel(&SALEvent);
    nanosleep(&delay_10ms,NULL);
    itimer++;
    if (itimer > STD_TIMEOUT*100) {
      cout << "SALCommmander: timed out for getEvent_logLevel" << endl;
      exit(-1);
    }
  }

  if (SALEvent.level != logLevel) {
    cout << "SALCommmander: unexpected logLevel received" << SALEvent.level << endl;
    exit(-2);
  }

  for ( ilevel=0;ilevel<3;ilevel++ ) {

    SALCommand.level = loglevels[ilevel];
    cmdid = mgr.issueCommand_setLogLevel(&SALCommand);
    cout << "SALCommmander:  send setLogLevel(level=" << SALCommand.level << ") command" << endl;

    status = mgr.waitForCompletion_setLogLevel(cmdid, STD_TIMEOUT);
    if (status != SAL__CMD_COMPLETE) {
     cout << "SALCommmander: timed out for ackcmd setLogLevel" << endl;
     exit(-3);
    }

    status = SAL__ERR;
    itimer = 0;
    while (status != SAL__OK) {
     status = mgr.getEvent_logLevel(&SALEvent);
     nanosleep(&delay_10ms,NULL);
     itimer++;
      if (itimer > STD_TIMEOUT*100) {
        cout << "SALCommmander: timed out for getEvent_logLevel" << endl;
        exit(-4);
      }
    }
    if (SALEvent.level != loglevels[ilevel]) {
      cout << "SALCommmander: unexpected logLevel logEvent received " << SALEvent.level << endl;
      exit(-5);
    }

    status = SAL__ERR;
    itimer = 0;
    while (status != SAL__OK) {
      status = mgr.getSample_scalars(&SALTelemetry);
      nanosleep(&delay_10ms,NULL);
      itimer++;
      if (itimer > STD_TIMEOUT*100) {
        cout << "SALCommmander: timed out for getSample_scalars" << endl;
        exit(-6);
      }
    }
    if (SALTelemetry.int0 != loglevels[ilevel]) {
      cout << "SALCommmander: unexpected logLevel telemetry received " << SALTelemetry.int0 << endl;
      exit(-7);
    }

  }



  // Remove the DataWriters etc
  cout << "SALCommander: completed" << endl;
  sleep(1);
  mgr.salShutdown();

  return 0;
}



int main (int argc, char *argv[])
{
  int index, logLevel;
  if ( argc < 2 ) {
    cout << "Arguments required : index" << endl;
    exit(-1);
  }
  index=strtol(argv[1],NULL,10);
  logLevel=strtol(argv[2],NULL,10);
  cout << "SALController: starting with index=" << index << ", initial_log_level=" << logLevel << endl;
  return test_TestWithSalobjTarget(index,logLevel);
}




