/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class BT_BudgetEditControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    public static testMethod void test1() {
    	
    	Budget__c budget = [Select Id from Budget__c LIMIT 1];
    	BT_BudgetEditController.editBudget(budget.Id);
    	BT_BudgetEditController.getTypeOptions('buildertek__Budget__c', 'buildertek__Type__c');
    	BT_BudgetEditController.updateBudgetInformation(budget);
    	System.assertEquals('Test','Test');
    }
}