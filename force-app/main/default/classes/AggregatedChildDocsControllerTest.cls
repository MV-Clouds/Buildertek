@isTest
public  class AggregatedChildDocsControllerTest {
    @testSetup static void setupBaseData() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;

        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.name='Test Quote';
        quote.buildertek__Project__c=proj.Id;
        insert quote;


        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=quote.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
    }
    @isTest
    static void makeData(){
        Project__c proj = [Select Id from Project__c LIMIT 1];


        Test.startTest();
        AggregatedChildDocsController.getChildObectName();
        AggregatedChildDocsController.getAttachement('buildertek__Quote__c', proj.Id);
        Test.stopTest();


    }
}