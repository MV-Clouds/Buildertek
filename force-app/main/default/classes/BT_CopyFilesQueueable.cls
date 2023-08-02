/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_CopyFilesQueueable
* Created by Sagar: 04/09/2017
*
* Purpose/Methods:
* - Copy file from source file. This will be called from after update trigger for files
*
* Unit Test: 
* 
* Modifications:
* - Sagar, 04/09/2017 - Initial Development
************************************************************************** */
public class BT_CopyFilesQueueable implements Queueable, Database.AllowsCallouts {
    
    // Files needs to copy from source.
    List<File__c> filesNeedsToCopyFromSource = new List<File__c>();
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_CopyFilesQueueable(List<File__c> filesNeedsToCopyFromSource) {
        this.filesNeedsToCopyFromSource = filesNeedsToCopyFromSource;
    }
    
    /*
    *   Purpose:    Copy 100 files on Amazon from source and schedule for remaining files
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(QueueableContext context) {
        // Query files with source file
        Set<Id> fileIdsNeedsToCopyFromSource = new Set<Id>();
        for(File__c file : filesNeedsToCopyFromSource){
            fileIdsNeedsToCopyFromSource.add(file.Id);
        }
        
        // Query files with source file
        List<String> fields = new List<String>{'Id', 'Bucket_Name__c', 'Amazon_File_Key__c', 'Public_On_Amazon__c', 'Source_File__c'};
        SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
        filesNeedsToCopyFromSource =  BT_Utils.queryForWithOrWithoutSharing(true,'Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ', Source_File__r.Bucket_Name__c, Source_File__r.Amazon_File_Key__c FROM File__c where Id In '+BT_Utils.prepareQueryStringForInClause(fileIdsNeedsToCopyFromSource));
        
        // List of files to update the status
        List<File__c> filesWithUpdatedStatus = new List<File__c>();
        
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
            List<File__c> newFilesToCopyFromSource = new List<File__c>();
            
            // Went through all files and copy on amazon server
            integer i = 0;
            for(File__c fileToCopy : filesNeedsToCopyFromSource){
                if(i >= 100){
                    newFilesToCopyFromSource.add(fileToCopy);
                } else{
                    Boolean success = amazonS3.CopyObject_ACL(fileToCopy.Source_File__r.Bucket_Name__c, fileToCopy.Source_File__r.Amazon_File_Key__c, fileToCopy.Bucket_Name__c, fileToCopy.Amazon_File_Key__c , null, fileToCopy.Public_On_Amazon__c ? 'public-write' : null, amazonS3.key, now, amazonS3.signature('CopyObject', now), amazonS3.secret, canonicalUserId);
                    if(success){
                        fileToCopy.Upload_Status__c  = BT_Constants.FILE_UPLOAD_STATUS_COMPLETED;
                        targetFileIdsBySourceFileIds.put(fileToCopy.Source_File__c, fileToCopy.Id);
                        filesWithUpdatedStatus.add(fileToCopy);
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
            List<File_Access_Control__c> fileAccessControlsForSourceFiles = BT_Utils.queryForWithOrWithoutSharing(true, 'Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File_Access_Control__c Where File__c in '+BT_Utils.prepareQueryStringForInClause(targetFileIdsBySourceFileIds.keySet()));
            List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
            if(!fileAccessControlsForSourceFiles.isEmpty()){
                for(File_Access_Control__c fileAccessControlForSourceFile : fileAccessControlsForSourceFiles){
                    File_Access_Control__c fileAccessControl = fileAccessControlForSourceFile.clone(false,true,false,false);  
                    fileAccessControl.File__c = targetFileIdsBySourceFileIds.get(fileAccessControl.File__c);
                    fileAccessControls.add(fileAccessControl);
                }
                if(!fileAccessControls.isEmpty()){
                    BT_NoSharingUtils.doInsert(fileAccessControls, true);
                }
            }
            
            // If there are still files to copy, queue it using another job
            if(newFilesToCopyFromSource != null && !newFilesToCopyFromSource.isEmpty()){
                // Add the remaining files into schedule.
                BT_CopyFilesSchedulable scheduledJob = new BT_CopyFilesSchedulable(newFilesToCopyFromSource);
                
                // Time for next schedule
                DateTime scheduledTime = DateTime.Now().addSeconds(1);
                
                // Cron expression for next schedule
                String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                System.schedule(BT_CopyFilesSchedulable.class.getName() + '-' + System.Now() + '-' + Math.random(), cronExpression, scheduledJob);
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Copy File Job failed.', String.valueof(e));
        }
    }
}