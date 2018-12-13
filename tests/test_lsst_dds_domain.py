# This file is part of ts_scriptqueue.
#
# Developed for the LSST Telescope and Site Systems.
# This product includes software developed by the LSST Project
# (https://www.lsst.org).
# See the COPYRIGHT file at the top-level directory of this distribution
# for details of code ownership.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import asyncio
import unittest

from lsst.ts.sal import test_utils
import SALPY_Test

SAL_INDEX = 1
POLL_INTERVAL = 0.2  # seconds


class SimpleController:
    """A trivial Test SAL controller that receives a single command:
    setScalars.

    Parameters
    ----------
    int0 : `int`
        Required value of setScalars.int0
    """
    def __init__(self, int0):
        self.required_int0 = int0
        self.manager = SALPY_Test.SAL_Test(SAL_INDEX)
        self.run = True
        """Set `run` False to quit"""
        self.setScalars_data = SALPY_Test.Test_command_setScalarsC()
        self.manager.salProcessor("Test_command_setScalars")
        self.done_task = asyncio.Future()
        asyncio.ensure_future(self.handle_setScalars())

    async def handle_setScalars(self):
        """Handle the setScalars command.
        """
        while self.run:
            await asyncio.sleep(POLL_INTERVAL)
            cmd_id = self.manager.acceptCommand_setScalars(self.setScalars_data)

            if cmd_id <= 0:
                # no command seen
                continue

            ack = SALPY_Test.Test_ackcmdC()
            int0 = self.setScalars_data.int0
            if int0 == self.required_int0:
                ack.ack = SALPY_Test.SAL__CMD_COMPLETE
                ack.result = f"int0={int0} as required"
            else:
                ack.ack = SALPY_Test.SAL__CMD_FAILED
                ack.result = f"int0={int0} instead of {self.required_int0}"
            self.manager.ackCommand_setScalars(cmd_id, ack.ack, 0, ack.result)
        self.done_task.set_result(None)


class SimpleRemote:
    """A trivial Test SAL controller that sends a single command:
    setScalars.
    """
    def __init__(self):
        self.manager = SALPY_Test.SAL_Test(SAL_INDEX)
        self.setScalars_data = SALPY_Test.Test_command_setScalarsC()
        self.manager.salCommand("Test_command_setScalars")
        self.done_ack_codes = frozenset((
            SALPY_Test.SAL__CMD_ABORTED,
            SALPY_Test.SAL__CMD_COMPLETE,
            SALPY_Test.SAL__CMD_FAILED,
            SALPY_Test.SAL__CMD_NOACK,
            SALPY_Test.SAL__CMD_NOPERM,
            SALPY_Test.SAL__CMD_STALLED,
            SALPY_Test.SAL__CMD_TIMEOUT,
        ))

    async def setScalars(self, int0):
        """Send the setScalars with int0 field set as specified.

        Parameters
        ----------
        int0 : `int`
            Value for the int0 field of the setScalars command.
        """
        self.setScalars_data.int0 = int0
        self.manager.issueCommand_setScalars(self.setScalars_data)
        while True:
            await asyncio.sleep(POLL_INTERVAL)
            ack = SALPY_Test.Test_ackcmdC()
            response_id = self.manager.getResponse_setScalars(ack)
            if response_id == SALPY_Test.SAL__CMD_NOACK:
                continue
            if ack.ack not in self.done_ack_codes:
                continue
            if ack.ack == SALPY_Test.SAL__CMD_COMPLETE:
                return int0
            raise RuntimeError("Command ended with ack.ack={ack.ack}")


class Harness:
    def __init__(self, int0):
        self.int0 = int0
        self.remote = SimpleRemote()
        self.controller = SimpleController(int0)


class LsstDdsDomainTestCase(unittest.TestCase):
    def test_lsst_dds_domain(self):
        """Test that LSST_DDS_DOMAIN shields multiple SAL components
        with the same SAL index from each other.
        """
        async def doit():
            harnesses = []
            int0_set = (1, 2, 5)
            try:
                for int0 in sorted(int0_set):
                    print(f"Make harness for int0={int0}")
                    test_utils.set_random_lsst_dds_domain()
                    harnesses.append(Harness(int0))

                for harness in harnesses:
                    print(f"Test harness for int0={int0}")
                    for int0 in int0_set:
                        with self.subTest(harness_int0=harness.int0, int0=int0):
                            if int0 != harness.int0:
                                with self.assertRaises(RuntimeError):
                                    await asyncio.wait_for(harness.remote.setScalars(int0), 2)
                            else:
                                retval = await asyncio.wait_for(harness.remote.setScalars(int0), 2)
                                self.assertEqual(retval, int0)

            finally:
                for harness in harnesses:
                    harness.controller.run = False
                    await asyncio.wait_for(harness.controller.done_task, 2)

        asyncio.get_event_loop().run_until_complete(doit())


if __name__ == "__main__":
    unittest.main()
