/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Util Class: BT_HomeUtils
* Created by Sagar
*
* - All file explorer page utils

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_HomeUtils {
    /*
    *   Purpose:    Returns download url for file
    *   Parameters: 
    */
    public static string getDownloadURL(Sobject file){
        string downloadUrl = '';
        if((!Boolean.valueOf(file.get('Public_On_Amazon__c')) && !Boolean.valueOf(file.get('Allow_to_Download_by_Presigned_URL__c'))) || (file.get('OwnerId') != UserInfo.getUserId() &&  Boolean.valueOf(file.get('Track_Download_History__c')))){
            downloadUrl = new PageReference('/apex/BT_FileDetail').getUrl()+'?cleanId='+ file.get('Id');
        } else{
            downloadUrl = String.valueOf(file.get('File_Presigned_URL__c'));
        }
        return downloadUrl;
    }
    
    /*
    *   Purpose:    Get file cleanup job id
    *   Parameters: 
    */
    public static String getFileCleanupJobId(){
        return BT_Utils.getApplicationConfigurationValue(BT_Constants.FILE_CLEANUP_JOBID);
    }
    
    /*
    *   Purpose:    Set file cleanup job id
    *   Parameters: 
    */
    public static void setFileCleanupJobId(String jobId){
        Map<String, Application_Configuration__c> appConfigurationMap = Application_Configuration__c.getAll();
        Application_Configuration__c config = appConfigurationMap.get(BT_Constants.FILE_CLEANUP_JOBID);
        if(config == null){
            config = new Application_Configuration__c(Name = BT_Constants.FILE_CLEANUP_JOBID);  
        }
        config.Configured_Value__c = jobId;
        DMLManager.upsertAsUser(config);
        return;
    }
    
    /*
    *   Purpose:    Get file import job id
    *   Parameters: 
    */
    public static String getFileImportJobId(){
        return BT_Utils.getApplicationConfigurationValue(BT_Constants.FILE_IMPORT_JOBID);
    }
    
    /*
    *   Purpose:    Set file Import job id
    *   Parameters: 
    */
    public static void setFileImportJobId(String jobId){
        Map<String, Application_Configuration__c> appConfigurationMap = Application_Configuration__c.getAll();
        Application_Configuration__c config = appConfigurationMap.get(BT_Constants.FILE_IMPORT_JOBID);
        if(config == null){
            config = new Application_Configuration__c(Name = BT_Constants.FILE_IMPORT_JOBID);   
        }
        config.Configured_Value__c = jobId;
        DMLManager.upsertAsUser(config);
        return;
    }
    
    /*
    *   Purpose:    Get canonical user id
    *   Parameters: 
    */
    public static String getAmazonCanonicalUserId(){
        return BT_Utils.getApplicationConfigurationValue(BT_Constants.AMAZON_CANONICAL_USERID);
    }
    
    /*
    *   Purpose:    Set canonical user id
    *   Parameters: 
    */
    public static void setAmazonCanonicalUserId(String amazonCanonicalUserId){
        Map<String, Application_Configuration__c> appConfigurationMap = Application_Configuration__c.getAll();
        Application_Configuration__c config = appConfigurationMap.get(BT_Constants.AMAZON_CANONICAL_USERID);
        if(config == null){
            config = new Application_Configuration__c(Name = BT_Constants.AMAZON_CANONICAL_USERID); 
        }
        config.Configured_Value__c = amazonCanonicalUserId;
        DMLManager.upsertAsUser(config);
        return;
    }
    
    /*
    *   Purpose:    Returns true if the file download history uis enabled
    *   Parameters: 
    */
    public static Boolean getIsFileDownloadHistoryActivate(){
        return BT_Utils.getApplicationConfigurationBooleanValue(BT_Constants.ENABLE_FILE_DOWNLOAD_HISTORY);
    }
    
    /*
    *   Purpose:    Returns list of all lookup fields which are used as parent record
    *   Parameters: 
    */
    public static List<Schema.SObjectField> getAllParentsForFolder(){
        List<Schema.SObjectField> parentsForFolder = new List<Schema.SObjectField>();
        Map<String, Schema.SObjectField> mapSchemaFields = Schema.getGlobalDescribe().get(BT_Constants.OBJECT_TYPE_FOLDER).getDescribe().fields.getMap();
        for(Schema.SObjectField objSchemaField: mapSchemaFields.Values()) {
            Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
            if(objFieldDescribe.getType() == Schema.DisplayType.REFERENCE && objFieldDescribe.getName() != 'OwnerId' && objFieldDescribe.getName() != 'LastModifiedById' && objFieldDescribe.getName() != 'CreatedById' && objFieldDescribe.getName() != BT_Utils.getNamespacePrefix()+'Parent__c' && objFieldDescribe.getName() != BT_Utils.getNamespacePrefix()+'Source_Folder__c' && objFieldDescribe.getName() != BT_Utils.getNamespacePrefix()+'Source_File__c') {
                parentsForFolder.add(objSchemaField);
            }
        }
        return parentsForFolder;
    }
    
    /*
    *   Purpose:    Returns default file from File Upload Configuratgion
    *   Parameters: 
    */
    public static File__c getDefaultFile(){
        File__c objFile = new File__c(Public_On_Amazon__c = false, Allow_to_Download_by_Presigned_URL__c = true);
        
        // Get File Upload Configuration for default values
        File_Upload_Page_Configuration__c fileUploadPageConfiguration  = File_Upload_Page_Configuration__c.getValues(BT_Constants.FILE_UPLOAD_CONFIGURATION);
        
        if(fileUploadPageConfiguration != null){
             if(Schema.sObjectType.File__c.fields.Track_Download_History__c.isCreateable() && Schema.sObjectType.File__c.fields.Allow_to_Download_by_Presigned_URL__c.isCreateable()
                && Schema.sObjectType.File__c.fields.Access_Type__c.isCreateable() && Schema.sObjectType.File__c.fields.Public_On_Amazon__c.isCreateable() 
                && Schema.sObjectType.File__c.fields.Allow_to_Copy_Move__c.isCreateable() && Schema.sObjectType.File__c.fields.Presigned_URL_Frequency__c.isCreateable()){
                    
                objFile.Allow_to_Download_by_Presigned_URL__c = fileUploadPageConfiguration.Default_Allow_Download_by_Presigned_URL__c;
                objFile.Public_On_Amazon__c = fileUploadPageConfiguration.Default_Public_on_Amazon__c;
                objFile.Access_Type__c = fileUploadPageConfiguration.Default_Salesforce_Access_Type__c;
                objFile.Allow_to_Copy_Move__c = fileUploadPageConfiguration.Default_Copy_Move__c;
                objFile.Presigned_URL_Frequency__c = fileUploadPageConfiguration.Default_Presigned_URL_Frequency__c;
                if(BT_HomeUtils.getIsFileDownloadHistoryActivate()){
                    objFile.Track_Download_History__c = fileUploadPageConfiguration.Default_Track_Download_History__c;
                }
            }
        } else{
            if(Schema.sObjectType.File__c.fields.Track_Download_History__c.isCreateable() && Schema.sObjectType.File__c.fields.Allow_to_Download_by_Presigned_URL__c.isCreateable()
                && Schema.sObjectType.File__c.fields.Access_Type__c.isCreateable() && Schema.sObjectType.File__c.fields.Public_On_Amazon__c.isCreateable() 
                && Schema.sObjectType.File__c.fields.Allow_to_Copy_Move__c.isCreateable() && Schema.sObjectType.File__c.fields.Presigned_URL_Frequency__c.isCreateable()){
                    
                objFile.Allow_to_Download_by_Presigned_URL__c = true;
                objFile.Public_On_Amazon__c = false;
                objFile.Access_Type__c = BT_Constants.FILE_ACCESS_PRIVATE;
                objFile.Allow_to_Copy_Move__c = true;
                objFile.Presigned_URL_Frequency__c = BT_Constants.PRESIGNED_URL_FREQUENCY_EVERY_WEEK;
                if(BT_HomeUtils.getIsFileDownloadHistoryActivate()){
                    objFile.Track_Download_History__c = true;
                }
            }
        }
        return objFile;
    }
    
    /*
    *   Purpose:    Returns default file access controls from File Upload Configuratgion
    *   Parameters: 
    */
    public static List<File_Access_Control__c> getDefaultFileAccessControls(File__c file){
        List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
        
        // Get File Upload Configuration for default values
        File_Upload_Page_Configuration__c fileUploadPageConfiguration  = File_Upload_Page_Configuration__c.getValues(BT_Constants.FILE_UPLOAD_CONFIGURATION);
        
        // Set default file access controls
        if(fileUploadPageConfiguration.Default_Grantees_for_Private_Files__c != null && fileUploadPageConfiguration.Default_Grantees_for_Private_Files__c != ''){
            List<String> defaultGranteeIds = fileUploadPageConfiguration.Default_Grantees_for_Private_Files__c.split(',');
            for(String granteeId : defaultGranteeIds){
                fileAccessControls.add(new File_Access_Control__c(Grantee__c = granteeId, File__c = file.Id, Download__c = true, View__c = true));
            }
        }
        return fileAccessControls;
    }
    
    /*
    *   Purpose:    Returns File Explorer Configuratgion
    *   Parameters: 
    */
    public static BT_UploadFileController.FileUploadConfiguration getFileUploadPageConfiguration(){
        BT_UploadFileController.FileUploadConfiguration fileUploadPageConfiguration = new BT_UploadFileController.FileUploadConfiguration();
        
        // Get File Upload Configuration for default values
        File_Upload_Page_Configuration__c configuration  = File_Upload_Page_Configuration__c.getValues(BT_Constants.FILE_UPLOAD_CONFIGURATION);
        
        if(configuration  != null){
            if(configuration.File_Administrative_Fields__c != null){
                List<String> fields = configuration.File_Administrative_Fields__c.split(',');
                String nameSpacePrefix = BT_Utils.getNamespacePrefix();
                for(String field : fields){
                    if(field == nameSpacePrefix+'Access_Type__c'){
                        fileUploadPageConfiguration.isShowAccessType = true;
                    }
                    if(field == nameSpacePrefix+'Public_On_Amazon__c'){
                        fileUploadPageConfiguration.isShowPublicOnAmazon = true;
                    }
                    if(field == nameSpacePrefix+'Allow_to_Copy_Move__c'){
                        fileUploadPageConfiguration.isShowAllowCopy = true;
                    }
                    if(field == nameSpacePrefix+'Allow_to_Download_by_Presigned_URL__c'){
                        fileUploadPageConfiguration.isShowAllowShareViaPresignedURL = true;
                    }
                    if(field == nameSpacePrefix+'Track_Download_History__c' && getIsFileDownloadHistoryActivate()){
                        fileUploadPageConfiguration.isShowTrackDownload = true;
                    }
                }
            }
        } else{
            fileUploadPageConfiguration.isShowAccessType = false;
            fileUploadPageConfiguration.isShowPublicOnAmazon = false;
            fileUploadPageConfiguration.isShowAllowCopy = false;
            fileUploadPageConfiguration.isShowAllowShareViaPresignedURL = false;
            fileUploadPageConfiguration.isShowTrackDownload = false;
        }
        
        fileUploadPageConfiguration.isShowSettings = fileUploadPageConfiguration.isShowPublicOnAmazon || fileUploadPageConfiguration.isShowAllowCopy || fileUploadPageConfiguration.isShowAllowShareViaPresignedURL || fileUploadPageConfiguration.isShowTrackDownload;
        return fileUploadPageConfiguration;
    }
    
    /*
    *   Purpose:    Returns Global File Explorer Configuratgion
    *   Parameters: 
    */
    public static BT_FileExplorerComponentController.FileExplorePageConfguration getFileExplorerPageConfiguration(){
        return getFileExplorerPageConfiguration(BT_Constants.FILE_EXPLORER_CONFIGURATION);
    }
    
    /*
    *   Purpose:    Returns File Explorer Configuratgion
    *   Parameters: 
    */
    public static BT_FileExplorerComponentController.FileExplorePageConfguration getFileExplorerPageConfiguration(String configurationName){
        BT_FileExplorerComponentController.FileExplorePageConfguration fileExplorerPageConfiguration = new BT_FileExplorerComponentController.FileExplorePageConfguration();
        configurationName = (configurationName != null && configurationName != '' ? configurationName : BT_Constants.FILE_EXPLORER_CONFIGURATION);
        //Get the confugration done for Amazon S3
        File_Explorer_Page_Configuration__c configuration  = File_Explorer_Page_Configuration__c.getValues(configurationName);
        
        //If configuration is not done means we have to create new configration so here we are initializing new configuration
        if(configuration  != null){
            if(configuration.File_Detail_Fields__c != null){
                List<String> fields = configuration.File_Detail_Fields__c.split(',');
                for(String field : fields){
                    if(field == 'Description__c'){
                        fileExplorerPageConfiguration.isShowDescription = true;
                    }
                    if(field == 'CreatedBy'){
                        fileExplorerPageConfiguration.isShowCreatedBy = true;
                    }
                    if(field == 'CreatedDate'){
                        fileExplorerPageConfiguration.isShowCreatedDate = true;
                    }
                    if(field == 'Size__c'){
                        fileExplorerPageConfiguration.isShowSize = true;
                    }
                    if(field == 'Download__c'){
                        fileExplorerPageConfiguration.isShowDownload = true;
                    }
                    if(field == 'File_Downloads__c'){
                        fileExplorerPageConfiguration.isShowFileDownloads = true;
                    }
                    if(field == 'Extension__c'){
                        fileExplorerPageConfiguration.isShowExtension = true;
                    }
                }
            }
            fileExplorerPageConfiguration.isShowSearch = configuration.Enable_Search__c;
            fileExplorerPageConfiguration.isShowBreadcrumb = configuration.Show_Breadcrumb__c;
            fileExplorerPageConfiguration.isShowMassActions = configuration.Enable_Mass_Actions__c;
            fileExplorerPageConfiguration.isShowExtensionIcon = configuration.Show_Extension_Icon__c;
            fileExplorerPageConfiguration.isShowHeader = configuration.Show_Header__c;
            fileExplorerPageConfiguration.homeFolders = configuration.Home_Folder__c;
            if(configuration.Static_Resource_Name__c != null && configuration.Static_Resource_Name__c.trim() != ''){
                 List<StaticResource> staticResources;
                 if(Schema.sObjectType.StaticResource.fields.id.isAccessible()){
                    staticResources = [Select Id From StaticResource where Name =: configuration.Static_Resource_Name__c LIMIT 1];    
                 }
                 if(!staticResources.isEmpty()){
                     fileExplorerPageConfiguration.fileExtensionIconStaticResourceName = configuration.Static_Resource_Name__c;
                 } else{
                     fileExplorerPageConfiguration.fileExtensionIconStaticResourceName = getDefaultStaticResourceName();
                 }
            } else{
                fileExplorerPageConfiguration.fileExtensionIconStaticResourceName = getDefaultStaticResourceName();
            }
            fileExplorerPageConfiguration.isShowHirarchicalFileUI = configuration.Show_Hierarchical_File_UI__c;
            if(configurationName == BT_Constants.FILE_EXPLORER_CONFIGURATION){
                fileExplorerPageConfiguration.isShowRelatedFiles = configuration.Show_Related_Files_Folders__c;
            }
            fileExplorerPageConfiguration.pageSize = configuration.Page_Size__c != null ? Integer.valueOf(configuration.Page_Size__c) : 10;
            fileExplorerPageConfiguration.maxSearchRecords = configuration.Max_Search_Records__c != null ? Integer.valueOf(configuration.Max_Search_Records__c) : 1000;
            fileExplorerPageConfiguration.maxInnerItemsCount = configuration.Max_Sub_Folders_Files_Count__c != null ? Integer.valueOf(configuration.Max_Sub_Folders_Files_Count__c) : 100;
            
        } else{
            fileExplorerPageConfiguration.isShowDescription = true;
            fileExplorerPageConfiguration.isShowCreatedBy = true;
            fileExplorerPageConfiguration.isShowCreatedDate = true;
            fileExplorerPageConfiguration.isShowSize = true;
            fileExplorerPageConfiguration.isShowDownload = true;
            fileExplorerPageConfiguration.isShowExtension = true;
            fileExplorerPageConfiguration.isShowExtensionIcon = true;
            fileExplorerPageConfiguration.fileExtensionIconStaticResourceName = getDefaultStaticResourceName();
            fileExplorerPageConfiguration.isShowSearch = true;
            fileExplorerPageConfiguration.isShowBreadcrumb = true;
            fileExplorerPageConfiguration.isShowMassActions = true;
            fileExplorerPageConfiguration.isShowRelatedFiles = false;
            fileExplorerPageConfiguration.maxSearchRecords = 1000;
            fileExplorerPageConfiguration.maxInnerItemsCount = 100;
            if(configurationName == BT_Constants.FILE_EXPLORER_CONFIGURATION){
                fileExplorerPageConfiguration.isShowHeader = true;
                fileExplorerPageConfiguration.isShowHirarchicalFileUI = true;
                fileExplorerPageConfiguration.pageSize = 10;
            } else{
                fileExplorerPageConfiguration.isShowHeader = false;
                fileExplorerPageConfiguration.isShowHirarchicalFileUI = false;
                fileExplorerPageConfiguration.pageSize = 5;
            }
        }
        return fileExplorerPageConfiguration;
    }
    
    /*
    *   Purpose:    Returns default static resource name
    *   Parameters: 
    */
    private static string getDefaultStaticResourceName(){
        String namespace = BT_Utils.getNamespacePrefix();
        return namespace + 'BT_ResourceUtils';
    }
}