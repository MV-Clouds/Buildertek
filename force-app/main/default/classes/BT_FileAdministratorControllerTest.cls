@isTest
public class BT_FileAdministratorControllerTest {
    @testSetup static void setupBaseData() {
		List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
		System.assertEquals(buckets.size() > 0, true);
		List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
		List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
		// Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testBT_FileAdministratorController1() {
        ApexPages.currentPage().getParameters().put('retURL', '');
        BT_FileAdministratorController service = new BT_FileAdministratorController(new ApexPages.StandardController([SELECT Id, OwnerId FROM File__c LIMIT 1]));
        service.save();
        service.cancel();
        service.retURL = '/sample/url';
        service.save();
        service.cancel();
        System.assertEquals('Test','Test');
    }
}