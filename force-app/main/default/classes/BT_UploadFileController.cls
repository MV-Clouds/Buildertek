/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class:BT_UploadFileController
* Created by Sagar: 13/06/2017
*
* - Used for browser based file upload to overcome 1MB file size limit.After fiel uploaded to AWS successfully it will 
    be redirected to this page so we can display success message and we can close the window in page action. 

* - Modifications:
* - Sagar, 14/06/2017 – Initial Development
************************************************************************** */
public without sharing class BT_UploadFileController {
    public String sitesURL { get; set; }
    public Boolean isSitesURL { get; set; }
    @AuraEnabled public AmazonS3Credential s3LinkConfig{get; set;}                       // File Control configuration 
    @AuraEnabled public FileUploadConfiguration fileUploadConfiguration{get; set;}       // File Upload Configruation
    
    @AuraEnabled public Boolean isNoAmazonCredential{get; set;}
    
    @AuraEnabled public Boolean isChildWindow {get;set;}                                 // If page is open as child window
    
    @AuraEnabled public String s3Key {get;set;}                                          // Key for Amazon S3
    @AuraEnabled public String policy {get; set;}
    @AuraEnabled public String signedPolicy {get; set;}
    @AuraEnabled public String redirectUrl{get; set;}
    
    @AuraEnabled public S3.AmazonS3 amazonS3 { get; private set; }                       // This object represents an instance of the Amazon S3 toolkit and makes all the Web Service calls to AWS.
    
    Datetime expire = system.now().addDays(1);                              // Expire time for the policy prepared for upload request
    
    //Formate of expire time
    String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';
    
    @AuraEnabled public String selectedFolder{get; set;}
    
    @AuraEnabled public String selectedBucket{get; set;}                                 // Selected Amazon bucket name
        
    @AuraEnabled public string folderPath{get; set;}                                     // Folder path 
    
    @AuraEnabled public string currentUrl;
    
    @AuraEnabled public string urlParameterForSuccess{get; set;}                         // Parameter passed for file detail
    
    @AuraEnabled public List<SelectOption> accessTypeOptions{get; set;}                 // Salesforce access type
    
    @AuraEnabled public string fileName{get; set;}                                      // Name of the new file get uploaded
    
    @AuraEnabled public string isDuplicateFound{get; set;}                              // True, if the file with the same name found
    
    @AuraEnabled public string fileData{get; set;}                                       // Data of file for default values. 
    
    @AuraEnabled public Boolean isSuccess{ get; set;}
    
    @AuraEnabled public string newFileId{get; set;}
    
    public BT_UploadFileController(){
        // Set duplicate found to false
        isDuplicateFound = 'false';
        isSitesURL = false;
        isSuccess = false;
        sitesURL = ApexPages.currentPage().getHeaders().get('Host');
        system.debug('sitesURL --------> '+sitesURL);
        if(sitesURL.contains('builderteklightning-developer-edition.na75.force.com')){
            isSitesURL = true;
        }
        // Set default value for file data
        fileData = '{}';
        File__c file = BT_HomeUtils.getDefaultFile();
        File fileObj = new File();
        fileObj.AccessType = file.Access_Type__c;
        fileObj.PublicOnAmazon = file.Public_On_Amazon__c;
        fileObj.AllowCopy = file.Allow_to_Copy_Move__c;
        fileObj.AllowShareViaURL = file.Allow_to_Download_by_Presigned_URL__c;
        fileObj.TrackDownload = file.Track_Download_History__c;
        fileData = JSON.serialize(fileObj);
        
        // Get file upload configuration
        fileUploadConfiguration = BT_HomeUtils.getFileUploadPageConfiguration();
        
        // Set values for access type options
        accessTypeOptions = BT_FileUploadPageConfigurationController.getSalesforceAccessTypePickListValue();
        if(!test.isRunningTest()){
        //Get the url of the current page
        currentURL = ApexPages.currentPage().getUrl();
        }
        //Success url paramnet, late file etail parameters will be added.
        urlParameterForSuccess = '&success=1';
        
        selectedFolder = ApexPages.CurrentPage().getParameters().Get('sf');
        String selectedBucketId;
            if(!test.isRunningTest()){
       selectedBucketId = ApexPages.CurrentPage().getParameters().Get('sb'); 
            }
        isChildWindow = ApexPages.CurrentPage().getParameters().Get('clr') != null;
        
        //Query the selected bucket using bucket folder Id
        if(selectedBucketId != null && selectedBucketId.trim() != ''){
            
            if(Schema.sObjectType.Folder__c.fields.Id.isAccessible() && Schema.sObjectType.Folder__c.fields.Name.isAccessible()){
            selectedBucket = [Select Id, Name From Folder__c where Id =:selectedBucketId LIMIT 1].Name;
            }
        }
        
        //Query the selected folder using selected folder Id and prepare the folderPath 
        if(selectedFolder != '' && selectedFolder != null){
            List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c', 'Amazon_File_Key__c', 'Parent_Object_API_Name__c'};
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            Folder__c folder  = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Id =:selectedFolder LIMIT 1');
            System.debug('folder' + folder);
            if(selectedBucket == null || selectedBucket == ''){
                selectedBucket = folder.Bucket_Name__c != null ? folder.Bucket_Name__c : folder.Name;
                System.debug('selectedBucket' + selectedBucket);

            }
            String folderForPath = folder.Amazon_File_Key__c;
            folderPath = (folderForPath != null ? folderForPath+'/' : '');
            System.debug('folderPath' + folderPath);

        }
    }
    
    
    public BT_UploadFileController(String sf, String sb){
        // Set duplicate found to false
        isDuplicateFound = 'false';
        isSuccess = false;
        
        // Set default value for file data
        fileData = '{}';
        File__c file = BT_HomeUtils.getDefaultFile();
        File fileObj = new File();
        fileObj.AccessType = file.Access_Type__c;
        fileObj.PublicOnAmazon = file.Public_On_Amazon__c;
        fileObj.AllowCopy = file.Allow_to_Copy_Move__c;
        fileObj.AllowShareViaURL = file.Allow_to_Download_by_Presigned_URL__c;
        fileObj.TrackDownload = file.Track_Download_History__c;
        fileData = JSON.serialize(fileObj);
        
        // Get file upload configuration
        fileUploadConfiguration = BT_HomeUtils.getFileUploadPageConfiguration();
        
        // Set values for access type options
        accessTypeOptions = BT_FileUploadPageConfigurationController.getSalesforceAccessTypePickListValue();
        
        //Get the url of the current page
        currentURL = ApexPages.currentPage().getUrl();
        //Success url paramnet, late file etail parameters will be added.
        urlParameterForSuccess = '&success=1';
        
        selectedFolder = sf;
        String selectedBucketId = sb;
        //isChildWindow = ApexPages.CurrentPage().getParameters().Get('clr') != null;
        
        //Query the selected bucket using bucket folder Id
        if(selectedBucketId != null && selectedBucketId.trim() != ''){
           
            selectedBucket = [Select Id, Name From Folder__c where Id =:selectedBucketId LIMIT 1].Name;
            
        }
        
        //Query the selected folder using selected folder Id and prepare the folderPath 
        if(selectedFolder != '' && selectedFolder != null){
            List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c', 'Amazon_File_Key__c', 'Parent_Object_API_Name__c'};
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            Folder__c folder  = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Id =:selectedFolder LIMIT 1');
            if(selectedBucket == null || selectedBucket == ''){
                selectedBucket = folder.Bucket_Name__c != null ? folder.Bucket_Name__c : folder.Name;
            }
            String folderForPath = folder.Amazon_File_Key__c;
            folderPath = (folderForPath != null ? folderForPath+'/' : '');
        }
    }
    
    /*
    Purpose:    This method is called when the uplaod file Visualforce page is loaded. 
                It verifies that the AWS Keys can be found in the custom setting. 
    Parameters: No parameter  
    Return:     
    Exception:  Any errors are added to the ApexPage and displayed in the Visualforce page. 
    */
    public PageReference InitData(){
        try{
            //Get the AWS credetials
            s3LinkConfig = new AmazonS3Credential();
            amazonS3 = new S3.AmazonS3(s3LinkConfig.key,s3LinkConfig.secret);
        }catch(AmazonS3Credential.AmazonS3CredentialException AmazonS3CredentialEx){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, AmazonS3CredentialEx.getMessage());
            ApexPages.addMessage(errorMsg);
            isNoAmazonCredential = true;
        }
        return null;
    }
    
    /*
    Purpose:    It will also be invoked once file uploaded to amazon server successfully and window closed.
    Parameters: No parameter  
    Return:     
    Exception:  Any errors are added to the ApexPage and displayed in the Visualforce page. 
    */
    public pagereference createFile(){
        try{
            system.debug('----createFile-----');
            isSuccess = false;
            String mainObjectFieldAPI = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().Get('mainObjectFieldAPI'));
            String mainObjectId = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().Get('mainObjectId'));
            String callerOfChildWindow = ApexPages.CurrentPage().getParameters().Get('caller');
            String retURL = ApexPages.CurrentPage().getParameters().Get('retURL');
            system.debug('retURL -----> '+retURL);
            system.debug('mainObjectId -----> '+mainObjectId);
            
            
            List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
            
            // Get the file detail from JSON
            File fileObj = (File)JSON.deserializeStrict(ApexPages.CurrentPage().getParameters().Get('jsonForFileDetail'), File.class);
            fileData = JSON.serialize(fileObj);
    
            // Query the folder with all fields
            List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c', 'Amazon_File_Key__c', 'Parent_Object_API_Name__c'};
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            Folder__c folder  = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ', (Select Name From Files__r) From Folder__c Where Id =:selectedFolder LIMIT 1');
            
            // If file is replaced delete old file. skip trigger.
            if(fileObj.Replace){
                FileTriggerHandler.isSkipTrigger = true;
                Set<String> allFileAccessControlFields = File_Access_Control__c.sObjectType.getDescribe().fields.getMap().keySet();
                fields = new List<String>();
                fields.addAll(allFileAccessControlFields);
                SOQLManager.checkFieldAccess(File_Access_Control__c.sObjectType, fields);
                List<File__c> filesWithSameNames = BT_Utils.queryForWithOrWithoutSharing(true, 'Select Id, (select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File_Access_Control__r) From File__c Where Folder__c ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Folder)+' AND Name ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Name));
                
                // Get file access controls for all duplicate files
                for(File__c duplicateFile : filesWithSameNames){
                    for(File_Access_Control__c fileAccessControl : duplicateFile.File_Access_Control__r){
                        File_Access_Control__c newFileAccessControl = fileAccessControl.clone(false, true, true, true);
                        fileAccessControls.add(newFileAccessControl);
                    }
                }
                BT_NoSharingUtils.deleteSobjects(filesWithSameNames);
                FileTriggerHandler.isSkipTrigger = false;
            }
                 
            // Window will be closed and method will be called to add the file in salesforce database
            File__c newFile = new File__c();
            newFile.Name = fileObj.Name;
            newFile.Folder__c = fileObj.Folder;
            newFile.Bucket_Name__c = fileObj.BucketName;
            newFile.Extension__c = fileObj.Extension;
            newFile.Size__c = Decimal.valueOf(fileObj.size);
            newFile.Content_Type__c = fileObj.ContentType;
            
            File__c defaultFile = BT_HomeUtils.getDefaultFile();
            
            newFile.Allow_to_Copy_Move__c = defaultFile.Allow_to_Copy_Move__c;
            newFile.Presigned_URL_Frequency__c = defaultFile.Presigned_URL_Frequency__c;
            
            if(!fileUploadConfiguration.isShowPublicOnAmazon){
                newFile.Public_On_Amazon__c = defaultFile.Public_On_Amazon__c;
            } else{
                newFile.Public_On_Amazon__c = fileObj.PublicOnAmazon;
            }
            if(!fileUploadConfiguration.isShowAllowShareViaPresignedURL){
                newFile.Allow_to_Download_by_Presigned_URL__c = defaultFile.Allow_to_Download_by_Presigned_URL__c;
            } else{
                newFile.Allow_to_Download_by_Presigned_URL__c = fileObj.AllowShareViaURL;
            }
            if(!fileUploadConfiguration.isShowTrackDownload){
                newFile.Track_Download_History__c = defaultFile.Track_Download_History__c;
            } else{
                newFile.Track_Download_History__c = fileObj.TrackDownload;
            }
            if(!fileUploadConfiguration.isShowAllowCopy){
                newFile.Allow_to_Copy_Move__c = defaultFile.Allow_to_Copy_Move__c;
            } else{
                newFile.Allow_to_Copy_Move__c = fileObj.AllowCopy;
            }
            if(!fileUploadConfiguration.isShowAccessType){
                newFile.Access_Type__c = defaultFile.Access_Type__c;
            } else{
                newFile.Access_Type__c = fileObj.AccessType;
            }
            
            newFile.Parent_Object_API_Name__c = mainObjectFieldAPI != null && mainObjectFieldAPI != '' ? mainObjectFieldAPI : folder.Parent_Object_API_Name__c;
            
            // File needs to be linked to the passed salesforce record ID
            if(mainObjectFieldAPI != null && mainObjectFieldAPI != '' && mainObjectFieldAPI != 'null'){
                newFile.put(mainObjectFieldAPI, mainObjectId);
            }
            DMLManager.insertAsUser(newFile);
            newFileId = newFile.Id;
            
            // Also insert file access controls
            if(!fileAccessControls.isEmpty()){
                for(File_Access_Control__c fileAccessControl : fileAccessControls){
                    fileAccessControl.File__c = newFile.Id;
                }
            } else if(!fileObj.Replace && newFile.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE){
                fileAccessControls = BT_HomeUtils.getDefaultFileAccessControls(newFile);
            }
            
            if(!fileAccessControls.isEmpty()){
                BT_NoSharingUtils.doInsert(fileAccessControls, true);
            }
            isSuccess = true;
            // Close the window and referesh parent window.
            if(isChildWindow){
                if(callerOfChildWindow == '1'){
                    return new Pagereference('javascript: window.parent.closeWindowForUploadFile();');
                } else{
                    return null;
                }
            }
            if(BT_Utils.isLightning()){
                return null;
            }
            if(retURL != null && retURL != ''){
                if(retURL.startsWith('/')){
                    retURL = retURL.replaceFirst('/', '');  
                }
                 return new Pagereference('/'+newFileId);
            } else{
                return new Pagereference('/home/home.jsp');
            }
            
        } catch(AmazonS3Credential.AmazonS3CredentialException AmazonS3CredentialEx){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, AmazonS3CredentialEx.getMessage());
            ApexPages.addMessage(errorMsg);
            isNoAmazonCredential = true;
        }  catch(Exception ex){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            isNoAmazonCredential = true;
        }
        return null;
    }
    
    /*
    Purpose:    Setting the file detail as a url parameter with success paramenter
    Parameters: No parameter  
    Return:     
    Exception:  
    */
    public void setSuccessActionUrl(){
        // Set duplicate found to false
        isDuplicateFound = 'false';
        system.debug('check file upload');
        // File detail
        File fileObj = (File)JSON.deserializeStrict(ApexPages.CurrentPage().getParameters().Get('jsonForFileDetail'), File.class);
        fileData = JSON.serialize(fileObj);
        system.debug('check file upload fileData------------'+fileData);
        // List of duplicate files
        List<File__c> filesWithSameNames = new List<File__c>();
        
        if(!fileObj.Replace){
            // Check for duplicate file name
            filesWithSameNames = BT_Utils.queryForWithOrWithoutSharing(true, 'Select Id From File__c Where Folder__c ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Folder)+' AND Name ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Name));
        }
        
        
        if(!filesWithSameNames.isEmpty()){
            isDuplicateFound = 'true';
        } else {
            urlParameterForSuccess = '&success=1&rpl='+fileObj.Replace;
            
            if(fileUploadConfiguration.isShowAccessType){
                urlParameterForSuccess +='&at='+EncodingUtil.urlEncode(fileObj.AccessType, 'UTF-8');
            }
            if(fileUploadConfiguration.isShowTrackDownload){
                urlParameterForSuccess +='&ftd='+fileObj.TrackDownload;             
            }
            if(fileUploadConfiguration.isShowPublicOnAmazon){
                urlParameterForSuccess +='&pa='+fileObj.PublicOnAmazon;             
            }
            if(fileUploadConfiguration.isShowAllowShareViaPresignedURL){
                urlParameterForSuccess +='&fsurl='+fileObj.AllowShareViaURL;                
            }
            if(fileUploadConfiguration.isShowAllowCopy){
                urlParameterForSuccess +='&fcopy='+fileObj.AllowCopy;               
            }
            urlParameterForSuccess +='&fname='+EncodingUtil.urlEncode(fileObj.Name, 'UTF-8')+'&fsize='+fileObj.size+'&ftype='+EncodingUtil.urlEncode(fileObj.ContentType, 'UTF-8')+'&fext='+EncodingUtil.urlEncode(fileObj.Extension, 'UTF-8');
            redirectUrl = URL.getSalesforceBaseUrl().toExternalForm()+ currentURL +urlParameterForSuccess;
            // Modified By: Laxman 04/07/2020
            // we get the Acess Key From Cusotm settings.
            Buildertek__Amazon_S3_Key__c s3LinkAcesskey = Buildertek__Amazon_S3_Key__c.getInstance('AWS Public Key');
            if(s3LinkAcesskey !=null){
            s3Key= s3LinkAcesskey.buildertek__Configured_value__c;
            }
           // s3Key = 'AKIAJV6Y5ZGEHP42GJHA';
            system.debug('s3Key------------'+s3Key);
            policy = EncodingUtil.base64Encode(Blob.valueOf(getUpdatedPolicy(fileObj.PublicOnAmazon)));
            system.debug('policy----------------'+policy);
            
            signedPolicy = make_sig1(policy);     
        }
    }
    
    
    
    /*
    Purpose:    Policy used for request to upload file to Amazon server
    Parameters: No parameter  
    Return:     
    Exception:  
    */
    private String getUpdatedPolicy(Boolean isPublicOnAmazon){
        return 
        '{ "expiration": "'+formattedexpire+'","conditions": ['+
        '{"bucket": "'+selectedBucket+'" },'+
        '{ "acl": "'+(isPublicOnAmazon ? 'public-read' : 'private')+'" },'+
        //'{"success_action_status": "201" },'+
        '{"success_action_redirect":"'+redirectUrl+'"},' +
        '["starts-with", "$key", ""] ]}'; 
    }
    
   
    
    /*
    Purpose:    This method will be used to prepare the singed policy for upload request
    Parameters: canonicalBuffer: String needs to be signed
    Return:     
    Exception:  
    */
    private String make_sig(string canonicalBuffer) {        
        String macUrl ;
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(amazonS3.secret));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(amazonS3.Secret)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }
    
    @AuraEnabled
    public static Id insertFiles(File fileObj, String mainObjectFieldAPI, String mainObjectId){
        List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
        
        
        // If file is replaced delete old file. skip trigger.
        if(fileObj.Replace){
            FileTriggerHandler.isSkipTrigger = true;
            Set<String> allFileAccessControlFields = File_Access_Control__c.sObjectType.getDescribe().fields.getMap().keySet();
            List<String> fields = new List<String>();
            fields.addAll(allFileAccessControlFields);
            SOQLManager.checkFieldAccess(File_Access_Control__c.sObjectType, fields);
            List<File__c> filesWithSameNames = BT_Utils.queryForWithOrWithoutSharing(true, 'Select Id, (select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File_Access_Control__r) From File__c Where Folder__c ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Folder)+' AND Name ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Name));
            
            // Get file access controls for all duplicate files
            for(File__c duplicateFile : filesWithSameNames){
                for(File_Access_Control__c fileAccessControl : duplicateFile.File_Access_Control__r){
                    File_Access_Control__c newFileAccessControl = fileAccessControl.clone(false, true, true, true);
                    fileAccessControls.add(newFileAccessControl);
                }
            }
            BT_NoSharingUtils.deleteSobjects(filesWithSameNames);
            FileTriggerHandler.isSkipTrigger = false;
        }
        
        
        File__c newFile = new File__c();
        newFile.Name = fileObj.Name;
        newFile.Folder__c = fileObj.Folder;
        newFile.Bucket_Name__c = fileObj.BucketName;
        newFile.Extension__c = fileObj.Extension;
        newFile.Size__c = Decimal.valueOf(fileObj.size);
        newFile.Content_Type__c = fileObj.ContentType;
        
        File__c defaultFile = BT_HomeUtils.getDefaultFile();
        
        newFile.Allow_to_Copy_Move__c = defaultFile.Allow_to_Copy_Move__c;
        newFile.Presigned_URL_Frequency__c = defaultFile.Presigned_URL_Frequency__c;
        newFile.Public_On_Amazon__c = fileObj.PublicOnAmazon;
        newFile.Allow_to_Download_by_Presigned_URL__c = fileObj.AllowShareViaURL;
        newFile.Track_Download_History__c = fileObj.TrackDownload;
        newFile.Allow_to_Copy_Move__c = fileObj.AllowCopy;
        newFile.Access_Type__c = fileObj.AccessType;
        newFile.Parent_Object_API_Name__c = mainObjectFieldAPI;
        
        // File needs to be linked to the passed salesforce record ID
        if(mainObjectFieldAPI != null && mainObjectFieldAPI != '' && mainObjectFieldAPI != 'null'){
            newFile.put(mainObjectFieldAPI, mainObjectId);
        }
        DMLManager.insertAsUser(newFile);
        Id newFileId = newFile.Id;
        
        // Also insert file access controls
        if(!fileAccessControls.isEmpty()){
            for(File_Access_Control__c fileAccessControl : fileAccessControls){
                fileAccessControl.File__c = newFile.Id;
            }
        } else if(!fileObj.Replace && newFile.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE){
            fileAccessControls = BT_HomeUtils.getDefaultFileAccessControls(newFile);
        }
        
        if(!fileAccessControls.isEmpty()){
            BT_NoSharingUtils.doInsert(fileAccessControls, true);
        }
        
        return newFileId;
    }
    
    @AuraEnabled
    public static List<File__c> insertFile(string fileObjJSON, String mainObjectFieldAPI, String mainObjectId,List<File__c> selectedFiles){
        system.debug('---fileObjJSON---'+fileObjJSON);
        FileUtils.skipDuplicateFileNameValidation = true;
        Id fileId = insertFiles((File)JSON.deserializeStrict(fileObjJSON, File.class), mainObjectFieldAPI,  mainObjectId);
        FileUtils.skipDuplicateFileNameValidation = false;
        File__c filerec;
        if(Schema.sObjectType.File__c.fields.Id.isAccessible() && 
               Schema.sObjectType.File__c.fields.Name.isAccessible() &&
                Schema.sObjectType.File__c.fields.buildertek__File_Presigned_URL__c.isAccessible() ){
                filerec =[Select Id, Name, buildertek__File_Presigned_URL__c from File__c where Id=:fileId];
          }
          selectedFiles.add(filerec);
        return selectedFiles;
    }
    
    @AuraEnabled
    public static List<File__c> InsertAttachment(List<String> IdsList, String mainObjectFieldAPI, String mainObjectId, List<File__c> selectedFiles){
        system.debug('List Ids -----------> '+IdsList); 
        List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
        List<File__c> filesList;
            if(Schema.sObjectType.File__c.fields.Id.isAccessible() && 
               Schema.sObjectType.File__c.fields.Name.isAccessible() && 
              Schema.sObjectType.File__c.fields.Folder__c.isAccessible() && 
              Schema.sObjectType.File__c.fields.Folder__c.isAccessible() && 
              Schema.sObjectType.File__c.fields.Extension__c.isAccessible() &&
              Schema.sObjectType.File__c.fields.Size__c.isAccessible() && 
              Schema.sObjectType.File__c.fields.Content_Type__c.isAccessible() &&
              Schema.sObjectType.File__c.fields.buildertek__Public_On_Amazon__c.isAccessible() && 
              Schema.sObjectType.File__c.fields.Allow_to_Download_by_Presigned_URL__c.isAccessible() && 
              Schema.sObjectType.File__c.fields.Track_Download_History__c.isAccessible() && 
              Schema.sObjectType.File__c.fields.Allow_to_Copy_Move__c.isAccessible() &&
               Schema.sObjectType.File__c.fields.Access_Type__c.isAccessible() && 
              Schema.sObjectType.File__c.fields.buildertek__File_Presigned_URL__c.isAccessible()){
            filesList= [select Id, Name, Folder__c, Bucket_Name__c, Extension__c, Size__c, Content_Type__c, 
                                                    buildertek__Public_On_Amazon__c, Allow_to_Download_by_Presigned_URL__c,
                                                    Track_Download_History__c, Allow_to_Copy_Move__c, Access_Type__c, buildertek__File_Presigned_URL__c
                                                    from File__c where Id IN: IdsList];
              }
        system.debug('filesList ---------> '+filesList);
        List<File__c> allFilesList = new List<File__c>();
        for(File__c fileObj : filesList){
            //if(fileObj.Replace){
                FileTriggerHandler.isSkipTrigger = true;
                Set<String> allFileAccessControlFields = File_Access_Control__c.sObjectType.getDescribe().fields.getMap().keySet();
                List<String> fields = new List<String>();
                fields.addAll(allFileAccessControlFields);
                SOQLManager.checkFieldAccess(File_Access_Control__c.sObjectType, fields);
                List<File__c> filesWithSameNames = BT_Utils.queryForWithOrWithoutSharing(true, 'Select Id, (select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File_Access_Control__r) From File__c Where Folder__c ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Folder__c)+' AND Name ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Name));
                
                // Get file access controls for all duplicate files
                for(File__c duplicateFile : filesWithSameNames){
                    for(File_Access_Control__c fileAccessControl : duplicateFile.File_Access_Control__r){
                        File_Access_Control__c newFileAccessControl = fileAccessControl.clone(false, true, true, true);
                        fileAccessControls.add(newFileAccessControl);
                    }
                }
                //BT_NoSharingUtils.deleteSobjects(filesWithSameNames);
                FileTriggerHandler.isSkipTrigger = true;
            //}
            File__c newFile = new File__c();
           if(Schema.sObjectType.File__c.fields.Content_Type__c.isCreateable() && Schema.sObjectType.File__c.fields.buildertek__RFQ__c.isCreateable() && 
              Schema.sObjectType.File__c.fields.Size__c.isCreateable() && Schema.sObjectType.File__c.fields.Extension__c.isCreateable() && 
              Schema.sObjectType.File__c.fields.Bucket_Name__c.isCreateable() && Schema.sObjectType.File__c.fields.Folder__c.isCreateable() && 
              Schema.sObjectType.File__c.fields.Name.isCreateable() && Schema.sObjectType.File__c.fields.Presigned_URL_Frequency__c.isCreateable() && 
              Schema.sObjectType.File__c.fields.buildertek__File_Presigned_URL__c.isCreateable() &&  Schema.sObjectType.File__c.fields.Parent_Object_API_Name__c.isCreateable() && 
              Schema.sObjectType.File__c.fields.Allow_to_Copy_Move__c.isCreateable()){
            newFile.Name = fileObj.Name;
            newFile.Folder__c = fileObj.Folder__c;
            newFile.Bucket_Name__c = fileObj.Bucket_Name__c;
            newFile.Extension__c = fileObj.Extension__c;
            newFile.Size__c = fileObj.Size__c;
            newFile.Content_Type__c = fileObj.Content_Type__c;
            Map<String, String> objNameMap = new Map<String, String>();
            List<EntityDefinition> edList;
          
          edList  = [SELECT MasterLabel, QualifiedApiName, NamespacePrefix FROM EntityDefinition WHERE IsCustomSetting = false AND NamespacePrefix = 'buildertek' Order by MasterLabel];
             
            for(EntityDefinition ed : edList){
                objNameMap.put(ed.QualifiedApiName, ed.QualifiedApiName);
            }
            if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('buildertek__RFQ__c')){ 
                newFile.buildertek__RFQ__c = mainObjectId;    
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('buildertek__RFI__c')){
                newFile.buildertek__RFI__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('buildertek__Change_Order__c')){
                newFile.buildertek__Change_Order__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('buildertek__Punch_List__c')){
                newFile.buildertek__Punch_List__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('buildertek__Submittal__c')){
                newFile.buildertek__Submittal__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('buildertek__Quote__c')){
                newFile.buildertek__Quote__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('buildertek__RFQ_To_Vendor__c')){  
                newFile.buildertek__RFQ_To_Vendor__c = mainObjectId;    
            }
            File__c defaultFile = BT_HomeUtils.getDefaultFile();
        
            newFile.Allow_to_Copy_Move__c = defaultFile.Allow_to_Copy_Move__c;
        
                newFile.Presigned_URL_Frequency__c = defaultFile.Presigned_URL_Frequency__c;
                newFile.Public_On_Amazon__c = fileObj.buildertek__Public_On_Amazon__c;
                newFile.Allow_to_Download_by_Presigned_URL__c = fileObj.Allow_to_Download_by_Presigned_URL__c;
                newFile.Track_Download_History__c = fileObj.Track_Download_History__c;
                newFile.Allow_to_Copy_Move__c = fileObj.Allow_to_Copy_Move__c;
                newFile.Access_Type__c = fileObj.Access_Type__c;
                newFile.buildertek__File_Presigned_URL__c = fileObj.buildertek__File_Presigned_URL__c;
                newFile.Parent_Object_API_Name__c = mainObjectFieldAPI;
                allFilesList.add(newFile);
            }
        }
        system.debug('allFilesList -----------> '+allFilesList);
    
        
            insert allFilesList;
        
        for(File__c newFile : allFilesList){
            Id newFileId = newFile.Id;
        
        // Also insert file access controls
            if(!fileAccessControls.isEmpty()){
                for(File_Access_Control__c fileAccessControl : fileAccessControls){
                    fileAccessControl.File__c = newFile.Id;
                }
            } else if(newFile.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE){
                fileAccessControls = BT_HomeUtils.getDefaultFileAccessControls(newFile);
            }
            
            if(!fileAccessControls.isEmpty()){
                BT_NoSharingUtils.doInsert(fileAccessControls, true);
            }
            selectedFiles.add(newFile);
        }
        return selectedFiles;
    }
    
    @AuraEnabled
    public static List<File__c> AddFileAttachments(List<String> IdsList, String mainObjectFieldAPI, String mainObjectId, List<Buildertek__File__c> selectedFiles){
        system.debug('List Ids -----------> '+IdsList); 
        List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
        List<File__c> filesList;
            
            filesList= [select Id, Name, Folder__c, Bucket_Name__c, Extension__c, Size__c, Content_Type__c, 
                                                    buildertek__Public_On_Amazon__c, Allow_to_Download_by_Presigned_URL__c,
                                                    Track_Download_History__c, Allow_to_Copy_Move__c, Access_Type__c, buildertek__File_Presigned_URL__c
                                                    from File__c where Id IN: IdsList];
              
        system.debug('filesList ---------> '+filesList);
        List<File__c> allFilesList = new List<File__c>();
        List<EntityDefinition> edList;
             
                edList = [SELECT MasterLabel, QualifiedApiName, NamespacePrefix FROM EntityDefinition WHERE IsCustomSetting = false AND NamespacePrefix = 'buildertek' Order by MasterLabel];
              
        for(File__c fileObj : filesList){
            //if(fileObj.Replace){
                FileTriggerHandler.isSkipTrigger = true;
                Set<String> allFileAccessControlFields = File_Access_Control__c.sObjectType.getDescribe().fields.getMap().keySet();
                List<String> fields = new List<String>();
                fields.addAll(allFileAccessControlFields);
                SOQLManager.checkFieldAccess(File_Access_Control__c.sObjectType, fields);
                List<File__c> filesWithSameNames = BT_Utils.queryForWithOrWithoutSharing(true, 'Select Id, (select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File_Access_Control__r) From File__c Where Folder__c ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Folder__c)+' AND Name ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Name));
                
                // Get file access controls for all duplicate files
                for(File__c duplicateFile : filesWithSameNames){
                    for(File_Access_Control__c fileAccessControl : duplicateFile.File_Access_Control__r){
                        File_Access_Control__c newFileAccessControl = fileAccessControl.clone(false, true, true, true);
                        fileAccessControls.add(newFileAccessControl);
                    }
                }
                //BT_NoSharingUtils.deleteSobjects(filesWithSameNames);
                FileTriggerHandler.isSkipTrigger = true;
            //}
            File__c newFile = new File__c();
          
            newFile.Name = fileObj.Name;
            newFile.Folder__c = fileObj.Folder__c;
            newFile.Bucket_Name__c = fileObj.Bucket_Name__c;
            newFile.Extension__c = fileObj.Extension__c;
            newFile.Size__c = fileObj.Size__c;
            newFile.Content_Type__c = fileObj.Content_Type__c;
            Map<String, String> objNameMap = new Map<String, String>();
            
            for(EntityDefinition ed : edList){
                objNameMap.put(ed.QualifiedApiName, ed.QualifiedApiName);
            }
            system.debug('objNameMap --------> '+objNameMap);
            system.debug('object Name ---------> '+Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName());
            if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == 'buildertek__RFQ__c'){
                system.debug('mainObjectId ------> '+mainObjectId);
                newFile.buildertek__RFQ__c = mainObjectId;    
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == 'buildertek__RFI__c'){
                newFile.buildertek__RFI__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
                newFile.buildertek__Change_Order__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == 'buildertek__Punch_List__c'){
                newFile.buildertek__Punch_List__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == 'buildertek__Submittal__c'){
                newFile.buildertek__Submittal__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == 'buildertek__Quote__c'){
                newFile.buildertek__Quote__c = mainObjectId; 
            }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == 'buildertek__RFQ_To_Vendor__c'){
                 newFile.buildertek__RFQ_To_Vendor__c = mainObjectId; 
            }
            File__c defaultFile = BT_HomeUtils.getDefaultFile();
        
            newFile.Allow_to_Copy_Move__c = defaultFile.Allow_to_Copy_Move__c;
        
                newFile.Presigned_URL_Frequency__c = defaultFile.Presigned_URL_Frequency__c;
                newFile.Public_On_Amazon__c = fileObj.buildertek__Public_On_Amazon__c;
                newFile.Allow_to_Download_by_Presigned_URL__c = fileObj.Allow_to_Download_by_Presigned_URL__c;
                newFile.Track_Download_History__c = fileObj.Track_Download_History__c;
                newFile.Allow_to_Copy_Move__c = fileObj.Allow_to_Copy_Move__c;
                newFile.Access_Type__c = fileObj.Access_Type__c;
                newFile.buildertek__File_Presigned_URL__c = fileObj.buildertek__File_Presigned_URL__c;
                newFile.Parent_Object_API_Name__c = mainObjectFieldAPI;
                allFilesList.add(newFile);
            
        }
        system.debug('allFilesList -----------> '+allFilesList);
        
       
            insert allFilesList;
            system.debug('Final allFilesList -------> '+allFilesList);
        
        for(File__c newFile : allFilesList){
            Id newFileId = newFile.Id;
        
        // Also insert file access controls
            if(!fileAccessControls.isEmpty()){
                for(File_Access_Control__c fileAccessControl : fileAccessControls){
                    fileAccessControl.File__c = newFile.Id;
                }
            } else if(newFile.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE){
                fileAccessControls = BT_HomeUtils.getDefaultFileAccessControls(newFile);
            }
            
            if(!fileAccessControls.isEmpty()){
                BT_NoSharingUtils.doInsert(fileAccessControls, true);
            }
            selectedFiles.add(newFile);
        }
        return selectedFiles;
    }
    
    /*
    File object that is used to pass file detail from page to controller.
    */
    public class File{
        Public Integer Size{get; set;}
        Public String Name{get; set;}
        Public String Extension{get; set;}
        Public String ContentType{get; set;}
        Public String BucketName;
        Public String Folder;
        Public Boolean Replace;
        Public String AccessType;
        Public Boolean PublicOnAmazon;
        Public Boolean AllowCopy;
        Public Boolean AllowShareViaURL;
        Public Boolean TrackDownload;
        public File(){
        }
    }
    
    /*
    File Upload Configuration
    */
    public class FileUploadConfiguration{
        Public Boolean isShowAccessType{get; set;}
        Public Boolean isShowPublicOnAmazon{get; set;}
        Public Boolean isShowAllowCopy{get; set;}
        Public Boolean isShowAllowShareViaPresignedURL{get; set;}
        Public Boolean isShowTrackDownload{get; set;}
        Public Boolean isShowSettings{get; set;}
        Public FileUploadConfiguration(){
            isShowAccessType = false;
            isShowPublicOnAmazon = false;
            isShowAllowCopy = false;
            isShowAllowShareViaPresignedURL = false;
            isShowTrackDownload = false;
        }
    }
    
    
    @AuraEnabled
    public static Folder__c getConfig(String mofa, String moi){
         List<Folder__c> defaultBucketFolders;
        
                defaultBucketFolders= [Select Id, Name From Folder__c Where Default__c = true AND Active__c = true];
         
         return defaultBucketFolders[0];
    }
    
    @AuraEnabled
    public static List<FilesWrapper> getFiles(String recordId, String objectAPI){
     system.debug('objectAPI'+objectAPI);
         system.debug('recordId'+recordId);
     String query = '';
        if(objectAPI == 'Account'){
          query = 'SELECT Id, Name, buildertek__ProjectId__c FROM '+objectAPI+' WHERE Id =: recordId';
        }else if(objectAPI == 'buildertek__RFQ_To_Vendor__c'){
          query = 'SELECT Id, Name FROM '+objectAPI+' WHERE Id =: recordId';
        }else{
            query = 'SELECT Id, Name, buildertek__Project__c FROM '+objectAPI+' WHERE Id =: recordId';
        }
        system.debug('query --------------> '+query);
        List<sObject> sobjList = Database.query(String.escapeSingleQuotes(query));
        /*RFQ__c selectedRFQ;
        if(Schema.sObjectType.RFQ__c.fields.Id.isAccessible() &&
                Schema.sObjectType.RFQ__c.fields.Name.isAccessible() &&
                Schema.sObjectType.RFQ__c.fields.buildertek__Project__c.isAccessible() ){
                 selectedRFQ = [select Id, Name, buildertek__Project__c from RFQ__c where Id =: recordId];
                }*/
                String selectedProject = '';
        if(objectAPI == 'Account'){
          selectedProject  = String.valueOf(sobjList[0].get('buildertek__ProjectId__c'));
        }else if(objectAPI == 'buildertek__RFQ_To_Vendor__c'){
          selectedProject  = String.valueOf(sobjList[0].get('Id'));
        }else{
            selectedProject  = String.valueOf(sobjList[0].get('buildertek__Project__c'));
        }
        
        system.debug('selectedProject ---------> '+selectedProject);
        List<buildertek__File__c > filesList;
        
             filesList = [select Id, Name from buildertek__File__c where OwnerId =: UserInfo.getUserId() ORDER BY Name ASC];
            
        system.debug('filesList --------> '+filesList);
        List<FilesWrapper> FilesWrapperList = new List<FilesWrapper>();
        for(buildertek__File__c files : filesList){
            FilesWrapperList.add(new FilesWrapper(files.Id, files.Name, false));  
        }
        return FilesWrapperList;
    }
    
    @AuraEnabled
    public static List<FilesWrapper> getRecentFiles(String recordId, String objectAPI){
     String query  = '';
        if(objectAPI == 'Account'){
            query = 'SELECT Id, Name, buildertek__ProjectId__c FROM '+objectAPI+' WHERE Id =: recordId';
        }else if(objectAPI == 'buildertek__RFQ_To_Vendor__c'){
          query = 'SELECT Id, Name FROM '+objectAPI+' WHERE Id =: recordId';
        }else{
            query = 'SELECT Id, Name, buildertek__Project__c FROM '+objectAPI+' WHERE Id =: recordId';
        }
        
        system.debug('query --------------> '+query);
        List<sObject> sobjList = Database.query(query);
        List<buildertek__File__c > filesList;
       
             filesList = [select Id, Name from buildertek__File__c where OwnerId =: UserInfo.getUserId() Order By CreatedDate Desc limit 5];
            
        system.debug('filesList --------> '+filesList);
        List<FilesWrapper> FilesWrapperList = new List<FilesWrapper>();
        for(buildertek__File__c files : filesList){
            FilesWrapperList.add(new FilesWrapper(files.Id, files.Name, false));  
        }
        return FilesWrapperList;
    }
    
    @AuraEnabled
    public static List<FilesWrapper> getRelatedFiles(String recordId, String objectAPI){
    String query = '';
        if(objectAPI == 'Account'){
           query = 'SELECT Id, Name,buildertek__Account__c FROM buildertek__File__c WHERE buildertek__Account__c =: recordId ORDER BY Name ASC';
        }else{
            query = 'SELECT Id, Name FROM buildertek__File__c WHERE '+objectAPI+'=: recordId ORDER BY Name ASC';
        }
        system.debug('query --------------> '+query);
        List<buildertek__File__c> filesList;
        
        filesList = Database.query(query);
                
        system.debug('filesList --------> '+filesList);
        List<FilesWrapper> FilesWrapperList = new List<FilesWrapper>();
        for(buildertek__File__c files : filesList){
            FilesWrapperList.add(new FilesWrapper(files.Id, files.Name, false));  
        }
        return FilesWrapperList;
    }
    
    @AuraEnabled
    public static ErrorMessageClass getFilesUploaded(List<string> recordIds, String mainObjectId, String mainObjectFieldAPI, List<buildertek__File__c> selectedFiles){ 
        //Set<Id> recordIds=new Set<Id>{recordId};
        system.debug('mainObjectId----->'+mainObjectId);
        system.debug('recordIds'+recordIds);
        ErrorMessageClass emsg = new ErrorMessageClass();
        try{
            Set<Id> documentIds = new Set<Id>(); 
            List<ContentDocumentLink> cdl;
           
                cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:recordIds]; 
             
            for(ContentDocumentLink cdLink:cdl){  
                documentIds.add(cdLink.ContentDocumentId);  
            }  
            List<ContentDocument> contentdoc ;
            
                contentdoc = [SELECT Id, Title FROM ContentDocument WHERE id IN: documentIds];
            
                
            List<Attachment> attList = new List<Attachment>();
            //List<ContentVersion> fileAttachments = new List<ContentVersion>();
            SET<Id> ContentDocumentSet = new SET<Id>();
            for(ContentDocument filesInserted : contentdoc){
                ContentDocumentSet.add(filesInserted.Id);           
            }
            List<ContentVersion> fileAttachments;
            
                
                fileAttachments = [Select Id, 
                                            ContentDocumentId, 
                                            Title, 
                                            VersionData,
                                            ContentSize,
                                            PathOnClient,
                                            FileType,
                                            FileExtension
                                            from ContentVersion 
                                            where ContentDocumentId IN :ContentDocumentSet];
            
            Map<String, String> fileNameMap = new Map<String, String>();
            List<Buildertek__Folder__c> folderList = [Select Id, Name From buildertek__Folder__c Where buildertek__Default__c = true AND buildertek__Active__c = true];
            List<buildertek__File__c> customFilesList = [SELECT Id, Name FROM buildertek__File__c WHERE Folder__r.Name =: folderList[0].Name];
            for(buildertek__File__c customFiles : customFilesList){
                fileNameMap.put(customFiles.Name, customFiles.Name);            
            }
            
            Integer i=0;
            List<File__c> filesList = new List<File__c>();
             List<EntityDefinition> edList;
                      
                         edList = [SELECT MasterLabel, QualifiedApiName, NamespacePrefix FROM EntityDefinition WHERE IsCustomSetting = false AND NamespacePrefix = 'buildertek' Order by MasterLabel];
            for(ContentVersion contentVer : fileAttachments){
                
                    String attachmentBody = EncodingUtil.base64Encode(contentVer.VersionData);
                    String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
                    String filename = contentVer.Title;
                    filename = filename.replaceAll('\\s', ''); 
                    filename = EncodingUtil.urlEncode(filename, 'UTF-8');
                    HttpRequest req = new HttpRequest();
                    req.setMethod('PUT');
                    req.setEndpoint('callout:buildertek__AWS_S3/'+folderList[0].Name+'/'+fileName+'.'+contentVer.FileExtension);
                    req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
                    req.setHeader('Content-Encoding', 'base64');
                    //req.setHeader('Content-type', ContentType(contentVer.FileExtension));
                    req.setHeader('Connection', 'keep-alive');
                    req.setHeader('Date', formattedDateString);
                    req.setHeader('ACL', 'public-read-write');
                    req.setBodyAsBlob(contentVer.VersionData);
                    
                    Http http = new Http();
                    HTTPResponse res = http.send(req);
                    system.debug('Response ------> '+res.getBody());
                    system.debug('Response ------> '+res.getStatusCode());
                    system.debug('Response ------> '+res.getStatus());
                if(res.getStatusCode() == 200){
                    File__c newFile = new File__c();
                    newFile.Name = EncodingUtil.urlDecode(fileName, 'UTF-8')+'.'+contentVer.FileExtension;  
                    newFile.Folder__c = folderList[0].Id;
                    newFile.Bucket_Name__c = folderList[0].Name;
                    newFile.Extension__c = contentVer.FileType;
                    newFile.Size__c = contentVer.ContentSize;
                    newFile.Content_Type__c = contentVer.FileType;
                    Map<String, String> objNameMap = new Map<String, String>();
                   
                         
                    for(EntityDefinition ed : edList){
                        objNameMap.put(ed.MasterLabel, ed.QualifiedApiName);
                    }
                    
                     /* 
                      * Modified By :- Laxman 29/06/2020
                      * Description :- Here we map the parent Id . 
                    */
                    
                    if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('RFQ')){
                        newFile.buildertek__RFQ__c = mainObjectId; 
                       
                    }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('RFI')){
                        newFile.buildertek__RFI__c = mainObjectId; 
                    }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('Change Order')){
                        newFile.buildertek__Change_Order__c = mainObjectId; 
                    }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('Punch List')){
                        newFile.buildertek__Punch_List__c = mainObjectId; 
                    }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('Submittal')){
                        newFile.buildertek__Submittal__c = mainObjectId; 
                    }else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('Quote')){
                        newFile.buildertek__Quote__c = mainObjectId; 
                    }/*else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == objNameMap.get('RFQ To Account')){
                        newFile.
                         = mainObjectId; 
                    }*/
                    else if(Id.valueOf(mainObjectId).getSObjectType().getDescribe().getName() == 'buildertek__RFQ_To_Vendor__c'){
                        newFile.buildertek__RFQ_To_Vendor__c = mainObjectId; 
                    }
                    //File__c defaultFile = BT_HomeUtils.getDefaultFile();
                    
                    newFile.Allow_to_Copy_Move__c = true;
                    
                    newFile.Presigned_URL_Frequency__c = 'Every Month';
                    newFile.Public_On_Amazon__c = true;
                    newFile.Allow_to_Download_by_Presigned_URL__c = true;
                    newFile.Track_Download_History__c = true;
                    newFile.Allow_to_Copy_Move__c = true;
                    newFile.Access_Type__c = 'Public';
                    newFile.buildertek__File_Presigned_URL__c = 'https://s3.amazonaws.com/'+folderList[0].Name+'/'+EncodingUtil.urlDecode(fileName, 'UTF-8')+'.'+contentVer.FileExtension;
                    newFile.Parent_Object_API_Name__c = mainObjectFieldAPI;
                    newFile.buildertek__ContentDocument_Id__c = contentVer.ContentDocumentId;
                    filesList.add(newFile);
                
                }
                       
            }
            if(filesList.size() > 0){
                
                    insert filesList;
                system.debug('filesList------>'+JSON.serialize(filesList));
               //if(ContentDocument.sObjectType.getDescribe().isDeletable()){
                    //DELETE contentdoc;      
               //}
                
            }
            for(buildertek__File__c newFile : filesList){
                selectedFiles.add(newFile);     
            }
            emsg.Message = 'File Uploaded Successfully';
            emsg.IsSuccess = 'Success';
            emsg.filesList = selectedFiles;
        }catch(Exception exp){
            emsg.Message = exp.getMessage();
            emsg.IsSuccess = 'Error';            
        }
        return emsg;  
    }
    
    @AuraEnabled
    public static List<String> gets3Key(){
        List<Folder__c> defaultBucketFolders;
    
            defaultBucketFolders = [Select Id, Name From Folder__c Where Default__c = true AND Active__c = true];
            
        AmazonS3Credential s3LinkConfig;
        s3LinkConfig = new AmazonS3Credential();
        
        String s3Key= s3LinkConfig.Key;
        String policy = EncodingUtil.base64Encode(Blob.valueOf(getUpdatedPolicy1(true, defaultBucketFolders[0].Name)));
        String signedPolicy = make_sig1(policy);     
        
        return new List<String>{s3Key, policy, signedPolicy};
    }
    
    private static String make_sig1(string canonicalBuffer) {        
        String macUrl ;
        //Get the AWS credetials
        S3.AmazonS3 amazonS3;
        AmazonS3Credential s3LinkConfig;
        s3LinkConfig = new AmazonS3Credential();
        amazonS3 = new S3.AmazonS3(s3LinkConfig.key,s3LinkConfig.secret);
            
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(amazonS3.secret));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(amazonS3.Secret)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }
    
     public static String getUpdatedPolicy1(Boolean isPublicOnAmazon, String selectedBucket){
        Datetime expire = system.now().addDays(1); 
        String formattedexpire =  expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';
        return 
        '{ "expiration": "'+formattedexpire+'","conditions": ['+
        '{"bucket": "'+selectedBucket+'" },'+
        '{ "acl": "'+(isPublicOnAmazon ? 'public-read' : 'private')+'" },'+
        //'{"success_action_status": "201" },'+
        '{"success_action_redirect":""},' +
        '["starts-with", "$key", ""] ]}'; 
    }
    
    public class FilesWrapper{
        @AuraEnabled public String FileId { get; set; }
        @AuraEnabled public String FileName { get; set; }
        @AuraEnabled public Boolean IsChecked { get; set; }
        
        public FilesWrapper(String FileId, String FileName, Boolean IsChecked){
            this.FileId = FileId;
            this.FileName = FileName;
            this.IsChecked = IsChecked;
        }
    }
    
    public class ErrorMessageClass{
        @AuraEnabled public String Message;
        @AuraEnabled public String IsSuccess;
        @AuraEnabled public List<buildertek__File__c> filesList;
    }
    
    public static string ContentType(string fileType)
    {
        switch on fileType.toLowerCase()
        {
            when 'docx'
            {
                return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            }
            when 'csv'
            {
                return 'application/vnd.ms-excel';
            }
            when 'wav'
            {
                return 'audio/wav';
            }
            when 'wmv'
            {
                return 'video/x-ms-wmv';
            }
            when 'mp3'
            {
                return 'audio/mpeg';
            }
            when 'mp4'
            {
                return 'video/mp4';
            }
            when 'png'
            {
                return 'image/png';
                
            }
            when 'pdf'
            {
                return 'application/pdf';
                
            }
            when else {
                return 'image/jpeg';
            }
        }
    }
    
}