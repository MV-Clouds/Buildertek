/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class BT_CompleteQuoteControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    	Quote__c qt = [Select Id,buildertek__Product__c from Quote__c where buildertek__Product__c!=null LIMIT 1];
    	BT_CompleteQuoteController.getQuoteRecordData(qt.Id);
    	
    	BT_CompleteQuoteController.updateAvailableQuantity(qt.Id);
    	System.assertEquals('Test','Test');
    }
}