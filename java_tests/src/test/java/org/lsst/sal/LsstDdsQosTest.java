package org.lsst.sal;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import java.io.File;

/**
 * This unit test class doesn't make much sense in Java due to the way JNI loads the
 * native libraries and doesn't unload them until the JVM stops.
 */
@RunWith(PowerMockRunner.class)
@PrepareForTest(SAL_Test.class)
public class LsstDdsQosTest {

    String dataDir;

    @Before
    public void setUp() {
        dataDir = "../tests/data";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv(Mockito.eq("LSST_DDS_PARTITION_PREFIX")))
                .thenReturn(TestUtils.generateRandomString());
    }

    @Test
    public void testQosNoEnvVar() {
        PowerMockito.when(System.getenv(Mockito.eq("LSST_DDS_QOS"))).thenReturn(null);
        try {
            new SAL_Test(1);
            Assert.fail("An exception should have been thrown.");
        } catch (RuntimeException e) {
            Assert.assertNotNull(e);
            Assert.assertEquals("ERROR : Cannot find envvar LSST_DDS_QOS profiles", e.getMessage());
        }
    }

    @Test
    public void testQosNoFile() {
        String filepath = dataDir + "/not_a_file";
        File file = new File(filepath);
        Assert.assertFalse(file.exists());
        PowerMockito.when(System.getenv(Mockito.eq("LSST_DDS_QOS"))).thenReturn("file://" + filepath);
        try {
            new SAL_Test(1);
            Assert.fail("An exception should have been thrown.");
        } catch (RuntimeException e) {
            Assert.assertNotNull(e);
            Assert.assertEquals("ERROR : Cannot find file with LSST_DDS_QOS", e.getMessage());
        }
    }

    @Test
    public void testQosMissingProfile() {
        String[] profiles = {"AckcmdProfile", "CommandProfile", "EventProfile", "TelemetryProfile"};
        for (String profile : profiles) {
            String filepath = dataDir + "/QoS_no_" + profile + ".xml";
            File file = new File(filepath);
            Assert.assertTrue(file.exists());
            PowerMockito.when(System.getenv(Mockito.eq("LSST_DDS_QOS"))).thenReturn("file://" + filepath);
            try {
                new SAL_Test(1);
                Assert.fail("An exception should have been thrown.");
            } catch (RuntimeException e) {
                Assert.assertNotNull(e);
                Assert.assertEquals("ERROR : Cannot find " + profile + " in QoS", e.getMessage());
            }
        }
    }

}
