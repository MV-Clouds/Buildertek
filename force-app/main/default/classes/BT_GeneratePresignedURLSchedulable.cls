/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_GeneratePresignedURLSchedulable
* Created by Sagar: 08/09/2017
*
* Purpose/Methods:
* - Generates the Presigned URL for files on amazon and set it into field.
*
* Unit Test: 
* 
* Modifications:
* - Sagar, 08/09/2017 - Initial Development
************************************************************************** */
public with sharing class BT_GeneratePresignedURLSchedulable implements Schedulable{
    /*
    *   Purpose:    Set presigned URL for files
    *   Parameters:
    *   UnitTests:  
    */
    public void execute(SchedulableContext context) {
        try{
            // Find all the files whose Next Presigned URL Generate Date today or in paste or not setted.
            List<String> fields = new List<String>{'Id', 'Public_On_Amazon__c', 'Allow_to_Download_by_Presigned_URL__c', 'Presigned_URL_Frequency__c', 'Amazon_File_Key__c', 'Presigned_URL_Expire_Date__c', 'Bucket_Name__c', 'File_Presigned_URL__c'};
            SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
            List<File__c> filesToSetPresignedURL;
            if(Schema.sObjectType.File__c.fields.Id.isAccessible()
                && Schema.sObjectType.File__c.fields.Public_On_Amazon__c.isAccessible()
                && Schema.sObjectType.File__c.fields.Allow_to_Download_by_Presigned_URL__c.isAccessible()
                && Schema.sObjectType.File__c.fields.Presigned_URL_Frequency__c.isAccessible()
                && Schema.sObjectType.File__c.fields.Amazon_File_Key__c.isAccessible()
                && Schema.sObjectType.File__c.fields.Presigned_URL_Expire_Date__c.isAccessible()
                && Schema.sObjectType.File__c.fields.Bucket_Name__c.isAccessible()
                && Schema.sObjectType.File__c.fields.File_Presigned_URL__c.isAccessible()){
                
                filesToSetPresignedURL = [Select Id, Public_On_Amazon__c, Allow_to_Download_by_Presigned_URL__c, Presigned_URL_Frequency__c, Amazon_File_Key__c, Presigned_URL_Expire_Date__c, Bucket_Name__c, File_Presigned_URL__c From File__c
                                                    Where Presigned_URL_Expire_Date__c = null OR Presigned_URL_Expire_Date__c <= :System.today()];    
            }
            
            // Set presigned URL for these files
            if(!filesToSetPresignedURL.isEmpty()){
                FileUtils.setPresignedURL(filesToSetPresignedURL);
                FileTriggerHandler.isSkipTrigger = true;
                BT_NoSharingUtils.updateSobjects(filesToSetPresignedURL);
                FileTriggerHandler.isSkipTrigger = false;
            }
        } catch(Exception e){
            BT_Utils.sendJobFailureEmail('Presigned URL Generate Schedule is failed.', e.getMessage());
        }
    }
}