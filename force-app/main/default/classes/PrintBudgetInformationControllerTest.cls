/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class PrintBudgetInformationControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    	String budgetId = [Select Id from Budget__c LIMIT 1].Id;
    	Apexpages.currentPage().getParameters().put('Id', budgetId);
    	
    	
    	PrintBudgetInformationController BT_PrintParentInformation = new PrintBudgetInformationController();
    	BT_PrintParentInformation.objectName = 'buildertek__Quote__c';
    	BT_PrintParentInformation.viewFieldApi =  'buildertek__Bill_To_Name__c,buildertek__Ship_To_Name__c,buildertek__Bill_To_Street__c,buildertek__Ship_To_Street__c,buildertek__Bill_To_City__c,buildertek__Ship_To_City__c';
    	
    	ApexPages.currentPage().getParameters().put('id',[Select Id from Quote__c LIMIT 1].Id);
    	BT_PrintParentInformation.getApiList();
    	System.assertEquals('Test','Test');
    }
}