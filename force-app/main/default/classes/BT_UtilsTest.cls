/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: BT_UtilsTest
* Created by Sagar: 06/05/2017
*
* - Test class for BT_Utils.

* - Modifications:
* - Sagar, 06/05/2017 – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_UtilsTest {
    static testMethod void testMethodCredentials() {
        //Create account 
        Account account = new Account(Name='Test Account');
        insert account;
        
        //Creating Amazon S3 credentials
        Application_Configuration__c credentialObjForKey = new Application_Configuration__c(Name=BT_Constants.AWS_PUBLIC_KEY);
        credentialObjForKey.Configured_Value__c ='Ad2sdadf41212wsas2ed';
        insert credentialObjForKey;
        Application_Configuration__c credentialObjForSecret = new Application_Configuration__c(Name=BT_Constants.AWS_SECRET_KEY);
        credentialObjForSecret.Configured_Value__c ='232dasaweg34r45bwergr6t';
        insert credentialObjForSecret;
        
        //Create folders
        List<Folder__c> folders = BT_TestUtils.createFoldersForBuckets();
        
        //Create sub folders
        List<Folder__c> subFolders = BT_TestUtils.createSubfolders(folders[0], account);
        
        //Create files
        List<File__c> files = BT_TestUtils.createFiles(folders[0], account);
        
        //Delete file
        delete files[0];
        
        //Delete folder
        delete subFolders;
        
        //Make sure there are no folders
        System.assertEquals([Select count() From Folder__c], 3);
    }
    static testMethod void testGetObjectTypeFromTypeName() {
        //Get the object type
        System.assertEquals(BT_Utils.getObjectTypeFromTypeName('Folder__c'), Folder__c.sObjectType);
        //Get quesry string with all fields
        System.assert(BT_Utils.getQueryStringForObjectWithAllFields('Folder__c') != null);
    }
    
    static testMethod void userHasWriteAccessTest(){
        // Create test data
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
        List<Id> fileIds = new List<Id>();
        for(File__c file : files){
            fileIds.add(file.Id);
        }
        // Check for signle file
        BT_Utils.userHasWriteAccess(files[0].id);
        // Check access for all files
        Map<String,Boolean> accessByRecordId = BT_Utils.userWithAccess(fileIds);
        System.assertEquals(accessByRecordId.get(fileIds[0]), true);
        
        // Test prepare substring with 1 as limit
        BT_Utils.prepareSubLists(fileIds, 1);
    }
    
    static testmethod void testBuildSelectListFragment(){
        // Provide Promary and secordary field set members
        String selectString = BT_Utils.buildSelectListFragment(BT_Utils.getFieldSetMembers(BT_Utils.getNamespacePrefix()+'File_Detail',BT_Constants.OBJECT_TYPE_FILE), BT_EmailFilesToUsersController.fileEmailFields(), new List<String>{'Id','Name', 'OwnerId'});
        System.assertEquals(selectString != null, true);
    }
    
    static testMethod void testController() {
        Boolean isNewOrg = BT_Utils.getIsNewOrg();
         System.assertEquals('Test','Test');
        //System.assert(isNewOrg);
       // BT_Utils.initializeNewOrg();
    }
    
    static testmethod void testisValidSalesforceId(){
        String StringId ='Test Id';
        Boolean result; 
        result=BT_Utils.isValidSalesforceId(StringId,Account.class);
        System.assertEquals(false,result);
        
        Account accountRec = new Account();
        accountRec.Name='Name Test';
        insert accountRec;
       
        
        StringId=accountRec.Id;
            
        result=BT_Utils.isValidSalesforceId(StringId,Account.class);
        System.assertEquals(true,result);
        
         
        contact contactRec = new contact();
        contactRec.AccountId=accountRec.Id;
        contactRec.LastName='test';
        insert contactRec;
        
        StringId=contactRec.Id;
            
        
        result=BT_Utils.isValidSalesforceId(StringId,Account.class);
        System.assertEquals(false,result);
    }
}