/* **************************************************************************
* Copyright 2017 - 2016, BuilderTek.
* All rights reserved
*
* Test Class: UserTriggerHandlerTest
* Created by Sagar
*
* - Test class for UserTriggerHandler.

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
public with sharing class UserTriggerHandlerTest {
    static testMethod void testInsertUser(){
        
        buildertek__Admin_Interface_Node_Configuration__c adminNode = new buildertek__Admin_Interface_Node_Configuration__c();
        
        adminNode.buildertek__User_SOV_Sharing__c = false;
        adminNode.name = 'Payment Application Configuration';
        insert adminNode;
        
        
        // Create a user
        Profile p = [select id from profile where name = 'System Administrator'];
        User adminUser = new User(alias='admin123', email='sam@test1234.com', 
                    emailencodingkey='UTF-8', lastname='testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid=p.id, 
                    timezonesidkey='America/Los_Angeles', username='aradmin123@72demo.com');
        insert adminUser;
        
        // Create Group
       // PostInstallClass pinstall = new PostInstallClass();
       // pinstall.createGroups();
        
        System.runAs(adminUser){
            
            User testUser = new User(alias='test123', email='sam@test98765.com', 
                    emailencodingkey='UTF-8', lastname='testing', languagelocalekey='en_US',
                    Is_File_Control_User__c = true,
                    File_Access_Type__c = BT_Constants.FILE_ACCESS_PUBLIC_READ_ONLY,
                    localesidkey='en_US', profileid=p.id, 
                    timezonesidkey='America/Los_Angeles', username='test654@72demo.com');
            insert testUser;
            
            testUser.Is_File_Control_User__c = false;
            testUser.File_Access_Type__c = BT_Constants.FILE_ACCESS_PUBLIC_WRITE;
            update testUser;
            testUser = [Select Id, Is_File_Control_User__c From User Where  Id =: testUser.Id];
            System.assertEquals(testUser.Is_File_Control_User__c, false);
            
        }
    }
}