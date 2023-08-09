public with sharing class TestUtility {

	static Integer s_num = 1;

	public static String getFakeId(Schema.SObjectType sot) {
		String result = String.valueOf(s_num++);
		String returnVal = sot.getDescribe().getKeyPrefix() + '0'.repeat(12 - result.length()) + result;
		System.debug(returnVal);
		return returnVal;
	}
}