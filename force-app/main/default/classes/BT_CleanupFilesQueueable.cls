/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_CleanupFilesQueueable
* Created by Sagar: 27/09/2017
*
* Purpose/Methods:
* - Delete the files and folders as per the amazon server. We are doing it in future method to make that page readonly.
*
* Unit Test: 
* 
* Modifications:
* - Sagar, 27/09/2017 - Initial Development
************************************************************************** */
public class BT_CleanupFilesQueueable implements Queueable {
    
    // JSON for selected file ids to delete.
    List<String> setFileIdsToCleanUp;
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_CleanupFilesQueueable(List<String> setFileIdsToCleanUp) {
        this.setFileIdsToCleanUp = setFileIdsToCleanUp;
    }
    
    /*
    *   Purpose:    Delete  files from Salesforce
    *   Parameters: 
    *   UnitTests:  
    */
    public void execute(QueueableContext context) {
        try {
            // Files needs to delete
            List<File__c> filesNeedsToCleanup;
            if(Schema.sObjectType.File__c.fields.id.isAccessible()){
                filesNeedsToCleanup = [Select Id from File__c Where Id In: setFileIdsToCleanUp];    
            }
            if(!filesNeedsToCleanup.isEmpty()){
                FileTriggerHandler.isSkipTrigger = true;
                DMLManager.deleteAsUser(filesNeedsToCleanup);
                FileTriggerHandler.isSkipTrigger = false;
            }
            
            //Clear the job id
            BT_HomeUtils.setFileCleanupJobId('');
            // Sending email
            BT_Utils.sendJobSuccessEmail(context.getJobId(), System.label.Cleanup_File_Job_Status_Subject, System.label.Cleanup_File_Job_Status_Body);
        }  catch(Exception e){
            BT_Utils.sendJobFailureEmail('Cleanup Job failed.', e.getMessage());
        }
    }
}