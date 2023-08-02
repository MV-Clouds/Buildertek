/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_MoveFilesQueueable
* Created by Sagar: 04/09/2017
*
* Purpose/Methods:
* - Move file from source file. This will be called from after update trigger for files
*
* Unit Test: 
* 
* Modifications:
* - Sagar, 04/09/2017 - Initial Development
************************************************************************** */
public class BT_MoveFilesQueueable implements Queueable, Database.AllowsCallouts {
    
    // Files needs to move from source.
    List<File__c> filesNeedsToMoveFromSource = new List<File__c>();
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_MoveFilesQueueable(List<File__c> filesNeedsToMoveFromSource) {
        this.filesNeedsToMoveFromSource = filesNeedsToMoveFromSource;
    }
    
    /*
    *   Purpose:    Copy 100 files on Amazon from source and schedule for remaining files
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(QueueableContext context) {
        
        // Query files with source file
        Set<Id> fileIdsNeedsToMoveFromSource = new Set<Id>();
        for(File__c file : filesNeedsToMoveFromSource){
            fileIdsNeedsToMoveFromSource.add(file.Id);
        }
        
        List<String> fields = new List<String>{'Id', 'Bucket_Name__c', 'Public_On_Amazon__c', 'Amazon_File_Key__c', 'Source_File__c'};
        SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
        filesNeedsToMoveFromSource = BT_Utils.queryForWithOrWithoutSharing(true, 'Select '+BT_Utils.buildSelectListFragment(null, null, fields)+', Source_File__r.Bucket_Name__c, Source_File__r.Amazon_File_Key__c FROM File__c where Id In '+BT_Utils.prepareQueryStringForInClause(fileIdsNeedsToMoveFromSource));
        
        // List of files to update the status
        List<File__c> filesWithUpdatedStatus = new List<File__c>();
        
        // List of source files to delete
        List<File__c> sourceFilesToDelete = new List<File__c>();
        
        // Target Files by Source Files
        Map<Id, Id> targetFileIdsBySourceFileIds = new Map<Id, Id>();
                
        // Current time. Used in SOAP request for delete of files
        Datetime now = Datetime.now(); 
         
        // Get the AWS credetials
        AmazonS3Credential credential = new AmazonS3Credential();
        S3.AmazonS3 amazonS3 = new S3.AmazonS3(credential.key, credential.secret);
        
        // The canonical user Id. This is the owner of the files.
        String canonicalUserId = BT_HomeUtils.getAmazonCanonicalUserId();  
        
        try{
            // New list of files after copying first 100 files
            List<File__c> newFilesToMoveFromSource = new List<File__c>();
            
            // Went through all files and copy on amazon server
            integer i = 0;
            for(File__c fileToMove : filesNeedsToMoveFromSource){
                if(i >= 100){
                    newFilesToMoveFromSource.add(fileToMove);
                } else{
                    Boolean success = amazonS3.CopyObject_ACL(fileToMove.Source_File__r.Bucket_Name__c, fileToMove.Source_File__r.Amazon_File_Key__c, fileToMove.Bucket_Name__c, fileToMove.Amazon_File_Key__c , null, fileToMove.Public_On_Amazon__c ? 'public-write':null, amazonS3.key, now, amazonS3.signature('CopyObject', now), amazonS3.secret, canonicalUserId);
                    if(success){
                        fileToMove.Upload_Status__c  = BT_Constants.FILE_UPLOAD_STATUS_COMPLETED;
                        filesWithUpdatedStatus.add(fileToMove);
                        targetFileIdsBySourceFileIds.put(fileToMove.Source_File__c, fileToMove.Id);
                        sourceFilesToDelete.add(fileToMove.Source_File__r);
                    }
                }
                i++;
            }
            
            // Update the status of processed files
            if(!filesWithUpdatedStatus.isEmpty()){
                BT_NoSharingUtils.updateSobjects(filesWithUpdatedStatus);
            }
            
            // Copy File Access controls from source
            fields = new List<String>{'Id', 'File__c', 'Grantee__c', 'Download__c', 'View__c'};
            SOQLManager.checkFieldAccess(File_Access_Control__c.sObjectType, fields);
            List<File_Access_Control__c> fileAccessControlsForSourceFiles = BT_Utils.queryForWithOrWithoutSharing(true, 'Select '+BT_Utils.buildSelectListFragment(null, null, fields) +' From File_Access_Control__c Where File__c in '+BT_Utils.prepareQueryStringForInClause(targetFileIdsBySourceFileIds.keySet()));
            List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
            if(!fileAccessControlsForSourceFiles.isEmpty()){
                for(File_Access_Control__c fileAccessControlForSourceFile : fileAccessControlsForSourceFiles){
                    File_Access_Control__c fileAccessControl = fileAccessControlForSourceFile.clone(false,true,false,false);  
                    fileAccessControl.File__c = targetFileIdsBySourceFileIds.get(fileAccessControl.File__c);
                    fileAccessControls.add(fileAccessControl);
                }
                if(!fileAccessControls.isEmpty()){
                    DMLManager.insertAsUser(fileAccessControls);
                }
            }
            
            // Delete the source files
            if(!sourceFilesToDelete.isEmpty()){
                BT_NoSharingUtils.deleteSobjects(sourceFilesToDelete);
            }
            
            // If there are still files to copy, queue it using another job
            if(newFilesToMoveFromSource != null && !newFilesToMoveFromSource.isEmpty()){
                // Add the remaining files into schedule.
                BT_MoveFilesSchedulable scheduledJob = new BT_MoveFilesSchedulable(newFilesToMoveFromSource);
                
                // Time for next schedule
                DateTime scheduledTime = DateTime.Now().addSeconds(1);
                
                // Cron expression for next schedule
                String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                System.schedule(BT_MoveFilesSchedulable.class.getName() + '-' + System.Now() + '-' + Math.random(), cronExpression, scheduledJob);
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Move File Job failed.', e.getMessage());
        }
    }
}