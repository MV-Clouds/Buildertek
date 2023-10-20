@isTest
public class SyncProductWithTakeoffLinesTest {
    @testSetup static void setup() {
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name='Project Name';
        insert project;

        buildertek__Quote_Line_Group__c qlgrp = new buildertek__Quote_Line_Group__c();
        qlgrp.Name = 'TEST GRP';
        insert qlgrp;

        buildertek__Project_Takeoff__c takeoff = new buildertek__Project_Takeoff__c();
        takeoff.buildertek__Name__c='Test Description';
        takeoff.buildertek__Project__c=project.Id;
        insert takeoff;

        
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
        
        buildertek__Project_Takeoff_Lines__c takeoffline = new buildertek__Project_Takeoff_Lines__c();
        takeoffline.buildertek__Project_Takeoff__c = takeoff.Id;
        takeoffline.buildertek__Product__c = prod.Id;
        insert takeoffline;

        buildertek__Project_Takeoff_Lines__c takeoffline2 = new buildertek__Project_Takeoff_Lines__c();
        takeoffline2.buildertek__Project_Takeoff__c = takeoff.Id;
        takeoffline2.buildertek__Product__c = null;
        insert takeoffline2;
        
    }
    public static testMethod void testMethod1() {
        Id pricebookstd= Test.getStandardPricebookId();
        
        Product2 prd= [Select Id , Name ,Family FROM Product2 LIMIT 1];
        Pricebook2 pricebook= [Select Id , Name FROM Pricebook2 ORDER BY NAME ASC LIMIT 1];
        Id pbId = pricebook.Id;
        List<buildertek__Project_Takeoff_Lines__c> data = [SELECT Id,buildertek__Project_Takeoff__c,buildertek__Product__c,buildertek__Product__r.Name ,buildertek__Product__r.Id  FROM buildertek__Project_Takeoff_Lines__c]; 
        buildertek__Project_Takeoff__c takeoff= [Select Id , Name FROM buildertek__Project_Takeoff__c LIMIT 1];
        
        String searialzeddata = JSON.serialize(data);

        buildertek__Project__c project1 = new buildertek__Project__c();
        project1.Name='Project';
        project1.buildertek__Price_Book__c = pricebook.Id;
        insert project1;
        
        buildertek__Project_Takeoff__c takeof = new buildertek__Project_Takeoff__c();
        takeof.buildertek__Name__c='Test Desc';
        takeof.buildertek__Project__c=project1.Id;
        insert takeof;
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookstd, Product2Id = prd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false,buildertek__Unit_Cost__c = 100,buildertek__Markup__c=12,buildertek__Discount__c=0);
        insert standardPrice;



        
        Test.startTest();
        SyncProductWithTakeoffLines.getPricebookList(takeof.Id);
        SyncProductWithTakeoffLines.getPricebookList(takeoff.Id);
        SyncProductWithTakeoffLines.getTakeoffLineRecordList(takeoff.Id);
        SyncProductWithTakeoffLines.getProductsthroughPriceBook2(pricebookstd);
        SyncProductWithTakeoffLines.getProductsthroughProductFamily(pricebookstd,prd.Family);
        SyncProductWithTakeoffLines.getProductsbyName(pricebookstd,'Test p');
        SyncProductWithTakeoffLines.getProductsbyNameandFamily(pricebookstd,'Test p',prd.Family);
        SyncProductWithTakeoffLines.massUpdateTakeoffLine(searialzeddata);
        SyncProductWithTakeoffLines.checkTakeoffLineItems(takeoff.Id);
        Test.stopTest();
    }
}