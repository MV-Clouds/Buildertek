/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_MoveFilesSchedulable
* Created by Sagar: 04/09/2017
*
* Schedulable class to move files on Amazon Server. We cannnot chain the Queueable job which contain web service callout 
* So we need to do it through schedulable

* - Modifications:
* - Sagar, 04/09/2017 - Initial Development
************************************************************************** */
public with sharing class BT_MoveFilesSchedulable implements Schedulable{
    // Files to move.
    List<File__c> filesNeedsToMoveFromSource;
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_MoveFilesSchedulable(List<File__c> filesNeedsToMoveFromSource) {
        this.filesNeedsToMoveFromSource = filesNeedsToMoveFromSource;
    }
    
    /*
    *   Purpose:    Copy next 100 files on Amazon
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(SchedulableContext context) {
        
        try{
            // If there are still files to move, queue it using another job
            if(filesNeedsToMoveFromSource != null && !filesNeedsToMoveFromSource.isEmpty()){
                System.enqueueJob(new BT_MoveFilesQueueable(filesNeedsToMoveFromSource));
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Move File Schedule Job failed.', e.getMessage());
        }
    }
}