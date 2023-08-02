/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_ImportFilesQueueable
* Created by Sagar: 27/09/2017
*
* Purpose/Methods:
* - Create the files and folders as per the amazon server. We are doing it in future method to make that page readonly.
*
* Unit Test: 
* 
* Modifications:
* - Sagar, 27/09/2017 - Initial Development
************************************************************************** */
public with sharing class BT_ImportFilesQueueable implements Queueable {
    
    // JSON for selected file keys to import.
    String selectedNodeKeys;
    
    // File with import attribute
    File__c fileWithImportAttribute;
    
    // File size by file path
    Map<String, Double> fileSizeByPath;
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_ImportFilesQueueable(String selectedNodeKeys, File__c fileWithImportAttribute, Map<String, Double> fileSizeByPath) {
        this.selectedNodeKeys = selectedNodeKeys;
        this.fileWithImportAttribute = fileWithImportAttribute;
        this.fileSizeByPath = fileSizeByPath;
    }
    
    /*
    *   Purpose:    Create file on salesforce
    *   Parameters: 
    *   UnitTests:  
    */
    public void execute(QueueableContext context) {     
        try{
            Map<String, String> selectedNodeKeysByKeys = new Map<String, String>();
            selectedNodeKeysByKeys = (Map<String, String>)JSON.deserialize(selectedNodeKeys, Map<String, String>.class);
            
            //Prepare the list of files we need to import
            Set<String> setKeysToImport = selectedNodeKeysByKeys.keySet(); 
            
            //All file paths
            Set<String> filePaths = new Set<String>();
            
            //All internal folder paths
            Set<String> internalFolderPaths = new Set<String>();
            
            //All File Names
            Set<String> fileNames = new Set<String>();
            
            //All Folder Names
            Set<String> folderNames = new Set<String>();
            
            //All bucket names
            Set<String> bucketNames = new Set<String>();
            
            //Bucket name by path
            Map<String, String> bucketsByPath = new Map<String, String>();
            
            //Go through all files and prepare the internal folder path and file path
            for(String filePathNeedsToCheckForImport : setKeysToImport){
                List<String> internalPathTokens = filePathNeedsToCheckForImport.split('/');
                String bucket = internalPathTokens[0];
                bucketNames.add(bucket);
                String interPath = '';
                for(integer i = 0; i < internalPathTokens.size();  i++){
                    interPath += internalPathTokens[i]+'/'; 
                    if(i == internalPathTokens.size()-1 && internalPathTokens[i].indexOf('.') != -1){
                        // Add into file names to import list
                        fileNames.add(internalPathTokens[i]);
                        String filePath = interPath.substring(bucket.length()+1, interPath.length() -1);
                        filePaths.add(filePath);
                        bucketsByPath.put(filePath, bucket);
                    } else if(i > 0){
                        // Add into folder names to import list
                        folderNames.add(internalPathTokens[i]);
                        String internalFolderPath = interPath.substring(bucket.length()+1, interPath.length() -1);
                        internalFolderPaths.add(internalFolderPath);
                        bucketsByPath.put(internalFolderPath, bucket);
                    }
                }
            }
            
            //Query all bucket folders
            List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c'};
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            List<Folder__c> bucketFolders = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Name In :  bucketNames'));
            
            //Bucket by name
            Map<String, Folder__c> bucketsByName = new Map<String, Folder__c>();
            for(Folder__c bucket : bucketFolders){
                bucketsByName.put(bucket.Name, bucket);
            }
            
            //Query all folders using internal folder paths
            fields = new List<String>{'Id', 'Name', 'Amazon_File_Key__c', 'Amazon_File_Path__c', 'Salesforce_Unique_Number__c'};
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            List<Folder__c> existingFolders = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Name In :  bucketNames OR Name In: folderNames'));
            
            //Existing folders by path
            Map<String, Folder__c> existingFoldersByPath = new Map<String, Folder__c>();
            for(Folder__c folder : existingFolders){
                if(internalFolderPaths.contains(folder.Amazon_File_Key__c)){
                    existingFoldersByPath.put(folder.Amazon_File_Key__c, folder);
                }
            }
            
            //Query all file using internal file paths
            fields = new List<String>{'Id', 'Name', 'Amazon_File_Key__c'};
            SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
            List<File__c> existingFiles = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File__c Where Name In: fileNames LIMIT 1000000'));
            
            //Existing file by path
            Map<String, File__c> existingFilesByPath = new Map<String, File__c>();
            for(File__c file : existingFiles){
                if(filePaths.contains(file.Amazon_File_Key__c)){
                    existingFilesByPath.put(file.Amazon_File_Key__c, file);
                }
            }
            
            //New folders by path
            Map<String, Folder__c> newFoldersByPath = new Map<String, Folder__c>();
            for(String internalFolderPath : internalFolderPaths){
                if(existingFoldersByPath.get(internalFolderPath) == null){
                    String folderName = internalFolderPath.split('/')[internalFolderPath.split('/').size()-1];
                    String bucketName = bucketsByPath.get(internalFolderPath);
                    Folder__c folder = new Folder__c(name = folderName, Access_Type__c = fileWithImportAttribute.Access_Type__c, Amazon_File_Key__c = internalFolderPath, Bucket_Name__c = bucketName);
                    newFoldersByPath.put(internalFolderPath,folder);
                }
            }
            
            //Insert new folders add them into map for existing folders by path so later on we can use
            //it for Folder for file
            if(newFoldersByPath.keySet().size() > 0){
                FolderTriggerHandler.isSkipTrigger = true;
                if(Schema.sObjectType.Folder__c.fields.buildertek__Account__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Active__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Amazon_File_Key__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Bucket_Name__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Budget__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Change_Order__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Contract__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Default__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Description__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__External_Folder_Name__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.Name.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Location__c.isCreateable() 
						&& Schema.sObjectType.Folder__c.fields.buildertek__Parent__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Parent_Object_API_Name__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Project__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Quote__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__RFI__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__RFQ__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__RFQ_To_Vendor__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Access_Type__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Amazon_File_Path__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Selection_Option__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Selection_Type__c.isCreateable()
						&& Schema.sObjectType.Folder__c.fields.buildertek__Source_Folder__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Spec__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Submittal__c.isCreateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Upload_Status__c.isCreateable()){
                insert newFoldersByPath.values();
                        }
                FolderTriggerHandler.isSkipTrigger = false;
                fields = new List<String>{'Id', 'Amazon_File_Key__c', 'Amazon_File_Path__c', 'Salesforce_Unique_Number__c'};
                SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
                Set<Id> newFolderIds = new Set<Id>();
                for(Folder__c newFolder : newFoldersByPath.values()){
                    newFolderIds.add(newFolder.Id);
                }
                for(Folder__c newFolder : Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Id In: newFolderIds'))){
                    //Put new folders into map for existing folders by path
                    existingFoldersByPath.put(newFolder.Amazon_File_Key__c, newFolder);
                }
            }
            
            List<String> sortedInternalFolderPaths = new List<String>();
            sortedInternalFolderPaths.addAll(newFoldersByPath.keySet());
            sortedInternalFolderPaths.sort();
            for(String internalFolderPath : sortedInternalFolderPaths){
                String name = internalFolderPath.split('/')[internalFolderPath.split('/').size()-1];
                String parentfolderPath = '';
                if(internalFolderPath.split('/').size() == 1){
                    newFoldersByPath.get(internalFolderPath).Parent__c = bucketsByName.get(bucketsByPath.get(internalFolderPath)).Id;
                    newFoldersByPath.get(internalFolderPath).Amazon_File_Path__c = String.valueOf(Integer.valueOf(existingFoldersByPath.get(internalFolderPath).Salesforce_Unique_Number__c));
                    existingFoldersByPath.put(internalFolderPath, newFoldersByPath.get(internalFolderPath));
                } else{
                    parentfolderPath = internalFolderPath.substring(0, internalFolderPath.length() - (name.length()+1));
                    newFoldersByPath.get(internalFolderPath).Parent__c = existingFoldersByPath.get(parentfolderPath).Id;
                    newFoldersByPath.get(internalFolderPath).Amazon_File_Path__c = existingFoldersByPath.get(parentfolderPath).Amazon_File_Path__c +'/'+Integer.valueOf(existingFoldersByPath.get(internalFolderPath).Salesforce_Unique_Number__c);
                    existingFoldersByPath.put(internalFolderPath, newFoldersByPath.get(internalFolderPath));
                }
            }
            
            //Update new folders parent folder id
            if(!newFoldersByPath.keySet().isEmpty()){
                if(Schema.sObjectType.Folder__c.fields.buildertek__Account__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Active__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Amazon_File_Key__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Bucket_Name__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Budget__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Change_Order__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Contract__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Default__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Description__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__External_Folder_Name__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.Name.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Location__c.isUpdateable() 
						&& Schema.sObjectType.Folder__c.fields.buildertek__Parent__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Parent_Object_API_Name__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Project__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Quote__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__RFI__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__RFQ__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__RFQ_To_Vendor__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Access_Type__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Amazon_File_Path__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Selection_Option__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Selection_Type__c.isUpdateable()
						&& Schema.sObjectType.Folder__c.fields.buildertek__Source_Folder__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Spec__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Submittal__c.isUpdateable()
                        && Schema.sObjectType.Folder__c.fields.buildertek__Upload_Status__c.isUpdateable()){
                update newFoldersByPath.values();
                        }
            }
            
            //New file by path
            Map<String, File__c> newFilesByPath = new Map<String, File__c>();
            for(String filePath : filePaths){
                if(existingFilesByPath.get(filePath) == null){
                    String fileName = filePath.split('/')[filePath.split('/').size()-1];
                    String bucketName = bucketsByPath.get(filePath);
                    String extension = fileName.split('\\.').size() > 1 ? '.'+fileName.split('\\.')[fileName.split('\\.').size()-1] : null;
                    Double fileSize = fileSizeByPath.get(bucketName+'/'+filePath);
                    File__c file = fileWithImportAttribute.clone(false, false, false, false);
                    file.Name = fileName;
                    file.Bucket_Name__c = bucketName;
                    file.Size__c = fileSize;
                    file.Extension__c = extension;
                    if(filePath.split('/').size() == 1){
                        file.Folder__c = bucketsByName.get(bucketName).Id;
                    } else{
                        String folderPath = filePath.substring(0, filePath.length() - (fileName.length()+1));
                        file.Folder__c = existingFoldersByPath.get(folderPath).Id;
                    }
                    newFilesByPath.put(filePath,file);
                }
            }
            
            //Insert new files
            if(newFilesByPath.keySet().size() > 0){
                if(Schema.sObjectType.File__c.fields.Name.isCreateable()
                    && Schema.sObjectType.File__c.fields.Bucket_Name__c.isCreateable()
                    && Schema.sObjectType.File__c.fields.Size__c.isCreateable()
                    && Schema.sObjectType.File__c.fields.Extension__c.isCreateable()
                    && Schema.sObjectType.File__c.fields.Folder__c.isCreateable()){
                    
                    insert newFilesByPath.values();    
                }
                
            }
            
            //Clear the job id
            BT_HomeUtils.setFileImportJobId('');
            
            // Sending email
            BT_Utils.sendJobSuccessEmail(context.getJobId(), System.label.Import_File_Job_Status_Subject, System.label.Import_File_Job_Status_Body);
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Your Import File Job Status', 'Your Import File Job has been failed. The issue has been forwarded to S3-Link support team. Here is the error: '+e.getMessage());
        }
    }
}