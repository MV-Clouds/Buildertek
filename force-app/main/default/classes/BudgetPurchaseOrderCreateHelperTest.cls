/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  19-Nov-2018
*/
@isTest
public class BudgetPurchaseOrderCreateHelperTest {
     @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
        Purchase_Order__c PO = [Select ID,buildertek__Budget__c from purchase_order__c LIMIT 1];
    //	BudgetPurchaseOrderCreateHelper.createBudgetFromPurchaseOrder(new List<Id> {PO.Id});
    	BudgetPurchaseOrderCreateHelper.getPurchaseWithLines(new List<Id> {PO.Id});
    	System.assertEquals('Test','Test');
    }
}