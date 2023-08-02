/* **************************************************************************
* Copyright 2017-2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_FileDownloadHistoryController
* Created by Sagar: 05/09/2017
*
* - Page for download history of file.

* - Modifications:
* - Sagar, 05/09/2017 – Initial Development
************************************************************************** */
public with sharing class BT_FileDownloadHistoryController {
    // Selected File Record
    File__c objFile;
    
    public String retURL{get;set;}
    
    // File download history
    public transient List<File_Download_History__c> fileDownloadHistories{get; set;}
	
	// Flag for Modify all permission
	public Boolean isHasModifyAllermissionForFile{get; set;}
	
	public Boolean isShowFileDownloadHistory{get; set;}
    
    //========================================================//
    // Constructor
    //========================================================//
    public BT_FileDownloadHistoryController(ApexPages.StandardController objStandardController){
		isShowFileDownloadHistory = false;
        isHasModifyAllermissionForFile = BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FILE);
		fileDownloadHistories = new List<File_Download_History__c>();
		retURL = ApexPages.currentPage().getParameters().get('retURL').escapeHtml4();
		
		// Add all lookup fields
        if(!Test.isRunningTest()){
        	objStandardController.addFields(new List<String>{'OwnerId', BT_Utils.getNamespacePrefix()+'Track_Download_History__c', BT_Utils.getNamespacePrefix()+'Access_Type__c'});
        }
        
		objFile = (File__c)objStandardController.getRecord();
		
		if(objFile.OwnerId == UserInfo.getUserId() || isHasModifyAllermissionForFile){
			// Check for Global confuguration and File field
			if(objFile.Track_Download_History__c){
				isShowFileDownloadHistory = true;
				if(Schema.sObjectType.File_Download_History__c.fields.Id.isAccessible()
				    && Schema.sObjectType.File_Download_History__c.fields.DownloadedBy__c.isAccessible()
				    && Schema.sObjectType.File_Download_History__c.fields.DownloadedDate__c.isAccessible()
				    && Schema.sObjectType.File_Download_History__c.fields.Type__c.isAccessible()){
				    
				    fileDownloadHistories = [Select Id, DownloadedBy__c, DownloadedDate__c, Type__c From File_Download_History__c Where File__c =: objFile.Id order by createddate desc];        
				}
			}
		}
    }
    
    /*
    Cancel page
    */
    public PageReference cancel(){
        if(BT_Utils.isLightning()){
            return null;
        }
        if(retURL != null){
            if(retURL.startsWith('/')){
                retURL = retURL.replaceFirst('/', '');    
            }
            return new PageReference('/'+retURL);
        } else{
        	return new PageReference('/'+objFile.Id);
        }
    }
}