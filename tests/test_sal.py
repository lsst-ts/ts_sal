import time
import unittest

import numpy as np
from lsst.ts.sal import test_utils
import SALPY_Test

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
            res = func(data)
            if res == self.salinfo.lib.SAL__OK:
                break
            elif res == self.salinfo.lib.SAL__NO_UPDATES:
                continue
            else:
                self.fail(f"Unexpected return value {res}")
        else:
            self.fail("Timed out waiting for events")

    def test_evt_get_oldest(self):
        """Write several messages and make sure gettting the oldest
        returns the data in the expected order.
        """
        int_values = (-5, 47, 999)  # arbitrary
        for val in int_values:
            data = self.salinfo.lib.Test_logevent_scalarsC()
            data.int0 = val
            res = self.manager.logEvent_scalars(data, 1)
            self.assertEqual(res, self.salinfo.lib.SAL__OK)

        for expected_value in int_values:
            data = self.salinfo.lib.Test_logevent_scalarsC()
            self.get_topic(self.manager.getEvent_scalars, data)
            self.assertEqual(data.int0, expected_value)

        # at this point there should be nothing on the queu
        res = self.manager.getNextSample_logevent_scalars(data)
        self.assertEqual(res, self.salinfo.lib.SAL__NO_UPDATES)

    def test_tel_get_newest(self):
        """Write several messages and make sure gettting the newest
        returns that and flushes the queue.
        """
        int_values = (-5, 47, 999)  # arbitrary
        for val in int_values:
            data = self.salinfo.lib.Test_scalarsC()
            data.int0 = val
            res = self.manager.putSample_scalars(data)
            self.assertEqual(res, self.salinfo.lib.SAL__OK)

        expected_value = int_values[-1]
        data = self.salinfo.lib.Test_scalarsC()
        self.get_topic(self.manager.getSample_scalars, data)
        self.assertEqual(data.int0, expected_value)

        # at this point there should be nothing on the queu
        res = self.manager.getNextSample_scalars(data)
        self.assertEqual(res, self.salinfo.lib.SAL__NO_UPDATES)

        res = self.manager.getSample_scalars(data)
        self.assertEqual(res, self.salinfo.lib.SAL__NO_UPDATES)

    def test_teloverflow_buffer(self):
        """Write enough message to overflow the read buffer and check that
        the oldest data is lost and the newest data preserved.
        """
        # from my measurements the queue has 10,000 slots;
        # if there is some way to shrink this then I suggest
        # doing so to speed up the test
        for val in range(0, 50000):
            data = self.salinfo.lib.Test_logevent_scalarsC()
            data.int0 = val
            res = self.manager.logEvent_scalars(data, 1)
            self.assertEqual(res, self.salinfo.lib.SAL__OK)

        data = self.salinfo.lib.Test_logevent_scalarsC()
        self.get_topic(self.manager.getEvent_scalars, data)
        # make sure the queue overflowed
        self.assertNotEqual(data.int0, 0)

        start_value = data.int0
        for i in range(1, 100):
            data = self.salinfo.lib.Test_logevent_scalarsC()
            self.get_topic(self.manager.getEvent_scalars, data)
            self.assertEqual(data.int0, start_value + i)

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
        res = self.manager.putSample_scalars(data)
        self.assertEqual(res, self.salinfo.lib.SAL__OK)

        data = self.salinfo.lib.Test_scalarsC()
        res = self.get_topic(self.manager.getNextSample_scalars, data)
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

    @unittest.expectedFailure
    def test_invalid_topic_names(self):
        """Test registering invalid topic names for commands,
        events and telemetry.
        """
        # These should fail (perhaps with a different exception),
        # but the commands don't raise any exception at all!
        bad_cmd_name = "Test_command_nonexistent"
        with self.assertRaises(ValueError):
            self.manager.salCommand(bad_cmd_name)
        with self.assertRaises(ValueError):
            self.manager.salProcessor(bad_cmd_name)

        bad_evt_name = "Test_logevent_nonexistent"
        with self.assertRaises(ValueError):
            self.manager.salEventPub(bad_evt_name)
        with self.assertRaises(ValueError):
            self.manager.salEventSub(bad_evt_name)

        bad_evt_name = "Test_nonexistent"
        with self.assertRaises(ValueError):
            self.manager.salTelemetryPub(bad_evt_name)
        with self.assertRaises(ValueError):
            self.manager.salTelemetrySub(bad_evt_name)

    @unittest.skip("this segfaults instead of raising")
    def test_evt_no_registration(self):
        """Test getting and putting topics without registering them first.
        """
        data = self.salinfo.lib.Test_logevent_scalarsC()

        # the following segfaults instead of raising an exception;
        # I think it should raise a RuntimeError
        self.check_evt_bad_data(data=data, exception=RuntimeError)

    @unittest.skip("this segfaults instead of raising")
    def test_evt_bad_data_types(self):
        """Test getting and putting invalid data types.

        This is not a very interesting test because pybind11
        should make this impossible, but it's worth a try,
        and indeed None segfaults!
        """
        topic_name = "Test_logevent_scalars"
        self.manager.salEventPub(topic_name)
        self.manager.salEventSub(topic_name)

        # make sure this worked
        data = self.salinfo.lib.Test_logevent_scalarsC()
        ret = self.manager.logEvent_scalars(data, 1)
        self.assertEqual(ret, self.salinfo.lib.SAL__OK)

        bad_data = self.salinfo.lib.Test_logevent_arraysC()
        self.check_evt_bad_data(data=bad_data, exception=TypeError)

        self.check_evt_bad_data(data=None, exception=TypeError)

    def check_evt_bad_data(self, data, exception):
        """Test getting and putting topics with invalid data

        Parameters
        ----------
        data : any
            Data to use as the argument to the get and put functions
        exception : subclass of `Exception`
            Expected exception, e.g. TypeError
        """
        # NOTE: It is even easier to write this for commands and telemetry
        # because you just need the func_name loop;
        # all functions take a single argument: the data

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


if __name__ == "__main__":
    unittest.main()
