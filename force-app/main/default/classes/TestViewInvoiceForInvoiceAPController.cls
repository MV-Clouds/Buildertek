@isTest
public with sharing class TestViewInvoiceForInvoiceAPController {

    @TestSetup 
    static void setup(){

        InsertFutureEmailTemp.insertTemplate();

        List<Contact> conList1 = new List<Contact>();
        Contact con1 = new Contact();
        con1.FirstName = 'Test FirstName';
        con1.LastName = 'Test LastName';
        con1.Email = 'test@gamil.com';
        conList1.add(con1);
        
        Contact con2 = new Contact();
        con2.FirstName = 'Test FirstName2';
        con2.LastName = 'Test LastName2';
        con2.Email = 'test2@gamil.com';
        conList1.add(con2);
        insert conList1;
        
        buildertek__Account_Payable_Clone__c invoiceAP = new buildertek__Account_Payable_Clone__c();
        invoiceAP.buildertek__posted__c = false;
        invoiceAP.buildertek__Contact__c = con1.Id;
        insert invoiceAP;

        buildertek__Account_Payable_Item_Clone__c invoiceAPLine = new buildertek__Account_Payable_Item_Clone__c();
        invoiceAPLine.Name = 'test item 1';
        invoiceAPLine.buildertek__Quantity__c = 2;
        invoiceAPLine.buildertek__Account_Payable_Clone__c = invoiceAP.Id;
        insert invoiceAPLine;

        buildertek__Account_Payable_Item_Clone__c invoiceAPLine1 = new buildertek__Account_Payable_Item_Clone__c();
        invoiceAPLine1.Name = 'test item 2';
        invoiceAPLine1.buildertek__Quantity__c = 2;
        invoiceAPLine1.buildertek__Account_Payable_Clone__c = invoiceAP.Id;
        insert invoiceAPLine1;
    }

    // @IsTest
    // static void testMethod1(){

    //     String templateText1 = '<messaging:emailTemplate subject="{!relatedTo.Name}" recipientType="User" relatedToType="Custom_Object__c"><messaging:htmlEmailBody ><ul><li>test content</li></ul></messaging:htmlEmailBody></messaging:emailTemplate>';

    //     EmailTemplate etemp = new EmailTemplate();
    //     etemp = [SELECT Id FROM EmailTemplate LIMIT 1];
    //     String templateId = etemp.Id;
        
    //     buildertek__Account_Payable_Clone__c invoiceAPdata = new buildertek__Account_Payable_Clone__c();
    //     invoiceAPdata = [SELECT Id,Name,buildertek__Contact__c FROM buildertek__Account_Payable_Clone__c LIMIT 1];
        
    //     List<String> conList1 = new List<String>();
    //     List<String> conList2 = new List<String>();

    //     Contact c = new Contact();
    //     c = [SELECT Id FROM Contact WHERE LastName = 'Test LastName'];
    //     conList1.add(c.Id);
        
    //     Contact c1 = new Contact();
    //     c1 = [SELECT Id FROM Contact WHERE LastName = 'Test LastName2']; 
    //     conList2.add(c1.Id);

    //     String recordId = invoiceAPdata.Id;

    //     Test.startTest();
    //         ViewInvoiceForInvoiceAPController.getTemplates();
    //         ViewInvoiceForInvoiceAPController.getInvoiceLines(invoiceAPdata.Id, etemp.Id);
    //         ViewInvoiceForInvoiceAPController.getObjectContact(invoiceAPdata.Id);
    //         ViewInvoiceForInvoiceAPController.sendInvoice(templateText1,recordId,templateId,conList1,conList2,null,null);
    //         // ViewInvoiceForInvoiceAPController.setAttachmentBody(invoiceAPdata.Id, eTemp.Id);
    //     Test.stopTest();
        
    // }
}