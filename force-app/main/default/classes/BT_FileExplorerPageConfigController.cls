/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_FileExplorerPageConfigController
* Created by Sagar: 06/06/2017
*
* - Page for the confugration needs to be done for AWS. User can create new buckets from here and can also select the buckets needs to used for their salsforce org.

* - Modifications:
* - Sagar, 06/06/2017 – Initial Development
************************************************************************** */
public with sharing class BT_FileExplorerPageConfigController {
    public Boolean isError{get; set;}
    public List<SelectOption> configurations{get; set;}
    public string selectedConfigurationType{get; set;}
    
    public File_Explorer_Page_Configuration__c edConfiguration {get;set;}                                   //Custom setting for configuration
    
    public List<SelectOption> leftAvailableFields{get; set;}                             // List of available customers on left side.
    public List<SelectOption> rightAvailableFields{get; set;}                            // List of available customers on right side.
    public List<String> leftSelectedFields {get; set;}                                   // Selected customers from selft side
    public List<String> rightSelectedFields {get; set;}                                  // Selected customers from right side
    
    public BT_FileExplorerPageConfigController() {
        isError = false;
        
        configurations = new List<SelectOption>(getConfigurations());
        selectedConfigurationType = BT_Constants.FILE_EXPLORER_CONFIGURATION;
        
        // Intializing all lists
        leftAvailableFields = new List<SelectOption>();
        rightAvailableFields = new List<SelectOption>();
        leftSelectedFields = new List<String>();
        rightSelectedFields = new List<String>();
        
        leftAvailableFields = getAllFields();
        
        refreshOnConfigurationChange();
        
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
    
    /*
    *   Purpose:    Initialize the system configuration
    *   Parameters: 
    *   UnitTests:  
    */
    public void initialize(){
        Map<String, File_Explorer_Page_Configuration__c> fileExplorerConfigurationMap = File_Explorer_Page_Configuration__c.getAll();
        
        File_Explorer_Page_Configuration__c config = fileExplorerConfigurationMap.get(selectedConfigurationType);
        if(config == null){
             config  = new File_Explorer_Page_Configuration__c(name=selectedConfigurationType);
        }
        
        // Set Default configuration
        setDefaultConfiguration(config);
        
        DMLManager.upsertAsUser(config);
        
        // Refreshig configuration in UI.
        refreshOnConfigurationChange();
    }
    
    /*
    *   Purpose:    Set Default configuration as per selected configuartion type
    *   Parameters: 
    *   UnitTests:  
    */
    private void setDefaultConfiguration(File_Explorer_Page_Configuration__c config){
        // Show the heirarchical file ui only for File System Tab.
        if(!config.Name.contains('__c')){
            config.Show_Hierarchical_File_UI__c = true;
            config.Show_Header__c = true;
            config.Page_Size__c = 10;
        } else{
            config.Show_Hierarchical_File_UI__c = false;
            config.Show_Header__c = false;
            config.Page_Size__c = 5;
        }
        
        // Set other fields to default value.
        config.Max_Search_Records__c = 1000;
        config.Max_Sub_Folders_Files_Count__c = 100;
        config.Enable_Search__c = true;
        config.Show_Breadcrumb__c = true;
        config.Show_Related_Files_Folders__c = false;
        config.Enable_Mass_Actions__c = true;
        config.File_Detail_Fields__c = 'Name,Description__c,CreatedBy,CreatedDate,Size__c,Download__c,Extension__c';
        // Check if the download tracking is enabled. If it is then also display the link for donwloads
        if(BT_HomeUtils.getIsFileDownloadHistoryActivate()){
            config.File_Detail_Fields__c += ',File_Downloads__c';
        }
    }
    
    /*
    *   Purpose:    Get all file explorer configurations and preapre the list for them
    *   Parameters: 
    *   UnitTests:  
    */
    private List<SelectOption> getConfigurations(){
        List<SelectOption> configurations = new List<SelectOption>();
        Set<String> fileExplorerConfigurations = File_Explorer_Page_Configuration__c.getAll().keySet();
        for(String config : fileExplorerConfigurations){
            configurations.add(new SelectOption(config, config));
        }
        if(!fileExplorerConfigurations.contains(BT_Constants.FILE_EXPLORER_CONFIGURATION)){
            configurations.add(new SelectOption(BT_Constants.FILE_EXPLORER_CONFIGURATION, BT_Constants.FILE_EXPLORER_CONFIGURATION));
        }
        List<Schema.SObjectField> parentsForFolder = BT_HomeUtils.getAllParentsForFolder();
        for(Schema.SObjectField objSchemaField: parentsForFolder) {
            Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
            if(!fileExplorerConfigurations.contains(objFieldDescribe.getName())){
                configurations.add(new SelectOption(objFieldDescribe.getName(), objFieldDescribe.getLabel()));
            }
        }
        return configurations;
    }
    
    /*
    *   Purpose:    Refreshes the select lists for fields for file detail
    *   Parameters: 
    *   UnitTests:  
    */
    public void refreshOnConfigurationChange(){
        // Intializing all lists
        leftAvailableFields = new List<SelectOption>();
        rightAvailableFields = new List<SelectOption>();
        leftSelectedFields = new List<String>();
        rightSelectedFields = new List<String>();
        
        leftAvailableFields = getAllFields();
        
        // Get the confugration done for Amazon S3
        edConfiguration  = File_Explorer_Page_Configuration__c.getValues(selectedConfigurationType);
        
        // If configuration is not done means we have to create new configration so here we are initializing new configuration
        if(edConfiguration  == null){
            // Set the name to "Amazon S3"
            edConfiguration = new File_Explorer_Page_Configuration__c(Name = selectedConfigurationType);
            // Set Default configuration
            setDefaultConfiguration(edConfiguration);
        }
        
        if(edConfiguration.File_Detail_Fields__c != null){
            leftSelectedFields = edConfiguration.File_Detail_Fields__c.split(',');
        }
        movingFieldsToRight();
        return;
    }
    
    /*
    *   Purpose:    Get all fields to available to display on file explorer page
    *   Parameters: 
    *   UnitTests:  
    */
    public List<SelectOption> getAllFields(){
        List<SelectOption> allFields = new List<SelectOption>();
        allFields.add(new SelectOption('Description__c', 'Description'));
        allFields.add(new SelectOption('Extension__c', 'Extension'));
        allFields.add(new SelectOption('CreatedBy', 'Created By'));
        allFields.add(new SelectOption('CreatedDate','Created Date'));
        allFields.add(new SelectOption('Size__c','Size'));
        allFields.add(new SelectOption('Download__c', 'Download'));
        if(BT_HomeUtils.getIsFileDownloadHistoryActivate()){
            allFields.add(new SelectOption('File_Downloads__c', 'Total Downloads'));
        }
        return allFields;
    }
    
    /*
    *   Executed:   On click of ">"
    *   Purpose:    When fields will be moved to left this method will be used
    *   Parameters: 
    *   UnitTests:  
    */
    public void movingFieldsToLeft(){
        rightAvailableFields = BT_Utils.movingSelectOptionsToLeft(rightAvailableFields, rightSelectedFields, leftAvailableFields );
    } 
    
    /*
    *   Executed:   On click of ">"
    *   Purpose:    When fields will be moved to right this method will be used
    *   Parameters: 
    *   UnitTests:  
    */
    public void movingFieldsToRight(){
        leftAvailableFields = BT_Utils.movingSelectOptionsToRight(leftAvailableFields, leftSelectedFields, rightAvailableFields );
    }
    /*
    *   Executed:   On click of "Save"
    *   Purpose:    Save the selected buckets and configuration
    *   Parameters: 
    *   UnitTests:  
    */
    public pageReference Save() {
        if(edConfiguration.Max_Search_Records__c != null && edConfiguration.Max_Search_Records__c > 1000){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Max Search Records cannot be greater than 1000.');
            ApexPages.addMessage(errorMsg);
            return null;
        }
        if(edConfiguration.Max_Sub_Folders_Files_Count__c != null && edConfiguration.Max_Sub_Folders_Files_Count__c > 100){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Max Sub folders/files Count cannot be greater than 100.');
            ApexPages.addMessage(errorMsg);
            return null;
        }
        if(edConfiguration.Static_Resource_Name__c != null && edConfiguration.Static_Resource_Name__c.trim() != ''){
            List<StaticResource> staticResources;
            if(Schema.sObjectType.StaticResource.fields.Id.isAccessible() &&
            Schema.sObjectType.StaticResource.fields.Name.isAccessible()){
                staticResources = [Select Id From StaticResource Where Name =: edConfiguration.Static_Resource_Name__c LIMIT 1];    
            }
            if(staticResources.isEmpty()){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Static Resource Name:  \''+edConfiguration.Static_Resource_Name__c+'\' doesn\'t exist.');
                ApexPages.addMessage(errorMsg);
                return null;
            }
        }
        
        String fields = '';
        if(rightAvailableFields != null && !rightAvailableFields.isEmpty()){
            for(SelectOption rightAvailableField : rightAvailableFields){
                if(fields == ''){
                    fields = rightAvailableField.getValue();
                } else{
                    fields +=','+rightAvailableField.getValue();
                }
            }
        }
        edConfiguration.File_Detail_Fields__c = fields;
        
        if(selectedConfigurationType.contains('__c')){
            edConfiguration.Show_Hierarchical_File_UI__c = false;
            edConfiguration.Show_Header__c = false;
        }
        try{
            DMLManager.upsertAsUser(edConfiguration);
        } catch(Exception ex){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            return null;
        }
        return null;
    }
    
    /*
    *   Executed:   On click of "Cancel"
    *   Purpose:    User will be redirected to home page
    *   Parameters: 
    *   UnitTests:  
    */
    public pageReference Cancel() {
        return new pageReference('/home/home.jsp');    
    }
}