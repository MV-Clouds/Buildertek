/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_FileDetailController
* Created by Sagar
*
* File downlaod

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_FileDetailController {
    public File__c objFile{get; set;}
    public String fileDownloadURL{get; set;}
    public String errMessage{get; set;}
    public Boolean isShowMsg{get; set;}
    public String id{get;set;}
    public BT_FileDetailController(){
        isShowMsg = false;
        fileDownloadURL = '';
        errMessage = '';
        
        id = ApexPages.currentPage().getParameters().get('cleanId').escapeHtml4();
            system.debug('id ------------> '+id);
            // Retrive file information
            retrieveFile(id);

            // If file found in database
            if(objFile != null){
                if((objFile.OwnerId != UserInfo.getUserId() || Test.isRunningTest()) && objFile.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE) {
                    // Flag for Modify all permission
                    Boolean isHasModifyAllermissionForFile = BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FILE);
                    if(!isHasModifyAllermissionForFile && (objFile.File_Access_Control__r == null || objFile.File_Access_Control__r.isEmpty())){
                        isShowMsg = true;
                        errMessage = System.Label.Insufficient_Access_Rights;
                        return;
                    }
                }
            } else {
                isShowMsg = true;
                errMessage = System.Label.Invalid_Download_Link_Warning;
            }    
    }
    
    /**************************************************************************
       Purpose: Get file details 
       Parameters: fileId - File Id
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    public void retrieveFile(String fileId){
        List<String> fields = new List<String>{'Id', 'Name', 'Size__c', 'OwnerId', 'Bucket_Name__c', 'Amazon_File_Key__c','Track_Download_History__c', 'Access_Type__c', 'File_Presigned_URL__c'};
        SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
        // SOQL Query variable for file
        String userId = UserInfo.getUserId();
        String fileQuery = 'SELECT ' + BT_Utils.buildSelectListFragment(fileFields(), null, fields);
        fileQuery += ', (Select Id From File_Access_Control__r Where Grantee__c =: userId AND Download__c = true) FROM File__c WHERE ID =: fileId LIMIT 1';
        system.debug('fileQuery -------> '+fileQuery);
        // Execute query
        List<File__c> files = Database.query(string.escapeSingleQuotes(fileQuery));
        system.debug('files --------> '+files);
        if(files != null && !files.isEmpty()){
            objFile = files[0];
        }
    }
    
    /**************************************************************************
       Purpose: Retrieve the fieldset member list of file fieldset
       Parameters:
       Returns: List of FieldSetMember
       Throws [Exceptions]: 
    ****************************************************************************/
    public List<Schema.FieldSetMember> fileFields() {
        return BT_Utils.getFieldSetMembers(BT_Utils.getNamespacePrefix()+'File_Detail',BT_Constants.OBJECT_TYPE_FILE);
    }
    
    /*
    *   Executed:   On page load
    *   Purpose:    Create file download history and redirect to file presinged URL.
    *   Parameters: 
    *   UnitTests:  
    */
    public void init(){
    
        try{
            
            // Get the File Id
            String id = ApexPages.currentPage().getParameters().get('cleanId').escapeHtml4();
            system.debug('id ------------> '+id);
            // Retrive file information
            retrieveFile(id);

            // If file found in database
            if(objFile != null){
                if((objFile.OwnerId != UserInfo.getUserId() || Test.isRunningTest()) && objFile.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE) {
                    // Flag for Modify all permission
                    Boolean isHasModifyAllermissionForFile = BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FILE);
                    if(!isHasModifyAllermissionForFile && (objFile.File_Access_Control__r == null || objFile.File_Access_Control__r.isEmpty())){
                        isShowMsg = true;
                        errMessage = System.Label.Insufficient_Access_Rights;
                        return;
                    }
                }
            } else {
                isShowMsg = true;
                errMessage = System.Label.Invalid_Download_Link_Warning;
            }
            
        } catch(Exception e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isShowMsg = true;
        }
        return;
    }
    /*
    *   Executed:   On page load
    *   Purpose:    Create file download history and redirect to file presinged URL.
    *   Parameters: 
    *   UnitTests:  
    */
    public void download(){
        try{
            
            fileDownloadURL = '';
            // If file found in database
            if(objFile != null){
                
                //Create file download history before downloading start.
                Map<String, Application_Configuration__c> applicationConfigurationMap = Application_Configuration__c.getAll();
                if(applicationConfigurationMap.get(BT_Constants.ENABLE_FILE_DOWNLOAD_HISTORY) != null && applicationConfigurationMap.get(BT_Constants.ENABLE_FILE_DOWNLOAD_HISTORY).Configured_value__c == 'True'){
                    if(objFile != null && objFile.OwnerId != UserInfo.getUserId()){
                        if(objFile.Track_Download_History__c){
                            File_Download_History__c fileDownloadHistory = new File_Download_History__c(File__c = objFile.Id, DownloadedBy__c = UserInfo.getUserId(), DownloadedDate__c = System.now());
                            if(Schema.sObjectType.File_Download_History__c.fields.File__c.isCreateable()
                                && Schema.sObjectType.File_Download_History__c.fields.DownloadedBy__c.isCreateable()
                                && Schema.sObjectType.File_Download_History__c.fields.DownloadedDate__c.isCreateable()){
                                
                                insert fileDownloadHistory;    
                            }
                            
                        }
                    }
                }
                
                // Page Reference for file URL
                if(objFile.File_Presigned_URL__c != null){
                    fileDownloadURL = objFile.File_Presigned_URL__c;
                    return;
                } else{
                    // Get AWS credentials
                    AmazonS3Credential s3Credentials = new AmazonS3Credential();
                    Datetime expiryDate = System.now().addMinutes(1);
                    fileDownloadURL = FileUtils.getPresignedURL(objFile.Bucket_Name__c, objFile.Amazon_File_Key__c, expiryDate, s3Credentials.key, s3Credentials.secret);
                    return;
                }
            } else {
                isShowMsg = true;
                errMessage = System.Label.Invalid_Download_Link_Warning;
            }
            
        } catch(Exception e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isShowMsg = true;
        }
        return;
    }
}