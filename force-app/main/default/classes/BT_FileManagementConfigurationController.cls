/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Controller Class: BT_FileManagementConfigurationController
* Created by Sagar - 12/09/2017
*
*  This  is controller for managing the files delete and other access.
*
* - Modifications:
* - Sagar – 12/09/2017 - Initial Development
************************************************************************** */
public with sharing class BT_FileManagementConfigurationController {
    public Boolean isError{get; set;}
    public List<String> selectedPermissions {get;set;}
    public List<SelectOption> availablePermissions {get;set;}
    public String allowedPermission {get;set;}
    @TestVisible File_Management_Configuration__c fileManagementConfiguration;
    
    public BT_FileManagementConfigurationController(){
        isError = false;
        selectedPermissions = new List<String>(); 
        availablePermissions = new List<SelectOption>();
        availablePermissions.add(new SelectOption('isOwner',System.Label.Record_Owner)); 
        availablePermissions.add(new SelectOption('hasModifyAll',System.Label.Users_With_Modify_All_Data_Permission)); 
        availablePermissions.add(new SelectOption('hasDelete',System.Label.Anyone_With_Delete_Permission)); 
        
        // Get the File Management Configuration
        Map<String, File_Management_Configuration__c> fileManagementConfigMap = File_Management_Configuration__c.getAll();
        fileManagementConfiguration = fileManagementConfigMap.get(BT_Constants.FILE_MANAGEMENT_CONFIGURATION);
        if(fileManagementConfigMap.size() > 0 && fileManagementConfigMap.get(BT_Constants.FILE_MANAGEMENT_CONFIGURATION) != null){
            allowedPermission = fileManagementConfiguration.Delete_Permissions__c;
        }else{
            fileManagementConfiguration = new File_Management_Configuration__c (Name = BT_Constants.FILE_MANAGEMENT_CONFIGURATION);
        }
        availablePermissionValues();
    }
    
    /*
    *   Purpose:    Initialize the controller
    *   Parameters: 
    *   UnitTests:  
    */
    public void init(){
         try{
             User currentUser;
             if(Schema.sObjectType.User.fields.Id.isAccessible()
                && Schema.sObjectType.Profile.fields.Name.isAccessible()){
                
                currentUser = [Select Id, Profile.Name From User Where Id = :UserInfo.getUserId() LIMIT 1];    
             }
             
            if(currentUser.Profile.Name != 'System Administrator'){
                throw new BT_ApplicationException(System.Label.Page_Access_Error);
            }
        } catch(Exception e){
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            return;
        }
    }
    
    public PageReference save(){
        allowedPermission = '';
        for(String str : selectedPermissions){
            if(allowedPermission == ''){
                allowedPermission = str;    
            } else {
                allowedPermission += ',' + str;
            }
        }
        if(fileManagementConfiguration != null){
            fileManagementConfiguration.Delete_Permissions__c = allowedPermission;
            try{
                DMLManager.upsertAsUser(fileManagementConfiguration);
            }  catch(Exception ex){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
                ApexPages.addMessage(errorMsg);
                return null;
            }
        }
        return null;
    }
    
    // This method is used to display checked and unchecked value after loading page (after constructor called)
    private void availablePermissionValues(){
        if (allowedPermission != null && allowedPermission != '') {
            List<String> listAllowedPermission = BT_Utils.tokenizeStringWithSeparator(allowedPermission,',');
            for (String str: listAllowedPermission) {
                selectedPermissions.add(str);
            }
        }
    }
    
    public PageReference Intialize() {
        clearConfig();
        IntializeConfig();
        selectedPermissions = new List<String>{'hasModifyAll'};
        return null;
    }
        
    public static void clearConfig() {
        SavePoint sp = Database.setSavePoint();
        try{    
           list<File_Management_Configuration__c> filemanagment;
           if(Schema.sObjectType.File_Management_Configuration__c.fields.id.isAccessible()){
           filemanagment = [SELECT Id FROM File_Management_Configuration__c LIMIT 999];
           }
            DMLManager.deleteAsUser(filemanagment);
        } catch(Exception ex){
            Database.rollback(sp);
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            return;
        }
    }
    
    public static void IntializeConfig() {
        File_Management_Configuration__c fileManagementConfiguration = new File_Management_Configuration__c(Name = BT_Constants.FILE_MANAGEMENT_CONFIGURATION);
        fileManagementConfiguration.Delete_Permissions__c = 'hasModifyAll';
        DMLManager.upsertAsUser(fileManagementConfiguration);
    }
}