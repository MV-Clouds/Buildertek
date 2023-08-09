/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_DeleteFilesSchedulable
* Created by Sagar: 27/09/2017
*
* Schedulable class to delete files from Amazon Server. We cannnot chain the Queueable job which contain web service callout 
* So we need to do it through schedulable

* - Modifications:
* - Sagar, 27/03/201 - Initial Development
************************************************************************** */
public with sharing class BT_DeleteFilesSchedulable implements Schedulable{
    // Files to delete.
    List<File__c> filesToDelete;
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_DeleteFilesSchedulable(List<File__c> filesToDelete) {
        this.filesToDelete = filesToDelete;
    }
    
    /*
    *   Purpose:    Delete next 100 files from Amazon
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(SchedulableContext context) {
        try{
            // If there are still files to delete, queue it using another job
            if(filesToDelete != null && !filesToDelete.isEmpty()){
                System.enqueueJob(new BT_DeleteFilesQueueable(filesToDelete));
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Delete File Schedule Job failed.', e.getMessage());
        }
        
    }
}