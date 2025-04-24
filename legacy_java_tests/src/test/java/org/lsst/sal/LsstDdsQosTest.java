package org.lsst.sal;

import org.junit.Assert;
import org.junit.Test;

import java.io.File;

public class LsstDdsQosTest extends BaseTestCase {

    final String dataDir = "../tests/data";

    @Test
    public void testQosNoEnvVar() {
        environmentVariables.clear("LSST_DDS_QOS");
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
        environmentVariables.set("LSST_DDS_QOS", "file://" + filepath);
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
            environmentVariables.set("LSST_DDS_QOS", "file://" + filepath);
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
