/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_RenameFilesSchedulable
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
public with sharing class BT_RenameFilesSchedulable implements Schedulable{
    // New Amazon File Paths  by Id.
    Map<Id, String> newAmazonFilePathsById = new Map<Id, String>();
    // Old Amazon File Paths by Id.
    Map<Id, String> oldAmazonFilePathsById = new Map<Id, String>();
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_RenameFilesSchedulable(Map<Id, String> newAmazonFilePathsById, Map<Id, String> oldAmazonFilePathsById) {
        this.newAmazonFilePathsById = newAmazonFilePathsById;
        this.oldAmazonFilePathsById = oldAmazonFilePathsById;
    }
    
    /*
    *   Purpose:    Rename next 50 files from Amazon
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(SchedulableContext context) {
        try{
            // If there are still files to delete, queue it using another job
            if(newAmazonFilePathsById != null && !newAmazonFilePathsById.keySet().isEmpty()){
                System.enqueueJob(new BT_RenameFilesQueueable(newAmazonFilePathsById, oldAmazonFilePathsById));
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Rename File Schedule Job failed.', e.getMessage());
        }
    }
}