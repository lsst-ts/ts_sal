import time
import unittest

import numpy as np
from lsst.ts.sal import test_utils
import SALPY_Test
import SALPY_Script

index_gen = test_utils.index_generator()


class BasicTestCase(unittest.TestCase):
    @property
    def next_index(self):
        return next(index_gen)

    def setUp(self):
        test_utils.set_random_lsst_dds_domain()

        self.salinfo = test_utils.SalInfo(SALPY_Test, self.next_index)
        self.manager = self.salinfo.manager
        self.wrapper = test_utils.TestWrapper(self.salinfo)

    def get_topic(self, func, data, timeout=2):
        """Get data for a topic using the specified command.

        Parameters
        ----------
        func : `callable`
            Function to call to get data.
            It must take one argument: ``data``
            and return a result that is SAL__OK or SAL__NO_UPDATES
        data : `any`
            Data struct to fill.
        timeout : `float`
            Time limit, in seconds.
        """
        start_time = time.time()
        while time.time() - start_time < 2:
            retcode = func(data)
            if retcode == self.salinfo.lib.SAL__OK:
                break
            elif retcode == self.salinfo.lib.SAL__NO_UPDATES:
                continue
            else:
                self.fail(f"Unexpected return value {retcode}")
        else:
            self.fail("Timed out waiting for events")

    def test_evt_get_oldest(self):
        """Write several logevent messages and make sure gettting the
        oldest returns the data in the expected order.
        """
        int_values = (-5, 47, 999)  # arbitrary
        for val in int_values:
            data = self.salinfo.lib.Test_logevent_scalarsC()
            data.int0 = val
            retcode = self.manager.logEvent_scalars(data, 1)
            self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

        for expected_value in int_values:
            data = self.salinfo.lib.Test_logevent_scalarsC()
            self.get_topic(self.manager.getEvent_scalars, data)
            self.assertEqual(data.int0, expected_value)

        # at this point there should be nothing on the queu
        retcode = self.manager.getNextSample_logevent_scalars(data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__NO_UPDATES)

    def test_tel_get_oldest(self):
        """Write several telemetry messages and make sure gettting
        the oldest returns the data in the expected order.
        """
        int_values = (-5, 47, 999)  # arbitrary
        for val in int_values:
            data = self.salinfo.lib.Test_scalarsC()
            data.int0 = val
            retcode = self.manager.putSample_scalars(data)
            self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

        for expected_value in int_values:
            data = self.salinfo.lib.Test_scalarsC()
            self.get_topic(self.manager.getNextSample_scalars, data)
            self.assertEqual(data.int0, expected_value)

        # at this point there should be nothing on the queu
        retcode = self.manager.getNextSample_scalars(data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__NO_UPDATES)

    def test_evt_get_newest(self):
        """Write several messages and make sure gettting the newest
        returns that and flushes the queue.
        """
        int_values = (-5, 47, 999)  # arbitrary
        for val in int_values:
            data = self.salinfo.lib.Test_logevent_scalarsC()
            data.int0 = val
            retcode = self.manager.logEvent_scalars(data, 1)
            self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

        expected_value = int_values[-1]
        data = self.salinfo.lib.Test_logevent_scalarsC()
        self.get_topic(self.manager.getSample_logevent_scalars, data)
        self.assertEqual(data.int0, expected_value)

        # at this point there should be nothing on the queu
        retcode = self.manager.getNextSample_logevent_scalars(data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__NO_UPDATES)

        retcode = self.manager.getSample_logevent_scalars(data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__NO_UPDATES)

    def test_tel_get_newest(self):
        """Write several messages and make sure gettting the newest
        returns that and flushes the queue.
        """
        int_values = (-5, 47, 999)  # arbitrary
        for val in int_values:
            data = self.salinfo.lib.Test_scalarsC()
            data.int0 = val
            retcode = self.manager.putSample_scalars(data)
            self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

        expected_value = int_values[-1]
        data = self.salinfo.lib.Test_scalarsC()
        self.get_topic(self.manager.getSample_scalars, data)
        self.assertEqual(data.int0, expected_value)

        # at this point there should be nothing on the queu
        retcode = self.manager.getNextSample_scalars(data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__NO_UPDATES)

        retcode = self.manager.getSample_scalars(data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__NO_UPDATES)

    def test_teloverflow_buffer(self):
        """Write enough message to overflow the read buffer and check that
        the oldest data is lost and the newest data preserved.
        """
        # from my measurements the queue has 10,000 slots;
        # if there is some way to shrink this then I suggest
        # doing so to speed up the test
        for val in range(0, 11000):
            data = self.salinfo.lib.Test_logevent_scalarsC()
            data.int0 = val
            retcode = self.manager.logEvent_scalars(data, 1)
            self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

        data = self.salinfo.lib.Test_logevent_scalarsC()
        self.get_topic(self.manager.getEvent_scalars, data)
        # make sure the queue overflowed
        self.assertNotEqual(data.int0, 0)

        start_value = data.int0
        for i in range(1, 100):
            data = self.salinfo.lib.Test_logevent_scalarsC()
            self.get_topic(self.manager.getEvent_scalars, data)
            self.assertEqual(data.int0, start_value + i)

    def test_evt_late_joiner_oldest(self):
        """Test that a late joiner can an event using getNextSample.

        Only one value is retrievable.
        """
        num_values = 3
        scalars_data = SALPY_Test.Test_logevent_scalarsC()
        for i in range(num_values):
            scalars_data.int0 = i + 1
            self.manager.logEvent_scalars(scalars_data, 1)

        salinfo2 = test_utils.SalInfo(SALPY_Test, self.salinfo.index)
        manager2 = salinfo2.manager
        manager2.salEventSub("Test_logevent_scalars")
        retcode = manager2.getNextSample_logevent_scalars(scalars_data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__OK)
        self.assertEqual(scalars_data.int0, num_values)

    def test_evt_late_joiner_newest(self):
        """Test that a late joiner can see an event using getEvent.
        """
        num_values = 3
        scalars_data = SALPY_Test.Test_logevent_scalarsC()
        for i in range(num_values):
            scalars_data.int0 = i + 1
            self.manager.logEvent_scalars(scalars_data, 1)

        salinfo2 = test_utils.SalInfo(SALPY_Test, self.salinfo.index)
        manager2 = salinfo2.manager
        manager2.salEventSub("Test_logevent_scalars")
        retcode = manager2.getEvent_scalars(scalars_data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

    def test_tel_late_joiner_oldest(self):
        """Test that a late joiner can see telemetry using getNextSample.

        Only one value is retrievable.
        """
        num_values = 3
        scalars_data = SALPY_Test.Test_scalarsC()
        for i in range(num_values):
            scalars_data.int0 = i + 1
            self.manager.putSample_scalars(scalars_data)

        salinfo2 = test_utils.SalInfo(SALPY_Test, self.salinfo.index)
        manager2 = salinfo2.manager
        manager2.salTelemetrySub("Test_scalars")
        retcode = manager2.getNextSample_scalars(scalars_data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

    def test_tel_late_joiner_newest(self):
        """Test that a late joiner can see telemetry using getSample.
        """
        num_values = 3
        scalars_data = SALPY_Test.Test_scalarsC()
        for i in range(num_values):
            scalars_data.int0 = i + 1
            self.manager.putSample_scalars(scalars_data)

        salinfo2 = test_utils.SalInfo(SALPY_Test, self.salinfo.index)
        manager2 = salinfo2.manager
        manager2.salTelemetrySub("Test_scalars")
        retcode = manager2.getSample_scalars(scalars_data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

    @unittest.expectedFailure
    def test_too_long_strings(self):
        """Check that sending too long a string causes an error.

        Warning: at present SALPY does not truncate the data
        that it sends. Thus for this test to be truly useful
        we would have to write data to listeners in different languages.
        But the proper fix is for SALPY to raise an exception
        when the data is sent, or at least truncate the data
        before sending it. That means we don't have to care about
        other languages because incorrect data will not be sent!
        """
        # from the XML file; unfortunately there is no way to ask SALPY
        str_len = 20
        too_long_data = "0123456789"*10
        self.assertEqual(len(too_long_data), 100)
        data = self.salinfo.lib.Test_scalarsC()
        # string0 has a limit of 20 characters
        data.string0 = too_long_data
        retcode = self.manager.putSample_scalars(data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

        data = self.salinfo.lib.Test_scalarsC()
        retcode = self.get_topic(self.manager.getNextSample_scalars, data)
        # this fails because the data is not truncated!
        self.assertEqual(data.string0, too_long_data[0:str_len])

    def test_wrong_length_arrays(self):
        """Check that setting sending too long an array causes an error.
        """
        data = self.salinfo.lib.Test_arraysC()
        float1_len = len(data.float0)
        bad_float_data = np.arange(float1_len + 1, dtype=data.float0.dtype)
        # cannot set array attributes at all
        with self.assertRaises(AttributeError):
            data.float0 = data.float
        # cannot set to too long a value
        with self.assertRaises(ValueError):
            data.float0[:] = bad_float_data  # too long
        # cannot set to too short a value
        with self.assertRaises(ValueError):
            data.float0[:] = data.float0[0:-2]  # too short


class ScriptTestCase(unittest.TestCase):
    """A few tests require a non-CSC component or a SAL component
    with enumerations. Script fits both criteria.
    """
    def test_enumerations_present(self):
        """Test that enumeration values are present as constants."""
        self.assertTrue(hasattr(SALPY_Script, "state_Done"))
        self.assertTrue(hasattr(SALPY_Script, "metadata_CSys_ICRS"))

    def test_generics_no(self):
        """Test that setting generics to `no` avoids generics."""
        self.assertFalse(hasattr(SALPY_Script, "Test_command_enterControlC"))
        self.assertFalse(hasattr(SALPY_Script, "Test_logevent_summaryStateC"))


class ErrorProtectionTestCase(unittest.TestCase):
    """Test misuse of the API
    """
    def setUp(self):
        test_utils.set_random_lsst_dds_domain()

        self.salinfo = test_utils.SalInfo(SALPY_Test, self.next_index)
        self.manager = self.salinfo.manager

    def test_multiple_shutdown(self):
        # Having no asserts is poor practice, but I'm not sure what else
        # I can call after shutdown to see if the manager was properly
        # shutdown
        self.manager.salShutdown()
        self.manager.salShutdown()

    @property
    def next_index(self):
        return next(index_gen)

    def test_invalid_topic_names(self):
        """Test registering invalid topic names for commands,
        events and telemetry.

        TODO TSS-3235: change these tests to use
        `with self.assertRaises(...):`
        """
        bad_cmd_name = "Test_command_nonexistent"
        with self.assertRaises(RuntimeError):
            self.manager.salCommand(bad_cmd_name)
        with self.assertRaises(RuntimeError):
            self.manager.salProcessor(bad_cmd_name)

        bad_evt_name = "Test_logevent_nonexistent"
        with self.assertRaises(RuntimeError):
            self.manager.salEventPub(bad_evt_name)
        with self.assertRaises(RuntimeError):
            self.manager.salEventSub(bad_evt_name)

        bad_tel_name = "Test_nonexistent"
        with self.assertRaises(RuntimeError):
            self.manager.salTelemetryPub(bad_tel_name)
        with self.assertRaises(RuntimeError):
            self.manager.salTelemetrySub(bad_tel_name)

    @unittest.skip("this segfaults instead of raising")
    def test_evt_no_registration(self):
        """Test getting and putting topics without registering them first.

        TODO TSS-3234: enable this test.
        """
        data = self.salinfo.lib.Test_logevent_scalarsC()

        # the following segfaults instead of raising an exception;
        # I think it should raise a RuntimeError
        self.check_evt_bad_data(data=data, exception=RuntimeError)

    def test_cmd_bad_data_types(self):
        """Test getting and putting invalid command data types.

        This is not a very interesting test because pybind11
        should make this impossible, but it's worth a try,
        and indeed None segfaults! TSS-3235
        """
        topic_name = "Test_command_setScalars"
        self.manager.salCommand(topic_name)
        self.manager.salProcessor(topic_name)

        # make sure this worked
        data = self.salinfo.lib.Test_command_setScalarsC()
        cmd_id = self.manager.issueCommand_setScalars(data)
        self.assertGreater(cmd_id, 0)

        bad_data = self.salinfo.lib.Test_command_setArraysC()
        self.check_cmd_bad_data(data=bad_data, exception=TypeError)

        # TODO TSS-3235: uncomment the following:
        # self.check_cmd_bad_data(data=None, exception=TypeError)

    def test_tel_bad_data_types(self):
        """Test getting and putting invalid telemetry data types.

        This is not a very interesting test because pybind11
        should make this impossible, but it's worth a try,
        and indeed None segfaults! TSS-3235
        """
        topic_name = "Test_scalars"
        self.manager.salTelemetryPub(topic_name)
        self.manager.salTelemetrySub(topic_name)

        # make sure this worked
        data = self.salinfo.lib.Test_scalarsC()
        retcode = self.manager.putSample_scalars(data)
        self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

        bad_data = self.salinfo.lib.Test_arraysC()
        self.check_tel_bad_data(data=bad_data, exception=TypeError)

        # TODO TSS-3235: uncomment the following:
        # self.check_tel_bad_data(data=None, exception=TypeError)

    def test_evt_bad_data_types(self):
        """Test getting and putting invalid logevent data types.

        This is not a very interesting test because pybind11
        should make this impossible, but it's worth a try,
        and indeed None segfaults! TSS-3235
        """
        topic_name = "Test_logevent_scalars"
        self.manager.salEventPub(topic_name)
        self.manager.salEventSub(topic_name)

        # make sure this worked
        data = self.salinfo.lib.Test_logevent_scalarsC()
        retcode = self.manager.logEvent_scalars(data, 1)
        self.assertEqual(retcode, self.salinfo.lib.SAL__OK)

        bad_data = self.salinfo.lib.Test_logevent_arraysC()
        self.check_evt_bad_data(data=bad_data, exception=TypeError)

        # TODO TSS-3235: uncomment the following:
        # self.check_evt_bad_data(data=None, exception=TypeError)

    def check_cmd_bad_data(self, data, exception):
        """Test getting and putting commands with invalid data

        Parameters
        ----------
        data : any
            Data to use as the argument to the get and put functions
        exception : subclass of `Exception`
            Expected exception, e.g. TypeError
        """
        for func_name in (
            "acceptCommand_setScalars",
            "issueCommand_setScalars",
        ):
            with self.subTest(func_name=func_name):
                func = getattr(self.manager, func_name)
                with self.assertRaises(exception):
                    func(data)

    def check_evt_bad_data(self, data, exception):
        """Test getting and putting logevent topics with invalid data.

        Parameters
        ----------
        data : any
            Data to use as the argument to the get and put functions
        exception : subclass of `Exception`
            Expected exception, e.g. TypeError
        """
        with self.assertRaises(exception):
            self.manager.logEvent_scalars(data, 1)

        for func_name in (
            "getEvent_scalars",
            "getNextSample_logevent_scalars",
            # "getSample_logevent_scalars",  # not yet wrapped
            "flushSamples_logevent_scalars",
        ):
            with self.subTest(func_name=func_name):
                func = getattr(self.manager, func_name)
                with self.assertRaises(exception):
                    func(data)

    def check_tel_bad_data(self, data, exception):
        """Test getting and putting Telemetry topics with invalid data.

        Parameters
        ----------
        data : any
            Data to use as the argument to the get and put functions
        exception : subclass of `Exception`
            Expected exception, e.g. TypeError
        """
        for func_name in (
            "getNextSample_logevent_scalars",
            "getSample_scalars",
            "flushSamples_logevent_scalars",
            "putSample_scalars",
        ):
            with self.subTest(func_name=func_name):
                func = getattr(self.manager, func_name)
                with self.assertRaises(exception):
                    func(data)


if __name__ == "__main__":
    unittest.main()
