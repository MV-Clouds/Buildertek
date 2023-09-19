public with sharing class PreviewSalesOrderController{
    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
        List<Emailtemplate> tempList = [SELECT Id, Name, folder.name
                                        FROM Emailtemplate
                                        WHERE Name = :'Sales Order'];
        return tempList;
    }

    @AuraEnabled
    public static string getSalesOrderLines(String recordId, String templateId){
        System.debug('In getSalesOrderLines method ::');
        string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        Contact con;

        con = [select id, Email
               from Contact
               where email != null
               order by createddate desc
               limit 1];

        String[] toaddres;
        toaddres = new String[]{ con.email };
        Savepoint sp = Database.setSavepoint();
        list<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        list<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        string theTemplate = [SELECT Id
                              FROM EmailTemplate
                              WHERE Id = :templateId].Id;
        email.setTemplateId(theTemplate);
        email.setWhatId(recordId);
        email.setTargetObjectId(con.Id);
        email.setSaveAsActivity(true);
        email.setToAddresses(toaddres);
        msgList.add(email);

        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ email });
        System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
        Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody1 = emailNew.getHTMLBody();
        }
        templateBody = templateBody1;
        system.debug('Final templateBody ----------> ' + templateBody);
        return templateBody;
    }

    @AuraEnabled
    public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc, string Emailsubject){
        System.debug('In SendEmail Method ::');
        try{
            string fileid = '';
            String body = '';
            //String subject =  Emailsubject;
            // String subject = ' Change Order [ref:' + recordId + ']';
            String subject = '';
            list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c
                                                                                                        from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                        WHERE Name = :'Sales Order Configuration' and buildertek__Email_Subject__c != null
                                                                                                        limit 1];
            if (adminInterfaceNodeConfigurations.size() > 0){
                subject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
            } else{
                subject = 'Sales Order';
            }
            system.debug('htmlBody----' + htmlBody);
            system.debug('recordId----' + recordId);
            system.debug('to----' + to);
            system.debug('cc----' + cc);
            system.debug('Emailsubject----' + Emailsubject);
            system.debug('templateId----' + templateId);
            List<string> strTO = new List<string>();
            List<string> strCC = new List<string>();
            SET<Id> contactIdSet = new SET<Id>();
            List<Contact> conList = new List<Contact>();
            if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
                conList = [Select Id, email
                           from Contact
                           where Id IN:to and email != null];
            }
            system.debug('conList -------> ' + conList);
            for (Contact con : conList){
                strTO.add(con.email);
            }
            List<Contact> ccConList = new List<Contact>();
            if (cc.size() > 0 && Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()){
                ccConList = [Select Id, email
                             from Contact
                             where Id IN:cc and Email != null];
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
            if (conList.size() > 0){
                mail.setTargetObjectId(conList[0].Id);
                mail.setWhatId(recordId);
            }
            if (strCC != null && strCC.size() > 0){
                system.debug('strCC -------> ' + strCC);
                mail.setCcAddresses(strCC);
            }
            EmailServicesAddress eServices;

            eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                         FROM EmailServicesAddress
                         where LocalPart = 'projects'];

            string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
            List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
            string SiteUrl;
            if (confirmationurl.size() > 0){
                SiteUrl = confirmationurl[0].buildertek__SiteURL__c;
            }
            // body += 'Hello, <br/><br/> ';
            // body += '</br> Please &nbsp;';
            // body += '<a href=' + SiteUrl + 'buildertek__ConfirmationPage?Id=' + recordId + '&templateId=' + templateId + '>Click here</a>';
            // body += '&nbsp;to confirm your Sales Order details. <br/> <br/> <br/>';
            // body += '<br/><center><a href="mailto:'+fromAddress+'?subject='+subject+'&body=Approved"><button type="button" style="cursor: pointer;background-color: #005fb2;color: white;padding-left: 16px;padding-right: 16px;text-align: center;vertical-align: middle;border: 1px solid #0070d2;line-height: 30px;min-height: 32px;cursor: pointer;">Approve</button></a> &nbsp;&nbsp;&nbsp;<a href="mailto:'+fromAddress+'?subject='+subject+'&body=Rejected"><button type="button" style="cursor: pointer;background-color: #a61a14;color: white;padding-left: 16px;padding-right: 16px;text-align: center;vertical-align: middle;border: 1px solid #0070d2;line-height: 30px;min-height: 32px;cursor: pointer;">Reject</a></button></center><br/>';

            mail.setReplyTo(fromAddress);
            //subject = subject ;
            subject = subject + '[ref:' + recordId + ']';
            mail.setSubject(subject);
            mail.setHTMLBody(htmlBody);
            mail.setSaveAsActivity(true);
            // List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            // Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            // efa.setFileName('ChangeOrder.pdf');
            // system.debug('templateid-----' + templateId + 'record---> ' + recordId);
            // system.debug('Blob ---> ' + setAttachmentBody(recordId, templateId, fileid));
            // efa.setBody(setAttachmentBody(recordId, templateId, fileid));
            // fileAttachments.add(efa);
            // mail.setFileAttachments(fileAttachments);
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
                    system.debug('CCaddresses ----------> ' + CCaddresses);


                    EmailMessage caseEmailMessage = new EmailMessage();
                    caseEmailMessage.fromAddress = UserInfo.getUserEmail();
                    caseEmailMessage.ToAddress = Toaddresses;
                    caseEmailMessage.FromName = UserInfo.getUserName();
                    caseEmailMessage.CcAddress = CCaddresses;
                    caseEmailMessage.Subject = subject;
                    caseEmailMessage.HtmlBody = body;
                    caseEmailMessage.Incoming = False;
                    //caseEmailMessage.IsTracked = true;
                    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                    caseEmailMessage.MessageDate = system.now();
                    caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                    system.debug('Content length ---------> ' + body.length());

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
            // list<buildertek__Change_Order__c> corec;

            // corec = [select id, Name, buildertek__Customer_Accepted_Date__c, buildertek__Status__c, buildertek__Date_Approved__c
            //          from buildertek__Change_Order__c
            //          where Id = :recordId
            //          limit 1];

            // if (corec.size() > 0){
            //     corec[0].buildertek__Date_Approved__c = system.now();
            //     update corec;

            // }
            return message;
        } catch (Exception exp){
            system.debug('Error Message --------> ' + exp);
            System.debug('In SendEmail Error block::');
            String message = exp.getMessage();
            return message;
        }
    }

}