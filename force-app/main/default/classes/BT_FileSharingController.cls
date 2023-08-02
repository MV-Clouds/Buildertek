/* **************************************************************************
* Copyright 2017-2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_FileSharingController
* Created by Sagar
*
* - Manages sharing of file.

* - Modifications:
* - Sagar, 19/09/2017 – Initial Development
************************************************************************** */
public with sharing class BT_FileSharingController {
    // Selected File Record
    File__c objFile;
    
    public String retURL{get;set;}
    
	// Flag for Modify all permission
	public Boolean isHasModifyAllermissionForFile{get; set;}
	
	public List<File_Access_Control__c> fileAccessControls{get; set;}
	
	// List of access levels
	public List<SelectOption> accessLevelOptions{get; set;}       
	public String selectedAccessLevel{get; set;}
	
	// List of grantees
	public List<SelectOption> leftAvailableGrantees{get; set;}                             // List of available grantess on left side.
    public List<SelectOption> rightAvailableGrantees{get; set;}                            // List of available grantess on right side.
    public List<String> leftSelectedGrantees {get; set;}                                   // Selected grantess from selft side
    public List<String> rightSelectedGrantees {get; set;}                                  // Selected grantess from right side
    
	public Boolean isError{get; set;}
	public Boolean isShowFileSharingList{get; set;}
	
    public BT_FileSharingController(ApexPages.StandardController objStandardController){
        accessLevelOptions = new List<SelectOption>{new SelectOption('Download', System.Label.Download), new SelectOption('View', System.Label.View)};
        selectedAccessLevel = 'Download';
        
        isError = false;
        isShowFileSharingList = false;
        isHasModifyAllermissionForFile = BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FILE);
		fileAccessControls = new List<File_Access_Control__c>();
		retURL = ApexPages.currentPage().getParameters().get('retURL').escapeHtml4();
		
		// Add all lookup fields
        if(!Test.isRunningTest()){
        	objStandardController.addFields(new List<String>{'OwnerId', BT_Utils.getNamespacePrefix()+'Access_Type__c'});
        }
        
		objFile = (File__c)objStandardController.getRecord();

		if(objFile.OwnerId == UserInfo.getUserId() || isHasModifyAllermissionForFile){
			if(objFile.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE){
				isShowFileSharingList = true;
				fileAccessControls = getFileAccessControls(objFile.Id);
			} else{
			    isError = true;
			    isShowFileSharingList = false;
			    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.Sharing_For_Non_Private_File_Warning));
			}
		} else{
		    isError = true;
		    isShowFileSharingList = false;
		    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.Non_Owner_Sharing_For_Private_File_Warning));
		}
    }
    
    /*
    *   Purpose:    Get file access controls for file
    *   Parameters: 
    *   UnitTests:  
    */
    public static List<File_Access_Control__c> getFileAccessControls(Id fileId){
        List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
        List<String> fields = new List<String>{'Id', 'Grantee__c', 'Download__c', 'View__c'};
    	SOQLManager.checkFieldAccess(File_Access_Control__c.sObjectType, fields);
	    fileAccessControls = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File_Access_Control__c Where File__c =: fileId'));
		return fileAccessControls;
    }
    
    /*
    *   Purpose:    Add more file access controls
    *   Parameters:
    *   UnitTests:  
    */
    public void addFileAccessControls(){
        leftAvailableGrantees = new List<SelectOption>();
        rightAvailableGrantees = new List<SelectOption>();
        leftSelectedGrantees = new List<String>();
        rightSelectedGrantees = new List<String>();
        
        Set<Id> existingGrantees = new Set<Id>();
        for(File_Access_Control__c fileAccessControl : fileAccessControls){
            existingGrantees.add(fileAccessControl.Grantee__c);
        }
        List<User> activeUsers;
        if(Schema.sObjectType.User.fields.Id.isAccessible()
            && Schema.sObjectType.User.fields.Name.isAccessible()){
            
            activeUsers = [Select Id, Name from User Where Id NOT IN : existingGrantees order by Name LIMIT 1000];    
        }
        
        if(!activeUsers.isEmpty()){
            for(User user : activeUsers ){
                leftAvailableGrantees.add(new SelectOption(user.Id, user.Name));
            }
        }
        isShowFileSharingList = false;
    }
    
    /*
    *   Purpose:    Save file access controls
    *   Parameters:
    *   UnitTests:  
    */
    public void saveFileAccessControls(){
        List<File_Access_Control__c> fileAccessControlToInsert = new List<File_Access_Control__c>();
        for (SelectOption rightAvailableGrantee : rightAvailableGrantees) {
                File_Access_Control__c objAccessControl = new File_Access_Control__c(File__c = objFile.Id);
				objAccessControl.Grantee__c = rightAvailableGrantee.getValue();
				objAccessControl.Download__c = selectedAccessLevel == 'Download';
				objAccessControl.View__c =  selectedAccessLevel == 'View';
				fileAccessControlToInsert.add(objAccessControl);
		}
		if (!fileAccessControlToInsert.isEmpty()) {
    		try{
                DMLManager.upsertAsUser(fileAccessControlToInsert);
            } catch(Exception ex){
            	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            	ApexPages.addMessage(errorMsg);
            	isShowFileSharingList = false;
            	return;
            }
		}
		
		fileAccessControls = getFileAccessControls(objFile.Id);
        isShowFileSharingList = true;
    }
    
    /*
    *   Purpose:    Delete file access controls
    *   Parameters:
    *   UnitTests:  
    */
    public void deleteAccessControl(){
        try{
        	String accessControlId = ApexPages.currentPage().getParameters().get('accessControlId');
        	File_Access_Control__c fieldacess;
        	if(Schema.sObjectType.File_Access_Control__c.fields.id.isAccessible()){
        	fieldacess = [Select Id from File_Access_Control__c Where Id =: accessControlId];
        }
			DMLManager.deleteAsUser(fieldacess);
			// Update the list of file access controls
            fileAccessControls = getFileAccessControls(objFile.Id);
            isShowFileSharingList = true;
			return;
        } catch(System.CalloutException callout){
			ApexPages.addMessages(callout);
			return;  
		} catch(Exception ex){
           ApexPages.addMessages(ex);
           return; 
        }
    }
    
    /*
    *   Purpose:    When grantees will be moved to left this method will be used
    *   Parameters: 
    *   UnitTests:  
    */
    public void movingGranteesToLeft(){
        rightAvailableGrantees = BT_Utils.movingSelectOptionsToLeft(rightAvailableGrantees, rightSelectedGrantees, leftAvailableGrantees);
    } 
    
    /*
    *   Purpose:    When grantees will be moved to right this method will be used
    *   Parameters: 
    *   UnitTests:  
    */
    public void movingGranteesToRight(){
        leftAvailableGrantees = BT_Utils.movingSelectOptionsToRight(leftAvailableGrantees, leftSelectedGrantees, rightAvailableGrantees );
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