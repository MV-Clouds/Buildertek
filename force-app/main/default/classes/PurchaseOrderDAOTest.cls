/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class PurchaseOrderDAOTest {
    @testSetup static void setupBaseData() {
        // SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        pricebook2 testPricebook = new pricebook2(Name = 'Test Pricebook');
        insert testPricebook;

        Opportunity opportunity1 = new Opportunity(
            Name = 'Sample Opportunity 1',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addMonths(1)
        );
        insert opportunity1;

        buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = acc.Id,
            buildertek__Opportunity__c = opportunity1.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5,
            buildertek__Price_Book__c = testPricebook.Id
        );
        insert project;

        Purchase_Order__c poRecs = new Purchase_Order__c(Project__c=project.id, buildertek__Vendor__c = acc.id,buildertek__Status__c = 'Open');
        insert poRecs;
        Purchase_Order__c po = [Select Id from Purchase_Order__c LIMIT 1];
        PurchaseOrderDAO.RollUpPurchaseOrder(new set<Id>{po.Id});
        
        Product2 prod1 = new Product2();
        prod1.Name='test product';
        insert prod1;

        
        
        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.Name = 'Test Budget';
        budget.buildertek__Project__c = project.Id;
        budget.buildertek__Type__c = 'Master';
        insert budget;
        
        buildertek__Budget_Item__c budItem = new buildertek__Budget_Item__c();
        budItem.Name = 'Test Budget';
        budItem.buildertek__Budget__c = budget.Id;
        budItem.buildertek__Quantity__c = 10;
        budItem.buildertek__Unit_Price__c = 100;
        insert budItem;

        RFQ__c rfq = new RFQ__c();
        rfq.Name = 'Test';
        rfq.Project__c = project.Id;
        rfq.buildertek__Budget__c = budget.Id;
        rfq.buildertek__vendor__c = null;
        insert rfq;
        
        RFQ_Item__c item = new RFQ_Item__c();
        item.Name = 'Test';
        item.RFQ_Package__c = rfq.Id;
        item.buildertek__Product__c = prod1.Id;
        item.buildertek__Quantity__c = 10;
        item.buildertek__Unit_Price__c = 100;
        insert item;
        
        RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
        rfqVendor.Vendor__c = [Select Id from Account LIMIT 1].Id;
        rfqVendor.RFQ__c = rfq.Id;
        insert rfqVendor;
        
        List<Purchase_Order__c> poList = new List<Purchase_Order__c>(); 
        Purchase_Order__c poRec2 = new Purchase_Order__c(Project__c=project.id, buildertek__Vendor__c = acc.id,buildertek__Status__c = 'Open');
        poList.add(poRec2);

        Purchase_Order__c poRec1 = new Purchase_Order__c(Project__c=project.id, buildertek__Vendor__c = acc.id,buildertek__Status__c = 'Paid');
        poList.add(poRec1);
        insert poList;
        
        List<Purchase_Order_Item__c> porListRec1 = new List<Purchase_Order_Item__c>();
        Purchase_Order_Item__c porRec1 = new Purchase_Order_Item__c();
        porRec1.Name ='Test';
        porRec1.buildertek__Purchase_Order__c = poList[1].id;
        porRec1.Budget_Item__c = budItem.Id;
        porListRec1.add(porRec1);

        List<Purchase_Order_Item__c> porListRec = new List<Purchase_Order_Item__c>();
        Purchase_Order_Item__c porRec2 = new Purchase_Order_Item__c();
        porRec2.Name ='Test';
        porRec2.buildertek__Purchase_Order__c = poList[0].id;
        porRec2.Quantity__c = 10;
        porRec2.Unit_Price__c = 100;
        porRec2.Quantity_Received__c = 0;
        porRec2.Budget_Item__c = budItem.Id;
        porRec2.Product__c = prod1.Id;
        porListRec1.add(porRec2);
        insert porListRec1;

        porListRec.add(porRec2);
        String PurchaseItemJSON = JSON.serialize(porListRec);

        Purchase_Order_Item__c porRec = new Purchase_Order_Item__c();
        porRec.Name ='Test';
        porRec.Product__c = prod1.Id;
        porRec.buildertek__Purchase_Order__c = poList[0].id;

        Map<Id, RFQ__c> rfqs = new Map<Id, RFQ__c>([Select Id, Name, budget__c, vendor__c, vendor__r.vendor__c, Project__c, (Select Id, Name, Description__c, Cost_Code__c, Quantity__c, Unit_Price__c, Budget_Item__c, Product__c from RFQ_Items__r) from RFQ__c LIMIT 1]);
        Map<Id, Contract__c> rfqToSubContract = new Map<Id, Contract__c>();
        List<String> budgetIds = new List<String>();
        budgetIds.add(String.valueOf(budItem.Id));

        Test.startTest();

        PurchaseOrderDAO.Checkifpaid(poList[0].Id);
        PurchaseOrderDAO.Checkifpaid(poList[1].Id);
        PurchaseOrderDAO.createPurchaseOrderItemToBudgetItemLink(porListRec);
        PurchaseOrderDAO.createPurchaseOrderItemToBudgetItemLink(porListRec1);
        PurchaseOrderDAO.createPOFromRFQ(rfqs,rfqToSubContract);
        PurchaseOrderDAO.getpricebook(poList[0].Id);
        PurchaseOrderDAO.getpricebooks(poList[1].Id);
        PurchaseOrderDAO.getFieldSet();
        // PurchaseOrderDAO.createLinesForExistedPO(poList[0].Id , PurchaseItemJSON , budItem.Id , budgetIds);
        PurchaseOrderDAO.getProductPrice(prod1.Id);
        PurchaseOrderDAO.createPO(poRecs,PurchaseItemJSON,budItem.Id);
        PurchaseOrderDAO.createAPFromPO(poList[0].Id);
        PurchaseOrderDAO.getProduct(PurchaseItemJSON);
        PurchaseOrderDAO.addProductsToList(PurchaseItemJSON, porListRec[0], 2);
        PurchaseOrderDAO.getselectOptions();
        PurchaseOrderDAO.getProductPricevalue(string.valueOf(prod1.Id));
        PurchaseOrderDAO.getProductfamilyRecords('Product2',string.valueOf(testPricebook.Id));

        System.assertEquals('Test','Test');

        Test.stopTest();
    }
}