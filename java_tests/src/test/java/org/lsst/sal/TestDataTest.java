package org.lsst.sal;

import org.junit.Assert;
import org.junit.Test;

public class TestDataTest {

    @Test
    public void testScalars() throws NoSuchFieldException, IllegalAccessException {
        int nelts = 10;
        TestUtils.ScalarTestData[] dataList = new TestUtils.ScalarTestData[nelts];
        for (int i = 0; i < nelts; i++) {
            TestUtils.ScalarTestData data = new TestUtils.ScalarTestData();
            TestUtils.fillScalarsWithRandomValues(data);
            dataList[i] = data;
        }

        for (int i = 0; i < nelts; i++) {
            TestUtils.ScalarTestData data0 = dataList[i];
            for (int j = 0; j < nelts; j++) {
                TestUtils.ScalarTestData data1 = dataList[j];
                if (i == j) {
                    TestUtils.assertScalarsEqual(data0, data1);
                } else {
                    try {
                        TestUtils.assertScalarsEqual(data0, data1);
                        Assert.fail("An exception should have been thrown.");
                    } catch (AssertionError e) {
                        Assert.assertNotNull(e);
                    } catch (RuntimeException e) {
                        Assert.assertNotNull(e);
                    }
                }
            }
        }
    }

    @Test
    public void testArrays() throws NoSuchFieldException, IllegalAccessException {
        int nelts = 10;
        TestUtils.ArrayTestData[] dataList = new TestUtils.ArrayTestData[nelts];
        for (int i = 0; i < nelts; i++) {
            TestUtils.ArrayTestData data = new TestUtils.ArrayTestData();
            TestUtils.fillArraysWithRandomValues(data);
            dataList[i] = data;
        }

        for (int i = 0; i < nelts; i++) {
            TestUtils.ArrayTestData data0 = dataList[i];
            for (int j = 0; j < nelts; j++) {
                TestUtils.ArrayTestData data1 = dataList[j];
                if (i == j) {
                    TestUtils.assertArraysEqual(data0, data1);
                } else {
                    try {
                        TestUtils.assertArraysEqual(data0, data1);
                        Assert.fail("An exception should have been thrown.");
                    } catch (AssertionError e) {
                        Assert.assertNotNull(e);
                    } catch (RuntimeException e) {
                        Assert.assertNotNull(e);
                    }
                }
            }
        }
    }

}
