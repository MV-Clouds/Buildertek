public with sharing class PreviewPunchlist {
    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
        List<Emailtemplate> temrec;
        if(Schema.sObjectType.Emailtemplate.fields.Id.isAccessible()&&
           Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() &&
           Schema.sObjectType.Emailtemplate.fields.folderid.isAccessible() &&
           Schema.sObjectType.Folder.fields.Name.isAccessible()){
               temrec = [Select Id, Name, folder.name from Emailtemplate where folder.name = 'BT PL'];
           }
        return temrec;
    }
    
    @AuraEnabled
    public static string getPayableLines(String recordId, String templateId){
        string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        Contact con ;
        if(Schema.sObjectType.Contact.fields.Id.isAccessible()&&
           Schema.sObjectType.Contact.fields.Name.isAccessible() &&
           Schema.sObjectType.Contact.fields.email.isAccessible()  ){
               con = [select id, Email from Contact where email != null order by createddate desc limit 1 ];
           }
        String[] toaddres;
        toaddres = new String[]{con.email};
            Savepoint sp = Database.setSavepoint();
        list<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>(); 
        list<Messaging.SingleEmailMessage> msgList1= new List<Messaging.SingleEmailMessage>(); 
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        string theTemplate = [SELECT Id FROM EmailTemplate WHERE Id =: templateId].Id; 
        System.debug(theTemplate);
        email.setTemplateId(theTemplate);
        email.setWhatId(recordId);                        
        email.setTargetObjectId(con.Id);       
        email.setSaveAsActivity(false);
        email.setToAddresses(toaddres);
        msgList.add(email);
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        System.debug('Email Results isSuccess = ' +  r[0].IsSuccess());
        Database.rollback(sp); 
        for (Messaging.SingleEmailMessage emailNew : msgList) {                   
            templateBody1 = emailNew.getHTMLBody(); 
        }
        templateBody = templateBody1 ;
        system.debug('Final templateBody ----------> '+templateBody);
        return templateBody;
        
    }
    
    @AuraEnabled
    public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc, List<String> emailIds){
        try{
            String body = '';
            String subject = 'Punch List'; 
            List<string> strTO = new List<string>();
            List<string> strCC = new List<string>();
            SET<Id> contactIdSet = new SET<Id>();
            List<Contact> conList = new List<Contact>();
            if(Schema.sObjectType.Contact.fields.Id.isAccessible()
               && Schema.sObjectType.Contact.fields.email.isAccessible()){
                   conList = [Select Id, email from Contact where Id IN:to and email != null];        
               }
            system.debug('conList -------> '+conList);
            for(Contact con: conList){
                strTO.add(con.email);
            }
            List<Contact> ccConList = new List<Contact>(); 
            if(cc.size() > 0 && Schema.sObjectType.Contact.fields.Id.isAccessible()
               && Schema.sObjectType.Contact.fields.Email.isAccessible()){
                   ccConList = [Select Id, email from Contact where Id IN:cc and Email != null];        
               }
            if(ccConList.size() > 0){
                for(Contact con: ccConList){
                    strCC.add(con.email);
                }    
            }
            system.debug('emailIds&&&&&&&&'+emailIds);
            strTO.addAll(emailIds);
            system.debug('strTO---->'+strTO);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            system.debug('strTO ---------> '+strTO);
            mail.setToAddresses(strTO);
            if(strCC != null && strCC.size() > 0) {
                system.debug('strCC -------> '+strCC);
                mail.setCcAddresses(strCC);
            }
            EmailServicesAddress eServices;
            if(Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible()&&
               Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
                   eServices =  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
               } 
            string fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName;
            mail.setReplyTo(fromAddress);
            subject = subject +'[ref:'+recordId+']'; 
            mail.setSubject(subject);
            mail.setHTMLBody(body);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName('AccountPayable.pdf');
            system.debug('Blob ---> '+setAttachmentBody(recordId, templateId));
            efa.setBody(setAttachmentBody(recordId, templateId));
            fileAttachments.add(efa); 
            mail.setFileAttachments(fileAttachments);
            mails.add(mail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            String message = 'Success';
            
            if(results.size() > 0){
                if (results[0].isSuccess()) {
                    string Toaddresses= '';
                    string CCaddresses= '';
                    integer i = 0;
                    for(String Str : strTO){
                        Toaddresses += Str;
                        if(strTO.size() > i){
                            Toaddresses += ';';
                        }
                        i++;
                    }
                    for(String Str : strCC){
                        CCaddresses += Str;
                        if(strCC.size() > i){
                            CCaddresses += ';';
                        }
                        i++;
                        
                    }
                    system.debug('CCaddresses ----------> '+CCaddresses);
                    EmailMessage caseEmailMessage = new EmailMessage();
                    caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                    caseEmailMessage.ToAddress = Toaddresses;
                    caseEmailMessage.FromName = UserInfo.getUserName();
                    caseEmailMessage.CcAddress = CCaddresses;
                    caseEmailMessage.Subject = subject;
                    caseEmailMessage.HtmlBody = body;
                    caseEmailMessage.Incoming= False;
                    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                    caseEmailMessage.MessageDate = system.now();
                    caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                    system.debug('Content length ---------> '+body.length());
                    caseEmailMessage.status = '5';
                    caseEmailMessage.RelatedToId = recordId;
                    caseEmailMessage.buildertek__Subject__c = 'Re: '+subject;
                    
                    insert caseEmailMessage;        
                    
                    
                    
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = caseEmailMessage.id;
                    emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                    emr.relationType = 'FromAddress';
                    emr.relationAddress = caseEmailMessage.fromAddress;
                    insert emr;        
                    
                }
            }
            
            
            return message;                   
        }catch(Exception exp){
            system.debug('Error Message --------> '+exp);
            String message = exp.getMessage();
            return message;    
        }
        
    }
    
    private static Blob setAttachmentBody(String recordId, String templateId){
        pagereference pdf;
        pdf = Page.buildertek__BT_GeneratePdf;
        pdf.getParameters().put('recordId',recordId);  
        pdf.getParameters().put('templateId',templateId); 
        pdf.setRedirect(true);
        
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }
}