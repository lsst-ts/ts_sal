/**
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
 */

package org.lsst.sal.junit.Test;

import junit.framework.TestCase;
import java.lang.Integer;
import Test.*;
import org.lsst.sal.SAL_Test;

public class TestWithSalobjTargetTest extends TestCase {

   	public TestWithSalobjTargetTest(String name) {
   	   super(name);
   	}

	public static final int STD_TIMEOUT = 60;

	public void testTestWithSalobjTarget() {

          int cmdid;
	  int status;
          int itimer;
          int ilevel;
	  int loglevels[] = { 10, 52, 0 };

          Test.logevent_logLevel SALEvent = new Test.logevent_logLevel();
          Test.command_setLogLevel SALCommand = new Test.command_setLogLevel();
          Test.scalars SALTelemetry = new Test.scalars() ;
          Integer index = Integer.valueOf(System.getProperty("index"));
          Integer logLevel = Integer.valueOf(System.getProperty("logLevel"));
	  SAL_Test mgr = new SAL_Test( (int) index);

          mgr.setDebugLevel(2);
          mgr.salEventSub("Test_logevent_logLevel");
          mgr.salTelemetrySub("Test_scalars");
          mgr.salCommand("Test_command_setLogLevel");

          System.out.println("SALCommander: waiting for initial logLevel.level " + logLevel);

	  status = mgr.getEvent_logLevel(SALEvent);
	  itimer = 0;
	  while (status != SAL_Test.SAL__OK) {
	    status = mgr.getEvent_logLevel(SALEvent);
            try {Thread.sleep(10);} catch (InterruptedException e)  { e.printStackTrace(); }
	    itimer++;
	    if (itimer > STD_TIMEOUT*100) {
	      System.out.println("SALCommmander: timed out for getEvent_logLevel");
	      System.exit(-1);
	    }
	  }

	  if (SALEvent.level != logLevel) {
	    System.out.println("SALCommmander: unexpected logLevel received " + SALEvent.level);
	    System.exit(-2);
	  }

	  for ( ilevel=0;ilevel<3;ilevel++ ) {

	    SALCommand.level = loglevels[ilevel];
	    cmdid = mgr.issueCommand_setLogLevel(SALCommand);
	    System.out.println("SALCommmander:  send setLogLevel(level=" + SALCommand.level + ") command");

	    status = mgr.waitForCompletion_setLogLevel(cmdid, 60);
	    if (status != SAL_Test.SAL__CMD_COMPLETE) {
	      System.out.println("SALCommmander: timed out for ackcmd setLogLevel");
	      System.exit(-3);
	    }

	    status = SAL_Test.SAL__ERR;
	    itimer = 0;
	    while (status != SAL_Test.SAL__OK) {
	      status = mgr.getEvent_logLevel(SALEvent);
              try {Thread.sleep(10);} catch (InterruptedException e)  { e.printStackTrace(); }
	      itimer++;
	      if (itimer > STD_TIMEOUT*100) {
	        System.out.println("SALCommmander: timed out for getEvent_logLevel");
	        System.exit(-4);
	      }
	    }
	    if (SALEvent.level != loglevels[ilevel]) {
	      System.out.println("SALCommmander: unexpected logLevel logEvent received " + SALEvent.level);
	      System.exit(-5);
	    }

	    status = SAL_Test.SAL__ERR;
	    itimer = 0;
	    while (status != SAL_Test.SAL__OK) {
	      status = mgr.getSample(SALTelemetry);
              try {Thread.sleep(10);} catch (InterruptedException e)  { e.printStackTrace(); }
	      itimer++;
	      if (itimer > STD_TIMEOUT*100) {
	        System.out.println("SALCommmander: timed out for getSample_scalars");
	        System.exit(-6);
	      }
	    }
	    if (SALTelemetry.int0 != loglevels[ilevel]) {
	      System.out.println("SALCommmander: unexpected logLevel telemetry received " + SALTelemetry.int0);
	      System.exit(-7);
	    }

	  }

	  // Remove the DataWriters etc
          System.out.println("SALCommander: completed");
          try{Thread.sleep(1000);} catch (InterruptedException e)  { e.printStackTrace(); }
          mgr.salShutdown();
        }

}


