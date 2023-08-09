/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* PostInstall Class: PostInstallClass
* Created by Sagar: 13/09/2017
*
* - Run all the script after install, upgrade and patch

* - Modifications:
* - Sagar, 13/09/2017 – Initial Development
************************************************************************** */
global without sharing class PostInstallClass implements InstallHandler {
    global void onInstall(InstallContext context) {
        try {
            // Create Group and members
            createGroups();
            
            // Start schedule job to generate presigned URL
            // startScheduleJobForPresignedURLs();
                    
            // Upgrading to 1.XX
            Integer XX = 999;
            if(context.previousVersion() != null && context.previousVersion().compareTo(new Version(1, 30)) >= 0 && context.previousVersion().compareTo(new Version(1, XX)) < 0){ 
                try {
                    upgradeTo1_XX('All');
                } catch(Exception ex) {
                    sendFailureMessage(ex, '1.XX', null);
                }
            }
        }  catch(Exception ex){
            sendFailureMessage(ex, 'Unknown', null);
        }
    }
    
    /*
    *   Purpose:    Required Create Groups and Group Members.
    *   Parameters: 
    *   UnitTests:  
    */
    global void createGroups(){
        PostInstallFuture.createRequiredGroupsOnPackageInstall();
    }
    
    /*
    *   Purpose:    Start schedule job to generate presigned URL.
    *   Parameters: 
    *   UnitTests:  
    */
    global void startScheduleJobForPresignedURLs(){
        PostInstallFuture.startScheduleJobForPresignedURLs();
    }
    
    /*
    *   Purpose:    Send the email to user if the upgrade fails.
    *   Parameters: 
    *   UnitTests:  
    */
    private void sendFailureMessage(Exception ex, String version, String step){
        Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
        list<String> listEmailMembers = new list<String>();
        listEmailMembers.add('thoriyas@gmail.com');
        emailTobeSent.setToAddresses(listEmailMembers);
        
        if(step != null){
            emailTobeSent.setSubject('Post install script step  ' + step + ' to version ' + version + ' failed for org:' + UserInfo.getOrganizationId());
        } else {        
            emailTobeSent.setSubject('Post install script to version ' + version + ' failed for org:' + UserInfo.getOrganizationId());
        }
        emailTobeSent.setHtmlBody('Message : ' + ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' getStackTraceString ' + ex.getStackTraceString() + '' + ex.getCause());
        Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
    }
  
    /*
    *   Purpose:    Send the email to user if the apex batch failed while upgrading.
    *   Parameters: 
    *   UnitTests:  
    */
    public static void sendBatchFailureMessage(Integer totalBatches, Integer failedBatches, String version, String step){
        String body = 'Message : ' + failedBatches + ' out of ' + totalBatches + ' failed.';
        sendBatchFailureMessage(version, step, body);
    }
  
    /*
    *   Purpose:    Send the email to user if the apex batch failed while upgrading.
    *   Parameters: 
    *   UnitTests:  
    */
    public static void sendBatchFailureMessage(String version, String step, String body){
        Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
        list<String> listEmailMembers = new list<String>();
        listEmailMembers.add('thoriyas@gmail.com');
        emailTobeSent.setToAddresses(listEmailMembers);
        
        if(step != null){
            emailTobeSent.setSubject('Post install script apex batch job for step  ' + step + ' to version ' + version + ' failed for org:' + UserInfo.getOrganizationId());
        } else {        
            emailTobeSent.setSubject('Post install script apex batch job to version ' + version + ' failed for org:' + UserInfo.getOrganizationId());
        }
        emailTobeSent.setHtmlBody(body);
        Messaging.SendEmailResult [] emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
    }
    
    global void upgradeTo1_0(String step){
      
    }
    
    /*
    1. Create public group for "Users with Access for File Control"
    2. Set "Is File Control" for all File Control profile users.
    3. Move AWS Keys into protected custom setting
    4. Set "Show File Extention Icon" for all file explore page config
    5. Set "File Access Type" for folders to "Public" if it's not set.
    */
    global void upgradeTo1_30(String step){
    }
    
    /*
    1. Show "File Upload Page Configuration".
    2. Update "File Explorer Page Configuration' to "Enable Mass Actions" and "Show Breadcrumb"
    3. Set access type for files and users
    4. Update the icons of admin configuration nodes.
    */
    global void upgradeTo1_XX(String step){
        
    }            
}