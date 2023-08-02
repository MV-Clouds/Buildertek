/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  15-Nov-2018
*/
@isTest
public class BT_SendEmailControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
RFIsetting.Name='RFI Settings';
RFIsetting.buildertek__Using_Communities__c = true;
RFIsetting.buildertek__Using_Email__c = true;
RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
RFIsetting.buildertek__Queue_Name__c = 'RFI';
insert RFIsetting;

        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
        List<EmailTemplate> templates = BT_SendEmailController.getTemplates('BT PO'); 
        List<String> texttoId = new List<String>();
        texttoId.add('test@gmail.com');
        
        BT_SendEmailController.SendEmail(new List<String>{}, new List<String> {}, new List<String> (),'Test', 'Test', [Select Id from buildertek__Purchase_Order__c LIMIT 1].Id, templates[0].Id, 'test',texttoId);
        account acc = new account();
        acc.name = 'Test';
        insert acc;
        List<Contact> ConRef = new List<Contact>();
        Contact con = new Contact();
        con.Email ='Test@gmail.com';
        con.LastName ='Test';
        con.AccountId =acc.id;
        ConRef.add(con);
        insert con;
        
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.Name = 'Test Budget';
        quote.buildertek__Project__c = proj.Id;
        quote.buildertek__Type__c = 'Master';
        insert quote;
        
        RFI__c rfi = new RFI__c();
        rfi.Project__c = proj.Id;
        rfi.buildertek__Subject__c = 'TEst'; 
        rfi.buildertek__Assigned_To__c = con.Id;
        rfi.buildertek__Due_Date__c = system.today();
        insert rfi;
        
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.buildertek__Project__c = proj.Id;
        rfq.buildertek__Status__c = 'Awarded';
        rfq.buildertek__Description__c = 'Test Description';
        insert rfq;
        
        buildertek__RFQ_To_Vendor__c rfqToVendor = new buildertek__RFQ_To_Vendor__c();
        rfqToVendor.Name = 'Test Vendor';
        rfqToVendor.buildertek__RFQ__c = rfq.Id;
        rfqToVendor.buildertek__Vendor__c = acc.Id;
        insert rfqToVendor;
        
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment att = new Attachment();
        att.Name = 'Test Attachemnt';
        att.ParentId = quote.Id;
        att.Body = blob.valueOf('Test Body');
        attachmentList.add(att);
        insert attachmentList;
        List<buildertek__File__c> filesList = new List<buildertek__File__c>();
        
        //EmailTemplate emTemp = [select id, Name from EmailTemplate where Name='Quote Template 1'];
        //BT_SendEmailController.FinalFileAttachmentsClass attClass = new BT_SendEmailController.FinalFileAttachmentsClass(attachmentList, contentVersionList, filesList);
        //BT_SendEmailController.getFileAttachments(quote.Id);
        //BT_SendEmailController.getFileAttachments(rfi.Id);
        //BT_SendEmailController.getObjectContact(rfi.Id, 'buildertek__Quote__c');
        //BT_SendEmailController.getEmailBodyFromTemplate(rfqToVendor.Id, con.Id, emTemp.Id, emTemp.Name);
        //System.assertEquals('Test','Test');
        
    //  buildertek__Amazon_S3_Key__c Amazon = new buildertek__Amazon_S3_Key__c();
    //  Amazon.Name = 'Test';
    //     Amazon.buildertek__Configured_Value__c = 'Test';
    //     Amazon.buildertek__Description__c = 'Test';
    //     insert Amazon;
        
    //  buildertek__File__c Builder = new buildertek__File__c();
    //  Builder.Name ='test';
    //  Builder.buildertek__Amazon_File_Key__c='test.jpg';
    // //   Builder.LastName ='test';
    //  insert Builder;
        
    //  buildertek__RFQ__c RFQref = new buildertek__RFQ__c();
    //  RFQref.buildertek__Description__c ='test';
    //  RFQref.buildertek__Project__c = buildertekProjectRef.id;
    //  insert RFQref;
    //  buildertek__RFQ_To_Vendor__c RFQVenRef = new buildertek__RFQ_To_Vendor__c();
    //  RFQVenRef.buildertek__Vendor__c =acc.id;
    //  RFQVenRef.buildertek__Contact__c = con.id;
    //  RFQVenRef.buildertek__RFQ__c =RFQref.id;
    //  insert RFQVenRef;
        
    //  Attachment attach=new Attachment();     
    //  attach.Name='Unit Test Attachment';
    //  Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    //  attach.body=bodyBlob;
    //     attach.parentId=Builder.id;
    //     insert attach;
        
        
        
    //      BT_SendEmailController.getFileAttachments(Builder.id);
    //     BT_SendEmailController.getFileDetails()
    //      BT_SendEmailController.getEmailBodyFromTemplate([Select Id from buildertek__Purchase_Order__c LIMIT 1].Id, null, templates[0].Id, '');
        // String action = EncodingUtil.base64Encode(Blob.valueOf('attach'));
        // BT_SendEmailController.setAttachmentBody('action','attach');
    //  BT_SendEmailController.FinalFileAttachmentsClass FinalRef = new BT_SendEmailController.FinalFileAttachmentsClass();
    }
}