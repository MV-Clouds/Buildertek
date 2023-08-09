/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_CopyFilesSchedulable
* Created by Sagar: 04/09/2017
*
* Schedulable class to copy files on Amazon Server. We cannnot chain the Queueable job which contain web service callout 
* So we need to do it through schedulable

* - Modifications:
* - Sagar, 04/09/2017 - Initial Development
************************************************************************** */
public with sharing class BT_CopyFilesSchedulable implements Schedulable{
    // Files to copy.
    List<File__c> filesNeedsToCopyFromSource;
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_CopyFilesSchedulable(List<File__c> filesNeedsToCopyFromSource) {
        this.filesNeedsToCopyFromSource = filesNeedsToCopyFromSource;
    }
    
    /*
    *   Purpose:    Copy next 100 files on Amazon
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(SchedulableContext context) {
        try{
            // If there are still files to copy, queue it using another job
            if(filesNeedsToCopyFromSource != null && !filesNeedsToCopyFromSource.isEmpty()){
                System.enqueueJob(new BT_CopyFilesQueueable(filesNeedsToCopyFromSource));
            } 
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Copy File Schedule Job failed.', e.getMessage());
        }
        
    }
}