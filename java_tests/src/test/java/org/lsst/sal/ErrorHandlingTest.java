package org.lsst.sal;

import Test.arrays;
import Test.command_setScalars;
import Test.logevent_scalars;
import Test.scalars;
import org.junit.Assert;
import org.junit.Ignore;
import org.junit.Test;

import java.lang.reflect.InvocationTargetException;


/**
 * Test misuse of the API.
 */
public class ErrorHandlingTest extends BaseTestCase {

    /**
     * Having no asserts is poor practice, but I'm not sure what else I can call
     * after shutdown to see if the manager was properly shutdown.
     */
    @Test
    public void testMultipleShutdown() {
        remote.salShutdown();
        remote.salShutdown();
        controller.salShutdown();
        controller.salShutdown();
    }

    /**
     * Test registering invalid topic names for commands, events and telemetry.
     */
    @Test
    public void testInvalidTopicNames() {
        final String badCmdName = "Test_command_nonexistent";
        try {
            controller.salCommand(badCmdName);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
        try {
            remote.salCommand(badCmdName);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }

        final String badEvtName = "Test_logevent_nonexistent";
        try {
            controller.salEventPub(badEvtName);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
        try {
            remote.salEventSub(badEvtName);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }

        final String badTelName = "Test_nonexistent";
        try {
            controller.salTelemetryPub(badTelName);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
        try {
            remote.salTelemetrySub(badTelName);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
    }

    /**
     * Test getting and putting topics without registering them first.
     */
    @Test
    public void testCmdNoRegistration() {
        command_setScalars data = new command_setScalars();
        checkCmdGetPutRaises(data);
    }

    /**
     * Test getting and putting topics without registering them first.
     */
    @Test
    public void testEvtNoRegistration() {
        logevent_scalars data = new logevent_scalars();
        checkEvtGetPutRaises(data);
    }

    /**
     * Test getting and putting topics without registering them first.
     */
    @Test
    public void testTelNoRegistration() {
        scalars data = new scalars();
        checkTelGetPutRaises(data);
    }

    /**
     * Test getting and putting invalid command data types.
     * <p>
     * This is not a very interesting test because Java
     * should make this impossible, but it's worth a try.
     */
    @Test
    public void testCmdBadDataTypes() {
        final String topic_name = "Test_command_setScalars";
        controller.salProcessor(topic_name);
        sleep(STD_SLEEP);
        remote.salCommand(topic_name);
        sleep(STD_SLEEP);

        //make sure this worked
        command_setScalars data = new command_setScalars();
        int cmd_id = remote.issueCommand_setScalars(data);
        sleep(STD_SLEEP);
        Assert.assertTrue(cmd_id > 0);

        checkCmdGetPutRaises(null);
    }

    /**
     * Test getting and putting invalid logevent data types.
     * <p>
     * This is not a very interesting test because Java
     * should make this impossible, but it's worth a try.
     */
    @Test
    public void testEvtBadDataTypes() {
        final String topic_name = "Test_logevent_scalars";
        controller.salEventPub(topic_name);
        remote.salEventSub(topic_name);
        sleep(STD_SLEEP);

        //make sure this worked
        logevent_scalars data = new logevent_scalars();
        int retcode = controller.logEvent_scalars(data, 1);
        sleep(STD_SLEEP);
        Assert.assertEquals(retcode, SAL_Test.SAL__OK);

        // This line doesn't work in Java. No exception is thrown.
        // checkEvtGetPutRaises(null);
    }

    /**
     * Test getting and putting invalid telemetry data types.
     * <p>
     * This is not a very interesting test because Java
     * should make this impossible, but it's worth a try.
     */
    @Test
    public void testTelBadDataTypes() {
        final String topic_name = "Test_scalars";
        remote.salTelemetrySub(topic_name);
        sleep(STD_SLEEP);
        controller.salTelemetryPub(topic_name);
        sleep(STD_SLEEP);

        //make sure this worked
        scalars data = new scalars();
        int retcode = controller.putSample(data);
        sleep(STD_SLEEP);
        Assert.assertEquals(retcode, SAL_Test.SAL__OK);

        // This line doesn't work in Java. No exception is thrown.
        // checkTelGetPutRaises(null);
    }

    /**
     * Write enough message to overflow the read buffer and check that
     * the oldest data is lost and the newest data preserved.
     */
    @Test
    public void testEvtOverflowBuffer() throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {
        remote.salEventSub("Test_logevent_scalars");
        sleep(STD_SLEEP);
        controller.salEventPub("Test_logevent_scalars");
        sleep(STD_SLEEP);

        // nextra is the number of extra messages to write and read
        // beyond READ_QUEUE_DEPTH. It must be <= READ_QUEUE_DEPTH.
        int nextra = 10;
        logevent_scalars data = new logevent_scalars();
        for (int val = 0; val < READ_QUEUE_DEPTH + nextra; val++) {
            data.int0 = val;
            int retcode = controller.logEvent_scalars(data, 1);
            sleep(STD_SLEEP);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        data = new logevent_scalars();
        getTopic("getEvent_scalars", data);
        // make sure the queue overflowed
        Assert.assertNotEquals(data.int0, 0);

        int start_value = data.int0;
        for (int i = 1; i < nextra; i++) {
            data = new logevent_scalars();
            getTopic("getEvent_scalars", data);
            Assert.assertEquals(data.int0, start_value + i);
        }
    }

    /**
     * Write enough message to overflow the read buffer and check that
     * the oldest data is lost and the newest data preserved.
     */
    @Test
    public void testTelOverflowBuffer() throws NoSuchMethodException, IllegalAccessException, InvocationTargetException {
        remote.salTelemetrySub("Test_scalars");
        sleep(STD_SLEEP);
        controller.salTelemetryPub("Test_scalars");
        sleep(STD_SLEEP);

        // nextra is the number of extra messages to write and read
        // beyond READ_QUEUE_DEPTH. It must be <= READ_QUEUE_DEPTH.
        int nextra = 10;
        scalars data = new scalars();
        for (int val = 0; val < READ_QUEUE_DEPTH + nextra; val++) {
            data.int0 = val;
            int retcode = controller.putSample(data);
            sleep(STD_SLEEP);
            Assert.assertEquals(retcode, SAL_Test.SAL__OK);
        }

        data = new scalars();
        getTopic("getNextSample", data);
        // make sure the queue overflowed
        Assert.assertNotEquals(data.int0, 0);

        int start_value = data.int0;
        for (int i = 1; i < nextra; i++) {
            data = new scalars();
            getTopic("getNextSample", data);
            Assert.assertEquals(data.int0, start_value + i);
        }
    }

    /**
     * Check that sending too long a string causes an error.
     */
    @Test
    @Ignore("This test actually crashes the JVM.")
    public void testTooLongStrings() {
        remote.salTelemetrySub("Test_scalars");
        sleep(STD_SLEEP);
        controller.salTelemetryPub("Test_scalars");
        sleep(STD_SLEEP);

        // from the XML file;
        // unfortunately there is no way to ask SAL
        String too_long_data = "0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789";
        Assert.assertEquals(too_long_data.length(), 100);
        scalars data = new scalars();
        // string0 has a limit of 20 characters
        data.string0 = too_long_data;
        try {
            controller.putSample(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
    }

    private void checkCmdGetPutRaises(command_setScalars data) {
        // try/catch blocks like these are the accepted design pattern for
        // JUnit tests to validated that a checked exception is thrown by the
        // method that gets called.
        try {
            controller.acceptCommand_setScalars(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
        try {
            remote.issueCommand_setScalars(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
    }

    private void checkEvtGetPutRaises(logevent_scalars data) {
        // try/catch blocks like these are the accepted design pattern for
        // JUnit tests to validated that a checked exception is thrown by the
        // method that gets called.
        try {
            remote.getNextSample(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
        try {
            remote.getEvent_scalars(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
        try {
            remote.getSample(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }

        try {
            controller.logEvent_scalars(data, 1);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
    }

    private void checkTelGetPutRaises(scalars data) {
        // try/catch blocks like these are the accepted design pattern for
        // JUnit tests to validated that a checked exception is thrown by the
        // method that gets called.
        try {
            remote.getNextSample(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
        try {
            remote.getSample(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
        try {
            remote.flushSamples(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }

        try {
            controller.putSample(data);
            Assert.fail("An exception should have been thrown.");
        } catch (Exception e) {
            Assert.assertNotNull(e);
        }
    }
}
