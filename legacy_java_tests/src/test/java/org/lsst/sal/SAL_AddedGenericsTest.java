package org.lsst.sal;

import org.junit.Assert;
import org.junit.Test;

public class SAL_AddedGenericsTest extends BaseTestCase {

    /**
     * Test topics for a SAL component that does not have "csc" in AddedGenerics.
     *
     * Use Script: one of the few SAL component that is not a CSC.
     */
    @Test
    public void testNoCsc() {
        Class<?> cls = SAL_Script.class;
        try {
            cls.getMethod("Script_command_enableC", cls);
            Assert.fail("A NoSuchMethodException should have been raised.");
        } catch (NoSuchMethodException e) {
            Assert.assertNotNull(e);
        }
        try {
            cls.getMethod("Script_logevent_summaryStateC", cls);
            Assert.fail("A NoSuchMethodException should have been raised.");
        } catch (NoSuchMethodException e) {
            Assert.assertNotNull(e);
        }
    }

    /**
     * Test that a standard CSC does not have the "enterControl" command.
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
