/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_UpdateFileAccessQueueable
* Created by Sagar: 24/09/2017
*
* Purpose/Methods:
* - Update the access controls of files on amazon. This will be called from after update trigger for files
*
* Unit Test: 
* 
* Modifications:
* - Sagar, 24/09/2017 - Initial Development
************************************************************************** */
public with sharing class BT_UpdateFileAccessQueueable implements Queueable, Database.AllowsCallouts{
    // File with updated Public On Amazon
    List<File__c> filesWithUpdatedPublicOnAmazon;
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_UpdateFileAccessQueueable(List<File__c> filesWithUpdatedPublicOnAmazon){
        this.filesWithUpdatedPublicOnAmazon = filesWithUpdatedPublicOnAmazon;
    }
    
    /*
    *   Purpose:    Update access for 100 files from Amazon and schedule for remaining files
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(QueueableContext context) {
        // Current time. Used in SOAP request for delete of files
        Datetime now = Datetime.now(); 
         
        // Get the AWS credetials
        AmazonS3Credential credential = new AmazonS3Credential();
        S3.AmazonS3 amazonS3 = new S3.AmazonS3(credential.key, credential.secret);
        
        // The canonical user Id. This is the owner of the files. Access will be revoked from everyone and granted only to file owner.
        String canonicalUserId = BT_HomeUtils.getAmazonCanonicalUserId(); 
        try{
            // New list of files after updating access for first 100 files
            List<File__c> newFilesWithUpdatedPublicOnAmazon = new List<File__c>();
            
            // Went through all file update access control on amazon server.
            integer i = 0;
            for(File__c objFile : filesWithUpdatedPublicOnAmazon){
                if(i >= 100){
                    newFilesWithUpdatedPublicOnAmazon.add(objFile);
                } else{
                    if(objFile.Public_On_Amazon__c){
                        // Grant the file access.
                        amazonS3.SetObjectAccessControlPolicy(objFile.Bucket_Name__c, objFile.Amazon_File_Key__c, 'public-write', amazonS3.key, now, amazonS3.signature('SetObjectAccessControlPolicy', now), amazonS3.secret, null);
                    } else{
                        // Revoke the file access.
                        amazonS3.SetObjectAccessControlPolicy(objFile.Bucket_Name__c, objFile.Amazon_File_Key__c, null, amazonS3.key, now, amazonS3.signature('SetObjectAccessControlPolicy', now), amazonS3.secret, canonicalUserId);
                    }
                }
                i++;
            }
            
            // If there are still files to update access, queue it using another job
            if(newFilesWithUpdatedPublicOnAmazon != null && !newFilesWithUpdatedPublicOnAmazon.isEmpty()){
                // Add the remaining files into schedule.
                BT_UpdateFileAccessSchedulable scheduledJob = new BT_UpdateFileAccessSchedulable(newFilesWithUpdatedPublicOnAmazon);
                
                // Time for next schedule
                DateTime scheduledTime = DateTime.Now().addSeconds(1);
                
                // Cron expression for next schedule
                String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                System.schedule(BT_UpdateFileAccessSchedulable.class.getName() + '-' + System.Now() + '-' + Math.random(), cronExpression, scheduledJob);
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Update File Access Job failed.', e.getMessage());
        }
    }
}