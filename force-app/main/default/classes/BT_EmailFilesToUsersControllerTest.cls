/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Test Class: BT_EmailFilesToUsersControllerTest
* Created by Sagar
*
* Test class for BT_EmailFilesToUsersController

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_EmailFilesToUsersControllerTest {
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
    }
    
    public static testmethod void testSendWithoutFileAndRecipient(){
        BT_EmailFilesToUsersController con = new BT_EmailFilesToUsersController();
        
        // Don't select any files and do send
        con.sendEmail();
        System.assertEquals(con.isSuccess, false);
        
        // Select file and do send, do select recipient
        for(File__c file : [Select Id, name From File__c]){
            con.selectedFileNodes.add(new TreePickerNode(file.Id, file.Name));
        }
        con.sendEmail();
        System.assertEquals(con.isSuccess, false);
    }
    
    public static testmethod void testSendFile(){
        
        // Creating user
        User user = BT_TestUtils.createUser('anlmegh', 'rertest@test.com1', 'tytytest@test1.com');
        List<File__c> files = [Select Id, Folder__c, Name From File__c];
        ApexPages.currentPage().getParameters().put('folderId', files[0].Folder__c);
        
        BT_EmailFilesToUsersController con = new BT_EmailFilesToUsersController();
        
        // Check the checkable object type
        System.assertEquals(con.getUserPickerConfigName(), 'User Picker Tree');
        System.assertEquals(con.getFilePickerConfigName(), 'File Picker Tree');
        System.assertEquals(con.getUserTreeType(), BT_Constants.TREE_TYPE_USER);
        System.assertEquals(con.getFileTreeType(), BT_Constants.TREE_TYPE_FILE);
        System.assertEquals(con.getUserPickerCheckableObjectTypes().size(), 1);
        System.assertEquals(con.getFilePickerCheckableObjectTypes().size(), 1);
        
        // Select files
        for(File__c file : files){
            con.selectedFileNodes.add(new TreePickerNode(file.Id, file.Name));
        }
        
        // Select recipient
        con.selectedUserNodes.add(new TreePickerNode(user.Id, user.Name));
        
        con.sendEmail();
        System.assertEquals(con.isSuccess, true);
        
        // Cancel
        con.cancel();
    }
}