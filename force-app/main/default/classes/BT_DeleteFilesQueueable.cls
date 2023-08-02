/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_DeleteFilesQueueable
* Created by Sagar: 27/09/2017
*
* Purpose/Methods:
* - Delete the files from amazon. This will be called from after delete trigger for files
*
* Unit Test: 
* 
* Modifications:
* - Sagar, 27/09/2017 - Initial Development
************************************************************************** */
public class BT_DeleteFilesQueueable implements Queueable, Database.AllowsCallouts  {
    
    // Files to delete.
    List<File__c> filesToDelete;
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_DeleteFilesQueueable(List<File__c> filesToDelete) {
        this.filesToDelete = filesToDelete;
    }
    
    /*
    *   Purpose:    Delete files from Amazon and schedule for remaining files.
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(QueueableContext context) {
        // Current time. Used in SOAP request for delete of files
        Datetime now = Datetime.now(); 
         
        // Get the AWS credetials
        AmazonS3Credential credential = new AmazonS3Credential();
        S3.AmazonS3 amazonS3 = new S3.AmazonS3(credential.key, credential.secret);
         
        try{
            // New list of files after delete first 50 files
            List<File__c> newFilesToDelete = new List<File__c>();
            // Went through all files and delete from amazon server
            integer i = 0;
            for(File__c fileToDelete : filesToDelete){
                if(i >= 100){
                    system.debug('if');
                    newFilesToDelete.add(fileToDelete);
                } else{
                    system.debug('else');
                    system.debug('Bucket Name -------> '+fileToDelete.Bucket_Name__c);
                    system.debug('File Key -------> '+fileToDelete.Amazon_File_Key__c);
                    system.debug('S3 Key -------> '+amazonS3.key);
                    system.debug('now -------> '+now);
                    system.debug('now -------> '+now);
                    system.debug('signature -------> '+amazonS3.signature('DeleteObject',now));
                    system.debug('secret -------> '+amazonS3.secret);
                    S3.Status deleteObjectReslt= amazonS3.DeleteObject(fileToDelete.Bucket_Name__c, fileToDelete.Amazon_File_Key__c, amazonS3.key, now, amazonS3.signature('DeleteObject',now), amazonS3.secret);
                }
                i++;
            }
            
            // If there are still files to delete, queue it using another job
            if(newFilesToDelete != null && !newFilesToDelete.isEmpty()){
                // Add the remaining files into schedule.
                BT_DeleteFilesSchedulable scheduledJob = new BT_DeleteFilesSchedulable(newFilesToDelete);
                
                // Time for next schedule
                DateTime scheduledTime = DateTime.Now().addSeconds(1);
                
                // Cron expression for next schedule
                String cronExpression = '' + scheduledTime.second() + ' ' + scheduledTime.minute() + ' ' + scheduledTime.hour() + ' ' + scheduledTime.day() + ' ' + scheduledTime.month() + ' ? ' + scheduledTime.year();
                System.schedule(BT_DeleteFilesSchedulable.class.getName() + '-' + System.Now() + '-' + Math.random(), cronExpression, scheduledJob);
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Delete File Job failed.', e.getMessage());
        }
    }
}