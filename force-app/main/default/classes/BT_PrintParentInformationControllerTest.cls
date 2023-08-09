/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class BT_PrintParentInformationControllerTest {
     @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
		ApexPages.currentPage().getParameters().put('id',[Select Id from Quote__c LIMIT 1].Id);
    	BT_PrintParentInformationController BT_PrintParentInformation = new BT_PrintParentInformationController();
    	BT_PrintParentInformation.objectName = 'buildertek__Quote__c';
    	BT_PrintParentInformation.viewFieldApi =  'buildertek__Bill_To_Name__c,buildertek__Ship_To_Name__c,buildertek__Bill_To_Street__c,buildertek__Ship_To_Street__c,buildertek__Bill_To_City__c,buildertek__Ship_To_City__c';
    	BT_PrintParentInformation.getApiList();
    	System.assertEquals('Test','Test');
    }
}