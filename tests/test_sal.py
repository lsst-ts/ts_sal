import time
import unittest
import os

import numpy as np
try:
    from astropy.time import Time
except ImportError:
    Time = None

from lsst.ts.sal import test_utils
import SALPY_Test
import SALPY_Script

# Depth of DDS read queues (which is also the depth of the write queues).
# This must be at least as long as the actual depth for some tests to pass.
# If it ever becomes possible to read or write the depth in SALPY, update
# these tests to do that, to eliminate the dependence on the default depth.
READ_QUEUE_DEPTH = 100

# This environment variable is used for the experimental dds code,
# but can interfere with the standard code
if "LSST_DDS_QOS" in os.environ:
    del os.environ["LSST_DDS_QOS"]

STD_SLEEP = test_utils.STD_SLEEP

index_gen = test_utils.index_generator()

np.random.seed(47)


class BaseSalTestCase(unittest.TestCase):
    @property
    def next_index(self):
        return next(index_gen)

    def setUp(self):
        test_utils.set_random_lsst_dds_domain()
        self.index = self.next_index
        # remote sends commands and listens to telemetry and events
        self.remote = SALPY_Test.SAL_Test(self.index)
        # controller listens to commands and publishes telemetry and events
        self.controller = SALPY_Test.SAL_Test(self.index)
        self.test_data = test_utils.TestData()

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
            time.sleep(STD_SLEEP)
            if retcode == SALPY_Test.SAL__OK:
                break
            elif retcode == SALPY_Test.SAL__NO_UPDATES:
                time.sleep(0.1)
                continue
            else:
                self.fail(f"Unexpected return value {retcode}")
        else:
            self.fail("Timed out waiting for events")


class BasicTestCase(BaseSalTestCase):
    def test_get_current_time(self):
        """Test that getCurrentTime() - UTC matches the value reported
        by getLeapSeconds().

        This tests DM-18637.

        See also test_get_leap_seconds.
        """
        # Run the test twice in the unlikely event that the first run
        # occurs at a leap second transition.
        for i in range(2):
            leap_seconds = self.remote.getLeapSeconds()
            self.assertIsInstance(leap_seconds, int)
            measured_leap_seconds = self.remote.getCurrentTime() - time.time()
            if abs(leap_seconds - measured_leap_seconds) - 1 < 0.1:
                # We are probably at a leap second transition;
                # sleep and try again.
                time.sleep(2)
                continue
            break
        self.assertAlmostEqual(leap_seconds, measured_leap_seconds, places=3)

    @unittest.skipIf(Time is None, "Could not import astropy")
    def test_get_leap_seconds(self):
        """Test the value returned by getLeapSeconds.

        The value will either be TAI-UTC, if SAL can see a time server,
        or 0 if not.
        """
        def get_astropy_tai_minus_utc():
            """Get TAI-UTC at the current time, in seconds, using astropy.
            """
            # Unfortunately I can't just output
            # curr_time.tai.unix - curr_time.utc.unix
            # because they are identical.
            curr_time = Time.now()
            return (curr_time.tai.mjd - curr_time.utc.mjd)*24*60*60

        # Run the test twice in the unlikely event that the first run
        # occurs at a leap second transition.
        for i in range(2):
            leap_seconds = self.remote.getLeapSeconds()
            self.assertIsInstance(leap_seconds, int)
            if leap_seconds == 0:
                print("Warning: leap second table not setup.")
                return
            astropy_leap_seconds = get_astropy_tai_minus_utc()
            if abs(leap_seconds - astropy_leap_seconds) - 1 < 0.1:
                # We are probably at a leap second transition;
                # sleep and try again.
                time.sleep(2)
                continue
            break
        self.assertAlmostEqual(leap_seconds, astropy_leap_seconds, places=3)

    def test_get_versions(self):
        """Test getSALVersion and getXMLVersion.

        We don't know what versions to expect, so this test simply
        checks that the functions run and return strings.
        """
        sal_version = self.remote.getSALVersion()
        self.assertIsInstance(sal_version, str)
        xml_version = self.remote.getXMLVersion()
        self.assertIsInstance(xml_version, str)

    def test_evt_get_oldest(self):
        """Write several logevent messages and make sure gettting the
        oldest returns the data in the expected order.
        """
        self.remote.salEventSub("Test_logevent_scalars")
        time.sleep(STD_SLEEP)
        self.controller.salEventPub("Test_logevent_scalars")
        time.sleep(STD_SLEEP)

        data_list = []
        for i in range(3):
            data = SALPY_Test.Test_logevent_scalarsC()
            self.test_data.set_random_scalars(data)
            data_list.append(data)
            retcode = self.controller.logEvent_scalars(data, 1)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        for expected_data in data_list:
            data = SALPY_Test.Test_logevent_scalarsC()
            self.get_topic(self.remote.getEvent_scalars, data)
            self.test_data.assert_scalars_equal(data, expected_data)

        # at this point there should be nothing on the queue
        retcode = self.remote.getNextSample_logevent_scalars(data)
        time.sleep(STD_SLEEP)
        self.assertEqual(retcode, SALPY_Test.SAL__NO_UPDATES)

    def test_tel_get_oldest(self):
        """Write several telemetry messages and make sure gettting
        the oldest returns the data in the expected order.
        """
        self.remote.salTelemetrySub("Test_scalars")
        time.sleep(STD_SLEEP)
        self.controller.salTelemetryPub("Test_scalars")
        time.sleep(STD_SLEEP)

        data_list = []
        for i in range(3):
            data = SALPY_Test.Test_scalarsC()
            self.test_data.set_random_scalars(data)
            data_list.append(data)
            retcode = self.controller.putSample_scalars(data)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        for expected_data in data_list:
            data = SALPY_Test.Test_scalarsC()
            self.get_topic(self.remote.getNextSample_scalars, data)
            self.test_data.assert_scalars_equal(data, expected_data)

        # at this point there should be nothing on the queue
        retcode = self.remote.getNextSample_scalars(data)
        time.sleep(STD_SLEEP)
        self.assertEqual(retcode, SALPY_Test.SAL__NO_UPDATES)

    def test_evt_get_newest(self):
        """Write several messages and make sure gettting the newest
        returns that and flushes the queue.
        """
        self.remote.salEventSub("Test_logevent_arrays")
        time.sleep(STD_SLEEP)
        self.controller.salEventPub("Test_logevent_arrays")
        time.sleep(STD_SLEEP)

        data_list = []
        for i in range(3):
            data = SALPY_Test.Test_logevent_arraysC()
            self.test_data.set_random_arrays(data)
            data_list.append(data)
            retcode = self.controller.logEvent_arrays(data, 1)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        expected_data = data_list[-1]
        data = SALPY_Test.Test_logevent_arraysC()
        self.get_topic(self.remote.getSample_logevent_arrays, data)
        self.test_data.assert_arrays_equal(data, expected_data)

        # at this point there should be nothing on the queue
        retcode = self.remote.getNextSample_logevent_arrays(data)
        time.sleep(STD_SLEEP)
        self.assertEqual(retcode, SALPY_Test.SAL__NO_UPDATES)

        retcode = self.remote.getSample_logevent_arrays(data)
        time.sleep(STD_SLEEP)
        self.assertEqual(retcode, SALPY_Test.SAL__NO_UPDATES)

    def test_tel_get_newest(self):
        """Write several messages and make sure gettting the newest
        returns that and flushes the queue.
        """
        self.remote.salTelemetrySub("Test_arrays")
        time.sleep(STD_SLEEP)
        self.controller.salTelemetryPub("Test_arrays")
        time.sleep(STD_SLEEP)

        data_list = []
        for i in range(3):
            data = SALPY_Test.Test_arraysC()
            self.test_data.set_random_arrays(data)
            data_list.append(data)
            retcode = self.controller.putSample_arrays(data)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        expected_data = data_list[-1]
        data = SALPY_Test.Test_arraysC()
        self.get_topic(self.remote.getSample_arrays, data)
        self.test_data.assert_arrays_equal(data, expected_data)

        # at this point there should be nothing on the queue
        retcode = self.remote.getNextSample_arrays(data)
        time.sleep(STD_SLEEP)
        self.assertEqual(retcode, SALPY_Test.SAL__NO_UPDATES)

        retcode = self.remote.getSample_arrays(data)
        time.sleep(STD_SLEEP)
        self.assertEqual(retcode, SALPY_Test.SAL__NO_UPDATES)

    def test_evt_get_newest_after_get_oldest(self):
        """Test that get newest after get oldest gets the newest value.

        This tests DM-18491.
        """
        self.remote.salEventSub("Test_logevent_arrays")
        time.sleep(STD_SLEEP)
        self.controller.salEventPub("Test_logevent_arrays")
        time.sleep(STD_SLEEP)

        for get_event in (False, True):
            with self.subTest(get_event=get_event):
                self.check_get_newest_after_get_oldest(test_events=True, get_event=get_event)

    def test_tel_get_newest_after_get_oldest(self):
        """Test that get newest after get oldest gets the newest value.

        This tests DM-18491.
        """
        self.remote.salTelemetrySub("Test_arrays")
        time.sleep(STD_SLEEP)
        self.controller.salTelemetryPub("Test_arrays")
        time.sleep(STD_SLEEP)

        self.check_get_newest_after_get_oldest(test_events=False, get_event=False)

    def check_get_newest_after_get_oldest(self, test_events, get_event):
        """Test that get newest after get oldest gets the newest value.

        Uses the arrays topic. This tests DM-18491.

        Parameters
        ----------
        test_events : `bool`
            If True then test events else test telemetry
        get_event : `bool`
            If True then use getEvent to get the oldest value,
            else use getNextSample_logevent_scalars.
            Ignored if test_events is False.
        """
        if test_events:
            dtype = SALPY_Test.Test_logevent_arraysC
        else:
            dtype = SALPY_Test.Test_arraysC

        # write at least three values
        data_list = []
        for i in range(5):
            data = dtype()
            self.test_data.set_random_arrays(data)
            data_list.append(data)
            if test_events:
                retcode = self.controller.logEvent_arrays(data, 1)
            else:
                retcode = self.controller.putSample_arrays(data)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        # read and check the oldest value
        expected_data = data_list[0]
        data = dtype()
        if test_events:
            if get_event:
                retcode = self.remote.getEvent_arrays(data)
            else:
                retcode = self.remote.getNextSample_logevent_arrays(data)
        else:
            retcode = self.remote.getNextSample_arrays(data)
        time.sleep(STD_SLEEP)
        self.test_data.assert_arrays_equal(data, expected_data)

        # read and check the newest value
        expected_data = data_list[-1]
        data = dtype()
        if test_events:
            self.get_topic(self.remote.getSample_logevent_arrays, data)
        else:
            self.get_topic(self.remote.getSample_arrays, data)
        self.test_data.assert_arrays_equal(data, expected_data)

    def test_evt_late_joiner_oldest(self):
        """Test that a late joiner can an event using getNextSample.

        Only one value is retrievable.
        """
        self.controller.salEventPub("Test_logevent_arrays")
        time.sleep(STD_SLEEP)

        data_list = []
        for i in range(5):
            data = SALPY_Test.Test_logevent_arraysC()
            self.test_data.set_random_arrays(data)
            data_list.append(data)
            retcode = self.controller.logEvent_arrays(data, 1)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        self.remote.salEventSub("Test_logevent_arrays")
        time.sleep(STD_SLEEP)
        retcode = self.remote.getNextSample_logevent_arrays(data)
        self.assertEqual(retcode, SALPY_Test.SAL__OK)
        self.test_data.assert_arrays_equal(data, data_list[-1])

    def test_tel_late_joiner_oldest(self):
        """Test that a late joiner can see telemetry using getNextSample.

        Only one value is retrievable.
        """
        self.controller.salTelemetryPub("Test_arrays")
        time.sleep(STD_SLEEP)

        data_list = []
        for i in range(5):
            data = SALPY_Test.Test_arraysC()
            self.test_data.set_random_arrays(data)
            data_list.append(data)
            retcode = self.controller.putSample_arrays(data)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        self.remote.salTelemetrySub("Test_arrays")
        time.sleep(STD_SLEEP)
        retcode = self.remote.getNextSample_arrays(data)
        self.assertEqual(retcode, SALPY_Test.SAL__OK)
        self.test_data.assert_arrays_equal(data, data_list[-1])

    def test_evt_late_joiner_newest(self):
        """Test that a late joiner can see an event using getEvent.
        """
        self.controller.salEventPub("Test_logevent_arrays")
        time.sleep(STD_SLEEP)

        data_list = []
        for i in range(5):
            data = SALPY_Test.Test_logevent_arraysC()
            self.test_data.set_random_arrays(data)
            data_list.append(data)
            retcode = self.controller.logEvent_arrays(data, 1)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        self.remote.salEventSub("Test_logevent_arrays")
        time.sleep(STD_SLEEP)
        retcode = self.remote.getEvent_arrays(data)
        self.assertEqual(retcode, SALPY_Test.SAL__OK)
        self.test_data.assert_arrays_equal(data, data_list[-1])

    def test_tel_late_joiner_newest(self):
        """Test that a late joiner can see telemetry using getSample.
        """
        self.controller.salTelemetryPub("Test_arrays")
        time.sleep(STD_SLEEP)

        data_list = []
        for i in range(5):
            data = SALPY_Test.Test_arraysC()
            self.test_data.set_random_arrays(data)
            data_list.append(data)
            retcode = self.controller.putSample_arrays(data)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        self.remote.salTelemetrySub("Test_arrays")
        time.sleep(STD_SLEEP)
        retcode = self.remote.getSample_arrays(data)
        self.assertEqual(retcode, SALPY_Test.SAL__OK)
        self.test_data.assert_arrays_equal(data, data_list[-1])

    def test_enumerations(self):
        """Test enumerations."""
        # Shared enum with default values
        self.assertEqual(SALPY_Test.Test_shared_Enum_One, 1)
        self.assertEqual(SALPY_Test.Test_shared_Enum_Two, 2)
        self.assertEqual(SALPY_Test.Test_shared_Enum_Three, 3)
        # Shared enum with specified values
        self.assertEqual(SALPY_Test.Test_shared_ValueEnum_Zero, 0)
        self.assertEqual(SALPY_Test.Test_shared_ValueEnum_Two, 2)
        self.assertEqual(SALPY_Test.Test_shared_ValueEnum_Four, 4)
        self.assertEqual(SALPY_Test.Test_shared_ValueEnum_Five, 5)
        # Topic-specific enum with default values
        self.assertEqual(SALPY_Test.scalars_Int0Enum_One, 1)
        self.assertEqual(SALPY_Test.scalars_Int0Enum_Two, 2)
        self.assertEqual(SALPY_Test.scalars_Int0Enum_Three, 3)
        # Topic-specific enum with specified values
        self.assertEqual(SALPY_Test.arrays_Int0ValueEnum_Zero, 0)
        self.assertEqual(SALPY_Test.arrays_Int0ValueEnum_Two, 2)
        self.assertEqual(SALPY_Test.arrays_Int0ValueEnum_Four, 4)
        self.assertEqual(SALPY_Test.arrays_Int0ValueEnum_Five, 5)


class ScriptTestCase(unittest.TestCase):
    """A few tests require CSC that doesn't use generics, so we use Script.
    """
    def test_generics_no(self):
        """Test that setting generics to `no` avoids generics."""
        self.assertFalse(hasattr(SALPY_Script, "Test_command_enterControlC"))
        self.assertFalse(hasattr(SALPY_Script, "Test_logevent_summaryStateC"))


class ErrorHandlingTestCase(BaseSalTestCase):
    """Test misuse of the API
    """
    def test_multiple_shutdown(self):
        # Having no asserts is poor practice, but I'm not sure what else
        # I can call after shutdown to see if the manager was properly
        # shutdown
        self.remote.salShutdown()
        self.remote.salShutdown()
        self.controller.salShutdown()
        self.controller.salShutdown()

    def test_invalid_topic_names(self):
        """Test registering invalid topic names for commands,
        events and telemetry.
        """
        bad_cmd_name = "Test_command_nonexistent"
        with self.assertRaises(RuntimeError):
            self.controller.salCommand(bad_cmd_name)
        with self.assertRaises(RuntimeError):
            self.remote.salProcessor(bad_cmd_name)

        bad_evt_name = "Test_logevent_nonexistent"
        with self.assertRaises(RuntimeError):
            self.controller.salEventPub(bad_evt_name)
        with self.assertRaises(RuntimeError):
            self.remote.salEventSub(bad_evt_name)

        bad_tel_name = "Test_nonexistent"
        with self.assertRaises(RuntimeError):
            self.controller.salTelemetryPub(bad_tel_name)
        with self.assertRaises(RuntimeError):
            self.remote.salTelemetrySub(bad_tel_name)

    def test_cmd_no_registration(self):
        """Test getting and putting topics without registering them first.
        """
        data = SALPY_Test.Test_command_setScalarsC()

        self.check_cmd_get_put_raises(data=data, exception=RuntimeError)

    def test_evt_no_registration(self):
        """Test getting and putting topics without registering them first.
        """
        data = SALPY_Test.Test_logevent_scalarsC()

        self.check_evt_get_put_raises(data=data, exception=RuntimeError)

    def test_tel_no_registration(self):
        """Test getting and putting topics without registering them first.
        """
        data = SALPY_Test.Test_scalarsC()

        self.check_tel_get_put_raises(data=data, exception=RuntimeError)

    def test_cmd_bad_data_types(self):
        """Test getting and putting invalid command data types.

        This is not a very interesting test because pybind11
        should make this impossible, but it's worth a try,
        and indeed None segfaults! DM-18209
        """
        topic_name = "Test_command_setScalars"
        self.controller.salProcessor(topic_name)
        time.sleep(STD_SLEEP)
        self.remote.salCommand(topic_name)
        time.sleep(STD_SLEEP)

        # make sure this worked
        data = SALPY_Test.Test_command_setScalarsC()
        cmd_id = self.remote.issueCommand_setScalars(data)
        time.sleep(STD_SLEEP)
        self.assertGreater(cmd_id, 0)

        bad_data = SALPY_Test.Test_command_setArraysC()
        self.check_cmd_get_put_raises(data=bad_data, exception=TypeError)

        self.check_cmd_get_put_raises(data=None, exception=RuntimeError)

    def test_evt_bad_data_types(self):
        """Test getting and putting invalid logevent data types.

        This is not a very interesting test because pybind11
        should make this impossible, but it's worth a try,
        and indeed None segfaults! DM-18209
        """
        topic_name = "Test_logevent_scalars"
        self.controller.salEventPub(topic_name)
        self.remote.salEventSub(topic_name)
        time.sleep(STD_SLEEP)

        # make sure this worked
        data = SALPY_Test.Test_logevent_scalarsC()
        retcode = self.controller.logEvent_scalars(data, 1)
        self.assertEqual(retcode, SALPY_Test.SAL__OK)

        bad_data = SALPY_Test.Test_logevent_arraysC()
        self.check_evt_get_put_raises(data=bad_data, exception=TypeError)

        self.check_evt_get_put_raises(data=None, exception=RuntimeError)

    def test_tel_bad_data_types(self):
        """Test getting and putting invalid telemetry data types.

        This is not a very interesting test because pybind11
        should make this impossible, but it's worth a try,
        and indeed None segfaults! DM-18209
        """
        topic_name = "Test_scalars"
        self.remote.salTelemetrySub(topic_name)
        time.sleep(STD_SLEEP)
        self.controller.salTelemetryPub(topic_name)
        time.sleep(STD_SLEEP)

        # make sure this worked
        data = SALPY_Test.Test_scalarsC()
        retcode = self.controller.putSample_scalars(data)
        time.sleep(STD_SLEEP)
        self.assertEqual(retcode, SALPY_Test.SAL__OK)

        bad_data = SALPY_Test.Test_arraysC()
        self.check_tel_get_put_raises(data=bad_data, exception=TypeError)

        self.check_tel_get_put_raises(data=None, exception=RuntimeError)

    def test_evt_overflow_buffer(self):
        """Write enough message to overflow the read buffer and check that
        the oldest data is lost and the newest data preserved.
        """
        self.remote.salEventSub("Test_logevent_scalars")
        time.sleep(STD_SLEEP)
        self.controller.salEventPub("Test_logevent_scalars")
        time.sleep(STD_SLEEP)

        # nextra is the number of extra messages to write and read
        # beyond READ_QUEUE_DEPTH. It must be <= READ_QUEUE_DEPTH.
        nextra = 10
        data = SALPY_Test.Test_logevent_scalarsC()
        for val in range(0, READ_QUEUE_DEPTH + nextra):
            data.int0 = val
            retcode = self.controller.logEvent_scalars(data, 1)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        data = SALPY_Test.Test_logevent_scalarsC()
        self.get_topic(self.remote.getEvent_scalars, data)
        # make sure the queue overflowed
        self.assertNotEqual(data.int0, 0)

        start_value = data.int0
        for i in range(1, nextra):
            data = SALPY_Test.Test_logevent_scalarsC()
            self.get_topic(self.remote.getEvent_scalars, data)
            self.assertEqual(data.int0, start_value + i)

    def test_tel_overflow_buffer(self):
        """Write enough message to overflow the read buffer and check that
        the oldest data is lost and the newest data preserved.
        """
        self.remote.salTelemetrySub("Test_scalars")
        time.sleep(STD_SLEEP)
        self.controller.salTelemetryPub("Test_scalars")
        time.sleep(STD_SLEEP)

        # nextra is the number of extra messages to write and read
        # beyond READ_QUEUE_DEPTH. It must be <= READ_QUEUE_DEPTH.
        nextra = 10
        data = SALPY_Test.Test_scalarsC()
        for val in range(0, READ_QUEUE_DEPTH + nextra):
            data.int0 = val
            retcode = self.controller.putSample_scalars(data)
            time.sleep(STD_SLEEP)
            self.assertEqual(retcode, SALPY_Test.SAL__OK)

        data = SALPY_Test.Test_scalarsC()
        self.get_topic(self.remote.getNextSample_scalars, data)
        # make sure the queue overflowed
        self.assertNotEqual(data.int0, 0)

        start_value = data.int0
        for i in range(1, nextra):
            data = SALPY_Test.Test_scalarsC()
            self.get_topic(self.remote.getNextSample_scalars, data)
            self.assertEqual(data.int0, start_value + i)

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
        self.remote.salTelemetrySub("Test_scalars")
        time.sleep(STD_SLEEP)
        self.controller.salTelemetryPub("Test_scalars")
        time.sleep(STD_SLEEP)

        # from the XML file; unfortunately there is no way to ask SALPY
        too_long_data = "0123456789"*10
        self.assertEqual(len(too_long_data), 100)
        data = SALPY_Test.Test_scalarsC()
        # string0 has a limit of 20 characters
        data.string0 = too_long_data
        with self.assertRaises(ValueError):
            self.controller.putSample_scalars(data)

    def test_wrong_length_arrays(self):
        """Check that setting sending too long an array causes an error.
        """
        data = SALPY_Test.Test_arraysC()
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

    def check_cmd_get_put_raises(self, data, exception):
        """Test getting and putting command topics where a raise is expected,
        e.g. due to invalid data or not registering the topic first.

        Parameters
        ----------
        data : any
            Data to use as the argument to the get and put functions
        exception : subclass of `Exception`
            Expected exception, e.g. TypeError
        """
        with self.assertRaises(exception):
            self.controller.acceptCommand_setScalars(data)
        with self.assertRaises(exception):
            self.remote.issueCommand_setScalars(data)

    def check_evt_get_put_raises(self, data, exception):
        """Test getting and putting logevent topics where a raise is expected,
        e.g. due to invalid data or not registering the topic first.

        Parameters
        ----------
        data : any
            Data to use as the argument to the get and put functions
        exception : subclass of `Exception`
            Expected exception, e.g. TypeError
        """
        with self.assertRaises(exception):
            self.remote.getNextSample_logevent_scalars(data)
        with self.assertRaises(exception):
            self.remote.getEvent_scalars(data)
        with self.assertRaises(exception):
            self.remote.getSample_logevent_scalars(data)
        with self.assertRaises(exception):
            self.remote.flushSamples_logevent_scalars(data)

        with self.assertRaises(exception):
            self.controller.logEvent_scalars(data, 1)

    def check_tel_get_put_raises(self, data, exception):
        """Test getting and putting the telemetry scalars topic
        where a raise is expected.

        Reasons this may raise include: incorrect data type,
        invalid data and not registering the topic first.

        Parameters
        ----------
        data : any
            Data to use as the argument to the get and put functions
        exception : subclass of `Exception`
            Expected exception, e.g. TypeError
        """
        with self.assertRaises(exception):
            self.remote.getNextSample_scalars(data)
        with self.assertRaises(exception):
            self.remote.getSample_scalars(data)
        with self.assertRaises(exception):
            self.remote.flushSamples_scalars(data)

        with self.assertRaises(exception):
            self.controller.putSample_scalars(data)


class TestTestData(unittest.TestCase):
    def setUp(self):
        self.test_data = test_utils.TestData()

    def test_scalars(self):
        data_list = []
        for i in range(10):
            data = SALPY_Test.Test_scalarsC()
            self.test_data.set_random_scalars(data)
            data_list.append(data)

        for i, data in enumerate(data_list):
            data0 = data_list[i]
            for j, data1 in enumerate(data_list):
                if i == j:
                    self.test_data.assert_scalars_equal(data0, data1)
                else:
                    with self.assertRaises(AssertionError):
                        self.test_data.assert_scalars_equal(data0, data1)

    def test_arrays(self):
        data_list = []
        for i in range(10):
            data = SALPY_Test.Test_arraysC()
            self.test_data.set_random_arrays(data)
            data_list.append(data)

        for i, data in enumerate(data_list):
            data0 = data_list[i]
            for j, data1 in enumerate(data_list):
                if i == j:
                    self.test_data.assert_arrays_equal(data0, data1)
                else:
                    with self.assertRaises(AssertionError):
                        self.test_data.assert_arrays_equal(data0, data1)


if __name__ == "__main__":
    unittest.main()
