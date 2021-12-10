package org.lsst.sal;

import org.junit.Assert;
import org.junit.Test;

/**
 * A few tests require CSC that doesn't use generics, so we use Script.
 */
public class SAL_ScriptTest {

    /**
     * Test that setting generics to `no` avoids generics.
     */
    @Test
    public void testGenericsNo() {
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

}
