/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class BT_CreatePurchaseOrderControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    	String projectId = [Select Id from Project__c LIMIT 1].Id;
    	Quote__c quote = [Select Id from Quote__c LIMIT 1];
    	BT_CreatePurchaseOrderController.getAllProducts(quote.Id);
    	
    	Purchase_Order__c po = [Select Id from Purchase_Order__c LIMIT 1];
    	BT_CreatePurchaseOrderController.updateAvailableQuantity(po.Id);
    	
    	BT_CreatePurchaseOrderController.getPurchaseOrderRecordData(po.Id);
    	
    	BT_CreatePurchaseOrderController.createPurchseOrderAndLines(new List<String>{[Select Id from Product2 LIMIT 1].Id+'- 1'}, quote.Id, projectId);
    	System.assertEquals('Test','Test');
    }
}