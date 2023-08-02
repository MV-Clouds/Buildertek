@isTest
public with sharing class BT_New_Meeting_ControllerTest {
    
    @isTest
    static void meeting1(){

        Contact con = new Contact();
        con.LastName = 'test';
        con.Email = 'abc@gmail.com';
        insert con;

        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('MSAForm.pdf');
        efa.setBody(bodyBlob);

        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] sendTo = new String[]{'XXXXXXXXX@gmail.com'};
        email.setToAddresses(sendTo);
        email.setTemplateID(emailTemplate.Id);
        email.setTargetObjectId(con.Id);
        email.setHtmlBody(con.Name);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{ efa });

        buildertek__Meeting__c meeting = new buildertek__Meeting__c();
        meeting.buildertek__Subject__c = 'test';
        meeting.buildertek__Meeting_Date__c = System.today();
        insert meeting;

        List<buildertek__Action_Item__c> actionItem = new List<buildertek__Action_Item__c>();
        buildertek__Action_Item__c actionItem1 = new buildertek__Action_Item__c();
        actionItem1.buildertek__Description__c = 'test';
        actionItem1.buildertek__Meeting__c = meeting.Id;
        actionItem1.buildertek__Owner__c = con.Id;
        actionItem.add(actionItem1);

        BT_New_Meeting_Controller.getLookupName(meeting.Id);
        BT_New_Meeting_Controller.saveActionItems(actionItem,meeting.Id);
    }
}