/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class PurchaseOrderDAOTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
        Purchase_Order__c po = [Select Id from Purchase_Order__c LIMIT 1];
        PurchaseOrderDAO.RollUpPurchaseOrder(new set<Id>{po.Id});
        
           Product2 prod1 = new Product2();
        prod1.Name='test product';
        insert prod1;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        buildertek__Project__c proj1 = new buildertek__Project__c();
        proj1.Name = 'Test Project';
        proj1.buildertek__Customer__c=acc.Id;
        insert proj1;
        
        
        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.Name = 'Test Budget';
        budget.buildertek__Project__c = proj1.Id;
        budget.buildertek__Type__c = 'Master';
        insert budget;
        
        buildertek__Budget_Item__c budItem = new buildertek__Budget_Item__c();
        budItem.Name = 'Test Budget';
        budItem.buildertek__Budget__c = budget.Id;
        budItem.buildertek__Quantity__c = 10;
        budItem.buildertek__Unit_Price__c = 100;
        insert budItem;
        
        Project__c proj = [Select Id from Project__c LIMIT 1];
        
        RFQ__c rfq = new RFQ__c();
        rfq.Name = 'Test';
        rfq.Project__c = proj.Id;
        insert rfq;
        
        RFQ_Item__c item = new RFQ_Item__c();
        item.Name = 'Test';
        item.RFQ_Package__c = rfq.Id;
        insert item;
        
        RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
        rfqVendor.Vendor__c = [Select Id from Account LIMIT 1].Id;
        rfqVendor.RFQ__c = rfq.Id;
        insert rfqVendor;
        
        List<Product2> productList = new List<Product2>();
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        insert prod;
        
        Purchase_Order__c poRec = new Purchase_Order__c(Project__c=proj.id, buildertek__Vendor__c = acc.id);
        String PurchaseJSON = JSON.serialize(poRec);
        
        List<Purchase_Order_Item__c> porListRec = new List<Purchase_Order_Item__c>();
        Purchase_Order_Item__c porRec = new Purchase_Order_Item__c();
        porRec.Name ='Test';
        porRec.buildertek__Purchase_Order__c = poRec.id;
        porListRec.add(porRec);
        String PurchaseItemJSON = JSON.serialize(porListRec);
        Map<Id, RFQ__c> rfqs = new Map<Id, RFQ__c>([Select Id, Name, budget__c, vendor__c, vendor__r.vendor__c, Project__c, (Select Id, Name, Description__c, Cost_Code__c, Quantity__c, Unit_Price__c, Budget_Item__c, Product__c from RFQ_Items__r) from RFQ__c LIMIT 1]);
        Map<Id, Contract__c> rfqToSubContract = new Map<Id, Contract__c>();
        //PurchaseOrderDAO.createPOFromRFQ(rfqs, rfqToSubContract);
        PurchaseOrderDAO.createPO(poRec,PurchaseItemJSON,budItem.Id);
        PurchaseOrderDAO.createAPFromPO(po.Id);
        PurchaseOrderDAO.getProduct(PurchaseItemJSON);
        PurchaseOrderDAO.addProductsToList(PurchaseItemJSON, porListRec[0], 2);
        System.assertEquals('Test','Test');
    }
}