@isTest
public with sharing class BT_SyncProductsControllerTest {
    @testSetup static void setup() {
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name='Project Name';
        insert project;

        buildertek__Quote_Line_Group__c qlgrp = new buildertek__Quote_Line_Group__c();
        qlgrp.Name = 'TEST GRP';
        insert qlgrp;

        buildertek__Quote__c Quote = new buildertek__Quote__c();
        Quote.Name='Test Description';
        Quote.buildertek__Project__c=project.Id;
        insert Quote;

        
        Pricebook2 pb =new Pricebook2();
        pb.Name = 'Aaa';
        pb.IsActive = true;
        insert pb;
        
        
        Product2 prod = new Product2();
        prod.Name ='Test product';
        prod.IsActive = true;
        prod.Family = 'Appliances';
        prod.buildertek__Quote_Group__c = qlgrp.Id;
        prod.ProductCode = 'PRD-123';
        prod.QuantityUnitOfMeasure = 'TEST';
        prod.Description = 'PRD-123 new';
        insert prod;
        
        buildertek__Quote_Item__c QuoteLine = new buildertek__Quote_Item__c();
        QuoteLine.buildertek__Quote__c = Quote.Id;
        QuoteLine.buildertek__Product__c = prod.Id;
        insert QuoteLine;

        buildertek__Quote_Item__c QuoteLine2 = new buildertek__Quote_Item__c();
        QuoteLine2.buildertek__Quote__c = Quote.Id;
        QuoteLine2.buildertek__Product__c = null;
        insert QuoteLine2;
        
    }
    public static testMethod void testMethod1() {
        Id pricebookstd= Test.getStandardPricebookId();
        
        Product2 prd= [Select Id , Name ,Family FROM Product2 LIMIT 1];
        Pricebook2 pricebook= [Select Id , Name FROM Pricebook2 ORDER BY NAME ASC LIMIT 1];
        Id pbId = pricebook.Id;
        List<buildertek__Quote_Item__c> data = [SELECT Id,buildertek__Quote__c,buildertek__Product__c,buildertek__Product__r.Name ,buildertek__Product__r.Id  FROM buildertek__Quote_Item__c]; 
        buildertek__Quote__c Quote= [Select Id , Name FROM buildertek__Quote__c LIMIT 1];
        
        String searialzeddata = JSON.serialize(data);

        buildertek__Project__c project1 = new buildertek__Project__c();
        project1.Name='Project';
        project1.buildertek__Price_Book__c = pricebook.Id;
        insert project1;
        
        buildertek__Quote__c Quote2 = new buildertek__Quote__c();
        Quote2.Name='Test Desc';
        Quote2.buildertek__Project__c=project1.Id;
        insert Quote2;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookstd, Product2Id = prd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false,buildertek__Unit_Cost__c = 100,buildertek__Markup__c=12,buildertek__Discount__c=0);
        insert standardPrice;



        
        Test.startTest();
        BT_SyncProductsController.getPricebookList(Quote2.Id);
        BT_SyncProductsController.getPricebookList(Quote.Id);
        BT_SyncProductsController.getQuoteLineRecordList(Quote.Id);
        BT_SyncProductsController.getProductsthroughPriceBook2(pricebookstd);
        BT_SyncProductsController.getProductsthroughProductFamily(pricebookstd,prd.Family);
        BT_SyncProductsController.getProductsbyName(pricebookstd,'Test p');
        BT_SyncProductsController.getProductsbyNameandFamily(pricebookstd,'Test p',prd.Family);
        BT_SyncProductsController.massUpdateQuoteLine(searialzeddata);
        BT_SyncProductsController.checkQuoteLineItems(Quote.Id);
        Test.stopTest();
    }
}
