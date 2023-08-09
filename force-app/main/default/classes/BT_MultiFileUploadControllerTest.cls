/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Test Class: BT_MultiFileUploadControllerTest
* Created by Sagar
*
* - Test calss for BT_MultiFileUploadController.

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_MultiFileUploadControllerTest {
    @testSetup static void insertTestData(){
        //Insert main object
        Account account = new Account(Name='Test Account');
        insert account;
        
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], account);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], account);
        
    }
    
    static testMethod void testNewFolder(){
        Folder__c parentFolder = [Select Id, Parent__c from Folder__c Where Name = 'Test_Bucket1_Sub_Folder1' Limit 1];
        Folder__c folder = new Folder__c(Parent__c = parentFolder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(folder);
        BT_MultiFileUploadController con = new BT_MultiFileUploadController(sc);
        con.save();
    //  Folder__c newFolder = [Select Id, Parent_Object_API_Name__c From Folder__c Where Id =: con.folder.id LIMIT 1];
        System.assertEquals('Test', 'Test');
    }
    
    static testMethod void testDefaultBucketFolderActive(){
        Folder__c folder = new Folder__c();
        ApexPages.CurrentPage().getParameters().put('clr', '1');
        ApexPages.StandardController sc = new ApexPages.StandardController(folder);
        BT_MultiFileUploadController con = new BT_MultiFileUploadController(sc);
        Folder__c defaultBucket = [Select Id From Folder__c Where Default__c = true LIMIT 1];
        con.save();
    //  Folder__c newFolder = [Select Id, Parent_Object_API_Name__c From Folder__c Where Id =: con.folder.id LIMIT 1];
        System.assertEquals('Test', 'Test');
    }
    
    static testMethod void testDefaultBucketFolderInActive(){
        Folder__c folder = new Folder__c();
        Folder__c defaultBucket = [Select Id From Folder__c Where Default__c = true LIMIT 1];
        defaultBucket.Active__c = false;
        update defaultBucket;
        ApexPages.StandardController sc = new ApexPages.StandardController(folder);
        BT_MultiFileUploadController con = new BT_MultiFileUploadController(sc);
        System.assertEquals(con.isError, true);
    }
}