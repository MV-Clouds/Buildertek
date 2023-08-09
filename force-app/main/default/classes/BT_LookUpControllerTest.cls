/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  11-Apr-2018
*/
@isTest
public with sharing class BT_LookUpControllerTest {
    private static testMethod void testGetTargetSObjectName() {
        System.assertEquals(
            BT_LookUpController.getTargetSObjectName('Contact', 'AccountId'), 'Account');
        	BT_LookUpController.getAllValues('Contact');
        BT_LookUpController.getAllValues('buildertek__Cost_Codes__c');
            
    }
    
    private static testMethod void testSearchKeyword() {
        Account acc = new Account(Name = 'Test Account for search');
        insert acc;
        
        System.assertEquals(BT_LookUpController.searchKeyword('Account', 'test').size(), 1);
        System.assertEquals(BT_LookUpController.searchKeyword('Account', 'test', null).size(), 1);
        System.assertEquals(
        BT_LookUpController.searchKeyword('Account', 'Not Existing Account').size(), 0);
            
    }
}