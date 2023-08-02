/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_UpdateFileAccessSchedulable
* Created by Sagar: 24/09/2017
*
* Schedulable class to update access control of files on Amazon Server. We cannnot chain the Queueable job which contain web service callout 
* So we need to do it through schedulable

* - Modifications:
* - Sagar, 24/09/2017 - Initial Development
************************************************************************** */
public with sharing class BT_UpdateFileAccessSchedulable implements Schedulable{
    // File with updated Public On Amazon
    List<File__c> filesWithUpdatedPublicOnAmazon;
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_UpdateFileAccessSchedulable(List<File__c> filesWithUpdatedPublicOnAmazon) {
        this.filesWithUpdatedPublicOnAmazon = filesWithUpdatedPublicOnAmazon;
    }
    
    /*
    *   Purpose:    Update access for next 100 files on Amazon
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(SchedulableContext context) {
        try{
            // If there are still files to copy, queue it using another job
            if(filesWithUpdatedPublicOnAmazon != null && !filesWithUpdatedPublicOnAmazon.isEmpty()){
                System.enqueueJob(new BT_UpdateFileAccessQueueable(filesWithUpdatedPublicOnAmazon));
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Update File  Access Schedule Job failed.', e.getMessage());
        }
    }
}