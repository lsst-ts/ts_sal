package org.lsst.sal;

import org.junit.Assert;
import org.junit.Test;

/**
 * A few tests require CSC that doesn't use generics, so we use Script.
 */
public class SAL_ScriptTest {

    /**
     * Test a SAL component that does not have csc in AddedGenerics.
     */
    @Test
    public void testNoCscGenerics() {
        Class<?> cls = SAL_Script.class;
        try {
            cls.getMethod("Test_command_enterControlC", cls);
            Assert.fail("A NoSuchMethodException should have been raised.");
        } catch (NoSuchMethodException e) {
            Assert.assertNotNull(e);
        }
        try {
            cls.getMethod("Test_logevent_summaryStateC", cls);
            Assert.fail("A NoSuchMethodException should have been raised.");
        } catch (NoSuchMethodException e) {
            Assert.assertNotNull(e);
        }
    }

    /**
     * Test that enterControl is not present for Test.
     */
    @Test
    public void testNoEnterControl() {
        Class<?> cls = SAL_Test.class;
        try {
            cls.getMethod("Test_command_enterControlC", cls);
            Assert.fail("A NoSuchMethodException should have been raised.");
        } catch (NoSuchMethodException e) {
            Assert.assertNotNull(e);
        }
    }

}
