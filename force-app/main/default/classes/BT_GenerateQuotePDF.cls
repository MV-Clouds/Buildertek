/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  10-Sep-2018
*/
public without sharing class BT_GenerateQuotePDF {
    public string recordID;
    public String templateId;
    public string templateName;
    public string fileid {get;set;}
    public string filerecid {get;set;}
    public String imageURL{get;set;}
    public Date CustomerAcceptedDate {get;set;} 
    public transient string strBody{get;set;}
    
    public BT_GenerateQuotePDF() {
        
    }
    
    public void createPDF(){
        
         string vendorID;
        // Pick a dummy Contact
         if(vendorID == null){
             Contact c;
             if(Schema.sObjectType.Contact.fields.id.isAccessible()
                && Schema.sObjectType.Contact.fields.Email.isAccessible()){
                
                c = [select id, Email from Contact where email <> null limit 1];    
             }
             vendorID = c.id;
             
         }
        
        recordID = apexpages.currentPage().getParameters().get('recordId').escapeHtml4();
        templateId = apexpages.currentPage().getParameters().get('templateId').escapeHtml4();
        system.debug('recordID --------> '+recordID);
        system.debug('templateId --------> '+templateId);
       
       
        // Construct the list of emails we want to send
       
        string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        
        String objectAPIName = '';
            string keyPrefix = recordID.substring(0,3);
            for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
            String prefix = obj.getDescribe().getKeyPrefix();
            //if(prefix == keyPrefix){
                if(keyPrefix.equals(prefix)){
                    objectAPIName = obj.getDescribe().getName();
                    break;
                }
            }
            if(objectAPIName.contains('buildertek__Quote__c')){
             filerecid = apexpages.currentPage().getParameters().get('fileId').escapeHtml4();
                /*List<buildertek__Quote__c> quoterec = [select id,
                                        Name,
                                        buildertek__Status__c,
                                        buildertek__Date_Accepted_by_Customer__c
                                        from buildertek__Quote__c where Id=:recordID limit 1];*/
            CustomerAcceptedDate = system.today();
            }
			
        if(objectAPIName.contains('buildertek__Contract__c')){
             filerecid = apexpages.currentPage().getParameters().get('fileId').escapeHtml4();
                
            CustomerAcceptedDate = system.today();
            }

        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>(); 
        List<String> templateList = new List<String>();
        Savepoint sp = Database.setSavepoint();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        string theTemplate = [SELECT Id FROM EmailTemplate WHERE Id =: templateId].Id; 
        System.debug('Email Template ID :: Generate PDF'+theTemplate);
        email.setTemplateId(theTemplate);
        email.setWhatId(recordId);                        
        email.setTargetObjectId(vendorID);       
        email.setSaveAsActivity(false);
        email.setToAddresses(new List<String>{'pratap.uddarraju@diligentforcelabs.com'});
        msgList.add(email);
        System.debug('********** --->'+msgList);
        System.debug('email--->'+email);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        System.debug('Email Results isSuccess = ' +  r[0].IsSuccess());
        Database.rollback(sp); 
        for (Messaging.SingleEmailMessage emailNew : msgList) {                   
        	templateBody1 = emailNew.getHTMLBody(); 
        }
        
        system.debug('templateBody1 ---------> '+templateBody1);
        Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
         
        string theTemplate1 = '';
        EmailTemplate etemp;
        if(objectAPIName.contains('Contract')){
             if(Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                etemp = [SELECT Id FROM EmailTemplate WHERE Name = 'BT Contract Proposal Images'];    
             }
             theTemplate1 = etemp.Id; 
        }
        else{
             //if(Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                etemp = [SELECT Id FROM EmailTemplate WHERE Name = 'BT Proposal Images'];   
            // }
             theTemplate1 = etemp.Id; 
        }
        email1.setTemplateId(theTemplate1);
        email1.setWhatId(recordId);                        
        email1.setTargetObjectId(vendorID);       
        email1.setSaveAsActivity(false);
        email1.setToAddresses(new List<String>{'pratap.uddarraju@diligentforcelabs.com'});
        msgList1.add(email1);
        Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1}); 
        System.debug('Email Results isSuccess = ' +  r1[0].IsSuccess());
        Database.rollback(sp); 
        for (Messaging.SingleEmailMessage emailNew1 : msgList1) {                   
        	//templateBody2 = emailNew1.getHTMLBody();         
        }
        system.debug('templateBody 2 ----------> '+templateBody2);
        templateBody = templateBody1 + templateBody2;
        system.debug('Final templateBody ----------> '+templateBody);
        strBody = templateBody;
        system.debug('strBody -----> '+strBody);
        
        try{
            document doc;
            if(Schema.sObjectType.Document.fields.Id.isAccessible()){
                doc = [ SELECT ID from Document where DeveloperName ='Company_Logo'  limit 1];    
            }
            string imageid = doc.id;
            imageid = imageid.substring(0,15);
            strBody = strBody.replace('###############',imageid);
        }catch( exception ex){
            
            
        }
    
    }
}