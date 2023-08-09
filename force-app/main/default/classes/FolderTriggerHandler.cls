/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: FolderTriggerHandler
* Created by Sagar: 15/05/2017
*
* - Trigger Handler Class for Folder Trigger
* - Set the Amazon path for all new folder and all child folders

* - Modifications:
* - Sagar, 25/05/2017 – Initial Development
************************************************************************** */
public with sharing class FolderTriggerHandler {
    public static Boolean isSkipTrigger = false;
    
    /*
    *   Executed:   On before insert of folder
    *   Purpose:    Setting the Amazon Folder Path
    *   Parameters: 
    *   UnitTests:  
    */
    public void onBeforeInsert(List<Folder__c> newFolders) {
        if(isSkipTrigger){
            return;
        }
         // Setting the Amazon Folder Path
        FolderUtils.setAmazonFolderPath(newFolders);
        
        // Check for duplicate folder name
        FolderUtils.checkForDuplicateFolderName(newFolders);
        
    }
    
    /*
    *   Executed:   On after insert of folder
    *   Purpose:    Creating file if folder is copied or moved
    *   Parameters: 
    *   UnitTests:  
    */
    public void onAfterInsert(List<Folder__c> newFolders) {
        if(isSkipTrigger){
            return;
        }
        
        // Query all folders to set Salesforce File Path
        List<String> fields = new List<String>{'Id', 'Name', 'Amazon_File_Key__c', 'Amazon_File_Path__c', 'Parent__c', 'Salesforce_Unique_Number__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
         List<Folder__c> foldersToSetSalesforceFilePath;
        /*if(Schema.sObjectType.Folder__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Folder__c.fields.Name.isAccessible()&&
            Schema.sObjectType.Folder__c.fields.Amazon_File_Key__c.isAccessible()&&
            Schema.sObjectType.Folder__c.fields.Amazon_File_Path__c.isAccessible() &&
            Schema.sObjectType.Folder__c.fields.Parent__c.isAccessible() ){*/
            foldersToSetSalesforceFilePath = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ', Parent__r.Amazon_File_Key__c, Parent__r.Amazon_File_Path__c From Folder__c Where Id In: newFolders'));
            /*}*/
        // Again setting the Salesforce Path
        FolderUtils.setSalesforceFolderPath(foldersToSetSalesforceFilePath);
        
        // Update the Amazon Folder Path
        if(Schema.sObjectType.Folder__c.fields.Name.isUpdateable()&&
            Schema.sObjectType.Folder__c.fields.Amazon_File_Key__c.isUpdateable()&&
            Schema.sObjectType.Folder__c.fields.Amazon_File_Path__c.isUpdateable() &&
            Schema.sObjectType.Folder__c.fields.Parent__c.isUpdateable() ){
            update foldersToSetSalesforceFilePath;
            }
        
        // Create the file from source folders files
        FolderUtils.createFilesForFoldersUsingSourceFolders(newFolders);
    }
    
    /*
    *   Executed:   On before update of folder
    *   Purpose:    Setting the Amazon Folder Path for all subfolders if the parent folders name get updated
    *   Parameters: 
    *   UnitTests:  
    */
    public void onBeforeUpdate(Map<Id, Folder__c > mapNewFoldersById, Map<Id, Folder__c> mapOldFoldersById) {
        if(isSkipTrigger){
            return;
        }
        
        // New Folder whose Name updated
        Map<Id, Folder__c> newFoldersWithUpdatedNameById = new Map<Id, Folder__c>();
        
        // Old Folder whose Name updated
        Map<Id, Folder__c> oldFoldersWithUpdatedNameById = new Map<Id, Folder__c>();
        
        // Set the external folder path
        for(Folder__c folder : mapNewFoldersById.values()){
            if(folder.Name != null && folder.Name != mapOldFoldersById.get(folder.Id).Name){
                newFoldersWithUpdatedNameById.put(folder.Id, folder);
                oldFoldersWithUpdatedNameById.put(folder.Id, mapOldFoldersById.get(folder.Id));
            }
        }
        
        if(!newFoldersWithUpdatedNameById.isEmpty()){
            // Setting the Amazon Folder Path
            FolderUtils.setAmazonFolderPath(newFoldersWithUpdatedNameById.values());
            
            // Check for duplicate folder name
            FolderUtils.checkForDuplicateFolderName(newFoldersWithUpdatedNameById.values());
            
            // Again setting the Salesforce Path
            FolderUtils.setSalesforceFolderPath(newFoldersWithUpdatedNameById.values());
            
            // Update the amazon file path for inner files and folders when parents name get updates 
            FolderUtils.updateAmazonFilePathForInnerFilesAndFolders(newFoldersWithUpdatedNameById, oldFoldersWithUpdatedNameById);
        }
    }
    
    /*
    *   Executed:   On after update of folder
    *   Purpose:    Setting the Amazon Folder Path for all subfolders if the parent get updated
    *   Parameters: 
    *   UnitTests:  
    */
    public void onAfterUpdate(Map<Id, Folder__c > mapNewFoldersById, Map<Id, Folder__c> mapOldFoldersById) {
        if(isSkipTrigger){
            return;
        }
        
        // We dont need to create files for folder whose name updates because it will be created in before update trigger
        List<Folder__c> foldersToCopy = new List<Folder__c>();
        for(Folder__c folder : mapNewFoldersById.values()){
            if(folder.Name == mapOldFoldersById.get(folder.Id).Name){
                foldersToCopy.add(folder);
            }
        }
        // Create the file from source folders files
        if(!foldersToCopy.isEmpty()){
            FolderUtils.createFilesForFoldersUsingSourceFolders(foldersToCopy);
        }
    }
    
    /*
    *   Executed:   On before delete of folder
    *   Purpose:    Deleting all subfolders and also deleting all files under that folder 
    *   Parameters: 
    *   UnitTests:  
    */
    public void onBeforeDelete(Map<Id, Folder__c > oldFoldersById) {
        if(isSkipTrigger){
            return;
        }
        
        // Check that its not folder for bucket. If it is only System Admin will be allowed to delete it
        Profile currentUserProfile;
        if(Schema.sObjectType.Profile.fields.Id.isAccessible() &&
            Schema.sObjectType.Profile.fields.Name.isAccessible()){
             currentUserProfile = [Select Name From Profile Where Id =: UserInfo.getProfileId() LIMIT 1];
            }
        if(currentUserProfile != null && currentUserProfile.Name != 'System Administrator'){
            for(Folder__c folder : oldFoldersById.values()){
                if(folder.Parent__c == null){
                    folder.addError(System.Label.Bucket_Delete_Validation);
                    return;
                }
            }
        }
        
        // Query file needs to delete from Amazon server
        List<File__c> filesToDelete = new List<File__c>();
        filesToDelete = FolderUtils.getAllInnerFiles(oldFoldersById.values());
        
        // Delete files
        if(!filesToDelete.isEmpty()){
            BT_NoSharingUtils.deleteSobjects(filesToDelete);
        }
        
        // Query all subfolders of the folders to delete
        List<Folder__c> subFoldersToDelete = new List<Folder__c>();
        subFoldersToDelete = FolderUtils.getAllSubFolders(oldFoldersById.values(), false);
        
        if(!subFoldersToDelete.isEmpty()){
            // Skip the trigger as we are deleting all subfolders 
            FolderTriggerHandler.isSkipTrigger = true;
            BT_NoSharingUtils.deleteSobjects(subFoldersToDelete);
            FolderTriggerHandler.isSkipTrigger = false;
        }
    }
}