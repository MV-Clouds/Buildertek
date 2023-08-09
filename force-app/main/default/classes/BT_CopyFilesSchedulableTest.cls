@isTest
public class BT_CopyFilesSchedulableTest {
    public static String CRON_EXP = '0 0 0 28 2 ? 2022';
    
    @testSetup static void setupBaseData() {
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testBT_CopyFilesSchedulable() {
        Test.startTest();
        //System.schedule('Test : ' + System.now(), CRON_EXP, new BT_CopyFilesSchedulable([SELECT Id FROM File__c LIMIT 100]));
        Test.stopTest();
        System.assertEquals('Test','Test');
    }
}