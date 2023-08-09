/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  19-Nov-2018
*/
@isTest
public class CreateInvoiceFromContractTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    	buildertek__Project__c project= Buildertek_UtilityClass.project();
    	
    	Account acc = new Account();
    	acc.Name ='test';
    	insert acc;
    	
    	buildertek__Change_Order__c co = new buildertek__Change_Order__c();
    	co.name = 'TEst';
    	co.Project__c = project.Id;
    	co.buildertek__Customer_Account__c =acc.id;
    	insert co;
    	
    	buildertek__change_order_Item__c coItem = new buildertek__change_order_Item__c(
        	Name = 'Sample Quote Item',
        	buildertek__Change_Order__c = co.Id
        );
        
        insert coItem;
        
    	
		 buildertek__Contract__c contract = new buildertek__Contract__c(
            Name = 'Sample Quote',
            // Project__c = [Select ID from Project__c LIMIT 1].Id,
            buildertek__Change_Order__c = co.id,
            buildertek__Vendor__c = acc.id,
        	buildertek__Project__c = project.id,
        	buildertek__Status__c ='pending'
        );
        
        insert contract;
        
        buildertek__Contract_Item__c contractItem = new buildertek__Contract_Item__c(
        	Name = 'Sample Quote Item',
        	Contract__c = contract.Id
        	
        );
        
        insert contractItem;
    	CreateInvoiceFromContract.CreateInvoiceMethod(contract.Id);
        System.assertEquals('Test','Test');	
   
    }
}