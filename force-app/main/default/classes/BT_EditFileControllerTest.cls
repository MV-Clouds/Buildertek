/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Test Class: BT_EditFileControllerTest
* Created by Sagar
*
* Test class for BT_EditFileController

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_EditFileControllerTest {
    @testSetup static void insertTestData(){
        //Insert main object
        Account account = new Account(Name='Test Account');
        insert account;
        
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], account);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], account);
        
    }
    
    static testMethod void testNewFile(){
        Account account = [Select Id from Account Where Name = 'Test Account' LIMIT 1];
        Folder__c bucket = [Select Id From Folder__c Where Name = 'Test_Bucket1' LIMIT 1];
        Folder__c folder = [Select Id From Folder__c Where Name = 'Test_Bucket1_Sub_Folder1' LIMIT 1];
        File__c file = new File__c(Folder__c = folder.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(file);
        ApexPages.currentPage().getParameters().put('retURL', '');
        BT_EditFileController con = new BT_EditFileController(sc);
        System.assertEquals('test', 'test');
    }
    
    static testMethod void testDefaultBucketFolderActive(){
        Account account = [Select Id from Account Where Name = 'Test Account' LIMIT 1];
        ApexPages.CurrentPage().getParameters().put('retURL', '/apex/test');
        Folder__c bucket = [Select Id From Folder__c Where Name = 'Test_Bucket1' LIMIT 1];
        File__c file = new File__c(Account__c = account.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(file);
        BT_EditFileController con = new BT_EditFileController(sc);
        System.assertEquals('test', 'test');
    }
    
    static testMethod void testDefaultBucketFolderInActive(){
        Folder__c bucket = [Select Id From Folder__c Where Name = 'Test_Bucket1' LIMIT 1];
        bucket.Active__c = false;
        update bucket;
        File__c file = new File__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(file);
        ApexPages.currentPage().getParameters().put('retURL', '');
        BT_EditFileController con = new BT_EditFileController(sc);
        System.assertEquals('test', 'test');
    }
}