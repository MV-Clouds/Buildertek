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
    public string fileIdNew {get;set;}
    public string filerecid {get;set;}
    public string filerecidNew {get;set;}
    public String imageURL{get;set;}
    public String imageURLNew{get;set;}
    public Date CustomerAcceptedDate {get;set;} 
    public transient string strBody{get;set;}
    public transient string strBodyNew{get;set;}
    public string theTemplateNew1;
    public string  tempId {get;set;}
    public string  templateIdForCondition {get;set;}
    public string theTemplate2;
    public string theTemplateNew21;
    public string theTemplate21;
    public Boolean divsign {get;set;}
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
        templateIdForCondition = templateId;
        System.debug('templateIdForCondition------>' + templateIdForCondition);
        EmailTemplate ET = [Select Id
        from EmailTemplate
        where DeveloperName = :'Quote_Template_2'
        limit 1];

        tempId = ET.Id;
        System.debug('tempId------->' + tempId);
        if (templateIdForCondition == tempId) {
            divsign = true;
        } else{
            divsign = false;
        }
        // Construct the list of emails we want to send
       
    string templateBody = '';
    string templateBodyNew = '';
    string templateBody1 = '';
    string templateBodyNew1 = '';
    string templateBodyNew21 = '';
    string templateBody2 = '';
    string templateBodyNew2 = '';
    string templateBodyNew22 = '';
    
        
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
            //  System.debug('TAB123------------>' +apexpages.currentPage().getParameters().get('fileIdNew').escapeHtml4());
             if (fileIdNew != 'null') {
                 filerecidNew = apexpages.currentPage().getParameters().get('fileIdNew').escapeHtml4();
                 fileIdNew = apexpages.currentPage().getParameters().get('fileIdNew');
                 System.debug('filerecidNew------------>' + filerecidNew);
                 System.debug('filerecidNew1------------>' + fileIdNew);
                 System.debug('filerecidNew2------------>' + apexpages.currentPage());
             }
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

        // List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        // List<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>(); 
        // List<String> templateList = new List<String>();
        // Savepoint sp = Database.setSavepoint();
        // Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // string theTemplate = [SELECT Id FROM EmailTemplate WHERE Id =: templateId].Id; 
        // System.debug('Email Template ID :: Generate PDF'+theTemplate);
        // email.setTemplateId(theTemplate);
        // email.setWhatId(recordId);                        
        // email.setTargetObjectId(vendorID);       
        // email.setSaveAsActivity(false);
        // email.setToAddresses(new List<String>{'pratap.uddarraju@diligentforcelabs.com'});
        // msgList.add(email);
        // System.debug('********** --->'+msgList);
        // System.debug('email--->'+email);
        // Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        // System.debug('Email Results isSuccess = ' +  r[0].IsSuccess());
        // Database.rollback(sp); 
        // for (Messaging.SingleEmailMessage emailNew : msgList) {                   
        // 	templateBody1 = emailNew.getHTMLBody(); 
        // }
        
        // system.debug('templateBody1 ---------> '+templateBody1);
        // Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
         
        // string theTemplate1 = '';
        // EmailTemplate etemp;
        // if(objectAPIName.contains('Contract')){
        //      if(Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
        //         etemp = [SELECT Id FROM EmailTemplate WHERE Name = 'BT Contract Proposal Images'];    
        //      }
        //      theTemplate1 = etemp.Id; 
        // }
        // else{
        //      //if(Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
        //         etemp = [SELECT Id FROM EmailTemplate WHERE Name = 'BT Proposal Images'];   
        //     // }
        //      theTemplate1 = etemp.Id; 
        // }
        // email1.setTemplateId(theTemplate1);
        // email1.setWhatId(recordId);                        
        // email1.setTargetObjectId(vendorID);       
        // email1.setSaveAsActivity(false);
        // email1.setToAddresses(new List<String>{'pratap.uddarraju@diligentforcelabs.com'});
        // msgList1.add(email1);
        // Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1}); 
        // System.debug('Email Results isSuccess = ' +  r1[0].IsSuccess());
        // Database.rollback(sp); 
        // for (Messaging.SingleEmailMessage emailNew1 : msgList1) {                   
        // 	//templateBody2 = emailNew1.getHTMLBody();         
        // }
        // system.debug('templateBody 2 ----------> '+templateBody2);
        // templateBody = templateBody1 + templateBody2;
        // system.debug('Final templateBody ----------> '+templateBody);
        // strBody = templateBody;
        // system.debug('strBody -----> '+strBody);
        
        // try{
        //     document doc;
        //     if(Schema.sObjectType.Document.fields.Id.isAccessible()){
        //         doc = [ SELECT ID from Document where DeveloperName ='Company_Logo'  limit 1];    
        //     }
        //     string imageid = doc.id;
        //     imageid = imageid.substring(0,15);
        //     strBody = strBody.replace('###############',imageid);
        // }catch( exception ex){
            
            
        // }
        List<Messaging.SingleEmailMessage> msgListNew1 = new List<Messaging.SingleEmailMessage>();
List<Messaging.SingleEmailMessage> msgListNew2 = new List<Messaging.SingleEmailMessage>();
List<String> templateListNew1 = new List<String>();
Savepoint sp = Database.setSavepoint();
Messaging.SingleEmailMessage emailNew1 = new Messaging.SingleEmailMessage();
//string theTemplate;
    theTemplateNew1 = [SELECT Id
                   FROM EmailTemplate
                   WHERE Name = 'quote top'].Id;

    EmailTemplate emailtemrec = [Select Id, Name, Body, DeveloperName
                                 from EmailTemplate
                                 where Name = 'quote top'
                                 limit 1];
    theTemplateNew1 = emailtemrec.Id;
emailNew1.setTemplateId(theTemplateNew1);
emailNew1.setWhatId(recordId);
emailNew1.setTargetObjectId(vendorID);
emailNew1.setSaveAsActivity(false);
emailNew1.setToAddresses(new List<String>{'noreplay@buildertek.com'});
msgListNew1.add(emailNew1);

Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailNew1});
System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
Database.rollback(sp);
for (Messaging.SingleEmailMessage emailNew : msgListNew1){
    templateBodyNew1 = emailNew.getHTMLBody();
    System.debug('templatebody---->' + templateBodyNew1);
}
/*  String[] toAddresses = new String[] {'mailto:manisha.kotha@diligentforcelabs.com'};

email.setToAddresses(toAddresses);
email.setSenderDisplayName('Salesforce Support');
email.setSubject('New Case Created : ');
email.setBccSender(false);
email.setUseSignature(false);
email.setPlainTextBody('Your Case: '  +' has been created.');
email.setHtmlBody('Your case:<b> </b>has been created.<p>'+
'To view your case <a href=https://mydomainname.my.salesforce.com/>click here.</a>');
email.SetSaveAsActivity(true);

// Send the email you have created.
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  */











Messaging.SingleEmailMessage emailNew2 = new Messaging.SingleEmailMessage();
string theTemplate2 = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name = 'BT Proposal Images'].Id;
emailNew2.setTemplateId(theTemplate2);
emailNew2.setWhatId(recordId);
emailNew2.setTargetObjectId(vendorID);
emailNew2.setSaveAsActivity(false);
emailNew2.setToAddresses(new List<String>{'noreplay@buildertek.com'});
msgListNew2.add(emailNew2);
Messaging.SendEmailResult[] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailNew2});
Database.rollback(sp);
for (Messaging.SingleEmailMessage email2 : msgListNew2){
    templateBodyNew2 = email2.getHTMLBody();
}
system.debug('templateBody 2 ----------> ' + templateBodyNew2);
templateBody = templateBodyNew1 + templateBodyNew2;
strBody = templateBody;
system.debug('strBody -----> ' + strBody);

try{
    document doc;
    doc = [SELECT ID
           from Document
           where DeveloperName = 'Company_Logo'
           limit 1];

    string imageid = doc.id;
    imageid = imageid.substring(0, 15);
    strBody = strBody.replace('###############', imageid);
} catch (exception ex){
    System.debug('Error Mesage::' + ex.getMessage());
    System.debug('Error Line::' + ex.getLineNumber());
}



List<Messaging.SingleEmailMessage> emailNew12 = new List<Messaging.SingleEmailMessage>();
List<Messaging.SingleEmailMessage> msgListNew22 = new List<Messaging.SingleEmailMessage>();
List<String> templateListNew12 = new List<String>();
Savepoint s = Database.setSavepoint();
Messaging.SingleEmailMessage emailNew11 = new Messaging.SingleEmailMessage();
//string theTemplate;
    theTemplateNew21 = [SELECT Id
                   FROM EmailTemplate
                   WHERE Name = 'quote bottom'].Id;

    EmailTemplate emailtemrec1 = [Select Id, Name, Body, DeveloperName
                                 from EmailTemplate
                                 where Name = 'quote bottom'
                                 limit 1];
    theTemplateNew21 = emailtemrec1.Id;
emailNew11.setTemplateId(theTemplateNew21);
emailNew11.setWhatId(recordId);
emailNew11.setTargetObjectId(vendorID);
emailNew11.setSaveAsActivity(false);
emailNew11.setToAddresses(new List<String>{'noreplay@buildertek.com'});
emailNew12.add(emailNew11);

Messaging.SendEmailResult[] r0 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailNew11});
System.debug('Email Results isSuccess = ' + r0[0].IsSuccess());
Database.rollback(sp);
for (Messaging.SingleEmailMessage emailNew : emailNew12){
    templateBodyNew21 = emailNew.getHTMLBody();
    System.debug('templatebody---->' + templateBodyNew21);
}
/*  String[] toAddresses = new String[] {'mailto:manisha.kotha@diligentforcelabs.com'};

email.setToAddresses(toAddresses);
email.setSenderDisplayName('Salesforce Support');
email.setSubject('New Case Created : ');
email.setBccSender(false);
email.setUseSignature(false);
email.setPlainTextBody('Your Case: '  +' has been created.');
email.setHtmlBody('Your case:<b> </b>has been created.<p>'+
'To view your case <a href=https://mydomainname.my.salesforce.com/>click here.</a>');
email.SetSaveAsActivity(true);

// Send the email you have created.
Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  */











Messaging.SingleEmailMessage emailNew22 = new Messaging.SingleEmailMessage();
string theTemplate2New = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name = 'BT Proposal Images'].Id;
emailNew22.setTemplateId(theTemplate2New);
emailNew22.setWhatId(recordId);
emailNew22.setTargetObjectId(vendorID);
emailNew22.setSaveAsActivity(false);
emailNew22.setToAddresses(new List<String>{'noreplay@buildertek.com'});
msgListNew22.add(emailNew22);
Messaging.SendEmailResult[] r2 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{emailNew22});
Database.rollback(sp);
for (Messaging.SingleEmailMessage email2 : msgListNew22){
    templateBodyNew22 = email2.getHTMLBody();
}
system.debug('templateBody 2 ----------> ' + templateBodyNew22);
templateBody = templateBodyNew21 + templateBodyNew22;
strBodyNew = templateBody;
system.debug('strBody -----> ' + strBodyNew);

try{
    document doc;
    doc = [SELECT ID
           from Document
           where DeveloperName = 'Company_Logo'
           limit 1];

    string imageid = doc.id;
    imageid = imageid.substring(0, 15);
    strBodyNew = strBodyNew.replace('###############', imageid);
} catch (exception ex){
    System.debug('Error Mesage::' + ex.getMessage());
    System.debug('Error Line::' + ex.getLineNumber());
}
    
    }
}