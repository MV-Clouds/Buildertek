@isTest
public class PublicFileShareControllerTest {

    @isTest
    static void testGetContentDocuments() {
        // Create test records as needed
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
		// Create a ContentVersion
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.Title = 'Test Content.txt';
        testContentVersion.VersionData = Blob.valueOf('Test Content Body');
        testContentVersion.PathOnClient = 'txt';
        insert testContentVersion;
        
        // Create a ContentDocumentLink related to the test record
        ContentDocumentLink testLink = new ContentDocumentLink(
            LinkedEntityId = testAccount.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :testContentVersion.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert testLink;
        String test0 = 'Test Folder';
        // Create a buildertek__Public_Folder__c
        buildertek__Public_Folder__c pubFolder = new buildertek__Public_Folder__c();
        // pubFolder.Name = 'Test Folder';
        pubFolder.Name = test0;
        insert pubFolder;
                  
        // Get Content Document title
        ContentDocumentLink cdn = [SELECT Id,LinkedEntityId,ContentDocumentId,ShareType,ContentDocument.Title,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE Id = :testLink.Id];
  		String cdtitle = cdn.ContentDocument.Title;
        Id cdNewid = cdn.ContentDocument.LatestPublishedVersionId;
        system.debug('TITLE--->' + cdNewid);
        
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        cdl.add(cdn);
        
        
        // Create a ContentDistribution
        ContentDistribution cd = new ContentDistribution();
        cd.Name = cdtitle;
        cd.ContentVersionId = cdNewid;
		insert cd;
        
        // Create a buildertek__Public_File__c
        buildertek__Public_File__c file = new buildertek__Public_File__c();
		file.buildertek__Content_Distrubution__c = cd.Id;
        file.buildertek__Content_Version__c = cd.ContentVersionId;
        file.buildertek__Public_URL__c = cd.DistributionPublicUrl;
        insert file;
        

        // Create a buildertek__Public_Folder__c
        List<buildertek__Public_Folder__c> pubFlder = new List<buildertek__Public_Folder__c>();
        pubFlder.add(pubFolder);
        system.debug('oubFolder--->' + pubFlder);
        
        List<String> str = new List<string>{String.valueOf(pubFolder.Id)};
        system.debug('STR--->' + str);
        
        // Create a buildertek__Public_File_Folder_Jn__c
        buildertek__Public_File_Folder_Jn__c junctionFolder = new buildertek__Public_File_Folder_Jn__c();
        junctionFolder.buildertek__Public_Folder__c = pubFolder.Id;
        junctionFolder.buildertek__Public_File__c = file.Id;
        insert junctionFolder;
        
        // Call the method to be tested
        Test.startTest();
        List<ContentDocumentLink> result = PublicFileShareController.getContentDocuments(testAccount.Id);
        PublicFileShareController.getFolderList();
        PublicFileShareController.createPublicFolder('Fname','Fdesc');
        PublicFileShareController.getFileFolderJuncData();
        PublicFileShareController.createPublicFileFolderJnc(pubFlder,cdl);
        PublicFileShareController.getAllFileFolderJunctionObj(str);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(1, result.size());
       // System.assertEquals('Test Content', result[0].ContentDocument.Title);
    }
}