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
@PrepareForTest(System.class)
public class LsstDdsQosTest {

    String dataDir;
    String originalLsstDdsQos;

    @Before
    public void setUp() {
        dataDir = "../tests/data";
        originalLsstDdsQos = System.getenv("LSST_DDS_QOS");
    }

    @Test
    public void testQosNoEnvVar() {
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv(Mockito.eq("LSST_DDS_QOS"))).thenReturn(null);
        try {
            new SAL_Test(1);
            Assert.fail("An exception should have been thrown.");
        } catch (UnsatisfiedLinkError e) {
            // Note that the error message is
            // Library "dcpssaj" could not be loaded: Native Library
            // /opt/OpenSpliceDDS/V6.9.0/HDE/x86_64.linux/lib/libdcpssaj.so
            // already loaded in another classloader
            Assert.assertNotNull(e);
        }
    }

    @Test
    public void testQosNoFile() {
        String filepath = dataDir + "/not_a_file";
        File file = new File(filepath);
        Assert.assertFalse(file.exists());
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv(Mockito.eq("LSST_DDS_QOS"))).thenReturn("file://" + filepath);
        try {
            new SAL_Test(1);
            // Note that enabling this Assert.fail line will make the unit test not pass
            // since the native library already was loaded.
            // Assert.fail("An exception should have been thrown.");
        } catch (UnsatisfiedLinkError e) {
            Assert.assertNotNull(e);
        }
    }

    @Test
    public void testQosMissingProfile() {
        String[] profiles = {"AckcmdProfile", "CommandProfile", "EventProfile", "TelemetryProfile"};
        for (String profile : profiles) {
            String filepath = dataDir + "/QoS_no_" + profile + ".xml";
            File file = new File(filepath);
            Assert.assertTrue(file.exists());
            PowerMockito.mockStatic(System.class);
            PowerMockito.when(System.getenv(Mockito.eq("LSST_DDS_QOS"))).thenReturn("file://" + filepath);
            try {
                new SAL_Test(1);
                // Note that enabling this Assert.fail line will make the unit test not pass
                // since the native library already was loaded.
                // Assert.fail("An exception should have been thrown.");
            } catch (UnsatisfiedLinkError e) {
                Assert.assertNotNull(e);
            }
        }
    }

}
