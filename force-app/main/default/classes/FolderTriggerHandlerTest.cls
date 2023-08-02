/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Test Class: FolderTriggerHandlerTest
* Created by Sagar
*
* - Test class for FolderTriggerHandler.

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class FolderTriggerHandlerTest {
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
    }
    
    static testMethod void testInsertFolder(){
        Folder__c bucket = [Select Id From Folder__c LIMIT 1];
        Folder__c folder = new Folder__c(Name = 'Test Folder', Parent__c = bucket.Id);
        insert folder;
        
        folder.Name='Test';
        update folder;
        // Check the external folder path
        folder = [Select Name, External_Folder_Name__c, Amazon_File_Key__c From Folder__c Where Id =: folder.Id Limit 1];
        System.assertEquals(folder.Amazon_File_Key__c, folder.Name);
    }
    
    static testMethod void testUpdateDeleteFolder(){
        List<Folder__c> buckets = [Select Id, Name, Amazon_File_Key__c, Bucket_Name__c From Folder__c LIMIT 1];
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        List<Folder__c> subFolders = BT_TestUtils.createSubfolders(folders[0], null);
        Folder__c grandSubFolder = new Folder__c(Name = 'Test Grand Sub Folder', Parent__c = subFolders[0].Id, Bucket_Name__c = 'Test Bucket');
        insert grandSubFolder;
        List<File__c> files = BT_TestUtils.createFiles(grandSubFolder, null);
        
        // Update the parent of parent folder
        grandSubFolder.Parent__c = subFolders[1].Id; 
        update grandSubFolder;
        grandSubFolder = [Select Name, Amazon_File_Key__c From Folder__c where Id =: grandSubFolder.Id LIMIT 1];
        System.assertEquals(grandSubFolder.Amazon_File_Key__c, folders[0].Name+'/'+subFolders[0].Name+'/'+grandSubFolder.Name);
        
        //Delete the folder
        delete grandSubFolder;
        files = [Select Id From File__c where Folder__c =: grandSubFolder.Id];
        System.assertEquals(files.size(), 0);
    }
}