public with sharing class EmailSubmittalProcessLightningController {
    
    @AuraEnabled
    public static Object getEmailSubmittals(string Id){
        List<buildertek__Submittal__c> buildertekSubmittalList;
            if(Schema.sObjectType.buildertek__Submittal__c.fields.Id.isAccessible()&&
              Schema.sObjectType.buildertek__Submittal__c.fields.Name.isAccessible() &&
              Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Title__c.isAccessible() &&
              Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Due_Date__c.isAccessible() &&
               Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Description__c.isAccessible() &&
              Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Status__c.isAccessible() &&
               Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Submitted_Date__c.isAccessible() &&
              Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Project__c.isAccessible() &&
              Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Responsible_Contact__c.isAccessible() &&
              Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Responsible_Vendor__c.isAccessible() &&
              Schema.sObjectType.contact.fields.Name.isAccessible() &&
              Schema.sObjectType.Contact.fields.Email.isAccessible() &&
              Schema.sObjectType.Account.fields.buildertek__Email_Address__c.isAccessible() ){
              buildertekSubmittalList = [select id, 
                                                Name, 
                                                buildertek__Responsible_Contact__c, 
                                                buildertek__Responsible_Vendor__c, 
                                                buildertek__Responsible_Vendor__r.buildertek__Email_Address__c,
                                                buildertek__Title__c,
                                                buildertek__Due_Date__c,
                                                buildertek__Description__c,
                                                buildertek__Responsible_Contact__r.Email,
                                                buildertek__Status__c,
                                                buildertek__Submitted_Date__c 
                                                from buildertek__Submittal__c 
                                                where buildertek__Project__c =: Id];
              }
    
        Map<String, list<String>> emailMap = new Map<String, list<String>>();
        for(buildertek__Submittal__c submit : buildertekSubmittalList){
            if(submit.buildertek__Responsible_Contact__c != null){
                if(!emailMap.containsKey(submit.Id)){
                    emailMap.put(submit.Id, new list<string>());
                }
                if(submit.buildertek__Responsible_Contact__r.Email != null){
                    emailMap.get(submit.Id).add(submit.buildertek__Responsible_Contact__r.Email);    
                }
            }
            if(submit.buildertek__Responsible_Vendor__c != null){
                if(!emailMap.containsKey(submit.Id)){
                    emailMap.put(submit.Id, new list<string>());
                }
                if(submit.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c != null){
                    emailMap.get(submit.Id).add(submit.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c);   
                }
            }
        }
        system.debug('emailMap --> '+emailMap);
        list<EmailSubmitalInnerClass> EmailSubmitalInnerClassList = new list<EmailSubmitalInnerClass>();
        for(buildertek__Submittal__c Submittal : buildertekSubmittalList){
            String joinedString = String.join(new List<String>(emailMap.get(Submittal.Id)), ',');
            system.debug('joinedString --> '+joinedString);
            EmailSubmitalInnerClass EmailSubmitalInnerClassRecord = new EmailSubmitalInnerClass();
            EmailSubmitalInnerClassRecord.buildertekSubmittalRecord = Submittal;
            EmailSubmitalInnerClassRecord.SubmittalCheck = false;
            if(Submittal.buildertek__Responsible_Contact__r.Email == Submittal.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c
                && Submittal.buildertek__Responsible_Contact__r.Email != '' && Submittal.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c != ''){
                EmailSubmitalInnerClassRecord.selectedEmail = Submittal.buildertek__Responsible_Contact__r.Email;
            }else{
                if(Submittal.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c != ''){
                    EmailSubmitalInnerClassRecord.selectedEmail = joinedString;
                }
                if(Submittal.buildertek__Responsible_Contact__r.Email != ''){
                     EmailSubmitalInnerClassRecord.selectedEmail = joinedString;
                }
            }       
            EmailSubmitalInnerClassList.add(EmailSubmitalInnerClassRecord);
            
        }
        String JSONString = JSON.serialize(EmailSubmitalInnerClassList);
        system.debug('Json String '+JSONString);
        return JSONString; 
    }
    
    @AuraEnabled
    public static EmailSentClass SendEmail(List<String> Id) {
        
        EmailSentClass EmailSentClassrec = new EmailSentClass();
        try{
            system.debug('Id --> '+Id);
            List<String> recordIdsList = new List<String>();
            Map<String, String> recordIdEmailMap = new Map<String, String>();
            for(string recordId : Id){
                List<String> recordEmailList = recordId.split('-'); 
                recordIdsList.add(recordEmailList[0]);
                recordIdEmailMap.put(recordEmailList[0], recordEmailList[1]);
            }
            system.debug('recordIdEmailMap --> '+recordIdEmailMap);
            EmailServicesAddress eServices;
            if(Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible()&&
                Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() &&
    			Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() &&
    			Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() &&
    			Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
                eServices =  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
    		}
            List<buildertek__Submittal__c> submitalList;
            if(Schema.sObjectType.buildertek__Submittal__c.fields.Id.isAccessible()&&
              Schema.sObjectType.buildertek__Submittal__c.fields.Name.isAccessible() &&
              Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Responsible_Contact__c.isAccessible() &&
              Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Responsible_Vendor__c.isAccessible() &&
              Schema.sObjectType.contact.fields.Name.isAccessible() &&
              Schema.sObjectType.Contact.fields.Email.isAccessible() &&
              Schema.sObjectType.Account.fields.buildertek__Email_Address__c.isAccessible() ){
              submitalList = [select Id, Name, buildertek__Responsible_Contact__c, buildertek__Responsible_Contact__r.Email,
                                                        buildertek__Responsible_Contact__r.Name, buildertek__Responsible_Vendor__c,
                                                        buildertek__Responsible_Vendor__r.buildertek__Email_Address__c from buildertek__Submittal__c where Id IN: recordIdsList];
              }
            system.debug('submitalList --> '+submitalList);
            set<Id> submittalIds = new set<Id>();
            for(buildertek__Submittal__c submittal : submitalList){
                submittalIds.add(submittal.Id);
            }
            system.debug('submittalIds --> '+submittalIds);
            Map<Id,list<Attachment>> AttachmentListMap = new Map<Id,list<Attachment>>();
            Map<Id,list<ContentDocumentLink>> FilesListMap = new Map<Id,list<ContentDocumentLink>>();
            List<Attachment> attList;
            if(Schema.sObjectType.Attachment.fields.Name.isAccessible()
                && Schema.sObjectType.Attachment.fields.Body.isAccessible()
                && Schema.sObjectType.Attachment.fields.BodyLength.isAccessible()
                && Schema.sObjectType.Attachment.fields.ParentId.isAccessible()){
                
                attList = [select Name, Body, BodyLength,ParentId from Attachment where ParentId IN: submitalList];    
            }
            
            for (Attachment attach : attList){
                 list<attachment> AttachList = New list<attachment>();
                 if(AttachmentListMap.get(attach.ParentId) == null){
                    AttachList.add(attach);
                    AttachmentListMap.put(attach.ParentId,AttachList);
                 }
                 else{
                    AttachList =  AttachmentListMap.get(attach.ParentId);
                    AttachList.add(attach);
                    AttachmentListMap.put(attach.ParentId,AttachList);
                 }
            }
            List<ContentDocumentLink> cdlList;
            if(Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()
                && Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible()){
                
                cdlList = [select ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId IN: submittalIds];    
            }
            
            for (ContentDocumentLink files : cdlList){
                 list<ContentDocumentLink> fileList = New list<ContentDocumentLink>();
                 if(FilesListMap.get(files.LinkedEntityId) == null){
                    fileList.add(files);
                    FilesListMap.put(files.LinkedEntityId,fileList);
                 }
                 else{
                    fileList =  FilesListMap.get(files.LinkedEntityId);
                    fileList.add(files);
                    FilesListMap.put(files.LinkedEntityId,fileList);
                 }
            }
            system.debug('files List --> '+FilesListMap);
            system.debug('buildertek__Submittal__c '+submitalList);
            system.debug('fileAttachments --> '+AttachmentListMap);
            integer success = 0;
            integer Fail = 0;
            integer Error = 0;
            system.debug('from Address --> '+eServices.LocalPart+'@'+eServices.EmailDomainName);
            EmailMessage caseEmailMessage = new EmailMessage();
            for(buildertek__Submittal__c submital : submitalList){
                string htmlBody = '';
                String fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                /*if(submital.buildertek__Responsible_Contact__r.Email == submital.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c
                    && submital.buildertek__Responsible_Contact__r.Email != '' && submital.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c != ''){
                     mail.toAddresses = new String[] {submital.buildertek__Responsible_Contact__r.Email};
                }else{
                    if(submital.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c != ''){
                        mail.toAddresses = new String[] {submital.buildertek__Responsible_Vendor__r.buildertek__Email_Address__c};   
                    }
                    if(submital.buildertek__Responsible_Contact__r.Email != ''){
                         mail.toAddresses = new String[] {submital.buildertek__Responsible_Contact__r.Email};
                    }
                }*/
                List<String> emailsToSendList = new List<String>();
                system.debug('recordIdEmailMap --> '+recordIdEmailMap);
                if(recordIdEmailMap.get(submital.Id).contains(',')){
                    String[] emailsList = recordIdEmailMap.get(submital.Id).split(',');
                    for(String emailAddress : emailsList){
                        emailsToSendList.add(emailAddress);
                    }
                }else{
                    List<String> emailAddresses = new List<String>();
                    /*for(String selectedEmail : recordIdEmailMap.values()){
                        emailsToSendList.add(selectedEmail);        
                    }*/
                    String selectedEmail = recordIdEmailMap.get(submital.Id);
                    emailsToSendList.add(selectedEmail);
                    system.debug('selectedEmail ----------> '+selectedEmail);
                    system.debug('emailAddresses ----------> '+emailsToSendList);
                }
                if(recordIdEmailMap.get(submital.Id) != ''){
                    mail.setToAddresses(emailsToSendList);
                }    
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setReplyTo(fromAddress);
                mail.setSubject(submital.Name + ' - [ref:' + submital.Id + ']'); 
                if(submital.buildertek__Responsible_Contact__c != null){
                    htmlBody ='Hi '+submital.buildertek__Responsible_Contact__r.Name+',<br/><br/>Thanks,<br/>'+UserInfo.getUserName();    
                }else{
                    htmlBody ='Hi,<br/><br/>Thanks,<br/>'+UserInfo.getUserName();    
                }
                
                mail.setHTMLBody(htmlBody);
                
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                if(AttachmentListMap.get(submital.Id) != null){
                    for(Attachment a : AttachmentListMap.get(submital.Id)){
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(a.Name);
                        efa.setBody(a.Body);
                        fileAttachments.add(efa);
                    }
                }
                
                if(FilesListMap.get(submital.Id) != null){
                    for(ContentDocumentLink content : FilesListMap.get(submital.Id)){
                        for (ContentVersion docs : [Select Id, ContentDocumentId, Title, VersionData from ContentVersion where ContentDocumentId = :content.ContentDocumentId]) {
                            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                            efa.setFileName(docs.Title);
                            efa.setBody(docs.VersionData);
                            fileAttachments.add(efa);
                        }
                    }
                }
                
                system.debug('fileAttachments --> '+fileAttachments);
                mail.setFileAttachments(fileAttachments);
                
        
                
                Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                system.debug('@@@@@@@@@@@@@@@@ mail'+results);
                    if (results[0].isSuccess()) {
                        submital.buildertek__Submitted_Date__c = system.Today();
                        submital.buildertek__Status__c = 'Submitted';
                        
                            caseEmailMessage.fromAddress= UserInfo.getUserEmail(); 
                            caseEmailMessage.ToAddress = submital.buildertek__Responsible_Contact__r.Email;
                            caseEmailMessage.FromName = UserInfo.getName();
                            //caseEmailMessage.Subject = submital.Name + ' - [ref:' + submital.Id + ']';
                            caseEmailMessage.Subject = submital.Name;
                            caseEmailMessage.HtmlBody = htmlBody;
                            caseEmailMessage.Incoming= False;
                            caseEmailMessage.TextBody = htmlBody.replaceAll('<br/>', '\n');
                            caseEmailMessage.status = '3';
                            caseEmailMessage.RelatedToId = submital.id;
                            success = success+1;
                         
                    } else {
                        Fail = Fail +1;
                        //response = resultMail[0].getErrors().get(0).getMessage();
                    }
                }
                if(Schema.sObjectType.EmailMessage.fields.fromAddress.isCreateable() && Schema.sObjectType.EmailMessage.fields.ToAddress.isCreateable()
                           && Schema.sObjectType.EmailMessage.fields.FromName.isCreateable() && Schema.sObjectType.EmailMessage.fields.Subject.isCreateable() 
                           && Schema.sObjectType.EmailMessage.fields.HtmlBody.isCreateable() && Schema.sObjectType.EmailMessage.fields.Incoming.isCreateable() 
                           && Schema.sObjectType.EmailMessage.fields.status.isCreateable() && Schema.sObjectType.EmailMessage.fields.RelatedToId.isCreateable() && Schema.sObjectType.EmailMessage.fields.TextBody.isCreateable()){
                        insert caseEmailMessage;
                }
                if(Schema.sObjectType.buildertek__Submittal__c.fields.Id.isUpdateable() &&
                    Schema.sObjectType.buildertek__Submittal__c.fields.Name.isUpdateable()&&
                    Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Submitted_Date__c.isUpdateable()&&
                    Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Status__c.isUpdateable()){
                    update submitalList;
        			}
                EmailSentClassrec.success = success;
                EmailSentClassrec.fail = Fail;
                 EmailSentClassrec.error = '';
                  return EmailSentClassrec;
        }
        catch(Exception e){
            system.debug('@@@@@@@@@@@@@@@@ getmessage()'+e.getmessage());
                EmailSentClass EmailSentClassrecs = new EmailSentClass();
                EmailSentClassrecs.success = 0;
                EmailSentClassrecs.fail = 0;
                EmailSentClassrecs.error = e.getmessage();
                return EmailSentClassrecs;
        }
        return EmailSentClassrec;
    }
    
     @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews;
         if(Schema.sObjectType.ListView.fields.Id.isAccessible() &&
         Schema.sObjectType.ListView.fields.Name.isAccessible() &&
         Schema.sObjectType.ListView.fields.SobjectType.isAccessible()){
       listviews =  [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__Submittal__c'];
    }
    
        // Perform isAccessible() check here
        return listviews;
    }
    
    public class EmailSubmitalInnerClass{
         @AuraEnabled
         public buildertek__Submittal__c buildertekSubmittalRecord {get;set;}
         @AuraEnabled
         public boolean SubmittalCheck {get;set;}
         @AuraEnabled 
         public string selectedEmail { get; set; }
         
    }
    
    public class EmailSentClass{
        @AuraEnabled
        public integer success {get;set;}
         @AuraEnabled
        public string error {get;set;}
         @AuraEnabled
        public integer fail {get;set;}
    } 
}