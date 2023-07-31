public class ErrorHandler {

	public static final int NR_ERROR_CODES = 2;

	/* Array to hold the names for all ReturnCodes. */
	public static String[] RetCodeName = new String[NR_ERROR_CODES];

	static {
		RetCodeName[0] = new String("KAFKA_RETCODE_OK");
		RetCodeName[1] = new String("KAFKA_RETCODE_ERROR");
	}

	/**
	 * Returns the name of an error code.
	 **/
	public static String getErrorName(int status) {
		return RetCodeName[status];
	}
	
}
