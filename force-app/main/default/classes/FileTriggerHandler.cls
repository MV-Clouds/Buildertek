/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: FileTriggerHandler
* Created by Sagar: 27/05/2017
*
* - Trigger Handler Class for File Trigger
* - File will be deleeted it will be deleted from Amazon also
* - Delete all File Access Controls also.

* - Modifications:
* - Sagar, 27/05/2017 – Initial Development
************************************************************************** */
public with sharing class FileTriggerHandler {
    
    // Flag to skipp trigger
    public static Boolean isSkipTrigger = false;
    
    /*
    *   Executed:   On before insert of files
    *   Purpose:    Setting Access type to default value if its null
    *   Parameters: 
    *   UnitTests:  
    */
    public void onBeforeInsert(List<File__c> newFiles){
        if(!isSkipTrigger){
            // Set the extension using file name
            FileUtils.setFileNameWithExtension(newFiles);
            
            // Set Amazon File Path
            FileUtils.setAmazonFilePath(newFiles);
            
            // Check for duplicate file name
            FileUtils.checkForDuplicateFileName(newFiles);
            
            // Set the Presigned URL
            FileUtils.setPresignedURL(newFiles);
            
            // Set the access type
            for(File__c newFile : newFiles){
                if(newFile.Access_Type__c == null || newFile.Access_Type__c == ''){
                    newFile.Access_Type__c = BT_Constants.FILE_ACCESS_PRIVATE;
                }
            }
        }
    }
    
    /*
    *   Executed:   On after insert of files
    *   Purpose:    Create files on amazon if its copied or moved from source
    *   Parameters: 
    *   UnitTests:  
    */
    public void onAfterInsert(List<File__c> newFiles){
        if(!isSkipTrigger){
            // Files needs to copy from source.
            List<File__c> newFilesNeedsToCopyFromSource = new List<File__c>();
            
            // Files needs to move from source.
            List<File__c> newFilesNeedsToMoveFromSource = new List<File__c>();
            
            // Filed with Public On Amazon
            List<File__c> newFilesWithPublicOnAmazon = new List<File__c>();
            
            for(File__c newFile : newFiles){
                if(newFile.Upload_Status__c == BT_Constants.FILE_UPLOAD_STATUS_COPYING){
                    newFilesNeedsToCopyFromSource.add(newFile);
                }
                if(newFile.Upload_Status__c == BT_Constants.FILE_UPLOAD_STATUS_MOVING){
                    newFilesNeedsToMoveFromSource.add(newFile);
                }
                if(newFile.Upload_Status__c == '' || newFile.Upload_Status__c == BT_Constants.FILE_UPLOAD_STATUS_COMPLETED){
                    newFilesWithPublicOnAmazon.add(newFile);
                }
            }
            
            // Copy files on Amazon Server
            if(!newFilesNeedsToCopyFromSource.isEmpty()){
                System.enqueueJob(new BT_CopyFilesQueueable(newFilesNeedsToCopyFromSource));
            }
            
            // Move files on Amazon Server
            if(!newFilesNeedsToMoveFromSource.isEmpty()){
                System.enqueueJob(new BT_MoveFilesQueueable(newFilesNeedsToMoveFromSource));
            }
            
            // Set the Access control for files
            if(!newFilesWithPublicOnAmazon.isEmpty()){
                System.enqueueJob(new BT_UpdateFileAccessQueueable(newFilesWithPublicOnAmazon));
            }
        }
    }
    
    /*
    *   Executed:   On before update of files
    *   Purpose:    Set the extension if its missing in name 
    *   Parameters: 
    *   UnitTests:  
    */
    
    public void onBeforeUpdate(Map<Id, File__c > newFilesById, Map<Id, File__c > oldFilesById) {
        // Set the extension using file name
        FileUtils.setFileNameWithExtension(newFilesById.values());
        
        // Set Amazon File Path
        FileUtils.setAmazonFilePath(newFilesById.values());
        
        // Set the Presigned URL
        FileUtils.setPresignedURL(newFilesById.values());
    }
    
    /*
    *   Executed:   On after update of files
    *   Purpose:    Deleting the file acccess controls and renaming the files on amazon server
    *   Parameters: 
    *   UnitTests:  
    */
    
    public void onAfterUpdate(Map<Id, File__c > newFilesById, Map<Id, File__c > oldFilesById) {
        if(!isSkipTrigger){
            // File with updated Public On Amazon
            List<File__c> filesWithUpdatedPublicOnAmazon = new List<File__c>();
            // File with updated Name
            List<File__c> filesWithUpdatedName = new List<File__c>();
            // New Amazon File Paths  by Id.
            Map<Id, String> newAmazonFilePathsById = new Map<Id, String>();
            // Old Amazon File Paths by Id.
            Map<Id, String> oldAmazonFilePathsById = new Map<Id, String>();
            // List of file whose file access controls needs to be deleted
            List<Id> fileIdsWhoseAccessControlNeedsToBeDeleted = new List<Id>();
            for(File__c newFile : newFilesById.values()){
                // If Public On Amazon gets updated
                if(newFile.Public_On_Amazon__c != oldFilesById.get(newFile.Id).Public_On_Amazon__c){
                    filesWithUpdatedPublicOnAmazon.add(newFile);
                }
                
                // If Name gets updated
                if(newFile.Name != oldFilesById.get(newFile.Id).Name){
                    filesWithUpdatedName.add(newFile);
                }
                
                // If name updated we need to update it in Amazon server as wel. We will copy existing file with new name and delete existing file
                if(newFile.Name != oldFilesById.get(newFile.Id).Name){
                    newAmazonFilePathsById.put(newFile.Id, (newFile.Public_On_Amazon__c ? 1: 0)+'-'+FileUtils.getAmazonFilePathWithBucket(newFile));
                    oldAmazonFilePathsById.put(newFile.Id, FileUtils.getAmazonFilePathWithBucket(oldFilesById.get(newFile.Id)));
                }
                
                // If the access type of file updated from private to public then delete access control fo that files.
                if((newFile.Access_Type__c == BT_Constants.FILE_ACCESS_PUBLIC_READ_ONLY || newFile.Access_Type__c == BT_Constants.FILE_ACCESS_PUBLIC_WRITE) && oldFilesById.get(newFile.Id).Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE){
                    fileIdsWhoseAccessControlNeedsToBeDeleted.add(newFile.Id);
                }
            }
            
            // Check for duplicate file name
            if(!filesWithUpdatedName.isempty()){
                FileUtils.checkForDuplicateFileName(filesWithUpdatedName);
            }
            
            // Delete file access controls
            if(!fileIdsWhoseAccessControlNeedsToBeDeleted.isEmpty()){
                // Delete File Access Controls.
                List<File_Access_Control__c> fileAccessControlsNeedsToBeDeleted ;
            if(Schema.sObjectType.File_Access_Control__c.fields.Id.isAccessible() &&
                Schema.sObjectType.File_Access_Control__c.fields.File__c.isAccessible()){
                fileAccessControlsNeedsToBeDeleted = [Select ID From File_Access_Control__c Where File__c In: fileIdsWhoseAccessControlNeedsToBeDeleted];
             }
                if(!fileAccessControlsNeedsToBeDeleted.isEmpty()){
                    DMLManager.deleteAsUser(fileAccessControlsNeedsToBeDeleted);
                }
            }
            
            // Rename the files on amazon server
            if(!newAmazonFilePathsById.keySet().isEmpty()){
                System.enqueueJob(new BT_RenameFilesQueueable(newAmazonFilePathsById, oldAmazonFilePathsById));
            }
            
            // Set the Access control for files
            if(!filesWithUpdatedPublicOnAmazon.isEmpty()){
                System.enqueueJob(new BT_UpdateFileAccessQueueable(filesWithUpdatedPublicOnAmazon));
            }
        }
    }
    
    /*
    *   Executed:   On before delete of files
    *   Purpose:    Deleting the file access controls and deleting the file from amazon as well.
    *   Parameters: 
    *   UnitTests:  
    */
    public void onBeforeDelete(Map<Id, File__c > oldFilesById) {
        if(!isSkipTrigger){
            // Deleting the file from amazon server
            System.enqueueJob(new BT_DeleteFilesQueueable(oldFilesById.values()));
            
            // Delete File Access Controls also.
            List<File_Access_Control__c> fileAccessControlsForDeletedFiles ;
            if(Schema.sObjectType.File_Access_Control__c.fields.Id.isAccessible() &&
            Schema.sObjectType.File_Access_Control__c.fields.File__c.isAccessible()){
             fileAccessControlsForDeletedFiles = [Select ID From File_Access_Control__c Where File__c In: oldFilesById.keySet()];
            }
            if(!fileAccessControlsForDeletedFiles.isEmpty()){
                BT_NoSharingUtils.deleteSobjects(fileAccessControlsForDeletedFiles);
            }
        }
    }
    
    /*
    *   Executed:   On after delete of files
    *   Purpose:    Deleting the source folders if the file is moved for folder moving.
    *   Parameters: 
    *   UnitTests:  
    */
    public void onAfterDelete(Map<Id, File__c > oldFilesById) {
        if(!isSkipTrigger){
            Set<Id> folderIdsToDelete = new Set<Id>();
            for(File__c file : oldFilesById.values()){
                folderIdsToDelete.add(file.Folder__c);
            }
            
            // Get all folders with Deleting status
            List<Folder__c> foldersToDelete = new List<Folder__c>();
            for(Folder__c folderToDelete : [Select Id, (Select Id From Files__r) From Folder__c where Id IN:folderIdsToDelete AND Upload_Status__c =: BT_Constants.FILE_UPLOAD_STATUS_DELETING]){
                foldersToDelete.add(folderToDelete);
            }
            
            // Delete all folders with deleting status
            if(!foldersToDelete.isEmpty()){
                FolderTriggerHandler.isSkipTrigger = true;
                DMLManager.deleteAsUser(foldersToDelete);
                FolderTriggerHandler.isSkipTrigger = false;
            }
        }
    }
}