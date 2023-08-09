/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: BT_CleanupFilesControllerTest
* Created by Sagar
*
* Test class for BT_CleanupFilesController

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public class BT_CleanupFilesControllerTest{
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
    }
    
     public static testmethod void treeNodeString() {
        Test.startTest();
        // Setting mock response for test class
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        BT_CleanupFilesController con = new BT_CleanupFilesController();
        System.assertEquals(con.getCleanupObjectTypes().size(), 2); 
        System.assertEquals(con.getCleanupObjectTypes()[0], 'AmazonFile'); 
        // System.assert(con.treeNodesString != null);
        Test.stopTest();
    }
    
    public static testmethod void cleanUp(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        BT_CleanupFilesController con = new BT_CleanupFilesController();
        Map<String, String> selectedNodesKeyByKey = new Map<String, String>();
        File__c file = [Select Id, Folder__r.Name, Bucket_Name__c,Amazon_File_Key__c  From File__c Where Name = 'File2.png' LIMIT 1];
        selectedNodesKeyByKey.put('Test_Bucket1/'+file.Folder__r.Name+'/File2.png', 'Test_Bucket1/'+file.Folder__r.Name+'/File2.png');
        ApexPages.CurrentPage().getParameters().put('selectedNodeKeys', JSON.serialize(selectedNodesKeyByKey));
        con.cleanUp();
        // System.assertEquals(BT_HomeUtils.getFileCleanupJobId() != null, true);
        Test.stopTest();
    }
}