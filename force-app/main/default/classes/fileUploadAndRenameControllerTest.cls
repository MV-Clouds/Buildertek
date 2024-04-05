@isTest
public with sharing class fileUploadAndRenameControllerTest {
    @IsTest
    static void testMethod1(){

        buildertek__Walk_Through_List__c walkThrough = new buildertek__Walk_Through_List__c();
        walkThrough.buildertek__Description__c = 'Test Walk Through';
        walkThrough.buildertek__Type__c = 'Standard';
        walkThrough.buildertek__Walk_Through_Date__c = Date.today();

        insert walkThrough;

        buildertek__Walk_Through_Line_Items__c walkThroughLineItem = new buildertek__Walk_Through_Line_Items__c();
        walkThroughLineItem.buildertek__Walk_Through_List__c = walkThrough.Id;
        walkThroughLineItem.buildertek__Description__c = 'Test Walk Through Line Item';

        insert walkThroughLineItem;

        Blob bodyBlob=Blob.valueOf('Unit Test Content');

        ContentVersion contentVersion_1 = new ContentVersion();
        contentVersion_1.Title = 'SampleFile';
        contentVersion_1.PathOnClient = 'SampleFile.jpg';
        contentVersion_1.VersionData = bodyBlob;
        contentVersion_1.origin = 'H';

        insert contentVersion_1;

        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion_1.Id];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = contentVersion_2.ContentDocumentId;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.LinkedEntityId = walkThroughLineItem.Id;

        insert contentDocumentLink;

        Test.startTest();


        List<String> docIds = new List<String>();
        docIds.add(contentVersion_2.ContentDocumentId);

        List<wrpClass> wrapperList = new List<wrpClass>();

        wrpClass wrapper = new wrpClass();
        wrapper.title = 'Title';
        wrapper.id = contentVersion_2.Id;
        wrapper.ContentDocumentId = contentVersion_2.ContentDocumentId;
        wrapper.image = '';
        wrapperList.add(wrapper);

        String str = JSON.serialize(wrapperList);

        fileUploadAndRenameController.deleteFiles(docIds, walkThroughLineItem.Id);
        fileUploadAndRenameController.getDataForDataTable(docIds);
        fileUploadAndRenameController.updateFileName(str);

        Test.stopTest();

    }

    public class wrpClass{
        @AuraEnabled
        public String title{ get; set; }

        @AuraEnabled
        public String id{ get; set; }

        @AuraEnabled
        public String ContentDocumentId{ get; set; }

        @AuraEnabled
        public String image{ get; set; }

    }
}