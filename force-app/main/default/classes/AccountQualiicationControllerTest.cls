@isTest
public with sharing class AccountQualiicationControllerTest {
    @IsTest
    static void testMethod1(){

        Contact c = new Contact();
        c.LastName = 'test Contact1';
        c.Email = 'test@gamil.com';
        insert c;

        List<Account> accList = new List<Account>();

        Account a = new Account();
        a.Name = 'Test Account';
        a.Phone = '32423123';
        a.buildertek__Qualification_Stage__c = 'Not Qualified';
        a.buildertek__Pre_Qual_Contact__c = c.Id;
        a.buildertek__MSA_Additional_Email__c = 'test@gmail.com';
        accList.add(a);

        Account a2 = new Account();
        a2.Name = 'Test Account2';
        a2.Phone = '45423123';
        a2.buildertek__Qualification_Stage__c = 'Email Sent';
        accList.add(a2);
        insert accList;

        Blob b = Blob.valueOf('Test Data');

    	Attachment attachment = new Attachment();
    	attachment.ParentId = accList[0].Id;
    	attachment.Name = 'File Test';
    	attachment.Body = b;

    	insert(attachment);

        buildertek__MSA_Settings__c msa = new buildertek__MSA_Settings__c();
        msa.Name = 'MSA Settings';
        msa.buildertek__Site_URL__c = 'https://test.com/';
        msa.buildertek__Send_MSA_Template_Name__c = 'Email Test';
        insert msa;

        EmailTemplate e = new EmailTemplate (developerName = 'Email Test', TemplateType= 'Text', Name = 'Email Test');

        String recordId = accList[0].Id;
        String oldStatus = 'Not Qualified';
        String FileData = '[{\"fileName\":\"image(4).png\",\"fileContent\":\"iVBORw0KGgoAAAANSUhEUgAAB3wAAAQeCAIAAAC8NNwoAAAAAXNSR0IArs\"}]';

        Test.startTest();
            AccountQualiicationController.getPreQualStage(recordId);
            AccountQualiicationController.ChangeAccountStatus(recordId);
            AccountQualiicationController.ChangeAccountStatustoOld(recordId,oldStatus);
            AccountQualiicationController.saveTheFile(recordId,'testFile', 'endcodedBase','JPEG');
            AccountQualiicationController.saveFile(recordId,'testFile', 'endcodedBase','JPEG', '');
            AccountQualiicationController.sendEmail(recordId, FileData);
        Test.stopTest();

    }
}