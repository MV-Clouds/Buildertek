@isTest
public with sharing class Test_NewCheckInBtnController {

    @isTest
    static void testCreateCheckIn() {
        // Create a test Project record  & DropBox foldar

        // String pathURL = '/BLUENEST OFFICE/';
        // DropboxToken__c dtoken = new DropboxToken__c(Name='Dropbox Token',AccessToken__c='f6ti8n7fwty348');
        // insert dtoken;
        // DropboxInfo__c dinfo = new DropboxInfo__c(Name='test',FolderSearchURL__c = 'https://api.dropboxapi.com/2/files/search_v2',ConsumerKey__c='fkuyjregis8',ClientSecret__c='r5tf834638i765384h5',AuthorizationURL__c='tdrfubtretenruyrfyufyhgthf',AccessTokenEndPoint__c='fs7eibtfrcsgnfsdufsejyrfgbe');
        // insert dinfo;
        // DropBoxMapping__c dr = new DropBoxMapping__c(Name='Newly Purchased',Folder_Path__c = 'Homework/Test');
        // insert dr;
        // buildertek__Project__c Project = new buildertek__Project__c(Name='test',Dropbox_Path__c=pathURL, Dropbox_Folder__c='Test', buildertek__Stage__c='Newly Purchased');
        // insert Project;

        // buildertek__Project__c pro1 = new buildertek__Project__c(Name='test1', buildertek__Geolocation__Latitude__s = 39.0162, buildertek__Geolocation__Longitude__s = -94.26, Dropbox_Path__c=pathURL, Dropbox_Folder__c='Test', buildertek__Stage__c='Newly Purchased');
        // insert pro1;

        // Test.startTest();
        // System.debug('Project Id : '+Project.Id);
        // Test.setMock(HttpCalloutMock.class, new DropBoxCalloutMock());
        // String tokenn = 'sl.fgsjfhdsuyfusyvter45hjkfebf7w34gbkfi82wegkiu7fib7ntciw7trfkg78ewrb';
        // String res = DropBoxController.createNewFolder('Test');
        // String expected = '{"entries": [{".tag": "folder", "name": "PROJECTS IN PROGRESS", "path_lower": "/bluenest office/projects in progress", "path_display": "/BLUENEST OFFICE/PROJECTS IN PROGRESS", "id": "id:jJ260QfSPK4AAAAAAAABOg"}], "cursor": "AAH86N0z42ukxHq5bdcyMQ4EFjqQKpji00QhovGoOSBsUT0vhc4X8fPV3lCSZSbkz8xd4yaWEmiT2APQVzWA1ltSFFmm3qOFTjA6usFlezi6P60LkYplojNEMBeBbGS2Iu3dz1wOJ1UcM-QhrZpEuhPnC_w7Wr_d03TnPKgATJ2ADwcVXXiJ07EJ2-sSPUxL8QT4ccY8nH1xcAjBnDkV0gGcjr3PQ1F-DZ3KcvKvc24zGw", "has_more": false}' ;
        // // DropboxToken__C
        // Test.setMock(HttpCalloutMock.class, new DropBoxCalloutMock());
        // String recordId = Project.Id;
        // String pid = Project.Id;
        // String accTok = 'sl.fsgufekusrnbnffdhbjgjdvsbjyurdvfbkgbshvhjsdgfvkusdgfjlr';

        // Dropboxcontroller.folderdetails res2 = DropBoxController.getFolderFromDropbox(pid, tokenn);
        // String expected2 = '{"entries": [{".tag": "folder", "name": "PROJECTS IN PROGRESS", "path_lower": "/bluenest office/projects in progress", "path_display": "/BLUENEST OFFICE/PROJECTS IN PROGRESS", "id": "id:jJ260QfSPK4AAAAAAAABOg"}], "cursor": "AAHK2-lDJnhi4P0oAp5fNKI4AI7rexZCkr2_YhtP0HSgzidlhlRxcx6PtiFTm2u4bcGJ3GdrCAjJG6VWdCEbvVXCnC7DFY-vc2G55xtnbbfcGcx2u5KSBATwwAKXiXO-qAEnitYfa7qx_cj1L3BBsKKN1BnVnjGZeP9mmYD3aa5u18ySc9gUvqL3cx0TYX5N_N-BoazzZWM-VJWSU1oZsdL2uxf4HNK3MUA3GFsx4y1Vkw", "has_more": false}' ;
        
        // String tokenresult = DropboxController.tokenExpired();

        // Map<String,Object> subfolder = DropboxController.createNewSubFolder('Testsub');

        // List<DropboxController.folderItems> getfolder = DropboxController.getFolderDetails('Test', 'dfuyt7bt3nwktfg7ikcr');

        // String download = DropboxController.downloadFileFromDropBox_V1('/fd8enrgbkes78grn');

        // String Upload = DropboxController.uploadFile(pathURL, 'dsk8eryns7cgf348tdgfeks');

        // DropboxController.folderdetails getfolder2 = DropboxController.getFolderFromDropbox_11(Project.Id, 'Testsub', 'Test', 'dkfygfcbsrufnistref');

        // ProjectTriggerHandler.moveFolderGeneric('/Homework/Test', '/Homework/Test2');
        
        // DropboxFutureToken.generatetoken();

        // ---------------------------------------------------

        // ContentVersion cv = new ContentVersion(
        //     Title = 'Test File',
        //     VersionData = Blob.valueOf('Test data'),
        //     PathOnClient = 'test.png',
        //     IsMajorVersion = true
        // );
        // insert cv;

        // Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        // System.debug('CondocId : ' + ConDocId);

        Date todayDate = date.today();
        buildertek__Check_In__c checkIn1 = new buildertek__Check_In__c( 
            Name = 'Check-in 1',
            buildertek__Notes__c = 'Test Notes',
            buildertek__Days_Lost__c = 1,
            buildertek__Reporting_Location__c = '',
            buildertek__Weather__c = '',
            buildertek__Date_Created__c = todayDate
        );
        insert checkIn1;
        
        Test.startTest();
        List<String> nullFileIds = new List<String>();
        String checkInId = NewCheckInBtnController.createCheckIn(checkIn1, nullFileIds);
        String baseUrlOfOrg = NewCheckInBtnController.getOrgBaseURL();
        NewCheckInBtnController.deleteContentVersion(nullFileIds);
        Test.stopTest();
        
    }
}