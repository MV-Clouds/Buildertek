/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_FileAdministratorController
* Created by Sagar: 23/09/2017
*
* File Administartor

* - Modifications:
* - Sagar, 23/09/2017 – Initial Development
************************************************************************** */
public with sharing  class BT_FileAdministratorController {
    public File__c objFile{get; set;}
    
    public String retURL{get;set;}
    
    // Flag for Modify all permission
	public Boolean isHasModifyAllermissionForFile{get; set;}
	
	public Boolean isFileDownloadHistoryActivate{get; set;}
	
	public Boolean isError{get; set;}
	public Boolean isSuccess{ get; set;}
    //========================================================//
    // Constructor
    //========================================================//
    public BT_FileAdministratorController(ApexPages.StandardController objStandardController){
        isError = false;
        isSuccess = false;
        isFileDownloadHistoryActivate = BT_HomeUtils.getIsFileDownloadHistoryActivate();
        isHasModifyAllermissionForFile = BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FILE);
		retURL = ApexPages.currentPage().getParameters().get('retURL').escapeHtml4();
		
        // Add all lookup fields
        if(!Test.isRunningTest()){
        	objStandardController.addFields(new List<String>{'OwnerId', 'Access_Type__c', 'Allow_to_Copy_Move__c', 'Public_On_Amazon__c', 'Allow_to_Download_by_Presigned_URL__c', 'Track_Download_History__c', 'Presigned_URL_Frequency__c'});
        }
        
		objFile = (File__c)objStandardController.getRecord();

		if(objFile.OwnerId != UserInfo.getUserId() && !isHasModifyAllermissionForFile){
		    isError = true;
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.Non_Owner_File_Administration_Warning));
		}
    }
    
    /**************************************************************************
       Purpose: Save file administartive fields
       Parameters:
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    public PageReference save(){
        isSuccess = false;
        try{
            DMLManager.updateAsUser(new List<File__c>{objFile});
        } catch(Exception ex){
        	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
        	ApexPages.addMessage(errorMsg);
        	return null;
        }
        isSuccess = true;
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
    
    /*
    *   Purpose:    Cancel page
    *   Parameters: 
    *   UnitTests:  
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