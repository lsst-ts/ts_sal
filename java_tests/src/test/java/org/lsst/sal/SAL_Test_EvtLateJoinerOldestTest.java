package org.lsst.sal;

import Test.logevent_arrays;
import org.junit.Assert;
import org.junit.Test;

public class SAL_Test_EvtLateJoinerOldestTest extends BaseTestCase {

    /**
     * Test that a late joiner can can read the most recent event using getNextSample.
     * <p>
     * Only one value should be retrievable but it turns out that all are. That is why
     * this test case is in a separate class because otherwise all data from all previously
     * run unit tests are retrievable. It is unclear why this is the case.
     */
    @Test
    public void testEvtLateJoinerOldest() throws Exception {
        final int numLoops = 5;
        controller.salEventPub("Test_logevent_arrays");

        logevent_arrays[] dataList = new logevent_arrays[numLoops];
        for (int i = 0; i < numLoops; i++) {
            logevent_arrays data = new logevent_arrays();
            TestUtils.fillArraysWithRandomValues(data);
            dataList[i] = data;
            int retcode = controller.logEvent_arrays(data, 1);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        logevent_arrays data = new logevent_arrays();
        remote.salEventSub("Test_logevent_arrays");

        // In Python this next call gets the newest sample but in Java the oldest.
        // This has been investigated but the cause for this is unclear.
        int retcode = remote.getNextSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        TestUtils.assertArraysEqual(data, dataList[0]);
    }

}
