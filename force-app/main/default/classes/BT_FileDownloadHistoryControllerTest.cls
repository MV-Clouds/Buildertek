/* **************************************************************************
* Copyright 2017-2017, BuilderTek.
* All rights reserved
*
* Test Class:BT_FileDownloadHistoryControllerTest
* Created by thoriyas@gmail.com
*
* - Test class for BT_FileDownloadHistoryController

* - Modifications:
* - thoriyas@gmail.com, 23/09/2017 - Initial Development
************************************************************************** */
@isTest
public with sharing class BT_FileDownloadHistoryControllerTest {

    static testMethod void testFileDownloadHistory() {
        List<Folder__c> bucketFolders = BT_TestUtils.createFoldersForBuckets();
        List<File__c> files = BT_TestUtils.createFiles(bucketFolders[0], Null);
        List<File_Download_History__c> fileDownloadHistory = BT_TestUtils.createFileDownloadHistory(files[0]);
        files[0].Access_Type__c = BT_Constants.FILE_ACCESS_PRIVATE;
        update files[0];
        
        ApexPages.StandardController objStandardController = new ApexPages.StandardController(files[0]);
        ApexPages.currentPage().getParameters().put('retURL', ''); 
        BT_FileDownloadHistoryController con = new BT_FileDownloadHistoryController(objStandardController);
        System.assertEquals(con.fileDownloadHistories.size(), 1);
        
        con.cancel();

	}

}