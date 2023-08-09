/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_FileUploadPageConfigurationController
* Created by Sagar: 26/09/2017
*
* - Page for the configuration needs to be done for file upload page.
*
* - Modifications:
* - Sagar, 26/09/2017 – Initial Development
************************************************************************** */
public with sharing class BT_FileUploadPageConfigurationController {
    public Boolean isError{get; set;}

    public File_Upload_Page_Configuration__c uploadPageConfiguration {get;set;}             //Custom setting for configuration

    public List<SelectOption> leftAvailableAdministrativeFields{get; set;}                             // List of available Grantees on left side.
    public List<SelectOption> rightAvailableAdministrativeFields{get; set;}                            // List of available Grantees on right side.
    public List<String> leftSelectedAdministrativeFields {get; set;}                                   // Selected Grantees from selft side
    public List<String> rightSelectedAdministrativeFields {get; set;}                                  // Selected Grantees from right side

    public List<SelectOption> leftAvailableGrantees{get; set;}                             // List of available Grantees on left side.
    public List<SelectOption> rightAvailableGrantees{get; set;}                            // List of available Grantees on right side.
    public List<String> leftSelectedGrantees {get; set;}                                   // Selected Grantees from selft side
    public List<String> rightSelectedGrantees {get; set;}                                  // Selected Grantees from right side

    public List<SelectOption> presignedURLFrequencyOptions {get; set;}

    public Boolean isFileDownloadHistoryActivate{get; set;}

    public BT_FileUploadPageConfigurationController() {
        isError = false;
        isFileDownloadHistoryActivate = BT_HomeUtils.getIsFileDownloadHistoryActivate();

        // Intializing all lists
        presignedURLFrequencyOptions = BT_Utils.getPickListValues(BT_Constants.OBJECT_TYPE_FILE, 'buildertek__Presigned_URL_Frequency__c');

        leftAvailableGrantees = new List<SelectOption>();
        rightAvailableGrantees = new List<SelectOption>();
        leftSelectedGrantees = new List<String>();
        rightSelectedGrantees = new List<String>();

        leftAvailableAdministrativeFields = new List<SelectOption>();
        rightAvailableAdministrativeFields = new List<SelectOption>();
        leftSelectedAdministrativeFields = new List<String>();
        rightSelectedAdministrativeFields = new List<String>();

        leftAvailableGrantees = getAllGrantees();

        leftAvailableAdministrativeFields = getAllAdministrativeFields();

        // Get the confugration done for file upload
        uploadPageConfiguration  = File_Upload_Page_Configuration__c.getValues(BT_Constants.FILE_UPLOAD_CONFIGURATION);

        // If configuration is not done means we have to create new configration so here we are initializing new configuration
        if(uploadPageConfiguration  == null){
            // Set the name to "Amazon S3"
            uploadPageConfiguration = new File_Upload_Page_Configuration__c(Name = BT_Constants.FILE_UPLOAD_CONFIGURATION);
            // Set Default configuration
            setDefaultConfiguration(uploadPageConfiguration);
        }
        if(uploadPageConfiguration.Default_Grantees_for_Private_Files__c != null){
            leftSelectedGrantees = uploadPageConfiguration.Default_Grantees_for_Private_Files__c.split(',');
        }
        if(uploadPageConfiguration.File_Administrative_Fields__c != null){
            leftSelectedAdministrativeFields = uploadPageConfiguration.File_Administrative_Fields__c.split(',');
        }
        movingGranteesToRight();
        movingAdministrativeFieldsToRight();
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
        Map<String, File_Upload_Page_Configuration__c> fileUploadConfigurationMap = File_Upload_Page_Configuration__c.getAll();

        File_Upload_Page_Configuration__c config = fileUploadConfigurationMap.get(BT_Constants.FILE_UPLOAD_CONFIGURATION);
        if(config == null){
             config  = new File_Upload_Page_Configuration__c(Name = BT_Constants.FILE_UPLOAD_CONFIGURATION);
        }

        // Set Default configuration
        setDefaultConfiguration(config);

        // Insert default config
        DMLManager.upsertAsUser(config);

        uploadPageConfiguration = config;


        // Intializing all lists
        leftAvailableGrantees = new List<SelectOption>();
        rightAvailableGrantees = new List<SelectOption>();
        leftSelectedGrantees = new List<String>();
        rightSelectedGrantees = new List<String>();

        leftAvailableAdministrativeFields = new List<SelectOption>();
        rightAvailableAdministrativeFields = new List<SelectOption>();
        leftSelectedAdministrativeFields = new List<String>();
        rightSelectedAdministrativeFields = new List<String>();



        leftAvailableGrantees = getAllGrantees();
        movingGranteesToRight();

        leftAvailableAdministrativeFields = getAllAdministrativeFields();
        movingAdministrativeFieldsToRight();
    }


    /**************************************************************************
       Purpose: Prepare the select option for Salesforce Access Type field.
       Parameters:
       Returns:
       Throws [Exceptions]:
    ****************************************************************************/
    public static List<SelectOption> getSalesforceAccessTypePickListValue(){
        Schema.sObjectType sobjectType = File__c.getSObjectType();
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = sobjectDescribe.fields.getMap();
        List<Schema.PicklistEntry> pickListValues;
        if(fieldsMap.containsKey('Access_Type__c')){
            pickListValues = fieldsMap.get('Access_Type__c').getDescribe().getPickListValues();
            List<selectOption> options = new List<selectOption>();
            for (Schema.PicklistEntry a : pickListValues) {
                options.add(new selectOption(a.getLabel(), a.getValue()));
            }
            return options;
        }else{
            return null;
        }

    }

    /**************************************************************************
       Purpose: Retrieve the fieldset member list of file fieldset
       Parameters:
       Returns: List of FieldSetMember
       Throws [Exceptions]:
    ****************************************************************************/
    public static List<Schema.FieldSetMember> fileAdministrativeFields() {
        List<Schema.FieldSetMember> fields = BT_Utils.getFieldSetMembers(BT_Utils.getNamespacePrefix()+'File_Fields_For_Upload_Page',BT_Constants.OBJECT_TYPE_FILE);
        return fields;
    }

    /*
    *   Purpose:    Set Default configuration as per selected configuartion type
    *   Parameters:
    *   UnitTests:
    */
    private void setDefaultConfiguration(File_Upload_Page_Configuration__c config){
        String nameSpacePrefix = BT_Utils.getNamespacePrefix();
        config.Default_Allow_Download_by_Presigned_URL__c = true;
        config.Default_Public_on_Amazon__c = false;
        config.Default_Salesforce_Access_Type__c = BT_Constants.FILE_ACCESS_PUBLIC_READ_ONLY;
        config.Default_Track_Download_History__c = true;
        config.Default_Copy_Move__c = true;
        config.Default_Presigned_URL_Frequency__c = 'Every 5 Years';
        config.Default_Grantees_for_Private_Files__c = '';
        config.File_Administrative_Fields__c = nameSpacePrefix+'Access_Type__c,'+nameSpacePrefix+'Public_On_Amazon__c,'+nameSpacePrefix+'Allow_to_Copy_Move__c,'+nameSpacePrefix+'Allow_to_Download_by_Presigned_URL__c,'+nameSpacePrefix+'Track_Download_History__c';
    }

    /*
    *   Purpose:    Get all administrative fields to available to display on file upload
    *   Parameters:
    *   UnitTests:
    */
    public List<SelectOption> getAllAdministrativeFields(){
        List<SelectOption> allAdministrativeFields = new List<SelectOption>();
        for(Schema.FieldSetMember field: fileAdministrativeFields()){
            allAdministrativeFields.add(new SelectOption(field.getFieldPath(), field.getLabel()));
        }
        return allAdministrativeFields;
    }

    /*
    *   Purpose:    Get all fields to available to display on file explorer page
    *   Parameters:
    *   UnitTests:
    */
    public List<SelectOption> getAllGrantees(){
        List<SelectOption> allGrantees = new List<SelectOption>();
        for(User user : [Select Id, Name From User Where Profile.Name != 'System Administrator']){
            allGrantees.add(new SelectOption(user.Id, user.Name));
        }
        return allGrantees;
    }

    /*
    *   Executed:   On click of "<"
    *   Purpose:    When administrative fields will be moved to left this method will be used
    *   Parameters:
    *   UnitTests:
    */
    public void movingAdministrativeFieldsToLeft(){
        rightAvailableAdministrativeFields = BT_Utils.movingSelectOptionsToLeft(rightAvailableAdministrativeFields, rightSelectedAdministrativeFields, leftAvailableAdministrativeFields);
    }

    /*
    *   Executed:   On click of ">"
    *   Purpose:    When administrative fields will be moved to right this method will be used
    *   Parameters:
    *   UnitTests:
    */
    public void movingAdministrativeFieldsToRight(){
        leftAvailableAdministrativeFields = BT_Utils.movingSelectOptionsToRight(leftAvailableAdministrativeFields, leftSelectedAdministrativeFields, rightAvailableAdministrativeFields);
    }

    /*
    *   Executed:   On click of "<"
    *   Purpose:    When grantees will be moved to left this method will be used
    *   Parameters:
    *   UnitTests:
    */
    public void movingGranteesToLeft(){
        rightAvailableGrantees = BT_Utils.movingSelectOptionsToLeft(rightAvailableGrantees, rightSelectedGrantees, leftAvailableGrantees );
    }

    /*
    *   Executed:   On click of ">"
    *   Purpose:    When grantees will be moved to right this method will be used
    *   Parameters:
    *   UnitTests:
    */
    public void movingGranteesToRight(){
        leftAvailableGrantees = BT_Utils.movingSelectOptionsToRight(leftAvailableGrantees, leftSelectedGrantees, rightAvailableGrantees );
    }

    /*
    *   Executed:   On click of "Save"
    *   Purpose:    Save the selected buckets and configuration
    *   Parameters:
    *   UnitTests:
    */
    public pageReference Save() {

        String grantees = '';
        if(rightAvailableGrantees != null && !rightAvailableGrantees.isEmpty()){
            for(SelectOption rightAvailableGrantee : rightAvailableGrantees){
                if(grantees == ''){
                    grantees = rightAvailableGrantee.getValue();
                } else{
                    grantees +=','+rightAvailableGrantee.getValue();
                }
            }
        }
        uploadPageConfiguration.Default_Grantees_for_Private_Files__c = grantees;

        String administrativeFields = '';
        if(rightAvailableAdministrativeFields != null && !rightAvailableAdministrativeFields.isEmpty()){
            for(SelectOption rightAvailableAdministrativeField : rightAvailableAdministrativeFields){
                if(administrativeFields == ''){
                    administrativeFields = rightAvailableAdministrativeField.getValue();
                } else{
                    administrativeFields +=','+rightAvailableAdministrativeField.getValue();
                }
            }
        }
        uploadPageConfiguration.File_Administrative_Fields__c = administrativeFields;

        try{
            DMLManager.upsertAsUser(uploadPageConfiguration);
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