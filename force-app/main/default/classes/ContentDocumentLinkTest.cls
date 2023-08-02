@isTest
public class ContentDocumentLinkTest {
    public static testMethod void testContentDocumentLink(){
        RFQ__c rfq = new buildertek__RFQ__c();
        rfq.Name = 'test';
        insert rfq;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Version
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        system.debug('cvList:::'+cvList);
        System.assertEquals(cvList.size(), 1);
        
        //Get Content Documents
        List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :cvList[0].ContentDocumentId];
        system.debug('cdList:::'+cdList);
        System.assertEquals(cdList.size(), 1);
        
        ContentDocumentLink Clink = new ContentDocumentLink();
        Clink.ContentDocumentId=cdList[0].Id;
        Clink.LinkedEntityId=rfq.Id;
        Clink.shareType = 'V';
        insert Clink;
        
        cv.VersionData = Blob.valueOf('Test Content1');
        update cv;
        
        update Clink;
    }
}