/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_RenameFilesQueueable
* Created by Sagar: 27/09/2017
*
* Purpose/Methods:
* - Rename the files from amazon. This will be called from after update trigger for files
*
* Unit Test: 
* 
* Modifications:
* - Sagar, 27/09/2017 - Initial Development
************************************************************************** */
public class BT_RenameFilesQueueable implements Queueable, Database.AllowsCallouts {
    
    // New Amazon File Paths  by Id.
    Map<Id, String> newAmazonFilePathsById = new Map<Id, String>();
    // Old Amazon File Paths by Id.
    Map<Id, String> oldAmazonFilePathsById = new Map<Id, String>();
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_RenameFilesQueueable(Map<Id, String> newAmazonFilePathsById, Map<Id, String> oldAmazonFilePathsById) {
        this.newAmazonFilePathsById = newAmazonFilePathsById;
        this.oldAmazonFilePathsById = oldAmazonFilePathsById;
    }
    
    /*
    *   Purpose:    Rename 50 files from Amazon and schedule for remaining files
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(QueueableContext context) {
        // Current time. Used in SOAP request for delete of files
        Datetime now = Datetime.now(); 
         
        // Get the AWS credetials
        AmazonS3Credential credential = new AmazonS3Credential();
        S3.AmazonS3 amazonS3 = new S3.AmazonS3(credential.key, credential.secret);
        
        // The canonical user Id. This is the owner of the files.
        String canonicalUserId = BT_HomeUtils.getAmazonCanonicalUserId(); 
        
        try{
            // File Id with to update the status
            Set<Id> fileIdToUpdateStatus = new Set<Id>();
            
            // Went through all file path and copy them on amazon server with updated name
            integer i = 0;
            for(Id newFileId : newAmazonFilePathsById.keyset()){
                if(i >= 50){
                    break;
                } else{
                    String newFileAccessType = newAmazonFilePathsById.get(newFileId).substring(0, 1);
                    String newAmazonFilePath = newAmazonFilePathsById.get(newFileId).substring(2, newAmazonFilePathsById.get(newFileId).length());
                    String oldAmazonFilePath = oldAmazonFilePathsById.get(newFileId);
                    
                    String newFileBucket = newAmazonFilePath.split('/')[0];
                    String newFileKey = newAmazonFilePath.substring(newFileBucket.length() + 1, newAmazonFilePath.length());
                    
                    String oldFileBucket = oldAmazonFilePath.split('/')[0];
                    String oldFileKey = oldAmazonFilePath.substring(oldFileBucket.length() + 1, oldAmazonFilePath.length());
                    
                    Boolean success = amazonS3.CopyObject_ACL(oldFileBucket, oldFileKey, newFileBucket, newFileKey , null, newFileAccessType == '1' ? 'public-write' : null, amazonS3.key, now, amazonS3.signature('CopyObject', now), amazonS3.secret, canonicalUserId);
                    if(success){
                        S3.Status deleteObjectReslt= amazonS3.DeleteObject(oldFileBucket, oldFileKey, amazonS3.key, now, amazonS3.signature('DeleteObject', now), amazonS3.secret);
                        fileIdToUpdateStatus.add(newFileId);
                    }
                    newAmazonFilePathsById.remove(newFileId);
                    oldAmazonFilePathsById.remove(newFileId);
                }
                i++;
            }
            // Mark upload status to complete
            if(!fileIdToUpdateStatus.isEmpty()){
                List<String> fields = new List<String>{'Id', 'Bucket_Name__c', 'Amazon_File_Key__c', 'File_Presigned_URL__c', 'Upload_Status__c', 'Public_On_Amazon__c', 'Allow_to_Download_by_Presigned_URL__c', 'Presigned_URL_Frequency__c', 'Presigned_URL_Expire_Date__c'};
                SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
                List<File__c> filesToUpdateStatus =  Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File__c Where Id In: fileIdToUpdateStatus');
                FileUtils.setPresignedURL(filesToUpdateStatus);
                for(File__c file : filesToUpdateStatus){
                    SYstem.debug(file.File_Presigned_URL__c);
                    file.Upload_Status__c = BT_Constants.FILE_UPLOAD_STATUS_COMPLETED;
                }
                // Update the Status of files
                FileTriggerHandler.isSkipTrigger = true;
                BT_NoSharingUtils.updateSobjects(filesToUpdateStatus);
                FileTriggerHandler.isSkipTrigger = false;
            }
            
            // If there are still files to delete, queue it using another job
            if(newAmazonFilePathsById != null && !newAmazonFilePathsById.keySet().isEmpty()){
                // Add the remaining files into schedule.
                BT_RenameFilesSchedulable scheduledJob = new BT_RenameFilesSchedulable(newAmazonFilePathsById, oldAmazonFilePathsById);
                
                // Time for next schedule
                DateTime scheduledTime = DateTime.Now().addSeconds(1);
                
                // Cron expression for next schedule
                String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                System.schedule(BT_RenameFilesSchedulable.class.getName() + '-' + System.Now() + '-' + Math.random(), cronExpression, scheduledJob);
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Rename File Job failed.', e.getMessage());
        }
    }
}