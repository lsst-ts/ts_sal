package org.lsst.sal;

import Test.logevent_arrays;
import org.junit.Assert;
import org.junit.Test;

public class SAL_Test_EvtLateJoinerGetSampleTest extends BaseTestCase {

    /**
     * Test that a late joiner can read the most recent historic event using getSample.
     */
    @Test
    public void testEvtLateJoinerGetSample() throws Exception {
        final int numLoops = 5;
        controller.salEventPub("Test_logevent_arrays");

        // Write historical data, before creating the subscriber.
        logevent_arrays[] dataList = new logevent_arrays[numLoops];
        for (int i = 0; i < numLoops; i++) {
            logevent_arrays data = new logevent_arrays();
            TestUtils.fillArraysWithRandomValues(data);
            dataList[i] = data;
            int retcode = controller.logEvent_arrays(data, 1);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        remote.salEventSub("Test_logevent_arrays");

        // Read using getSample.
        // We should see one item: the most recent historical data.
        logevent_arrays data = new logevent_arrays();
        int retcode = remote.getSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        TestUtils.assertArraysEqual(data, dataList[numLoops - 1]);

        retcode = remote.getSample(data);
        Assert.assertEquals(retcode, SAL_Test.SAL__NO_UPDATES);
    }

}
