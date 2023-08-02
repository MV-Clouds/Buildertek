public with sharing class EmailPunchListsLightningController {
    
    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(String folderName){
         List<EmailTemplate> templateRecs;
         if(Schema.sObjectType.EmailTemplate.fields.Id.isAccessible()&&
                Schema.sObjectType.EmailTemplate.fields.Name.isAccessible() &&
                 Schema.sObjectType.EmailTemplate.fields.folderId.isAccessible() &&
                 Schema.sObjectType.Folder.fields.Name.isAccessible()){
                 templateRecs = [Select Id, Name, folder.name from Emailtemplate where folder.name =: folderName];
                }
		return templateRecs;
    }
    
    @AuraEnabled
    public static Object getPunchLists(string Id){
        list<buildertek__Punch_List__c> buildertekPunchList;
         if(Schema.sObjectType.buildertek__Punch_List__c.isAccessible() &&
            Schema.sObjectType.buildertek__Punch_List__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Punch_List__c.fields.Name.isAccessible() &&
            Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Vendor_Account__c.isAccessible() &&
            Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Vendor_Contact__c.isAccessible() &&
            Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Description__c.isAccessible() &&
            Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Location__c.isAccessible() &&
            Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Project__c.isAccessible() &&
			Schema.sObjectType.contact.fields.Email.isAccessible() &&
			Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Vendor_Account__c.isAccessible() &&
			Schema.sObjectType.Account.fields.buildertek__Email_Address__c.isAccessible()){
            buildertekPunchList= [select id, 
                                        Name, 
                                        buildertek__Vendor_Account__c, 
                                        buildertek__Vendor_Contact__c,
                                        buildertek__Vendor_Contact__r.Email, 
                                        buildertek__Description__c,
                                        buildertek__Location__c,
                                        buildertek__Vendor_Account__r.buildertek__Email_Address__c 
                                        from buildertek__Punch_List__c 
                                        where buildertek__Project__c =: Id];
			}
    
        
        set<Id> accountIds = new set<Id>();
        for(buildertek__Punch_List__c punchs: buildertekPunchList){
            if(punchs.buildertek__Vendor_Account__c != null){
                accountIds.add(punchs.buildertek__Vendor_Account__r.Id);    
            }
        }
        system.debug('accountIds --> '+accountIds);
        list<contact> contactList;
         if(Schema.sObjectType.Contact.fields.Id.isAccessible() &&
             Schema.sObjectType.Contact.fields.Email.isAccessible() &&
             Schema.sObjectType.Contact.fields.AccountId.isAccessible() &&
              Schema.sObjectType.Contact.fields.buildertek__Primary_Contact__c.isAccessible()){
            contactList = [select Id, Email, AccountId from Contact where AccountId IN: accountIds and buildertek__Primary_Contact__c = true];
         }
        system.debug('contactList --> '+contactList);
        Map<String, list<String>> accountIdMap = new Map<String, list<String>>();
        List<String> emailList = new List<String>();
        for(contact con : contactList){
            if(!accountIdMap.containsKey(con.AccountId)){
                accountIdMap.put(con.AccountId, new list<string>());
            }
            accountIdMap.get(con.AccountId).add(con.Email);
        }
        system.debug('accountIdMap --> '+accountIdMap);
        
        list<EmailPunchListInnerClass> EmailPunchlistInnerClassList = new list<EmailPunchListInnerClass>();
        for(buildertek__Punch_List__c punchLists : buildertekPunchList){
                String joinedString = String.join(new List<String>(accountIdMap.get(punchLists.buildertek__Vendor_Account__r.Id)), ',');
                system.debug('joinedString --> '+joinedString);
                EmailPunchListInnerClass EmailPunchListInnerClassRecord = new EmailPunchListInnerClass();
                EmailPunchListInnerClassRecord.buildertekPunchlistRecord = punchLists;
                EmailPunchListInnerClassRecord.punchListCheck = false;
                if(punchLists.buildertek__Vendor_Contact__c == null && punchLists.buildertek__Vendor_Account__c != null){
                    EmailPunchListInnerClassRecord.selectedEmail = joinedString;  
                    system.debug('selected Email --> '+joinedString);
                }else{
                    EmailPunchListInnerClassRecord.selectedEmail = punchLists.buildertek__Vendor_Contact__r.Email;
                }
                EmailPunchlistInnerClassList.add(EmailPunchListInnerClassRecord);
            
        }
        String JSONString = JSON.serialize(EmailPunchlistInnerClassList);
        system.debug('Json String '+JSONString);
        return JSONString; 
    }
    
    @AuraEnabled
    public static EmailSentClass SendEmail(List<String> Id) {
        List<EmailTemplate> templateList;
         if(Schema.sObjectType.EmailTemplate.fields.Id.isAccessible()&&
                Schema.sObjectType.EmailTemplate.fields.Name.isAccessible() &&
                 Schema.sObjectType.EmailTemplate.fields.folderId.isAccessible() &&
                 Schema.sObjectType.folder.fields.name.isAccessible()){
                 templateList = [Select Id, Name, folder.name from Emailtemplate where folder.name = 'BT PL'];
                }
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
                eServices=  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
    		}
            List<buildertek__Punch_List__c> punchlistList;
            if(Schema.sObjectType.buildertek__Punch_List__c.isAccessible()&&
                Schema.sObjectType.buildertek__Punch_List__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Punch_List__c.fields.Name.isAccessible() &&
                Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Vendor_Contact__c.isAccessible() &&
    			Schema.sObjectType.contact.fields.Email.isAccessible() &&
    			Schema.sObjectType.Contact.fields.Name.isAccessible() &&
    			Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Vendor_Account__c.isAccessible() &&
    			Schema.sObjectType.Account.fields.buildertek__Email_Address__c.isAccessible()){
            punchlistList= [select Id, 
                                    Name, 
                                    buildertek__Vendor_Contact__c, 
                                    buildertek__Vendor_Contact__r.Email,
                                    buildertek__Vendor_Contact__r.Name, 
                                    buildertek__Vendor_Account__c,
                                    buildertek__Vendor_Account__r.buildertek__Email_Address__c 
                                    from buildertek__Punch_List__c 
                                    where Id IN: recordIdsList];
			}
            set<Id> punchListIds = new set<Id>();
            for(buildertek__Punch_List__c punchlist : punchlistList){
                punchListIds.add(punchlist.Id);
            }
            Map<Id,list<Attachment>> AttachmentListMap = new Map<Id,list<Attachment>>();
            Map<Id,list<ContentDocumentLink>> FilesListMap = new Map<Id,list<ContentDocumentLink>>();
            List<Attachment> atList;
            if(Schema.sObjectType.Attachment.fields.Name.isAccessible()
                && Schema.sObjectType.Attachment.fields.Body.isAccessible()
                && Schema.sObjectType.Attachment.fields.BodyLength.isAccessible()
                && Schema.sObjectType.Attachment.fields.ParentId.isAccessible()){
                    
                atList = [select Name, Body, BodyLength,ParentId from Attachment where ParentId IN: punchlistList];    
            }
            for (Attachment attach : atList){
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
            List<ContentDocumentLink>  cdlList;
            if(Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()
                && Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible()){
                    
                cdlList = [select ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId IN: punchListIds];    
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
            system.debug('buildertek__Punch_List__c '+punchlistList);
            system.debug('fileAttachments --> '+AttachmentListMap);
            integer success = 0;
            integer Fail = 0;
            integer Error = 0;
            system.debug('from Address --> '+eServices.LocalPart+'@'+eServices.EmailDomainName);
            EmailMessage caseEmailMessage = new EmailMessage();
            for(buildertek__Punch_List__c pcList : punchlistList){
                string htmlBody = '';
                String fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                system.debug('Email Addresses --> '+recordIdEmailMap.get(pcList.Id));
                List<String> emailsToSendList = new List<String>();
                if(recordIdEmailMap.get(pcList.Id).contains(',')){
                    String[] emailsList = recordIdEmailMap.get(pcList.Id).split(',');
                    for(String emailAddress : emailsList){
                        emailsToSendList.add(emailAddress);
                    }
                }else{
                    List<String> emailAddresses = new List<String>();
                    /*for(String selectedEmail : recordIdEmailMap.values()){
                        emailsToSendList.add(selectedEmail);        
                    }*/
                    String selectedEmail = recordIdEmailMap.get(pcList.Id);
                    emailsToSendList.add(selectedEmail);
                    system.debug('selectedEmail ----------> '+selectedEmail);
                    system.debug('emailAddresses ----------> '+emailsToSendList);
                    system.debug('emailAddresses ----------> '+emailAddresses);
                }
                if(recordIdEmailMap.get(pcList.Id) != ''){
                    mail.setToAddresses(emailsToSendList);
                } 
                mail.setToAddresses(emailsToSendList);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setReplyTo(fromAddress);
                //mail.setSubject(pcList.Name + ' - [ref:' + pcList.Id + ']');
                mail.setSubject(pcList.Name);
                if(pcList.buildertek__Vendor_Contact__c == null){
                   htmlBody ='Hi ,<br/><br/>Thanks,<br/>'+UserInfo.getUserName();   
                }else{
                    htmlBody ='Hi '+pcList.buildertek__Vendor_Contact__r.Name+',<br/><br/>Thanks,<br/>'+UserInfo.getUserName();    
                }
                mail.setHTMLBody(htmlBody);
                mail.setTemplateId(templateList[0].Id);
                
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
                efa1.setFileName('pdfFileName.pdf');
                efa1.setBody(setAttachmentBody(pcList.Id, templateList[0].Id));
                fileAttachments.add(efa1);
                
                //List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                if(AttachmentListMap.get(pcList.Id) != null){
                    for(Attachment a : AttachmentListMap.get(pcList.Id)){
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(a.Name);
                        efa.setBody(a.Body);
                        fileAttachments.add(efa);
                    }
                }
                
                
                if(FilesListMap.get(pcList.Id) != null){
                    for(ContentDocumentLink content : FilesListMap.get(pcList.Id)){
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
                        caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                        caseEmailMessage.ToAddress = pcList.buildertek__Vendor_Contact__r.Email;
                        caseEmailMessage.FromName = UserInfo.getName();
                        caseEmailMessage.Subject = pcList.Name + ' - [ref:' + pcList.Id + ']';
                        caseEmailMessage.HtmlBody = htmlBody;
                        caseEmailMessage.Incoming= False;
                        caseEmailMessage.TextBody = htmlBody.replaceAll('<br/>', '\n');
                        caseEmailMessage.status = '3';
                        caseEmailMessage.RelatedToId = pcList.id;
                        success = success+1;
                        
                    } else {
                        Fail = Fail +1;
                        //response = resultMail[0].getErrors().get(0).getMessage();
                    }
                }
                if(Schema.sObjectType.EmailMessage.isCreateable()&&
                    Schema.sObjectType.EmailMessage.fields.FromName.isCreateable()&&
                    Schema.sObjectType.EmailMessage.fields.FromAddress.isCreateable() &&
        			Schema.sObjectType.EmailMessage.fields.HtmlBody.isCreateable() &&
        			Schema.sObjectType.EmailMessage.fields.Incoming.isCreateable()&&
        			Schema.sObjectType.EmailMessage.fields.Status.isCreateable() &&
        			Schema.sObjectType.EmailMessage.fields.relatedToId.isCreateable() &&
        			Schema.sObjectType.EmailMessage.fields.TextBody.isCreateable() &&
        			Schema.sObjectType.EmailMessage.fields.ToAddress.isCreateable() &&
        			Schema.sObjectType.EmailMessage.fields.CcAddress.isCreateable() &&
        			Schema.sObjectType.EmailMessage.fields.Subject.isCreateable()){
                    insert caseEmailMessage;
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
    public static String getListViews() {
        //List<ListView> listviews = 
           // [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__Punch_List__c'];
    
        // Perform isAccessible() check here
        string listviews  = System.URL.getSalesforceBaseUrl().toExternalForm();

        System.debug('baseUrl =' + listviews);
        return listviews;
    }
    
    private static Blob setAttachmentBody(String recordId, String templateId){
    	pagereference pdf;
    	pdf = Page.buildertek__BT_Generatepdf;
        pdf.getParameters().put('recordId',recordId);  
        pdf.getParameters().put('templateId',templateId); 
        pdf.setRedirect(true);
        
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
    	return blobbody;
    }
    
    public class EmailPunchListInnerClass{
         @AuraEnabled
         public buildertek__Punch_List__c buildertekPunchlistRecord { get; set; }
         @AuraEnabled
         public boolean punchListCheck { get; set; }
         @AuraEnabled 
         public string selectedEmail { get; set; }
    }
    
    public class SelectedEmailAddressClass{
        @AuraEnabled
        public string recordId { get; set; }
        @AuraEnabled
        public string email { get; set; }
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