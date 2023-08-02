@isTest
public class ContentDocumentImageDeleteTest {
     public static testMethod void testContentDocumentLink(){
         Product2 productRec = new Product2();
         productRec.buildertek__Type__c = 'Test';
         productRec.Name = 'New Product';
         insert productRec;
         
        // list<buildertek__Question__c> questionlist = new list<buildertek__Question__c>();
         buildertek__Question__c quesRec = new buildertek__Question__c();
         quesRec.buildertek__Image_Id__c = 'Test';
         quesRec.buildertek__Product__c = productRec.id;
         quesRec.buildertek__Document_Id__c = 'Test Documnet';
         //questionlist.add(quesRec);
         insert quesRec;
         
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
       ContentDocument cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :conDocId];
        delete cdList;
     }
}