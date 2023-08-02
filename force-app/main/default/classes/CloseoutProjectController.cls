public with sharing class CloseoutProjectController {
    @AuraEnabled
    public static string createInvoice(String recordId){
        string mainAR = '';
        List<buildertek__Billings__c> oldAR = [SELECT Id, Name FROM buildertek__Billings__c WHERE buildertek__Project__c =: recordId AND Name =: 'Closeout-Project-Invoice'];
        if (oldAR.isEmpty()) {
            buildertek__Billings__c AR = new buildertek__Billings__c();
            AR.Name = 'Closeout-Project-Invoice';
            AR.buildertek__Project__c = recordId;
            insert AR;
            mainAR = AR.Id;
        } else {
            mainAR = oldAR[0].Id;
        }

        String emailLabel = System.label.CloseOutProjectTemplate;
        EmailTemplate eTemp = [SELECT Id, Name FROM EmailTemplate WHERE Name =: emailLabel LIMIT 1];
        Contact con = [SELECT id, Email FROM Contact WHERE email != null ORDER BY createddate DESC LIMIT 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(eTemp.Id);
        email.setWhatId(mainAR);
        email.setTargetObjectId(con.Id);
        email.setSaveAsActivity(false);
        email.setToAddresses(new String[]{con.email});

        Savepoint sp = Database.setSavepoint();
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        Database.rollback(sp);

        string templateBody = email.getHTMLBody();
        return templateBody;
    }

    @AuraEnabled
    public static void updateMemo(String recordId, String memoValue){
        if(String.isNotBlank(recordId)){
            List<buildertek__Billings__c> invrec;
            if (Schema.sObjectType.buildertek__Billings__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Invoiced_Date__c.isAccessible() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Memo__c.isAccessible()){
                invrec = [SELECT Id, buildertek__Invoiced_Date__c, buildertek__Memo__c
                          FROM buildertek__Billings__c
                          WHERE Id = :recordId
                          Limit 1
                          FOR  UPDATE ];
            }
            if (invrec.size() > 0){
                invrec[0].buildertek__Invoiced_Date__c = System.today();
                invrec[0].buildertek__Memo__c = memoValue;
                if (Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Invoiced_Date__c.isUpdateable() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Memo__c.isUpdateable()){
                    update invrec;
                }
            }
        }
    }

    @AuraEnabled
    public static String sendProposal(String htmlBody, String recordPId, List<String> to, List<String> cc){
        try{

            buildertek__Billings__c oldAR = [SELECT Id, Name FROM buildertek__Billings__c WHERE buildertek__Project__c =: recordPId AND Name =: 'Closeout-Project-Invoice' LIMIT 1];
            String recordId = oldAR.Id;

            String emailLabel = System.label.CloseOutProjectTemplate;
            EmailTemplate eTemp = [SELECT Id, Name FROM EmailTemplate WHERE Name =: emailLabel LIMIT 1];
            String templateId = eTemp.Id;

            List<Contact> conToList =  [Select Id,Name,email,MailingStreet,MailingCity, MailingState,MailingPostalCode,MailingCountry from Contact where Id IN :to and email != null];

            List<Contact> conCcList = [Select Id, email from Contact where Id IN :cc and email != null];

            // String address = conToList.MailingStreet;
            String subject = 'Project Closeout';
            String body;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<String> sendTo = new List<String>();
            List<String> ccTo = new List<String>();
            for(Contact myContact : conToList)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                sendTo.add(myContact.Email);
                mail.setToAddresses(sendTo);
                EmailServicesAddress eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart FROM EmailServicesAddress WHERE LocalPart = 'projects'];

                string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;

                mail.setReplyTo(fromAddress);
                for(Contact con : conCcList){
                    ccTo.add(con.email);
                }
                mail.setCcAddresses(ccTo);
                if(myContact.MailingStreet==null){
                    subject = subject;
                    mail.setSubject(subject);
                }else{
                    subject = subject + '-' + myContact.MailingStreet;
                    mail.setSubject(subject);
                }
                
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
            String message = exp.getMessage() + '  -  ' + exp.getLineNumber();
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