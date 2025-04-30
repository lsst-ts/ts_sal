package org.lsst.sal;

import Test.logevent_arrays;
import org.junit.Assert;
import org.junit.Test;

public class SAL_Test_EvtLateJoinerGetEventTest extends BaseTestCase {

    /**
     * Test that a late joiner can see historical data using getEvent.
     */
    @Test
    public void testEvtLateJoinerGetEvent() throws Exception {
        controller.salEventPub("Test_logevent_arrays");
        final int numLoops = 5;

        // Write historical data, before creating the subscriber.
        logevent_arrays[] dataList = new logevent_arrays[numLoops * 2];
        for (int i = 0; i < numLoops; i++) {
            logevent_arrays data = new logevent_arrays();
            TestUtils.fillArraysWithRandomValues(data);
            dataList[i] = data;
            int retcode = controller.logEvent_arrays(data, 1);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        remote.salEventSub("Test_logevent_arrays");

        // Write new data, after creating the subscriber.
        for (int i = numLoops; i < numLoops * 2; i++) {
            logevent_arrays data = new logevent_arrays();
            TestUtils.fillArraysWithRandomValues(data);
            dataList[i] = data;
            int retcode = controller.logEvent_arrays(data, 1);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        // Read using getEvent.
        // We should see all historical data followed by all new data.
        logevent_arrays data = new logevent_arrays();
        for (int i = 0; i < numLoops * 2; i++) {
            int retcode = remote.getEvent_arrays(data);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
            TestUtils.assertArraysEqual(data, dataList[i]);
        }
        int retcode = remote.getEvent_arrays(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__NO_UPDATES);

    }

}
