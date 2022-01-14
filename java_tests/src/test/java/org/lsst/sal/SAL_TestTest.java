package org.lsst.sal;

import Test.*;
import org.junit.Assert;
import org.junit.Test;

public class SAL_TestTest extends BaseTestCase {

    @Test
    public void testGetCurrentTime() {
        salUtils su = new salUtils();
        // Run the test twice in the unlikely event that the first run
        // occurs at a leap second transition.
        int leapSeconds = 0;
        double measuredSeconds = 0.0;
        for (int i = 0; i < 2; i++) {
            leapSeconds = su.getLeapSeconds();
            measuredSeconds = remote.getCurrentTime() - (System.currentTimeMillis() / 1000.0);
            if (Math.abs(leapSeconds - measuredSeconds) - 1 < 0.1) {
                // We are probably at a leap second transition;
                // sleep and try again.
                sleep(2);
                continue;
            }
            break;
        }
        Assert.assertEquals(leapSeconds, measuredSeconds, 0.001);
    }

    @Test
    public void testGetLeapSeconds() {
        salUtils salUtil = new salUtils();
        int leapSeconds = salUtil.getLeapSeconds();
        Assert.assertTrue(leapSeconds >= 0);
    }

    @Test
    public void testGetVersions() {
        final String salVersion = remote.getSALVersion();
        Assert.assertNotNull(salVersion);
        Assert.assertNotSame("", salVersion);
        final String xmlVersion = remote.getXMLVersion();
        Assert.assertNotNull(xmlVersion);
        Assert.assertNotSame("", xmlVersion);
    }

    /**
     * Write several logevent messages and make sure gettting the oldest returns the data in the expected order.
     *
     * @throws Exception In case of a problem related to reflection.
     */
    @Test
    public void testEvtGetOldest() throws Exception {
        remote.salEventSub("Test_logevent_scalars");
        controller.salEventPub("Test_logevent_scalars");

        final int numLoops = 3;

        logevent_scalars[] dataArray = new logevent_scalars[numLoops];
        for (int i = 0; i < numLoops; i++) {
            logevent_scalars data = new logevent_scalars();
            TestUtils.fillScalarsWithRandomValues(data);
            dataArray[i] = data;
            int retCode = controller.logEvent_scalars(data, 1);
            Assert.assertEquals(SAL_Test.SAL__OK, retCode);
        }

        for (logevent_scalars expected_data : dataArray) {
            logevent_scalars data = new logevent_scalars();
            getTopic("getEvent_scalars", data);
            TestUtils.assertScalarsEqual(expected_data, data);
        }

        // at this point there should be nothing on the queue
        logevent_scalars data = new logevent_scalars();
        int retCode = remote.getEvent_scalars(data);
        Assert.assertEquals(SAL_Test.SAL__NO_UPDATES, retCode);
    }

    /**
     * Write several telemetry messages and make sure gettting the oldest returns the data in the expected order.
     *
     * @throws Exception In case of a problem related to reflection.
     */
    @Test
    public void testTelGetOldest() throws Exception {
        remote.salTelemetrySub("Test_scalars");
        controller.salTelemetryPub("Test_scalars");

        final int numLoops = 3;

        scalars[] dataArray = new scalars[numLoops];
        for (int i = 0; i < numLoops; i++) {
            scalars data = new scalars();
            TestUtils.fillScalarsWithRandomValues(data);
            int retCode = controller.putSample(data);
            dataArray[i] = data;
            Assert.assertEquals(SAL_Test.SAL__OK, retCode);
        }

        for (scalars expected_data : dataArray) {
            scalars data = new scalars();
            getTopic("getNextSample", data);
            TestUtils.assertScalarsEqual(expected_data, data);
        }

        // at this point there should be nothing on the queue
        scalars data = new scalars();
        int retCode = remote.getNextSample(data);
        Assert.assertEquals(SAL_Test.SAL__NO_UPDATES, retCode);
    }

    /**
     * Write several messages and make sure gettting the newest returns that and flushes the queue.
     *
     * @throws Exception In case of a problem related to reflection.
     */
    @Test
    public void testEvtGetNewest() throws Exception {
        remote.salEventSub("Test_logevent_arrays");
        controller.salEventPub("Test_logevent_arrays");
        final int numLoops = 3;

        logevent_arrays[] dataArray = new logevent_arrays[numLoops];
        for (int i = 0; i < numLoops; i++) {
            logevent_arrays data = new logevent_arrays();
            TestUtils.fillArraysWithRandomValues(data);
            dataArray[i] = data;
            int retCode = controller.logEvent_arrays(data, 1);
            Assert.assertEquals(SAL_Test.SAL__OK, retCode);
        }

        logevent_arrays expected_data = dataArray[numLoops - 1];
        logevent_arrays data = new logevent_arrays();
        getTopic("getSample", data);
        TestUtils.assertArraysEqual(expected_data, data);

        // at this point there should be nothing on the queue
        int retcode = remote.getNextSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__NO_UPDATES);

        retcode = remote.getSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__NO_UPDATES);
    }

    /**
     * Write several messages and make sure gettting the newest returns that and flushes the queue.
     *
     * @throws Exception In case of a problem related to reflection.
     */
    @Test
    public void testTelGetNewest() throws Exception {
        remote.salTelemetrySub("Test_arrays");
        controller.salTelemetryPub("Test_arrays");
        final int numLoops = 3;

        arrays[] dataList = new arrays[numLoops];
        for (int i = 0; i < numLoops; i++) {
            arrays data = new arrays();
            TestUtils.fillArraysWithRandomValues(data);
            dataList[i] = data;
            int retcode = controller.putSample(data);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        arrays expected_data = dataList[numLoops - 1];
        arrays data = new arrays();
        getTopic("getSample", data);
        TestUtils.assertArraysEqual(data, expected_data);

        // at this point there should be nothing on the queue
        int retcode = remote.getNextSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__NO_UPDATES);

        retcode = remote.getSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__NO_UPDATES);
    }

    /**
     * Test that get newest after get oldest gets the newest value.
     * <p>
     * This tests DM-18491.
     *
     * @throws Exception In case of a problem related to reflection.
     */
    @Test
    public void testEvtGetNewestAfterGetOldest() throws Exception {
        remote.salEventSub("Test_logevent_arrays");
        controller.salEventPub("Test_logevent_arrays");
        boolean[] getEvents = {false, true};

        for (boolean getEvent : getEvents) {
            getNewestAfterGetOldest(true, getEvent);
        }
    }

    /**
     * Test that get newest after get oldest gets the newest value.
     * <p>
     * This tests DM-18491.
     *
     * @throws Exception In case of a problem related to reflection.
     */
    @Test
    public void testTelGetNewestAfterGetOldest() throws Exception {
        remote.salTelemetrySub("Test_arrays");
        controller.salTelemetryPub("Test_arrays");

        getNewestAfterGetOldest(false, false);
    }

    /**
     * Test that get newest after get oldest gets the newest value.
     * <p>
     * Uses the arrays topic. This tests DM-18491.
     *
     * @param testEvents If True then test events else test telemetry.
     * @param getEvent   If True then use getEvent to get the oldest value, else use getNextSample_logevent_scalars.
     *                   Ignored if test_events is False.
     * @throws Exception In case of a problem related to reflection.
     */
    private void getNewestAfterGetOldest(boolean testEvents, boolean getEvent) throws Exception {
        final int numLoops = 5;
        Object[] dataList = new Object[numLoops];
        Object data;
        if (testEvents) {
            data = new logevent_arrays();
        } else {
            data = new arrays();
        }

        int retcode;
        for (int i = 0; i < numLoops; i++) {
            TestUtils.fillArraysWithRandomValues(data);
            dataList[i] = data;
            if (testEvents) {
                retcode = controller.logEvent_arrays((logevent_arrays) data, 1);
            } else {
                retcode = controller.putSample((arrays) data);
            }
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        // read and check the oldest value
        Object expected_data = dataList[0];
        if (testEvents) {
            if (getEvent) {
                retcode = remote.getEvent_arrays((logevent_arrays) data);
            } else {
                retcode = remote.getNextSample((logevent_arrays) data);
            }
        } else {
            retcode = remote.getNextSample((arrays) data);
        }
        Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        TestUtils.assertArraysEqual(expected_data, data);

        // read and check the newest value
        expected_data = dataList[numLoops - 1];
        getTopic("getSample", data);
        TestUtils.assertArraysEqual(expected_data, data);
    }

    /**
     * Test that a late joiner cannot see historical telemetry using getNextSample.
     * <p>
     * Telemetry is volatile so there should be no late joiner data.
     */
    @Test
    public void testTelLateJoinerGetNextSample() throws Exception {
        final int numLoops = 5;
        controller.salTelemetryPub("Test_arrays");

        for (int i = 0; i < numLoops; i++) {
            arrays data = new arrays();
            TestUtils.fillArraysWithRandomValues(data);
            int retcode = controller.putSample(data);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        arrays data = new arrays();
        remote.salTelemetrySub("Test_arrays");
        int retcode = remote.getNextSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__NO_UPDATES);
    }

    /**
     * Test that a late joiner cannot see historical telemetry using getSample.
     * <p>
     * Telemetry is volatile so there should be no late joiner data.
     */
    @Test
    public void testTelLateJoinerGetSample() throws Exception {
        final int numLoops = 5;
        controller.salTelemetryPub("Test_arrays");

        for (int i = 0; i < numLoops; i++) {
            arrays data = new arrays();
            TestUtils.fillArraysWithRandomValues(data);
            int retcode = controller.putSample(data);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        arrays data = new arrays();
        remote.salTelemetrySub("Test_arrays");
        int retcode = remote.getSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__NO_UPDATES);
    }

    /**
     * Test enumerations.
     */
    @Test
    public void test_enumerations() {
        // Shared enum with default values
        Assert.assertEquals(Test_shared_Enum_One.value, 1);
        Assert.assertEquals(Test_shared_Enum_Two.value, 2);
        Assert.assertEquals(Test_shared_Enum_Three.value, 3);
        // Shared enum with specified values
        Assert.assertEquals(Test_shared_ValueEnum_Zero.value, 0);
        Assert.assertEquals(Test_shared_ValueEnum_Two.value, 2);
        Assert.assertEquals(Test_shared_ValueEnum_Four.value, 4);
        Assert.assertEquals(Test_shared_ValueEnum_Five.value, 5);
        // Topic - specific enum with default values
        Assert.assertEquals(scalars_Int0Enum_One.value, 1);
        Assert.assertEquals(scalars_Int0Enum_Two.value, 2);
        Assert.assertEquals(scalars_Int0Enum_Three.value, 3);
        // Topic - specific enum with specified values
        Assert.assertEquals(arrays_Int0ValueEnum_Zero.value, 0);
        Assert.assertEquals(arrays_Int0ValueEnum_Two.value, 2);
        Assert.assertEquals(arrays_Int0ValueEnum_Four.value, 4);
        Assert.assertEquals(arrays_Int0ValueEnum_Five.value, 5);
    }

}
