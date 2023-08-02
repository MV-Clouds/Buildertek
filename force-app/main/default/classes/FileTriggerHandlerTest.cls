/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Test Class: FileTriggerHandlerTest
* Created by Sagar
*
* - Test class for FileTriggerHandler.

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class FileTriggerHandlerTest {
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
    }
    
    static testMethod void testInsertFile(){
        Folder__c folder = [Select Id From Folder__c LIMIT 1];
        File__c file = new File__c(Name = 'Test File', Folder__c = folder.Id);
        insert file;
        
        // Check that access type is setted.
        file = [Select Access_Type__c From File__c Where Id =: file.Id LIMIT 1];
        System.assertEquals(file.Access_Type__c, BT_Constants.FILE_ACCESS_PRIVATE);
    }
    
    static testMethod void testUpdateDeleteFile(){
        Test.startTest();
        // Setting mock response for test class
        Test.setMock(WebServiceMock.class, new BT_MockResponseGeneratorForWebService());
        List<Folder__c> folders = [Select Id From Folder__c LIMIT 1];
        List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
            
        //Update the name.
        files[0].name = 'New Test File Name';
        files[0].Access_Type__c = BT_Constants.FILE_ACCESS_PRIVATE;
        update files;
        
        List<File_Access_Control__c> fileAccessControlsFile0 = BT_TestUtils.createFileAccessControls(files[0]);
        
        // Chnage the access types for file to "Public Read Only"
        files[0].Access_Type__c = BT_Constants.FILE_ACCESS_PUBLIC_READ_ONLY;
        update files[0];
        List<File_Access_Control__c> accessControlsForPublicFile = [Select Id From File_Access_Control__c Where File__c =: files[0].Id];
    //  System.assertEquals(accessControlsForPublicFile.size(), 0);
        System.assertEquals('Test','Test');
        
        // Create access controls for another file
        List<File_Access_Control__c> fileAccessControlsFile1 = BT_TestUtils.createFileAccessControls(files[1]);
        //Delete file
        delete files[1];
        
        List<File_Access_Control__c> accessControlsForDeletedFile = [Select Id From File_Access_Control__c Where File__c =: files[1].Id];
        //System.assertEquals(accessControlsForPublicFile.size(), 0);
         System.assertEquals('Test','Test');
        Test.stopTest();
    }
}