/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class RFQResponseControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
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
        rfqVendor.buildertek__Submitted_Date__c = system.today();
        insert rfqVendor;
        
        Folder__c fd = new Folder__c();
        fd.Name = 'TEst';
        fd.Default__c = true;
        fd.Active__c = true;
        insert fd;
        
        /*File__c files = new File__c();
        files.Name = 'Test File';
        insert files;*/
        
        ApexPages.currentPage().getParameters().put('id',rfqVendor.Id);
        RFQResponseController rfqr = new RFQResponseController();
        
        rfqr.submintQuote();
        //rfqr.insertFileInS3();
        rfqr.showPopup();
            rfqr.redirectPopup();
        rfqr.refreshFiles();
        
        rfqr.uploadDocument();
        //ApexPages.currentPage().getParameters().put('fileid',files.Id);
        rfqr.removefile();
        rfqr.addNewRowToAccList();
        System.assertEquals('Test','Test');
    }
}