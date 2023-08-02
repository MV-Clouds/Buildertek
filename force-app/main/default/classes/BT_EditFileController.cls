/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: BT_EditFileController
* Created by Sagar
*
* Edit of file.

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_EditFileController {
    public Boolean isError{get; set;}
    public String retURL{get;set;}
    public String uploadFileURL{get;set;}
    public BT_EditFileController(ApexPages.StandardController controller) {
        retURL = ApexPages.currentPage().getParameters().get('retURL').escapeHtml4();
        system.debug('Return URL Set As: ' + retURL);
        String folderId;
        String fileId;
        String selectedBucketId;
        String strMainObjectFieldAPI;
        String strMainObjectId;
        String strOtherObjectId;
        String strOtherObjectFieldAPI;
        File__c file = new File__c();
        Folder__c fileFolder = new Folder__c();
        try{
            List<String> allParentObjectFieldAPINames = new List<String>();
            List<Schema.SObjectField> parentsForFile = BT_HomeUtils.getAllParentsForFolder();
            for(Schema.SObjectField objSchemaField: parentsForFile) {
                Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
                allParentObjectFieldAPINames.add(objFieldDescribe.getName());
            }
            
            // Add all lookup fields
            if(!Test.isRunningTest()){
                List<String> allFileFields = new List<String>();
                allFileFields.addAll(allParentObjectFieldAPINames);
                allFileFields.add(BT_Utils.getNamespacePrefix()+'Folder__c');
                controller.addFields(allParentObjectFieldAPINames);
            }
            
            // Add Parent__c, as we use the same list for folder
            allParentObjectFieldAPINames.add(BT_Utils.getNamespacePrefix()+'Parent__c');
            file = (File__c)controller.getRecord();
            fileId = file.Id;
            folderId = file.Folder__c;
            
            // Get the parent folder id
            if(folderId != null){
                List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c', 'Active__c'};
                fields.addAll(allParentObjectFieldAPINames);
                SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
                fileFolder = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Id =:folderId LIMIT 1'));
            }
            
            // If folder is not available then check for default bucket folder
            if(fileFolder.Id == null){
                List<Folder__c> defaultBucketFolders;
                if(Schema.sObjectType.Folder__c.fields.id.isAccessible() &&
                Schema.sObjectType.Folder__c.fields.Default__c.isAccessible() &&
                Schema.sObjectType.Folder__c.fields.Active__c.isAccessible()){
                    defaultBucketFolders = [Select Id From Folder__c Where Default__c = true AND Active__c = true];    
                }
                if(defaultBucketFolders != null && !defaultBucketFolders.isEmpty()){
                    folderId = defaultBucketFolders[0].Id;
                    selectedBucketId = defaultBucketFolders[0].Id;
                } else{
                    throw new BT_ApplicationException(System.Label.No_Bucket_Configured_Warning);
                }
            } else{
                if(fileFolder.Parent__c == null){
                    if(fileFolder.Active__c){
                        selectedBucketId = fileFolder.Id;
                    } else{
                        throw new BT_ApplicationException('Bucket is inactive. You cannot upload file in inactive bucket.');
                    }
                } else{
                    List<Folder__c> bucketFolders;
                    if(Schema.sObjectType.Folder__c.fields.id.isAccessible() &&
                    Schema.sObjectType.Folder__c.fields.Name.isAccessible() &&
                    Schema.sObjectType.Folder__c.fields.Active__c.isAccessible()){
                        bucketFolders = [Select Id From Folder__c Where Name =: fileFolder.Bucket_Name__c AND Active__c = true LIMIT 1];    
                    }    
                    if(!bucketFolders.isEmpty()){
                        selectedBucketId = bucketFolders[0].Id;
                    } else{
                        throw new BT_ApplicationException(System.Label.No_Bucket_Configured_Warning);
                    }
                }
                
            }
            
            // Check if file is related to any record
            for(Schema.SObjectField objSchemaField: parentsForFile) {
                Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
                if(file.get(objFieldDescribe.getName()) != null){
                    strMainObjectFieldAPI = String.valueOf(objFieldDescribe.getName());
                    strMainObjectId = String.valueOf(file.get(objFieldDescribe.getName()));
                }
            }
            
            // If the file is not related to any records then check if folder is related to any record or not
            for(Schema.SObjectField objSchemaField: parentsForFile) {
                Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
                if(fileFolder.get(objFieldDescribe.getName()) != null){
                    strMainObjectFieldAPI = String.valueOf(objFieldDescribe.getName());
                    strMainObjectId = String.valueOf(fileFolder.get(objFieldDescribe.getName()));
                }
            }
            uploadFileURL = '/apex/buildertek__BT_UploadFile?sf='+folderId+'&sb='+selectedBucketId;
            if(strMainObjectFieldAPI != null){
                 uploadFileURL += '&mofa='+strMainObjectFieldAPI+'&moi='+strMainObjectId;
            }
            if(strOtherObjectFieldAPI != null){
                 uploadFileURL += '&oofa='+strOtherObjectFieldAPI+'&ooi='+strOtherObjectId;
            }
            if(!String.isBlank(retURL)){
                uploadFileURL += '&retURL='+retURL;
            }
            
        } catch(BT_ApplicationException e){ 
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isError = true;
        } 
    }
}