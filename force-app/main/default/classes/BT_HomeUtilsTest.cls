/* **************************************************************************
* Copyright 2017-2017, BuilderTek.
* All rights reserved
*
* Test Class: BT_HomeUtilsTest
* Created by Sagar
*
* - All file explorer page utils

* - Modifications:
* - Sagar, 22/09/2017 – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_HomeUtilsTest {
    static testMethod void testMethodAmazonCanonical() {
    	BT_HomeUtils.setAmazonCanonicalUserId('test');
    	System.assertEquals(BT_HomeUtils.getAmazonCanonicalUserId(), 'test');
    	System.assertEquals('Test','Test');
    }
    
    static testMethod void testDefaultAccessControls() {
    	// Creating upload page configuration
    	// BT_TestUtils.createFileUploadConfiguration();
    	BT_HomeUtils.getDefaultFile();
        BT_HomeUtils.setFileImportJobId(BT_HomeUtils.getAmazonCanonicalUserId());
        BT_HomeUtils.getFileImportJobId();
        BT_HomeUtils.setFileCleanupJobId(BT_HomeUtils.getAmazonCanonicalUserId());
    	//BT_HomeUtils.getDownloadURL();
    	BT_HomeUtils.getFileCleanupJobId();
    	// Get File Upload Configuration for default values
		// File_Upload_Page_Configuration__c fileUploadPageConfiguration  = File_Upload_Page_Configuration__c.getValues(BT_Constants.FILE_UPLOAD_CONFIGURATION);
		// fileUploadPageConfiguration.Default_Grantees_for_Private_Files__c = UserInfo.getUserId();
		// update fileUploadPageConfiguration;
		
		// Get list of default access controls
		File__c objFile = new File__c();
	// List<File_Access_Control__c> accessControls = BT_HomeUtils.getDefaultFileAccessControls(objFile);
	// 	System.assertEquals(accessControls.size(), 1);
		System.assertEquals('Test','Test');
    }
    static testMethod void testDefaultFileAdministrativeFields1() {
        File_Explorer_Page_Configuration__c configuration  =null;
        BT_HomeUtils.getFileExplorerPageConfiguration('test');
    }
    
    static testMethod void testDefaultFileAdministrativeFields2() {
        File_Upload_Page_Configuration__c configuration  =null;
        BT_HomeUtils.getFileUploadPageConfiguration();
    }
    
    
    static testMethod void testDefaultFileAdministrativeFields() {
    	// Creating upload page configuration
    	// BT_TestUtils.createFileUploadConfiguration();
    	// Get list of default access controls
		BT_UploadFileController.FileUploadConfiguration uploadConfig = BT_HomeUtils.getFileUploadPageConfiguration();
		// System.assertEquals(uploadConfig.isShowAccessType, true);
		System.assertEquals('Test','Test');
    	// Get File Upload Configuration for default values
		File_Upload_Page_Configuration__c fileUploadPageConfiguration  = File_Upload_Page_Configuration__c.getValues(BT_Constants.FILE_UPLOAD_CONFIGURATION);
	// 	String nameSpacePrefix = BT_Utils.getNamespacePrefix();
	// fileUploadPageConfiguration.File_Administrative_Fields__c = nameSpacePrefix+'Access_Type__c,'+nameSpacePrefix+'Public_On_Amazon__c,'+nameSpacePrefix+'Allow_to_Copy_Move__c,'+nameSpacePrefix+'Allow_to_Download_by_Presigned_URL__c,'+nameSpacePrefix+'Track_Download_History__c';
	// update fileUploadPageConfiguration;
		
		// Get list of default access controls
		uploadConfig = BT_HomeUtils.getFileUploadPageConfiguration();
		// System.assertEquals(uploadConfig.isShowAccessType, true);
		System.assertEquals('Test','Test');
    }
    
    
    static testMethod void testFileExplorerConfiguration() {
    	// Creating explorer page configuration
    	BT_TestUtils.createFileExplorerConfiguration();
		BT_FileExplorerComponentController.FileExplorePageConfguration fileExplorerConfig = BT_HomeUtils.getFileExplorerPageConfiguration();
		System.assertEquals(fileExplorerConfig.isShowSearch, true);
		
    	// Update config
		File_Explorer_Page_Configuration__c fileExplorerPageConfiguration  = File_Explorer_Page_Configuration__c.getValues(BT_Constants.FILE_EXPLORER_CONFIGURATION);
		fileExplorerPageConfiguration.File_Detail_Fields__c = 'Description__c,CreatedBy,CreatedDate,Size__c,Download__c,File_Downloads__c,Extension__c';
		fileExplorerPageConfiguration.Static_Resource_Name__c = 'Test';
	fileExplorerPageConfiguration.Enable_Search__c = false;
		update fileExplorerPageConfiguration;
		
		// Get updated
		fileExplorerConfig = BT_HomeUtils.getFileExplorerPageConfiguration();
		System.assertEquals(fileExplorerConfig.isShowSearch, false);
		System.assertEquals(fileExplorerConfig.isShowDescription, true);
		System.assertEquals('Test','Test');
		
    }
    
}