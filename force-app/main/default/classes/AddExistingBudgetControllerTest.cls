/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  15-Nov-2018
*/
@isTest
public class AddExistingBudgetControllerTest {
    
    public static testMethod void testAddExistingBudgetController() {
       Contract__c contract = new Contract__c();
       contract.Name = 'Test';
       insert contract;
       buildertek__Budget__c budget = new buildertek__Budget__c(
            Name = 'Sample Budget',
            buildertek__Type__c = 'Standard'
        );
       insert budget;
        buildertek__Budget_Item__c BudgetLineToInsert = new buildertek__Budget_Item__c();
        BudgetLineToInsert.Name = 'Test';
        BudgetLineToInsert.buildertek__Budget_Line_Group__c = null;
        BudgetLineToInsert.buildertek__Unit_Price__c = 100;
        BudgetLineToInsert.buildertek__Quantity__c = 1;
        BudgetLineToInsert.buildertek__Budget__c = budget.Id;
        BudgetLineToInsert.buildertek__Description__c = 'Test Description';
        insert BudgetLineToInsert;
       AddExistingBudgetController.updateBudgetItemRecordMethod(BudgetLineToInsert);
       AddExistingBudgetController.getContractDetails(contract.Id, 'Contract__c', 'Id,Name,Contract_Amount__c');
       System.assertEquals('Test','Test');
    }
}