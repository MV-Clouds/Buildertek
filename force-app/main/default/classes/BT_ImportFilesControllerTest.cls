/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_ImportFilesControllerTest
* Created by Sagar
*
* - Test calss for BT_ImportFilesController.

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_ImportFilesControllerTest {
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
    }
    
     public static testmethod void treeNodeString() {
        // Setting mock response for test class
        Test.startTest();
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        BT_ImportFilesController con = new BT_ImportFilesController();
        System.assertEquals(con.getImportObjectTypes().size(), 2); 
        System.assertEquals(con.getImportObjectTypes()[0], 'AmazonFile'); 
        System.assert(con.treeNodesString != null);
        Test.stopTest();
    }
    
    public static testmethod void importFile(){
        Test.startTest();
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        BT_ImportFilesController con = new BT_ImportFilesController();
        Map<String, String> selectedNodesKeyByKey = new Map<String, String>();
        selectedNodesKeyByKey.put('Test_Bucket1/Test_Bucket1_Sub_Folder1/File1.jpg', 'Test_Bucket1/Test_Bucket1_Sub_Folder1/File1.jpg');
        ApexPages.CurrentPage().getParameters().put('selectedNodeKeys', JSON.serialize(selectedNodesKeyByKey));
        con.importFiles();
        System.assertEquals(BT_HomeUtils.getFileImportJobId() == null, true);
        Test.stopTest();
    }
}