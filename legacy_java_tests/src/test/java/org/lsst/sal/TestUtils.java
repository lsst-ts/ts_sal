package org.lsst.sal;

import org.junit.Assert;

import java.util.Arrays;
import java.util.Random;

public final class TestUtils {

    public static class ScalarTestData {
        public boolean boolean0;
        public byte byte0;
        public short short0;
        public int int0;
        public int long0;
        public long longLong0;
        public short unsignedShort0;
        public int unsignedInt0;
        public float float0;
        public double double0;
        public String string0;
    }

    public static class ArrayTestData {
        public boolean[] boolean0 = new boolean[5];
        public byte[] byte0 = new byte[5];
        public short[] short0 = new short[5];
        public int[] int0 = new int[5];
        public int[] long0 = new int[5];
        public long[] longLong0 = new long[5];
        public short[] unsignedShort0 = new short[5];
        public int[] unsignedInt0 = new int[5];
        public float[] float0 = new float[5];
        public double[] double0 = new double[5];
    }

    /**
     * Generate a String filled with random characters between 'a' and 'z'.
     *
     * @return A String with random characters.
     */
    public static String generateRandomString() {
        final int leftLimit = 97; // letter 'a'
        final int rightLimit = 122; // letter 'z'
        final int targetStringLength = 10;
        final Random random = new Random();
        final StringBuilder buffer = new StringBuilder(targetStringLength);
        for (int i = 0; i < targetStringLength; i++) {
            final int randomLimitedInt = leftLimit + (int) (random.nextFloat() * (rightLimit - leftLimit + 1));
            buffer.append((char) randomLimitedInt);
        }
        return buffer.toString();
    }

    /**
     * Make random data for the arrays or setArrays topic.
     *
     * @param data The array to fill with random data.
     * @throws NoSuchFieldException   In case a field with a particular name cannot be found.
     * @throws IllegalAccessException In case the value of a particular field cannot be set.
     */
    public static void fillArraysWithRandomValues(final Object data) throws NoSuchFieldException,
            IllegalAccessException {
        final Class<?> cls = data.getClass();
        final Random random = new Random();
        final int nelts = 5;
        final boolean[] bools = new boolean[nelts];
        final byte[] bytes = new byte[nelts];
        final short[] shorts = new short[nelts];
        final int[] ints = new int[nelts];
        final long[] longs = new long[nelts];
        final float[] floats = new float[nelts];
        final double[] doubles = new double[nelts];
        for (int i = 0; i < nelts; i++) {
            bools[i] = random.nextBoolean();
            bytes[i] = (byte) random.nextInt(1 << 8);
            shorts[i] = (short) random.nextInt(1 << 16);
            ints[i] = random.nextInt();
            longs[i] = random.nextLong();
            floats[i] = random.nextFloat();
            doubles[i] = random.nextDouble();
        }
        cls.getField("boolean0").set(data, bools);
        cls.getField("byte0").set(data, bytes);
        cls.getField("short0").set(data, shorts);
        cls.getField("int0").set(data, ints);
        cls.getField("long0").set(data, ints);
        cls.getField("longLong0").set(data, longs);
        cls.getField("unsignedShort0").set(data, shorts);
        cls.getField("unsignedInt0").set(data, ints);
        cls.getField("float0").set(data, floats);
        cls.getField("double0").set(data, doubles);
    }

    /**
     * Make random data for scalars or setScalars topic.
     *
     * @param data The scalar to fill with random data.
     * @throws NoSuchFieldException   In case a field with a particular name cannot be found.
     * @throws IllegalAccessException In case the value of a particular field cannot be set.
     */
    public static void fillScalarsWithRandomValues(final Object data) throws NoSuchFieldException,
            IllegalAccessException {
        final Class<?> cls = data.getClass();
        final Random random = new Random();
        cls.getField("boolean0").set(data, random.nextBoolean());
        cls.getField("string0").set(data, generateRandomString());
        cls.getField("byte0").set(data, (byte) random.nextInt(1 << 8));
        cls.getField("short0").set(data, (short) random.nextInt(1 << 16));
        cls.getField("int0").set(data, random.nextInt());
        cls.getField("long0").set(data, random.nextInt());
        cls.getField("longLong0").set(data, random.nextLong());
        cls.getField("unsignedShort0").set(data, (short) random.nextInt(1 << 16));
        cls.getField("unsignedInt0").set(data, random.nextInt());
        cls.getField("float0").set(data, random.nextFloat());
        cls.getField("double0").set(data, random.nextDouble());
    }

    /**
     * Assert that two scalars data structs are equal.
     * <p>
     * The types need not match; each struct can be command, event or telemetry data.
     *
     * @param scalars1 The first scalars data struct.
     * @param scalars2 The second scalars data struct.
     * @throws NoSuchFieldException   In case a field with a particular name cannot be found.
     * @throws IllegalAccessException In case the value of a particular field cannot be read.
     */
    public static void assertScalarsEqual(final Object scalars1, final Object scalars2) throws NoSuchFieldException,
            IllegalAccessException {
        Class<?> cls1 = scalars1.getClass();
        Class<?> cls2 = scalars2.getClass();
        String[] fieldNames = {"boolean0", "byte0", "short0", "int0", "long0", "longLong0", "unsignedShort0",
                "unsignedInt0", "float0", "double0"};
        for (String fieldName : fieldNames) {
            if (!cls1.getField(fieldName).get(scalars1).equals(cls2.getField(fieldName).get(scalars2))) {
                throw new RuntimeException("Values for field " + fieldName + " are not the same.");
            }
        }
    }

    /**
     * Assert that two arrays data structs are equal.
     * <p>
     * The types need not match; each struct can be command, event or telemetry data.
     *
     * @param arrays1 The first arrays data struct.
     * @param arrays2 The second arrays data struct.
     * @throws NoSuchFieldException   In case a field with a particular name cannot be found.
     * @throws IllegalAccessException In case the value of a particular field cannot be read.
     */
    public static void assertArraysEqual(final Object arrays1, final Object arrays2) throws NoSuchFieldException,
            IllegalAccessException {
        Class<?> cls1 = arrays1.getClass();
        Class<?> cls2 = arrays2.getClass();
        Assert.assertArrayEquals((boolean[]) cls1.getField("boolean0").get(arrays1), (boolean[]) cls2.getField(
                "boolean0").get(arrays2));
        Assert.assertArrayEquals((byte[]) cls1.getField("byte0").get(arrays1),
                (byte[]) cls2.getField("byte0").get(arrays2));
        Assert.assertArrayEquals((short[]) cls1.getField("short0").get(arrays1),
                (short[]) cls2.getField("short0").get(arrays2));
        Assert.assertArrayEquals((int[]) cls1.getField("int0").get(arrays1),
                (int[]) cls2.getField("int0").get(arrays2));
        Assert.assertArrayEquals((int[]) cls1.getField("long0").get(arrays1),
                (int[]) cls2.getField("long0").get(arrays2));
        Assert.assertArrayEquals((long[]) cls1.getField("longLong0").get(arrays1),
                (long[]) cls2.getField("longLong0").get(arrays2));
        Assert.assertArrayEquals((short[]) cls1.getField("unsignedShort0").get(arrays1), (short[]) cls2.getField(
                "unsignedShort0").get(arrays2));
        Assert.assertArrayEquals((int[]) cls1.getField("unsignedInt0").get(arrays1), (int[]) cls2.getField(
                "unsignedInt0").get(arrays2));
        Assert.assertTrue(Arrays.equals((float[]) cls1.getField("float0").get(arrays1), (float[]) cls2.getField(
                "float0").get(arrays2)));
        Assert.assertTrue(Arrays.equals((double[]) cls1.getField("double0").get(arrays1), (double[]) cls2.getField(
                "double0").get(arrays2)));
    }

}
