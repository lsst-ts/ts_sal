/**
 * This file contains the implementation for the TestWithSalobj test.
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

public class TestWithSalobjTest extends TestCase {

   	public TestWithSalobjTest(String name) {
   	   super(name);
   	}

	public void testTestWithSalobj() {

          int cmdid;

          Test.logevent_logLevel SALEvent = new Test.logevent_logLevel();
          Test.command_setLogLevel SALCommand = new Test.command_setLogLevel();
          Test.scalars SALTelemetry = new Test.scalars() ;
          Integer index = Integer.valueOf(System.getProperty("index"));
          Integer logLevel = Integer.valueOf(System.getProperty("logLevel"));
	  SAL_Test mgr = new SAL_Test( (int) index);

          mgr.setDebugLevel(2);
          mgr.salEventPub("Test_logevent_logLevel");
          mgr.salTelemetryPub("Test_scalars");
          mgr.salProcessor("Test_command_setLogLevel");

          System.out.println("SALController: writing initial logLevel.level " + logLevel);
          SALEvent.level = logLevel;
          mgr.logEvent_logLevel(SALEvent,1);

          while (true) {
// receive event
          cmdid = mgr.acceptCommand_setLogLevel(SALCommand);

            if (cmdid < 0) {
              System.out.println( "SALController: error reading setLogLevel command; cmdid=" + cmdid);
            } else {
              if ( cmdid > 0 ) {
                System.out.println("SALController: read setLogLevel(cmdid=" + cmdid + ";level=" + SALCommand.level + ")");
                mgr.ackCommand_setLogLevel(cmdid, SAL_Test.SAL__CMD_COMPLETE, 0, "Done : OK");
                try {Thread.sleep(10);} catch (InterruptedException e)  { e.printStackTrace(); }
                System.out.println("SALController: writing logLevel=" + SALCommand.level + " event and the same value in scalars.int0 telemetry");
                SALTelemetry.int0 = SALCommand.level;
                SALEvent.level = SALCommand.level;
                mgr.logEvent_logLevel(SALEvent,1);
                mgr.putSample(SALTelemetry);
                try {Thread.sleep(10);} catch (InterruptedException e)  { e.printStackTrace(); }
                if (SALCommand.level == 0) break;
              }
            }
            try {Thread.sleep(1000);} catch (InterruptedException e)  { e.printStackTrace(); }
          }

// Remove the DataWriters etc
          System.out.println("SALController: completed");
          try{Thread.sleep(1000);} catch (InterruptedException e)  { e.printStackTrace(); }
          mgr.salShutdown();
      }

}


