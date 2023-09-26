public without sharing class PreviewQuoteController{
    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
        List<Emailtemplate> temrec;
        if (Schema.sObjectType.Emailtemplate.fields.Id.isAccessible() && Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() && Schema.sObjectType.Emailtemplate.fields.folderid.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){
            temrec = [Select Id, Name, folder.name, DeveloperName
                      from Emailtemplate
                      where folder.name = 'BT Quote' AND DeveloperName != 'quote_top' AND DeveloperName != 'quote_bottom'];
        }
        System.debug('Template ========>>>>>'+temrec);
        return temrec;
    }

    @AuraEnabled
    public static List<Contact> getObjectContact(String recordId){
        List<Contact> con;
        buildertek__Quote__c qut;
        Set<Id> projectAccId= new Set<Id>();
        
        qut = [SELECT Id, Name, buildertek__Project__c , buildertek__Project__r.buildertek__Customer__c FROM buildertek__Quote__c WHERE Id = :recordId];

        System.debug('qut.buildertek__Project__c' + qut.buildertek__Project__c);
        System.debug('qut.buildertek__Project__c' + qut.buildertek__Project__r.buildertek__Customer__c);

        if (qut.buildertek__Project__c != null && qut.buildertek__Project__r.buildertek__Customer__c != null){
            if(qut.buildertek__Project__r.buildertek__Customer__c != null){
                projectAccId.add(qut.buildertek__Project__r.buildertek__Customer__c);
            }
            
        }

        System.debug('projectAccId' + projectAccId);
        if(!projectAccId.isEmpty()){
            con = [SELECT Id, Name, Email , buildertek__Primary_Contact__c, AccountId FROM Contact WHERE AccountId IN: projectAccId];
        }
        return con;
    }

    @AuraEnabled
    public static string getQuoteLines(String recordId, String templateId){
        string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        Boolean useSignature = false;
        Contact con;
        if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
            con = [select id, Email
                   from Contact
                   where email != null
                   order by createddate desc
                   limit 1];
        }
        String[] toaddres;
        // toaddres = new String[]{con.email};
        toaddres = new String[]{'info@buildertek.com'};
        Savepoint sp = Database.setSavepoint();
        list<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        list<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        EmailTemplate theTemplate;
        if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
            theTemplate = [SELECT Id, Name
                           FROM EmailTemplate
                           WHERE Id = :templateId];
        }
        email.setTemplateId(theTemplate.Id);
        email.setWhatId(recordId);
        email.setTargetObjectId(con.Id);
        // email.setSaveAsActivity(true);
        email.setSaveAsActivity(false);
        email.setToAddresses(toaddres);
        email.setUseSignature(useSignature);
        msgList.add(email);

        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
        Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody1 = emailNew.getHTMLBody();
        }

        if (theTemplate.Name != 'Quote - HISAB') {
            Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
            string theTemplate1 = [SELECT Id
                                FROM EmailTemplate
                                WHERE Name = 'BT Proposal Images'].Id;
            email1.setTemplateId(theTemplate1);
            System.debug(theTemplate1);
            email1.setWhatId(recordId);
            email1.setTargetObjectId(con.Id);
            // email1.setSaveAsActivity(true);
            email1.setSaveAsActivity(false);
            email1.setToAddresses(toaddres);
            email1.setUseSignature(useSignature);
            msgList1.add(email1);
            Messaging.SendEmailResult[] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email1});
            System.debug('Email Results isSuccess = ' + r1[0].IsSuccess());
            Database.rollback(sp);
            for (Messaging.SingleEmailMessage emailNew1 : msgList1){
                templateBody2 = emailNew1.getHTMLBody();
            }
            system.debug('templateBody 2 ----------> ' + templateBody2);
            templateBody = templateBody1 + templateBody2;
            system.debug('Final templateBody ----------> ' + templateBody);
        } else {
            templateBody = templateBody1;

        }

        return templateBody;
    }

    @AuraEnabled
    public static List<buildertek__Proposal_Images__c> getProposalImages(String recordId){
        List<buildertek__Proposal_Images__c> proposalImagesList;
        if (Schema.sObjectType.buildertek__Proposal_Images__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Image__c.isAccessible() && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Proposal__c.isAccessible()){
            proposalImagesList = [SELECT Id , buildertek__Image__c, buildertek__Description__c
                                  FROM buildertek__Proposal_Images__c
                                  WHERE buildertek__Proposal__c = :recordId];
        }
        return proposalImagesList;
    }

    @AuraEnabled
    public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc, List<String> emailIds, string memovalue){
       // try{
            String fileid = '';
            String body = '';
            String subject='';
            String salesRepEmailId='';
            string templateBody = '';
            string templateBody1 = '';
            string templateBody2 = '';
            Boolean useSignature = false;
            system.debug(' To list '+to);
            List<buildertek__Quote__c> salesRepEmail=[SELECT Id, buildertek__Sales_Rep__r.Email FROM buildertek__Quote__c WHERE Id = : recordId LIMIT 1];
            if(salesRepEmail.size()>0){
                if(salesRepEmail[0].buildertek__Sales_Rep__r.Email != null){
                    salesRepEmailId = salesRepEmail[0].buildertek__Sales_Rep__r.Email; //Add Sales Reps in CC.
                    system.debug('salesRepEmailId'+salesRepEmailId);
                }
            }

             list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                  buildertek__Quote_Configuration__c,buildertek__Email_Subject__c
                                                                                                  from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                  WHERE Name=:'Quote Configuration' and buildertek__Email_Subject__c !=null limit 1];
            if(adminInterfaceNodeConfigurations.size()>0){
                subject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
            }else{
                // subject = 'Quote';
                //BUIL 3119
                list<buildertek__Quote__c> quoterecbody = new list<buildertek__Quote__c>();
                quoterecbody = [select id, Name, buildertek__Status__c, buildertek__TemplateId__c,buildertek__Template_Name__c, buildertek__To_Emails__c,buildertek__Date_Sent_To_Customer__c,buildertek__Memo__c
                                from buildertek__Quote__c
                                where Id = :recordId
                                limit 1];
                if (quoterecbody.size() > 0){
                    subject = 'Quote : ' + quoterecbody[0].Name;
                }
            }


        List<EmailTemplate> et = [SELECT Id,Name,Subject FROM EmailTemplate WHERE Id =:templateId];

        //* nishit's logic for wide org email starts from here
        buildertek__WideOrgEmailsettings__c getEmail = buildertek__WideOrgEmailsettings__c.getOrgDefaults();
        String wideOrgEmailName = getEmail.buildertek__WideEmail__c;
        List<OrgWideEmailAddress> wideOrgEmail =[select Id,Address from OrgWideEmailAddress WHERE Address =:wideOrgEmailName];
        //* nishit's logic for wide org email ends from here

        system.debug('recordId----' + recordId);
            system.debug('templateId----' + templateId);
            list<buildertek__Quote__c> quoterecbody = new list<buildertek__Quote__c>();
            quoterecbody = [select id, Name, buildertek__Status__c, buildertek__TemplateId__c,buildertek__Template_Name__c, buildertek__To_Emails__c,buildertek__Date_Sent_To_Customer__c,buildertek__Memo__c
                            from buildertek__Quote__c
                            where Id = :recordId
                            limit 1];
            if (quoterecbody.size() > 0){
                quoterecbody[0].buildertek__TemplateId__c = templateId;
                if(!et.isEmpty()){
                   quoterecbody[0].buildertek__Template_Name__c	 = et[0].Name;
                }
                quoterecbody[0].buildertek__Memo__c = memovalue;

                string toemail = string.join(to,',');

                quoterecbody[0].buildertek__To_Emails__c = toemail;
                update quoterecbody;
                System.debug('Memo : '+quoterecbody[0].buildertek__Memo__c);
            }

            List<Contact> conList = [SELECT Id, email FROM Contact WHERE Id IN :to AND Email != null];

            system.debug('random contact id '+conList[0]);
            List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
            Savepoint sp = Database.setSavepoint();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            string theTemplatebodyid = [SELECT Id
                                        FROM EmailTemplate
                                        WHERE DeveloperName = 'QuoteTemplateBody'].Id;
            email.setTemplateId(theTemplatebodyid);
            email.setTargetObjectId(conList[0].Id);
            // email.setSaveAsActivity(true);
            email.setSaveAsActivity(false);
            email.setWhatId(recordId);
            email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
            email.setUseSignature(useSignature);
            msgList.add(email);

            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
            Database.rollback(sp);
            for (Messaging.SingleEmailMessage emailNew : msgList){
                system.debug(emailNew);
                templateBody1 = emailNew.getHTMLBody();
            }

            List<string> strTO = new List<string>();
            List<string> strCC = new List<string>();
            SET<Id> contactIdSet = new SET<Id>();
            system.debug('conList -------> ' + conList);
            for (Contact con : conList){
                strTO.add(con.email);
              //  strTo.add('mahesh@diligentforcelabs.com');
            }
            List<Contact> ccConList = new List<Contact>();
            if (cc.size() > 0){
                if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
                    ccConList = [Select Id, email
                                 from Contact
                                 where Id IN :cc and Email != null];
                }
            }
            if (ccConList.size() > 0){
                for (Contact con : ccConList){
                    strCC.add(con.email);
                }
            }
            if(salesRepEmailId != ''){
                strCC.add(salesRepEmailId);
                system.debug('salesRepEmailId'+strCC);
            }
            strTO.addAll(emailIds);

            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            system.debug('strTO ---------> ' + strTO);
            mail.setToAddresses(strTO);
            if (strCC != null && strCC.size() > 0){
                system.debug('strCC -------> ' + strCC);
                mail.setCcAddresses(strCC);
            }
            EmailServicesAddress eServices;

            eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];

            string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
            List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
            string SiteUrl;
            if (confirmationurl.size() > 0){
                SiteUrl = confirmationurl[0].buildertek__SiteURL__c;
            }

            mail.setReplyTo(fromAddress);
            if (wideOrgEmail.size() > 0) {
                mail.setOrgWideEmailAddressId(wideOrgEmail[0].Id);
            }
            subject = subject + '[ref:' + recordId + ']';
            mail.setSubject(subject);
            mail.setHTMLBody(templateBody1);
            //mail.setTargetObjectId(conrec.Id);
            mail.setSaveAsActivity(false);
            // mail.setSaveAsActivity(true);
            mail.setWhatId(recordId);

            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            // efa.setFileName('Quote.pdf');
            efa.setFileName(quoterecbody[0].Name+'.pdf');
            Blob b = setAttachmentBody(recordId, templateId, fileid);
            system.debug('Blob ---> ' + b);
            
            efa.setBody(b);
            fileAttachments.add(efa);
            mail.setFileAttachments(fileAttachments);
            mail.setUseSignature(useSignature);
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
                    integer j = 0;
                    for (String Str : strCC){
                        CCaddresses += Str;
                        if (strCC.size() > j){
                            CCaddresses += ';';
                        }
                        j++;

                    }


                    String anchorTagRegex = '<a href=\"(.*?)">(.*?)</a>';
                    String plainText = templateBody1.replaceAll(anchorTagRegex, ' ');
                    String plainText2 = plainText.stripHtmlTags();

                    // Print the plain text.
                    System.debug('Plain text: ' + plainText);

                    system.debug('CCaddresses ----------> ' + CCaddresses);
                    system.debug('Toaddresses ----------> ' + Toaddresses);
                    EmailMessage caseEmailMessage = new EmailMessage();
                    caseEmailMessage.fromAddress = UserInfo.getUserEmail();
                    caseEmailMessage.ToAddress = Toaddresses;
                    caseEmailMessage.FromName = UserInfo.getName();
                    caseEmailMessage.CcAddress = CCaddresses;
                    caseEmailMessage.Subject = subject;
                    caseEmailMessage.HtmlBody = templateBody1;
                    caseEmailMessage.Incoming = False;
                    caseEmailMessage.RelatedToId = recordId;
                    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                    caseEmailMessage.MessageDate = system.now();
                    caseEmailMessage.TextBody = plainText2;
                    system.debug('Content length ---------> ' + body.length());
                    caseEmailMessage.status = '3';
                    caseEmailMessage.RelatedToId = recordId;
                    caseEmailMessage.buildertek__Subject__c = 'Re: ' + subject;
                    System.debug('before caseEmailMessage:- '+caseEmailMessage);

                    insert caseEmailMessage;

                    System.debug('caseEmailMessage:- '+caseEmailMessage);
                    
                    ContentVersion conVer = new ContentVersion();
                    conVer.PathOnClient = 'Quote.pdf'; // The files name, extension is very important here which will help the file in preview.
                    conVer.Title = quoterecbody[0].Name; // Display name of the files
                    conVer.VersionData = b; // converting your binary string to Blog
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
                    
                    System.debug('emrid+- '+ emr);
                    System.debug('caseEmailMessage id :- '+emr.EmailMessageId);

                }
            }
            list<buildertek__Quote__c> quoterec;

            quoterec = [select id, Name, buildertek__Status__c, buildertek__Date_Sent_To_Customer__c,buildertek__Memo__c, buildertek__Date_Accepted_by_Customer__c, buildertek__Date_Rejected_by_Customer__c
                        from buildertek__Quote__c
                        where Id = :recordId
                        limit 1];

        system.debug('quoterec----------->'+quoterec);

            if (quoterec.size() > 0){
            //  if (quoterec[0].buildertek__Status__c != 'Customer Accepted'){
                    quoterec[0].buildertek__Status__c = 'Sent';
                //}
                if(quoterec[0].buildertek__Date_Rejected_by_Customer__c == null && quoterec[0].buildertek__Date_Accepted_by_Customer__c == null){
                    quoterec[0].buildertek__Date_Sent_To_Customer__c = System.today();
                }
                quoterec[0].buildertek__Memo__c = '';
                update quoterec;

            }

        system.debug('updatedquoterec----------->'+quoterec);

            return message;
    }

    @AuraEnabled
    public static String acceptandsendProposal(string signName, String htmlBody, String recordId, String templateId, List<String> to, List<String> cc, string fileid, List<String> emailIds, string memovalue){

        try{
            String body = '';
            String subject = '';
            Boolean useSignature = false;
             list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                  buildertek__Quote_Configuration__c,buildertek__Email_Subject__c
                                                                                                  from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                  WHERE Name=:'Quote Configuration' and buildertek__Email_Subject__c !=null limit 1];
            if(adminInterfaceNodeConfigurations.size()>0){
                subject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
            }else{
                subject = 'Quote';
            }
            String salesRepEmailId='';
            List<buildertek__Quote__c> salesRepEmail=[SELECT Id,Name, buildertek__Sales_Rep__r.Email FROM buildertek__Quote__c WHERE Id = : recordId LIMIT 1];
            if(salesRepEmail.size()>0){
                if(salesRepEmail[0].buildertek__Sales_Rep__r.Email != null){
                    salesRepEmailId = salesRepEmail[0].buildertek__Sales_Rep__r.Email;
                }
            }
            List<string> strTO = new List<string>();
            List<string> strCC = new List<string>();
            SET<Id> contactIdSet = new SET<Id>();
            List<Contact> conList = new List<Contact>();

            //* nishit's logic for wide org email starts from here
            buildertek__WideOrgEmailsettings__c getEmail = buildertek__WideOrgEmailsettings__c.getOrgDefaults();
            String wideOrgEmailName = getEmail.buildertek__WideEmail__c;
            List<OrgWideEmailAddress> wideOrgEmail =[select Id,Address from OrgWideEmailAddress WHERE Address =:wideOrgEmailName];
            //* nishit's logic for wide org email ends from here

            system.debug('to'+to);
            if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
                conList = [Select Id, email
                           from Contact
                           where Id IN :to and Email != null];
            }
            system.debug('conList -------> ' + conList);
            for (Contact con : conList){
                strTO.add(con.email);
            }

            List<Contact> ccConList = new List<Contact>();
            if (cc.size() > 0){
                if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
                    ccConList = [Select Id, email
                                 from Contact
                                 where Id IN :cc and Email != null];
                }
            }
            if (ccConList.size() > 0){
                for (Contact con : ccConList){
                    strCC.add(con.email);
                }
            }
            if(salesRepEmailId != ''){
                strCC.add(salesRepEmailId);
            }
            strTO.addAll(emailIds);

            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            system.debug('strTO ---------> ' + strTO);
            mail.setToAddresses(strTO);
            if (strCC != null && strCC.size() > 0){
                system.debug('strCC -------> ' + strCC);
                mail.setCcAddresses(strCC);
            }
            EmailServicesAddress eServices;
            //if (Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
                eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                             FROM EmailServicesAddress
                             where LocalPart = 'projects'];
            //}
            List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
            string SiteUrl;
            if (confirmationurl.size() > 0){
                SiteUrl = confirmationurl[0].buildertek__SiteURL__c;
            }
            system.debug('&&&&&&'+eServices.LocalPart);
            system.debug('**********'+eServices.EmailDomainName);
            string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
           system.debug('fromAddress'+fromAddress);
            /*  body += 'Hi, <br/><br/> ';fileid
             body += '</br> Please &nbsp;';
             body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+recordId+'&templateId='+templateId+'>Click here</a>';
             body += '&nbsp;to confirm your Quote Order details.' ; */
            mail.setReplyTo(fromAddress);
            if (wideOrgEmail.size() > 0) {
                mail.setOrgWideEmailAddressId(wideOrgEmail[0].Id);
            }
            subject = subject + '[ref:' + recordId + ']';
            mail.setSubject(subject);
            mail.setHTMLBody(body);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            if(salesRepEmail.size()>0){
                String fileName = salesRepEmail[0].Name + '.pdf';
                efa.setFileName(fileName);

            }
            //system.debug('Blob ---> ' + setAttachmentBody(recordId, templateId, fileid));
            system.debug('templateId'+templateId);

            Blob b = setAttachmentBody(recordId, templateId, fileid);
            system.debug('Blob ---> ' + b);

            ContentVersion conVer = new ContentVersion();
            conVer.PathOnClient = 'Quote.pdf'; // The files name, extension is very important here which will help the file in preview.
            conVer.VersionData = b; // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion

            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recordId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;  //ContentDocumentId Id from ContentVersion
            conDocLink.Visibility = 'AllUsers';
            insert conDocLink;

            efa.setBody(setAttachmentBody(recordId, templateId, fileid));
            fileAttachments.add(efa);
            mail.setFileAttachments(fileAttachments);
            mail.setUseSignature(useSignature);
            mails.add(mail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            String message = 'Success';
            System.debug('results '+results);
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
                    system.debug('CCaddresses ----------> ' + CCaddresses);
                    system.debug('body ----------> ' + body);
                    system.debug('subject ----------> ' + subject);
                    system.debug('Toaddresses ----------> ' + Toaddresses);
                    EmailMessage caseEmailMessage = new EmailMessage();
                    caseEmailMessage.fromAddress = UserInfo.getUserEmail();
                    caseEmailMessage.ToAddress = Toaddresses;
                    caseEmailMessage.FromName = UserInfo.getUserName();
                    caseEmailMessage.CcAddress = CCaddresses;
                    caseEmailMessage.Subject = subject;
                    caseEmailMessage.HtmlBody = body;
                    caseEmailMessage.Incoming = False;
                    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                    caseEmailMessage.MessageDate = system.now();
                    caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                    system.debug('Content length ---------> ' + body.length());
                    caseEmailMessage.status = '5';
                    caseEmailMessage.RelatedToId = recordId;
                    caseEmailMessage.buildertek__Subject__c = 'Re: ' + subject;

                    insert caseEmailMessage;

                    ContentVersion conVer1 = new ContentVersion();
                    conVer1.PathOnClient = 'Quote.pdf'; // The files name, extension is very important here which will help the file in preview.
                    conver1.Title = 'Quote.pdf';
                    conVer1.VersionData = b; // converting your binary string to Blog
                    insert conVer1;    //Insert ContentVersion

                    ContentDocumentLink conDocLink1 = New ContentDocumentLink();
                    conDocLink1.LinkedEntityId = caseEmailMessage.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                    conDocLink1.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer1.Id].ContentDocumentId;  //ContentDocumentId Id from ContentVersion
                    conDocLink1.Visibility = 'AllUsers';
                    insert conDocLink1;


                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = caseEmailMessage.id;
                    emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                    emr.relationType = 'FromAddress';
                    emr.relationAddress = caseEmailMessage.fromAddress;
                    insert emr;

                }
            }
            list<buildertek__Quote__c> quoterec;

            quoterec = [select id, Name, buildertek__Status__c, buildertek__Date_Sent_To_Customer__c, buildertek__Date_Accepted_by_Customer__c
                        from buildertek__Quote__c
                        where Id = :recordId
                        limit 1];

            if (quoterec.size() > 0){

                //quoterec[0].buildertek__Status__c = 'Sent';
                quoterec[0].buildertek__Status__c = 'Customer Accepted';
                quoterec[0].buildertek__Date_Accepted_by_Customer__c = system.now();
                quoterec[0].buildertek__Date_Sent_To_Customer__c = System.today();
                quoterec[0].buildertek__Memo__c = memovalue;
                update quoterec;

            }

            return message;
      } catch (Exception exp){
            system.debug('Error Message --------> ' + exp);
            String message = exp.getMessage();
            return message;
        }
    }

    private static Blob setAttachmentBody(String recordId, String templateId, String fileid){
        System.debug(recordId);
        System.debug(templateId);
        System.debug(fileid);




        pagereference pdf;
        pdf = Page.buildertek__BT_GenerateQuotePDF;
        system.debug('*********'+pdf);
        pdf.getParameters().put('recordId', recordId);
        pdf.getParameters().put('templateId', templateId);
        pdf.getParameters().put('fileId', fileId);
        pdf.setRedirect(true);

        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }

    @AuraEnabled
    public static String getBlobBody(String recordId, String templateId, String fileid){

        pagereference pdf;
        pdf = Page.buildertek__BT_GenerateQuotePDF;
        system.debug('*********'+pdf);
        pdf.getParameters().put('recordId', recordId);
        pdf.getParameters().put('templateId', templateId);
        pdf.getParameters().put('fileId', fileId);
        pdf.setRedirect(true);

        return EncodingUtil.base64Encode(pdf.getContent());
    }

    @AuraEnabled
    public static void createTask(String whatId, String emailSubject){
        //system.debug('whoId ---------> '+whoId);
        system.debug('whatId ---------> ' + whatId);
        system.debug('emailSubject ---------> ' + emailSubject);
        if (Schema.sObjectType.Task.fields.Subject.isCreateable() && Schema.sObjectType.Task.fields.WhatId.isCreateable() && Schema.sObjectType.Task.fields.TaskSubType.isCreateable() && Schema.sObjectType.Task.fields.ActivityDate.isCreateable() && Schema.sObjectType.Task.fields.Status.isCreateable()){

            Task tsk = new Task();
            tsk.Subject = emailSubject;
            //tsk.WhoId = whoId;
            tsk.WhatId = whatId;
            tsk.TaskSubType = 'Email';
            tsk.ActivityDate = Date.today();
            tsk.Status = 'Completed';
            insert tsk;

        }
    }

    /* To Save the Signature in Files */
    @AuraEnabled
    public static string saveSign(String recId, String base64Data, String contentType, string signName){
        system.debug('base64Data-------------' + base64Data);
        string conversn;
        if (base64Data.length() > 1696 || Test.isRunningTest()){
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'SignatureName.png'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = signName; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
            system.debug('*******conVer*******' + conVer);
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE Id = :conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'I';
            insert conDocLink;
            system.debug('conDocLink---' + conDocLink.id);

            list<buildertek__Quote__c> quoterec;

            quoterec = [select id, Name, buildertek__Status__c, buildertek__Date_Sent_To_Customer__c, buildertek__Date_Accepted_by_Customer__c
                        from buildertek__Quote__c
                        where Id = :recId
                        limit 1];

            if (quoterec.size() > 0){

                quoterec[0].buildertek__Status__c = 'Customer Accepted';

                quoterec[0].buildertek__Date_Accepted_by_Customer__c = system.now();

                update quoterec;
                system.debug(quoterec + 'quoterec---' + quoterec[0].buildertek__Date_Accepted_by_Customer__c);
            }

            conversn = [SELECT Id, VersionData
                        FROM ContentVersion
                        WHERE ContentDocumentId = :conDoc AND IsLatest = true].Id;
            //system.debug('conversn[0].Id ='+conversn[0].Id);
            return conversn;
        } else{
            String message = 'NoImage';
            return message;
        }
    }
    @AuraEnabled
    public static buildertek__Quote__c getmemoval(String recordId){
        Contact con;
        buildertek__Quote__c qut;
        if (Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Primary_Contact__c.isAccessible()){

            qut = [SELECT Id, buildertek__Memo__c
                   FROM buildertek__Quote__c
                   WHERE Id = :recordId];
        }
        return qut;
    }

}