package org.lsst.sal;

import org.junit.Assert;
import org.junit.Before;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.Random;


public class BaseTestCase {

    // Standard sleep time in ms.
    final long STD_SLEEP = 1L;
    final long TIME_TO_WAIT = 2000L;
    SAL_Test remote;
    SAL_Test controller;

    // Depth of DDS read queues (which is also the depth of the write queues).
    // This must be at least as long as the actual depth for some tests to pass.
    // If it ever becomes possible to read or write the depth in SAL, update
    // these tests to do that, to eliminate the dependence on the default depth.
    final int READ_QUEUE_DEPTH = 100;

    @Before
    public void setUp() {
        Random rand = new Random(2000L);
        int index = 0;
        while (index <= 0) {
            index = rand.nextInt();
        }
        remote = new SAL_Test(index);
        controller = new SAL_Test(index);
    }

    /**
     * Sleep for the provided amount of seconds.
     *
     * @param sleep Sleep time in seconds.
     */
    void sleep(long sleep) {
        try {
            Thread.sleep(sleep);
        } catch (InterruptedException e) {
            // Ignore
        }
    }


    /**
     * Get data for a topic using the specified command.
     *
     * @param funcName Function to call to get data. It must take one argument: data and return a result that is SAL__OK
     *                 or SAL__NO_UPDATES.
     * @param data     Data struct to fill.
     */
    void getTopic(final String funcName, Object data) throws NoSuchMethodException, IllegalAccessException,
            InvocationTargetException {
        Class<?> cls = this.remote.getClass();
        final Method m = cls.getMethod(funcName, data.getClass());
        final long startTime = System.currentTimeMillis();
        Integer retcode = SAL_Test.SAL__NO_UPDATES;
        while (System.currentTimeMillis() - startTime < TIME_TO_WAIT) {
            retcode = (Integer) m.invoke(remote, data);
            sleep(STD_SLEEP);
            if (retcode == SAL_Test.SAL__OK) {
                break;
            } else if (retcode == SAL_Test.SAL__NO_UPDATES) {
                sleep(100);
            } else {
                Assert.fail("Unexpected return value " + retcode);
            }
        }
        if (retcode != SAL_Test.SAL__OK) {
            Assert.fail("Timed out waiting for events");
        }
    }

}
