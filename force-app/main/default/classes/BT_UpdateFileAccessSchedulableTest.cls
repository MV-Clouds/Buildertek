@isTest
public class BT_UpdateFileAccessSchedulableTest {
    public static String CRON_EXP =  '0 0 1 * * ?';
    
	@testSetup static void insertTestData(){
		List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
		System.assertEquals('Test','Test');
	}
    
    public static testMethod void testBT_UpdateFileAccessSchedulable() {
       Test.startTest();
        System.schedule('ScheduledApexTest', CRON_EXP, new BT_UpdateFileAccessSchedulable([SELECT Id FROM File__c]));
       Test.stopTest();
        System.assertEquals('Test','Test');
    }
}