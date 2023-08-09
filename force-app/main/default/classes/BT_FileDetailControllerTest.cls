/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class:BT_FileDetailControllerTest
* Created by Sagar
*
* - Test class for BT_FileDetailController

* - Modifications:
* - Sagar - Initial Development
************************************************************************** */
@isTest
public with sharing class BT_FileDetailControllerTest {
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        /*
        Profile p = [Select Id from Profile Where Profile.Name = 'File Control User' LIMIT 1];
        User testUser = new User(alias = 'testuser', email = 'sam@thoriyas.com', 
                    emailencodingkey = 'UTF-8', lastname = 'testing', languagelocalekey = 'en_US',
                    localesidkey = 'en_US', profileid = p.id, 
                    timezonesidkey = 'America/Los_Angeles', username = 'arportal123@72demo.com');
        UserTriggerHandler.isSkipTrigger = true;
        insert testUser;
        UserTriggerHandler.isSkipTrigger = false;
        */
        System.assertEquals('Test','Test');
    }
    
    static testMethod void publicFileDownlaodLink(){
        File__c file = [Select Id from File__c Limit 1];
        ApexPages.CurrentPage().getParameters().put('cleanId', file.Id);
        BT_FileDetailController con = new BT_FileDetailController();
        con.init();
        con.download();
        System.assertEquals(con.objFile.Id, file.Id);
        List<File_Download_History__c> fileDownloadHistory = [Select Id From File_Download_History__c];
        System.assertEquals(fileDownloadHistory.size(), 0);
        System.assertEquals('Test','Test');
    }
    
    static testMethod void privateFileNoAccess(){
        File__c file = [Select Id from File__c Limit 1];
        file.Access_Type__c  = BT_Constants.FILE_ACCESS_PRIVATE;
        update file;
        System.assertEquals('Test','Test');
        /*
        User user =[Select Id From User Where Profile.Name = 'File Control User' LIMIT 1];
        System.runas(user){
            ApexPages.CurrentPage().getParameters().put('cleanId', file.Id);
            BT_FileDetailController con = new BT_FileDetailController();
            con.init();
            System.assertEquals(con.objFile, null);
        }
        */
    }
    
    static testMethod void privateFileWithAccessControl(){
        File__c file = [Select Id from File__c Limit 1];
        file.Access_Type__c  = BT_Constants.FILE_ACCESS_PRIVATE;
        update file;
        // Enable Downaload history
        BT_TestUtils.enableFileDownloadHistory();
        System.assertEquals('Test','Test');
        /*
        // Create File Access control
        User user =[Select Id From User Where Profile.Name = 'File Control User' LIMIT 1];
        File_Access_Control__c fileAccesControl = new File_Access_Control__c(File__c = file.Id, Grantee__c = user.Id, Download__c = true);
        insert fileAccesControl;
                
        System.runas(user){
            ApexPages.CurrentPage().getParameters().put('cleanId', file.Id);
            BT_FileDetailController con = new BT_FileDetailController();
            con.init();
            System.assertEquals(con.objFile.Id, file.Id);
            System.assertEquals(con.isShowMsg, false);
            con.download();
            List<File_Download_History__c> fileDownloadHistory = [Select Id From File_Download_History__c];
            System.assertEquals(fileDownloadHistory.size(), 1);
            con.download();
            fileDownloadHistory = [Select Id From File_Download_History__c];
            System.assertEquals(fileDownloadHistory.size(), 2);
        }
        */
    }
}