/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Test Class: FileAccessControlTriggerHandlerTest
* Created by Sagar
*
* - Test class for FileAccessControlTriggerHandler.

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class FileAccessControlTriggerHandlerTest {
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
    }
    static testMethod void testInsert(){
        List<File_Access_Control__c> newFileAccessControls = new List<File_Access_Control__c>();
        List<File__c> files = [Select id From File__c];
        newFileAccessControls.add(new File_Access_Control__c(File__c = files[0].Id, Grantee__c = UserInfo.getUserId()));
        insert newFileAccessControls;
        List<buildertek__File__share> shares = [Select id From buildertek__File__share];
        System.assert(shares.size() > 0);
        
        //Update the file for file access conrol
        //newFileAccessControls[0].File__c = files[1].Id;
        //update newFileAccessControls;
    }
}