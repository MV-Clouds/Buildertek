public with sharing class PreviewBillingsController{
    public buildertek__Billings__c relatedTo{get;set;}


    public PreviewBillingsController(){
        System.debug('relatedTo=='+relatedTo);

    }


    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
        List<Emailtemplate> temrec;
        if (Schema.sObjectType.Emailtemplate.fields.Id.isAccessible() && Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() && Schema.sObjectType.Emailtemplate.fields.folderid.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){
            temrec = [Select Id, Name, folder.name
                      from Emailtemplate
                      where folder.name = 'BT Bill' and Name !=:'Invoice3'];

        }
        return temrec;
    }

    @AuraEnabled
    public static string getInvoiceLines(String recordId, String templateId){
        string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        System.debug('templateId=='+templateId);
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

        string theTemplate = [SELECT Id
                              FROM EmailTemplate
                              WHERE Id = :templateId].Id;

        System.debug('theTemplate=='+theTemplate);
        System.debug('recordId=='+recordId);
        System.debug('con.Id=='+con.Id);
        System.debug('toaddres=='+toaddres);


        email.setTemplateId(theTemplate);
        email.setWhatId(recordId);
        email.setTargetObjectId(con.Id);
        email.setSaveAsActivity(false);
        email.setToAddresses(toaddres);
        msgList.add(email);

        System.debug('msgList=='+msgList);

        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
        Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody1 = emailNew.getHTMLBody();
        }


        /*Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
        string theTemplate1 = [SELECT Id FROM EmailTemplate WHERE Name = 'BT Proposal Images'].Id;
        email1.setTemplateId(theTemplate1);
        email1.setWhatId(recordId);
        email1.setTargetObjectId(con.Id);
        email1.setSaveAsActivity(false);
        email1.setToAddresses(toaddres);
        msgList1.add(email1);
        Messaging.SendEmailResult [] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email1});
        System.debug('Email Results isSuccess = ' +  r1[0].IsSuccess());
        Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew1 : msgList1) {
        templateBody2 = emailNew1.getHTMLBody();
        }
        system.debug('templateBody 2 ----------> '+templateBody2);*/
        templateBody = templateBody1;
        system.debug('Final templateBody ----------> ' + templateBody);
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

    /*   @AuraEnabled
        public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc){
        try{
        String body = '';
        String subject = 'Invoice';
        List<string> strTO = new List<string>();
        List<string> strCC = new List<string>();
        SET<Id> contactIdSet = new SET<Id>();
        List<Contact> conList = new List<Contact>();
        if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
        conList = [Select Id, email
        from Contact
        where Id IN :to and email != null];
        }
        system.debug('conList -------> ' + conList);
        for (Contact con : conList){
        strTO.add(con.email);
        }
        List<Contact> ccConList = new List<Contact>();
        if (cc.size() > 0 && Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
        ccConList = [Select Id, email
        from Contact
        where Id IN :cc and email != null];
        }
        if (ccConList.size() > 0){
        for (Contact con : ccConList){
        strCC.add(con.email);
        }
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        system.debug('strTO ---------> ' + strTO);
        mail.setToAddresses(strTO);
        if (strCC != null && strCC.size() > 0){
        system.debug('strCC -------> ' + strCC);
        mail.setCcAddresses(strCC);
        }
        EmailServicesAddress eServices;
        if (Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
        eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
        FROM EmailServicesAddress
        where LocalPart = 'projects'];
        }
        string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
        mail.setReplyTo(fromAddress);
        subject = subject + '[ref:' + recordId + ']';
        mail.setSubject(subject);
        mail.setHTMLBody(body);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName('Invoice.pdf');
        efa.setBody(setAttachmentBody(recordId, templateId));
        fileAttachments.add(efa);
        mail.setFileAttachments(fileAttachments);
        mails.add(mail);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);

        String message = 'Success';
        if (results.size() > 0){
        if (results[0].isSuccess()){
        string Toaddresses = '';
        string CCaddresses = '';
        integer i = 0;
        for (String Str : strTO){
        Toaddresses += Str;
        if (strTO.size() > i){
        Toaddresses += ';';
        }
        i++;
        }
        for (String Str : strCC){
        CCaddresses += Str;
        if (strCC.size() > i){
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
        } catch (Exception exp){
        system.debug('Error Message --------> ' + exp);
        String message = exp.getMessage();
        return message;
        }
        } */

    @AuraEnabled
    public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc){
        try{
            Blob tempblob;
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
                tempblob = setAttachmentBody(recordId, templateId);
                system.debug('Blob ---> ' + tempblob);
                mail.setSaveAsActivity(false);
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

                    ContentVersion conVer = new ContentVersion();
                    conVer.PathOnClient = 'Invoice.pdf'; // The files name, extension is very important here which will help the file in preview.
                    conVer.Title = 'Invoice.pdf'; // Display name of the files
                    conVer.VersionData = tempblob; // converting your binary string to Blog
                    insert conVer;    //Insert ContentVersion
                    
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = caseEmailMessage.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                    conDocLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;  //ContentDocumentId Id from ContentVersion
                    conDocLink.Visibility = 'AllUsers';
                    insert conDocLink;

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