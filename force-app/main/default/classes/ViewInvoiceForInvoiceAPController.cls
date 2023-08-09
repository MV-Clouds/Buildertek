public class ViewInvoiceForInvoiceAPController {
    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
        List<Emailtemplate> temrec;
        if (Schema.sObjectType.Emailtemplate.fields.Id.isAccessible() && Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() && Schema.sObjectType.Emailtemplate.fields.folderid.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){
            temrec = [Select Id, Name, folder.name
                      from Emailtemplate
                      where folder.name = 'Invoices AP']; /* and Name !=:'Invoice3' */
        }
        return temrec; 
    }
    
    /*@AuraEnabled
    public static string getInvoiceLines(String recordId, String templateId){
        
         List<buildertek__BT_Payment_App_Sign_Url__c> paymentAppSignUrl = [select Name__c, buildertek__Site_Url__c from buildertek__BT_Payment_App_Sign_Url__c limit 1];
        
        system.debug('recId'+recordId);
         system.debug('templateId'+templateId);
        
        PageReference pagePdf = new PageReference(paymentAppSignUrl[0].buildertek__Site_Url__c+'/apex/BT_Invoice');
        if(paymentAppSignUrl[0].buildertek__Site_Url__c != null || paymentAppSignUrl[0].buildertek__Site_Url__c != 'undefined'){
        String url = paymentAppSignUrl[0].buildertek__Site_Url__c;
        return url ;
                                   }
        //pagePdf.getParameters().put('recId', recordId);
       // pagePdf.getParameters().put('tempId', templateId);
        
        return null;
    }*/

    @AuraEnabled
    public static string getInvoiceLines(String recordId, String templateId){
        
        string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        Contact con;
        if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
            con = [select id, Email
                   from Contact
                   where email != null
                   order by createddate desc
                   limit 1];
        }
        String[] toaddres;
        toaddres = new String[]{con.email};
        Savepoint sp = Database.setSavepoint();
        list<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        list<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string theTemplate;
        if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
            theTemplate = [SELECT Id
                           FROM EmailTemplate
                           WHERE Id = :templateId].Id;
        }
        email.setTemplateId(theTemplate);
        email.setWhatId(recordId);
        email.setTargetObjectId(con.Id);
        email.setSaveAsActivity(true);
        email.setToAddresses(toaddres);
        msgList.add(email);

        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
        Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody1 = emailNew.getHTMLBody();
        }
        return templateBody1;
    }


    @AuraEnabled
    public static Contact getObjectContact(String recordId){
        Contact con;
        buildertek__Account_Payable_Clone__c qut;
        if (Schema.sObjectType.buildertek__Account_Payable_Clone__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Account_Payable_Clone__c.fields.buildertek__Contact__c.isAccessible()){

            qut = [SELECT Id, buildertek__Contact__c
                   FROM buildertek__Account_Payable_Clone__c
                   WHERE Id = :recordId];
        }


        if (qut.buildertek__Contact__c != null){
            con = [SELECT Id, Name, Email
                   FROM Contact
                   WHERE Id = :qut.buildertek__Contact__c];
        }
        return con;
    }

    @AuraEnabled
    public static String sendInvoice(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc, List<String> emailIds, string memovalue){
        try{
            
            List<Contact> conList =  [Select Id,Name,email from Contact where Id IN :to and email != null];
            
            String subject = 'Invoice';
            String body;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<String> sendTo = new List<String>();
            List<String> ccTo = new List<String>();
            for(Contact myContact : conList)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                
                sendTo.add(myContact.Email);
                mail.setToAddresses(sendTo);
                
                EmailServicesAddress eServices;
                if (Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
                    eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                                 FROM EmailServicesAddress
                                 where LocalPart = 'projects'];
                }
                string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
                mail.setReplyTo(fromAddress);
                
                
                for(Contact myccContact : [Select Id, email from Contact where Id IN :cc and email != null]){
                    
                    ccTo.add(myccContact.email);
                    
                }
                
                mail.setCcAddresses(ccTo);
                subject = subject + '[ref:' + recordId + ']';
                mail.setSubject(subject);
                
                body = '<html><body>Hello '+myContact.Name+',<br/><br/>Please review your attached Invoice.</body>  </html>';
                mail.setHtmlBody(body);
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName('Invoice.pdf');
                efa.setBody(setAttachmentBody(recordId, templateId));
                fileAttachments.add(efa);
                mail.setFileAttachments(fileAttachments);
                mails.add(mail);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            
            String message = 'Success';
            if (results.size() > 0){
                if (results[0].isSuccess()){
                    string Toaddresses = '';
                    string CCaddresses = '';
                    integer i = 0;
                    for (String Str : sendTo){
                        Toaddresses += Str;
                        if (sendTo.size() > i){
                            Toaddresses += ';';
                        }
                        i++;
                    }
                    for (String Str : ccTo){
                        CCaddresses += Str;
                        if (ccTo.size() > i){
                            CCaddresses += ';';
                        }
                        i++;
                    } 
                    EmailMessage caseEmailMessage = new EmailMessage();
                    caseEmailMessage.fromAddress = UserInfo.getUserEmail();
                    caseEmailMessage.ToAddress = Toaddresses;
                    caseEmailMessage.FromName = UserInfo.getUserName();
                    caseEmailMessage.CcAddress = CCaddresses;
                    caseEmailMessage.Subject = subject;
                    caseEmailMessage.HtmlBody = body;
                    caseEmailMessage.Incoming = False;
                    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                    caseEmailMessage.MessageDate = System.now();
                    caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                    caseEmailMessage.status = '5';
                    caseEmailMessage.RelatedToId = recordId;
                    caseEmailMessage.buildertek__Subject__c = 'Re: ' + subject;
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
        }
        catch (Exception exp){
            system.debug('Error Message --------> ' + exp);
            String message = exp.getMessage();
            return message;
        }
    }

    private static Blob setAttachmentBody(String recordId, String templateId){
        pagereference pdf;
        pdf = Page.buildertek__BT_GeneratePdf;
        pdf.getParameters().put('recordId', recordId);
        pdf.getParameters().put('templateId', templateId);
        pdf.setRedirect(true);
        
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }
}