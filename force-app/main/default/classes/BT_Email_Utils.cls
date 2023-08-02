/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  09-Nov-2017
*/
public with sharing class BT_Email_Utils {
    
    
    public static void sendEmailNotification(String recordId, String targetRecipientId, String templateId) {
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(targetRecipientId);
        mail.setWhatId(recordId); 
        mail.setTemplateID(templateId); 
        mail.setSaveAsActivity(true);
    }
    
    
    /*
        Get all the templates from folder
    */
    public static List<EmailTemplate> getTemplates(String folderName) {
        List<EmailTemplate> emailTemplateList;
        
        return emailTemplateList;
    }
    
}