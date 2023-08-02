/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Utils Class: FolderUtils
* Created by Sagar: 27/09/2017
*
* - All utility method for folder.

* - Modifications:
* - Sagar, 27/09/2017 – Initial Development
************************************************************************** */
public with sharing class FolderUtils{
    /*
    *   Executed:   On before insert of folder
    *   Purpose:    Setting the Amazon Folder Path
    *   Parameters: 
    *   UnitTests:  
    */
    public static void setAmazonFolderPath(List<Folder__c> folders){
        
        // Parent folder ids
        Set<Id> parentFolderIds = new Set<Id>();
        for(Folder__c folder: folders){
            parentFolderIds.add(folder.Parent__c);
        }
        
        // Get the parent folders.
        List<String> fields = new List<String>{'Id', 'Name', 'Amazon_File_Key__c', 'Amazon_File_Path__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        Map<Id, Folder__c> parentFoldersById = new Map<Id, Folder__c>();
        for(Folder__c folder : Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' from Folder__c Where Id In: parentFolderIds'))){
            parentFoldersById.put(folder.Id, folder);
        }
        for(Folder__c folder : folders){
            if(folder.Parent__c != null){
                Folder__c parentFolder = parentFoldersById.get(folder.Parent__c);
                folder.Amazon_File_Key__c = (parentFolder.Amazon_File_Key__c != null ? parentFolder.Amazon_File_Key__c+'/'+folder.Name : folder.Name);
            }
        }
    }
    
    /*
    *   Executed:   On after insert of folder
    *   Purpose:    Setting the Salesforce Folder Path
    *   Parameters: 
    *   UnitTests:  
    */
    public static void setSalesforceFolderPath(List<Folder__c> folders){
        // Parent folder ids
        Set<Id> parentFolderIds = new Set<Id>();
        for(Folder__c folder: folders){
            parentFolderIds.add(folder.Parent__c);
        }
        
        // Get the parent folders.
        List<String> fields = new List<String>{'Id', 'Name', 'Amazon_File_Key__c', 'Amazon_File_Path__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        Map<Id, Folder__c> parentFoldersById = new Map<Id, Folder__c>();
        for(Folder__c folder : Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' from Folder__c Where Id In: parentFolderIds'))){
            parentFoldersById.put(folder.Id, folder);
        }
        for(Folder__c folder : folders){
            if(folder.Parent__c != null){
                Folder__c parentFolder = parentFoldersById.get(folder.Parent__c);
                folder.Amazon_File_Path__c = (parentFolder.Amazon_File_Path__c != null ? parentFolder.Amazon_File_Path__c+'/'+Integer.valueOf(folder.Salesforce_Unique_Number__c) : String.valueOf(Integer.valueOf(folder.Salesforce_Unique_Number__c)));
            }
        }
    }
    
    /*
    *   Executed:   On before insert/update of folder
    *   Purpose:    Check for dupliacate folder path
    *   Parameters: 
    *   UnitTests:  
    */
    public static void checkForDuplicateFolderName(List<Folder__c> folders){
        // Check for the duplicate folder name
        Set<String> newFolderNames = new Set<String>();
        for(Folder__c folder: folders){
              newFolderNames.add(folder.Name);          
        }
        
        // Get other folder id with the same path by path
        Map<String, String> existingFolderIdsByPath = new Map<String, String>();
         Map<Id, buildertek__Folder__c> existingFolderparentIdsByPath = new Map<Id, buildertek__Folder__c>();
        List<Folder__c> existingFolders = BT_Utils.queryForWithOrWithoutSharing(true,'Select Id,Name,Amazon_File_Key__c,buildertek__Parent__c From Folder__c Where Name In '+BT_Utils.prepareQueryStringForInClause(newFolderNames));
        for(Folder__c folder : existingFolders){
            system.debug('folder.buildertek__Parent__c'+ folder.buildertek__Parent__c);
             existingFolderIdsByPath.put(folder.Amazon_File_Key__c, folder.Id);
            existingFolderparentIdsByPath.put(folder.buildertek__Parent__c,folder);
          system.debug('existingFolderIdsByPath.get(folder.buildertek__Parent__c)'+ existingFolderparentIdsByPath.values().size());  
        }
        
        // Check if there is any duplicate file found
       if(!existingFolderparentIdsByPath.values().isEmpty()){
          system.debug('*****'+folders);  
        for(buildertek__Folder__c folder: folders){
                system.debug('&&&&&'+folder.buildertek__Parent__c);
              //  system.debug('existingFolderIdsByPath.get(folder.buildertek__Parent__c)'+ existingFolderIdsByPath.get(folder.buildertek__Parent__c));
              //  system.debug('existingFolde'+ existingFolderIdsByPath.get(folder.Id));
              //  system.debug('existingFolderIdsByPath.get(folder.buildertek__Parent__c)'+ existingFolderparentIdsByPath.get(folder.Id).buildertek__Parent__c);
               // system.debug('existingFolde'+ existingFolderparentIdsByPath.get(folder));
             //   if(existingFolderIdsByPath.get(folder.Amazon_File_Key__c) != folder.Id){
                if(existingFolderparentIdsByPath.get(folder.buildertek__Parent__c) != null && existingFolderparentIdsByPath.get(folder.buildertek__Parent__c).Name == folder.Name){
                    folder.addError(String.format(system.Label.Duplicate_Folder_Name_Message, new String[]{folder.Name}));
                }
            }
        }
    }
    
    /*
    *   Purpose:    Get the Amazon Folder Path With Bucket
    *   Parameters: 
    *   UnitTests:  
    */
    public static String getAmazonFilePathWithBucket(Folder__c folder){
        String folderPathWithBucket = '';
        If(folder.Bucket_Name__c != null && folder.Bucket_Name__c != ''){
            folderPathWithBucket = folder.Bucket_Name__c+'/';
        }
        folderPathWithBucket += (folder.Amazon_File_Key__c != null && folder.Amazon_File_Key__c != '' ? folder.Amazon_File_Key__c : folder.Name);
        return folderPathWithBucket;
    }
    /*
    *   Executed:   On before update of folder
    *   Purpose:    Setting the Amazon Folder Path for all inner files and folders
    *   Parameters: 
    *   UnitTests:  
    */
    public static void updateAmazonFilePathForInnerFilesAndFolders(Map<Id, Folder__c> newFoldersWithUpdatedNameById, Map<Id, Folder__c> oldFoldersWithUpdatedNameById){
        // Subfolder ids by parent folder id
        Map<Id, Set<Folder__c>> subFoldersByParentFolderId = new Map<Id, Set<Folder__c>>(); 
        
        // New Amazon file path by folder id
        Map<Id, String> newAmazonFilePathByFolderId = new Map<Id, String>();
        
        // Old Amazon file path by folder id
        Map<Id, String> oldAmazonFilePathByFolderId = new Map<Id, String>();
        
        // Get the list of subfolders for all source folders
        List<Folder__c> subFoldersIncludingSourceFolders = FolderUtils.getAllSubFolders(oldFoldersWithUpdatedNameById.values(), true);

        // Went through all subfolders and parpare the map
        for(Folder__c folderNeedsToUpdate : subFoldersIncludingSourceFolders){
            // Prepare the map for parent to child folders
            Set<Folder__c> subFolders = subFoldersByParentFolderId.get(folderNeedsToUpdate.Parent__c);
            if(subFolders == null){
                subFolders = new Set<Folder__c>();
            }
            subFolders.add(folderNeedsToUpdate);
            subFoldersByParentFolderId.put(folderNeedsToUpdate.Parent__c, subFolders);
        }
        
        // Set of folders with updated amazon file path
        List<Folder__c> foldersWithUpdatedPath = new List<Folder__c>();
        
        // Prepare the map for Amazon file path by folder id
        for(Folder__c folderWithUpdatedName : newFoldersWithUpdatedNameById.values()){
            String newAmazonFolderPath = folderWithUpdatedName.Amazon_File_Key__c;
            String oldAmazonFolderPath = oldFoldersWithUpdatedNameById.get(folderWithUpdatedName.Id).Amazon_File_Key__c;
            
            newAmazonFilePathByFolderId.put(folderWithUpdatedName.Id, newAmazonFolderPath);
            oldAmazonFilePathByFolderId.put(folderWithUpdatedName.Id, oldAmazonFolderPath);
            
            for(Folder__c subFolder : getSubFolders(folderWithUpdatedName.Id, subFoldersByParentFolderId)){
                // Update the Amazon path for subfolders
                subFolder.Amazon_File_Key__c = subFolder.Amazon_File_Key__c.replaceFirst(oldAmazonFolderPath, newAmazonFolderPath);
                foldersWithUpdatedPath.add(subFolder);
                newAmazonFilePathByFolderId.put(subFolder.Id, newAmazonFolderPath);
                oldAmazonFilePathByFolderId.put(subFolder.Id, oldAmazonFolderPath);
            }
        }
        
        // Files with updated status
        List<File__c> filesWithUpdatedKeys = new List<File__c>();
        
        // New Amazon file path by file id
        Map<Id, String> newAmazonFilePathByFileId = new Map<Id, String>();
        
        // Old Amazon file path by file id
        Map<Id, String> oldAmazonFilePathByFileId = new Map<Id, String>();
        
        // Get all inner files for folders whose name gets updated
        for(File__c innerFile : getAllInnerFiles(oldFoldersWithUpdatedNameById.values())){
            String newAmazonFolderPath = newAmazonFilePathByFolderId.get(innerFile.Folder__c);
            String oldAmazonFolderPath = oldAmazonFilePathByFolderId.get(innerFile.Folder__c);
            
            newAmazonFilePathByFileId.put(innerFile.Id, (innerFile.Public_On_Amazon__c ? 1: 0)+'-'+innerFile.Bucket_Name__c+'/'+innerFile.Amazon_File_Key__c.replaceFirst(oldAmazonFolderPath, newAmazonFolderPath));
            oldAmazonFilePathByFileId.put(innerFile.Id, innerFile.Bucket_Name__c+'/'+innerFile.Amazon_File_Key__c);
            
            // Update the Amazon File Keys for inner files
            innerFile.Amazon_File_Key__c = innerFile.Amazon_File_Key__c.replaceFirst(oldAmazonFolderPath, newAmazonFolderPath);
            innerFile.Upload_Status__c = BT_Constants.FILE_UPLOAD_STATUS_COPYING;
            filesWithUpdatedKeys.add(innerFile);
        }

        // Update the path on Amazon Server
        if(!newAmazonFilePathByFileId.keySet().isEmpty()){
            System.enqueueJob(new BT_RenameFilesQueueable(newAmazonFilePathByFileId, oldAmazonFilePathByFileId));
        }
        
        // Update the Amazon File key for inner files
        if(!filesWithUpdatedKeys.isEmpty()){
            FileTriggerHandler.isSkipTrigger = true;
            BT_NoSharingUtils.updateSobjects(filesWithUpdatedKeys);
            FileTriggerHandler.isSkipTrigger = false;
        }
        
        // Update the Amazon File path for subfolders
        if(!foldersWithUpdatedPath.isEmpty()){
            FolderTriggerHandler.isSkipTrigger = true;
            BT_NoSharingUtils.updateSobjects(foldersWithUpdatedPath);
            FolderTriggerHandler.isSkipTrigger = false;
        }
    }
    
    /*
    *   Purpose:    Get all inner files undert the folders using amazon file path
    *   Parameters: 
    *   UnitTests:  
    */
    public static List<File__c> getAllInnerFiles(List<Folder__c> folders){
        // Query all inner files
        List<File__c> files = new List<File__c>();
        String queryForFiles = 'SELECT '+BT_Utils.getQueryStringForObjectWithAllFields(BT_Constants.OBJECT_TYPE_FILE)+' FROM File__c ';
        
        // Where clause for inner files
        String whereClauseForFiles = ' ID != null';
        whereClauseForFiles += ' AND (' +FolderUtils.getWhereClauseForAmazonPath(folders)+ ')';
        if(whereClauseForFiles != null && whereClauseForFiles != ''){
            queryForFiles += ' WHERE ' + whereClauseForFiles;
        }
        queryForFiles += ' order by Amazon_File_Path_With_Bucket__c';
        
        // Query all files
        files = BT_Utils.queryForWithOrWithoutSharing(true, queryForFiles);
        return files;
    }
    
    /*
    *   Executed:   To prepare the updated the amazon file path
    *   Purpose:    This method will return Set of  subfolders with amazon file path
    *   Parameters: 
    *   UnitTests:  
    */
    public static Set<Folder__c> getSubFolders(Id folderId, Map<Id, Set<Folder__c>> subFoldersByParentFolderId){
        Set<Folder__c> subFolders = new Set<Folder__c>();
        if(subFoldersByParentFolderId.get(folderId) == null){
            return new Set<Folder__c>();
        }
        for(Folder__c subFolder : subFoldersByParentFolderId.get(folderId)){
            subFolders.add(subFolder);
            subFolders.addAll(FolderUtils.getSubFolders(subFolder.Id, subFoldersByParentFolderId));
        }
        return subFolders;
    }
    
    /*
    *   Executed:   At the time of paste. To prepare thr updated the amazon file path
    *   Purpose:    This method will return list of  subfolders with amazon file path
    *   Parameters: 
    *   UnitTests:  
    */
    public static Set<Id> getSubFolders(Id folderId , Map<Id, Set<Id>> subFolderIdsByParentFolderId){
        Set<Id> subFolderIds = new Set<Id>();
        if(subFolderIdsByParentFolderId.get(folderId) == null){
            return new Set<Id>();
        }
        for(Id subFolderId : subFolderIdsByParentFolderId.get(folderId)){
            subFolderIds.add(subFolderId);
            subFolderIds.addAll(FolderUtils.getSubFolders(subFolderId, subFolderIdsByParentFolderId));
        }
        return subFolderIds;
    }
    
    /*
    *   Purpose:    Get all sub folders under the folders using amazon file path
    *   Parameters: 
    *   UnitTests:  
    */
    public static List<Folder__c> getAllSubFolders(List<Folder__c> folders, Boolean includesParent){
        // Query all sub folders
        List<Folder__c> subFolders = new List<Folder__c>();
        String queryForSubFolders = 'SELECT '+BT_Utils.getQueryStringForObjectWithAllFields(BT_Constants.OBJECT_TYPE_FOLDER)+' FROM Folder__c ';
        
        // Set of folder ids
        Set<Id> folderIds = new Set<Id>();
        for(Folder__c folder : folders){
            folderIds.add(folder.Id);
        }
        
        // Where clause for sub folders
        String whereClauseForSubFolders = ' ID != null ';
        whereClauseForSubFolders += ' AND (' +FolderUtils.getWhereClauseForAmazonPath(folders);
        if(includesParent){
            whereClauseForSubFolders += ' OR ID In '+BT_Utils.prepareQueryStringForInClause(folderIds);
        }
        whereClauseForSubFolders += ')';
        if(whereClauseForSubFolders != null && whereClauseForSubFolders != ''){
            queryForSubFolders += ' WHERE ' + whereClauseForSubFolders;
        }
        queryForSubFolders += ' order by Amazon_File_Path_With_Bucket__c';
        // Query all files
        subFolders = BT_Utils.queryForWithOrWithoutSharing(true, queryForSubFolders);
        return subFolders;
    }
    
    /*
    *   Purpose:    Get where cluse for subfolder using amazon file path
    *   Parameters: 
    *   UnitTests:  
    */
    public static string getWhereClauseForAmazonPath(List<Folder__c> folders){
        String whereClauseForAmazonPath = '';
        for(Folder__c folder : folders){
            whereClauseForAmazonPath += ' Amazon_File_Path_With_Bucket__c LIKE \''+ String.escapeSingleQuotes(folder.Amazon_File_Path_With_Bucket__c)+'/%\' OR ';
        }
        if (whereClauseForAmazonPath != null && whereClauseForAmazonPath.length() > 3) {
            whereClauseForAmazonPath = whereClauseForAmazonPath.substring(0, whereClauseForAmazonPath.length() - 3);
        }
        return whereClauseForAmazonPath;    
    }
    
    /*
    *   Purpose:    After inser/update of folder which is copoed from another folder. This methpd will create files for the new folder using the source folder.
    *   Parameters: 
    *   UnitTests:  
    */
    public static void createFilesForFoldersUsingSourceFolders(List<Folder__c> folders){
        // Folders needs to copy from source.
        List<Folder__c> foldersNeedsToCopyFromSource = new List<Folder__c>();
        
        // Folders needs to move from source.
        List<Folder__c> foldersNeedsToMoveFromSource = new List<Folder__c>();
        
        // Source folders needs to move
        Set<Id> sourceFolderIds = new Set<Id>();
        
        for(Folder__c folder : folders){
            if(folder.Parent__c != null && folder.Source_Folder__c != null && folder.Upload_Status__c != BT_Constants.FILE_UPLOAD_STATUS_COMPLETED && folder.Upload_Status__c != BT_Constants.FILE_UPLOAD_STATUS_DELETING){
                sourceFolderIds.add(folder.Source_Folder__c);
            }
        }
        
        // Find the files for folders create file for them
        Map<Id, Folder__c> sourceFoldersWithFilesById = new Map<Id, Folder__c>();
        
        // All source folders with files
        List<Folder__c> sourceFoldersWithFiles = new List<Folder__c>();
        if(!sourceFolderIds.isEmpty()){
            sourceFoldersWithFiles = BT_Utils.queryForWithOrWithoutSharing(true,'Select '+BT_Utils.getQueryStringForObjectWithAllFields(BT_Constants.OBJECT_TYPE_FOLDER)+' , (Select '+BT_Utils.getQueryStringForObjectWithAllFields(BT_Constants.OBJECT_TYPE_FILE)+'  From Files__r Where Upload_Status__c = null OR Upload_Status__c  = \''+BT_Constants.FILE_UPLOAD_STATUS_COMPLETED +'\') From Folder__c Where Id in' + BT_Utils.prepareQueryStringForInClause(sourceFolderIds));
        }
        
        for(Folder__c sourceFolderWithFiles : sourceFoldersWithFiles){
            sourceFoldersWithFilesById.put(sourceFolderWithFiles.Id, sourceFolderWithFiles);
        }
        
        // New files which are pasted from source files and folders 
        List<File__c> pastedFiles = new List<File__c>();
        
        // Source files to update the status
        List<File__c> sourceFilesWithUpdatedStatus = new List<File__c>();
        
        // Went through all new folders and create files
        for(Folder__c folder : folders){
            if(folder.Parent__c != null && folder.Source_Folder__c != null && folder.Upload_Status__c != BT_Constants.FILE_UPLOAD_STATUS_COMPLETED && folder.Upload_Status__c != BT_Constants.FILE_UPLOAD_STATUS_DELETING){
                
                Folder__c sourceFolder = sourceFoldersWithFilesById.get(folder.Source_Folder__c);
                if(sourceFolder != null && !sourceFolder.Files__r.isEmpty()){
                    
                    // Going through all source files and created respective copy of that file in amazon as well in salesforce database
                    for(File__c sourceFile : sourceFolder.Files__r){
                        
                        // Creating copy of that file in salesforce data base
                        File__c pastedFile = new File__c();
                        pastedFile = sourceFile.clone(false,true,false,false);
                        
                        // Set the source for the file needs to be pasted
                        pastedFile.Source_File__c  = sourceFile.Id;
                        
                        // Set the uplaod status.
                        pastedFile.Upload_Status__c  = folder.Upload_Status__c;
                        
                        // Folder is cutted then delete the source file from Amazon and salesorce database
                        if(folder.Upload_Status__c == BT_Constants.FILE_UPLOAD_STATUS_MOVING){
                            sourceFile.Upload_Status__c  = BT_Constants.FILE_UPLOAD_STATUS_DELETING;
                            sourceFilesWithUpdatedStatus.add(sourceFile);
                        }
                        
                        // Set the bucket name and other fields
                        pastedFile.Bucket_Name__c = sourceFolder.Bucket_Name__c;
                        pastedFile.Parent_Object_API_Name__c = sourceFolder.Parent_Object_API_Name__c;
                        if(pastedFile.Parent_Object_API_Name__c != null && pastedFile.Parent_Object_API_Name__c != ''){
                            pastedFile.put(pastedFile.Parent_Object_API_Name__c, sourceFolder.get(sourceFolder.Parent_Object_API_Name__c));
                        }
                        pastedFile.Folder__c = folder.Id;
                        pastedFiles.add(pastedFile);
                    }
                }
            }
        }
        // Update the status of source files
        if(!sourceFilesWithUpdatedStatus.isEmpty()){
            BT_NoSharingUtils.updateSobjects(sourceFilesWithUpdatedStatus);
        }
        
        // Insert new files for copy and move
        if(!pastedFiles.isEmpty()){
            DMLManager.insertAsUser(pastedFiles);
        }
    }
}