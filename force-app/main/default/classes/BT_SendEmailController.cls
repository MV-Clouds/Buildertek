/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  04-Sep-2018
 */
public with sharing class BT_SendEmailController{

    public static Change_Order__c co{get;set;}
    public List<Change_Order__c> changeOdrList{get;set;}
    public static List<Change_Order__c> changeOdrList1{get;set;}
    public String yrcId {get;set;}

    public BT_SendEmailController(){

        yrcId = ApexPages.currentPage().getParameters().get('id');
        System.debug('yrcId>>>'+yrcId);

        changeOdrList = [SELECT Id,buildertek__CO_Number__c,buildertek__Project__r.Name,buildertek__Project__r.buildertek__Customer__r.Name,buildertek__Project__r.buildertek__Customer__r.billingstreet,
                            buildertek__Project__r.buildertek__Customer__r.billingcity,buildertek__Project__r.buildertek__Customer__r.billingstate,buildertek__Project__r.buildertek__Customer__r.billingpostalcode,

                            buildertek__Project__r.buildertek__Customer__r.billingCountry,buildertek__Project__r.buildertek__Customer__r.Phone,Name,Total_Amount_Tax__c,buildertek__Status__c,

                            Total_Amount__c,Tax_Rate__c,(SELECT Name,Description__c,Quantity__c,Unit_Sales_Price__c,Total__c FROM Change_Order_Items__r) FROM Change_Order__c WHERE buildertek__Project__c =:yrcId AND buildertek__Type__c = 'Customer' AND (buildertek__Status__c = 'Customer Approved' OR buildertek__Status__c = 'Paid' OR buildertek__Status__c = 'Partially Paid')];
    }


    // public Pagereference savecontent(Id recordId,Blob bvalue){

    //     ContentVersion cv = new ContentVersion();
    //     cv.Title = 'Merged Document1';
    //     cv.PathOnClient = 'Merged Document1.pdf';
    //     cv.VersionData = bvalue;
    //     cv.IsMajorVersion = true;
    //     insert cv;

    //     //Get Content Documents
    //     Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

    //     //Create ContentDocumentLink
    //     ContentDocumentLink cdl = new ContentDocumentLink();
    //     cdl.LinkedEntityId = rcId;
    //     cdl.ContentDocumentId = conDocId;
    //     cdl.shareType = 'V';
    //     insert cdl;
    // }
    // public void generatepdf(){

    //     PageReference defaultPage = new PageReference('/apex/CreateSignedChangeVfWrapper'); //page location
    //     pageData = defaultPage.getContentAsPDF();
    // }

    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(String folderName){
        system.debug('folderName ----------> ' + folderName);
        if(String.isNotBlank(folderName)){
            List<EmailTemplate> emailTemplateList;
        //  if (Schema.sObjectType.Emailtemplate.fields.Id.isAccessible() && Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){

                emailTemplateList = [Select Id, Name, folder.name
                                     from Emailtemplate
                                     where folder.name = :folderName];
        //  }
            return emailTemplateList;
        }
        return null;
    }

    @AuraEnabled
    public Static List<EmailTemplate> getbodyTemplates(String folderName){
        system.debug('folderName ----------> ' + folderName);
        if(String.isNotBlank(folderName)){
            List<EmailTemplate> emailTemplateList;
        //  if (Schema.sObjectType.Emailtemplate.fields.Id.isAccessible() && Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){

                emailTemplateList = [Select Id, Name, folder.name,Body
                                     from Emailtemplate
                                     where folder.name = :folderName];
        //  }
        system.debug(emailTemplateList[0].Body);
            return emailTemplateList;
        }
        return null;
    }

     @AuraEnabled
    public Static String gettemplatebodyContent(String recordId, String templateId){
        string templateBody = '';
        string templateBody1 = '';

        Contact con ;

        con = [select id, Email from Contact where email != null order by createddate desc limit 1 ];

        String[] toaddres;
        toaddres = new String[]{con.email};
        Savepoint sp = Database.setSavepoint();
        list<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();
        list<Messaging.SingleEmailMessage> msgList1= new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<EmailTemplate> templateRecordList = [SELECT Id,Body FROM EmailTemplate WHERE Id =: templateId];
        string theTemplate = [SELECT Id,Body FROM EmailTemplate WHERE Id =: templateId].Id;
        email.setTemplateId(theTemplate);
        email.setWhatId(recordId);
        email.setTargetObjectId(con.Id);
        email.setSaveAsActivity(false);
        email.setToAddresses(toaddres);
       // email.setHtmlBody(templateRecordList[0].Body);
        msgList.add(email);
        system.debug('&&&&&recordId'+recordId);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        System.debug('Email Results isSuccess = ' +  r[0].IsSuccess());
        Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew : msgList) {
            system.debug(emailNew);
            system.debug(emailNew.getPlainTextBody());
            system.debug(emailNew.getHTMLBody());
            templateBody1 = emailNew.getHTMLBody();
        }
        system.debug(templateBody1);
        return templateBody1;
    }



    @AuraEnabled
    public Static String getFileAttachments(String recordId){
        Map<Id, list<ContentDocumentLink>> FilesListMap = new Map<Id, list<ContentDocumentLink>>();
        String fieldName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        system.debug('fieldName ----------> ' + fieldName);
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('buildertek__File__c').getDescribe().fields.getMap();
        String fields = '';
        for (Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            fields += dfield.getname()+',';
        }
        fields = fields.removeEnd(',');
        String query;
        if (fields.contains(fieldName)){
            query = 'select Id, Name, ' + fieldName + ' from buildertek__File__c where ' + fieldName + '=: recordId';
        } else{
            query = 'select Id, Name from buildertek__File__c where ' + fieldName + '=: recordId';
        }
        List<buildertek__File__c> customFilesList;
        /* if(Schema.sObjectType.buildertek__File__c.fields.Id.isAccessible()&&
         Schema.sObjectType.buildertek__File__c.fields.Name.isAccessible() ){*/
        customFilesList = Database.query(query);
        /*}*/
        system.debug('customFilesList --------> ' + customFilesList);
        system.debug('customFilesList --------> ' + customFilesList.size());
        List<FinalFileAttachmentsClass> FinalFileAttachmentsList = new List<FinalFileAttachmentsClass>();
        List<Attachment> attList = new List<Attachment>();
        if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() != 'buildertek__Quote__c'){
            for (Attachment att : [select Id, Name
                                   FROM Attachment
                                   where ParentId = :recordId]){
                attList.add(att);
            }
            if (attList.size() > 0){
                FinalFileAttachmentsList.add(new FinalFileAttachmentsClass(attList, null, null));
            }
        }
        for (ContentDocumentLink files : [select ContentDocumentId, LinkedEntityId
                                          FROM ContentDocumentLink
                                          where LinkedEntityId = :recordId]){
            list<ContentDocumentLink> fileList = New list<ContentDocumentLink>();
            if (FilesListMap.get(files.LinkedEntityId) == null){
                fileList.add(files);
                FilesListMap.put(files.LinkedEntityId, fileList);
            } else{
                fileList = FilesListMap.get(files.LinkedEntityId);
                fileList.add(files);
                FilesListMap.put(files.LinkedEntityId, fileList);
            }
        }
        system.debug('files List --> ' + FilesListMap);
        List<ContentVersion> fileAttachments = new List<ContentVersion>();
        if (FilesListMap.get(recordId) != null){
            for (ContentDocumentLink content : FilesListMap.get(recordId)){
                for (ContentVersion docs : [Select Id, ContentDocumentId, Title, VersionData
                                            from ContentVersion
                                            where ContentDocumentId = :content.ContentDocumentId]){
                    fileAttachments.add(docs);
                }
            }
        }
        if (fileAttachments.size() > 0){
            FinalFileAttachmentsList.add(new FinalFileAttachmentsClass(null, fileAttachments, null));
        }
        system.debug('fileAttachments ---------> ' + fileAttachments.size());
        List<buildertek__File__c> filesList = new List<buildertek__File__c>();
        if (customFilesList.size() > 0){
            FinalFileAttachmentsList.add(new FinalFileAttachmentsClass(null, null, customFilesList));
        }
        system.debug('FinalFileAttachmentsList ---------> ' + FinalFileAttachmentsList);
        String finalString = JSON.serialize(FinalFileAttachmentsList);
        system.debug('finalString ---------> ' + finalString);
        return finalString;
    }

    @AuraEnabled
    public static Contact getObjectContact(String recordId, String objectAPIName){
        Contact con;
        //String objectAPIName = 'buildertek__RFI__c';
        if (objectAPIName == 'buildertek__RFI__c'){
            buildertek__RFI__c rfi;
            if (Schema.sObjectType.buildertek__RFI__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFI__c.fields.buildertek__Assigned_To__c.isAccessible()){

                rfi = [SELECT Id, buildertek__Assigned_To__c
                       FROM buildertek__RFI__c
                       WHERE Id = :recordId];
            }


            con = [SELECT Id, Name, Email
                   FROM Contact
                   WHERE Id = :rfi.buildertek__Assigned_To__c];


        } else if (objectAPIName == 'buildertek__Submittal__c'){
            buildertek__Submittal__c sub;

            sub = [SELECT Id, buildertek__Responsible_Contact__c
                   FROM buildertek__Submittal__c
                   WHERE Id = :recordId];


            con = [SELECT Id, Name, Email
                   FROM Contact
                   WHERE Id = :sub.buildertek__Responsible_Contact__c];

        }
        return con;
    }
    @AuraEnabled
    public Static String getsubject(String recordId, String objectAPIName){
        string subject = '';
        if (objectAPIName == 'buildertek__Change_Order__c'){
            buildertek__Change_Order__c changeRec = [select id, Name from buildertek__Change_Order__c where Id =: recordId];
            subject = changeRec.Name;
        }else if (objectAPIName == 'buildertek__Contract__c'){
            buildertek__Contract__c contractRec = [select id, Name from buildertek__Contract__c where Id =: recordId];
            subject = contractRec.Name;
        }else if (objectAPIName == 'buildertek__Quote__c'){
            buildertek__Quote__c quoteRec = [select id, Name from buildertek__Quote__c where Id =: recordId];
            subject = quoteRec.Name;
        }else if (objectAPIName == 'buildertek__RFQ__c'){
            buildertek__RFQ__c rfqRec = [select id, Name from buildertek__RFQ__c where Id =: recordId];
            subject = rfqRec.Name;
        }else if (objectAPIName == 'buildertek__Account_Payable__c'){
            buildertek__Account_Payable__c invoiceRec = [select id, Name,buildertek__Ref_No__c,buildertek__Auto_Number__c,buildertek__AP_Number__c from buildertek__Account_Payable__c where Id =: recordId];
            subject = 'Invoice'+ ' : ' + + invoiceRec.Name;
        }else if (objectAPIName == 'buildertek__Account_Payable_Clone__c'){
            buildertek__Account_Payable_Clone__c invoicesRec = [select id, Name,buildertek__Ref_No__c,buildertek__Auto_Number__c,buildertek__AP_Number__c from buildertek__Account_Payable_Clone__c where Id =: recordId];
            subject = 'Invoice'+ ' : ' + + invoicesRec.Name;
         }else if (objectAPIName == 'buildertek__Billings__c'){
            buildertek__Billings__c invoicesRec = [select id, Name,buildertek__Auto_Number1__c,buildertek__Invoiced_Date__c from buildertek__Billings__c where Id =: recordId];
             if(invoicesRec.buildertek__Invoiced_Date__c == null){
                 invoicesRec.buildertek__Invoiced_Date__c = System.today();
                 update invoicesRec;
                 System.debug('Invoiced Date Updateed');
             }
            subject = 'Invoice'+ ' : ' + + invoicesRec.Name;
        }else{
            subject = '';
        }
        return subject;
    }
    @AuraEnabled
    public Static String SendEmail(List<String> to, List<String> cc, List<String> files, String subject, String body, String recordId, String templateId, String pdfFileName,List<String> emailIds){
        try{
            system.debug('files-->'+files);
            List<string> strTO = new List<string>();
            List<string> strCC = new List<string>();
            SET<Id> contactIdSet = new SET<Id>();
            List<Contact> conList;

            //* nishit's logic for wide org email starts from here
                buildertek__WideOrgEmailsettings__c getEmail = buildertek__WideOrgEmailsettings__c.getOrgDefaults();
                String wideOrgEmailName = getEmail.buildertek__WideEmail__c;
                List<OrgWideEmailAddress> wideOrgEmail =[select Id,Address from OrgWideEmailAddress WHERE Address =:wideOrgEmailName];
            //* nishit's logic for wide org email ends from here

            if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
                conList = [Select Id, email
                           from Contact
                           where Id IN :to and email != null];
            }

            for (Contact con : conList){
                strTO.add(con.email);
                contactIdSet.add(con.Id);
            }
            List<Contact> ccConList;
            if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
                ccConList = [Select Id, email
                             from Contact
                             where Id IN :cc and email != null];
            }
            for (Contact con : ccConList){
                strCC.add(con.email);
            }
            strTO.addAll(emailIds);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(strTO);
            //mail.setTemplateId(templateId);
            system.debug('strCC --------> ' + strCC);
            if (strCC != null && strCC.size() > 0)
                mail.setCcAddresses(strCC);
            //    List<OrgWideEmailAddress> owe = [SELECT ID,IsAllowAllProfiles,DisplayName,Address FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = TRUE LIMIT 1];
            EmailServicesAddress eServices;


            eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                         FROM EmailServicesAddress
                         where LocalPart = 'projects'];


            string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
            mail.setReplyTo(fromAddress);
            /*if(owe != null && owe.size() > 0){
             mail.setOrgWideEmailAddressId(owe[0].Id);
             mail.setReplyTo(owe[0].Address);
             }else {
             mail.setSenderDisplayName(UserInfo.getName());
             mail.setReplyTo(UserInfo.getUserEmail());
             }*/

            // add record id as a refrence id in subject
            //subject = subject +'[ref:'+recordId+']';
            //mail.setSubject(subject);
            String emailsubject = '';
            String Name = '';
            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
                mail.setTemplateId(templateId);
                list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c, Name
                                                                                                            from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                            WHERE Name = :'Change Order Configuration' and buildertek__Email_Subject__c != null
                                                                                                            limit 1];
                if (adminInterfaceNodeConfigurations.size() > 0){
                    emailsubject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
                    subject = subject + ' - '+ emailsubject + ' - [ref:' + recordId + ']';
                    System.debug('subject '+subject);
                } else{
                    // subject = subject + ' Change Order - [ref:' + recordId + ']';
                    subject = subject + ' Change Order';

                }
                //subject = subject + ' Change Order - [ref:' + recordId + ']';
                List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
                string SiteUrl;
                if (confirmationurl.size() > 0){
                    SiteUrl = confirmationurl[0].buildertek__SiteURL__c;
                }
              /*  body += 'Hi, <br/><br/> ';
                body += '</br> Please &nbsp;';
                body += '<a href=' + SiteUrl + 'buildertek__ConfirmationPage?Id=' + recordId + '&templateId=' + templateId + '>Click here</a>';
                body += '&nbsp;to confirm your Change Order details. <br/> <br/> <br/>'; */
                //subject = subject+'';
                //body = body + '<br/><center><a href="mailto:' + fromAddress + '?subject= Re:' + subject + '&body=Approved"><button type="button" style="cursor: pointer;background-color: #005fb2;color: white;padding-left: 16px;padding-right: 16px;text-align: center;vertical-align: middle;border: 1px solid #0070d2;line-height: 30px;min-height: 32px;cursor: pointer;">Approve</button></a> &nbsp;&nbsp;&nbsp;<a href="mailto:' + fromAddress + '?subject= Re:' + subject + '&body=Rejected"><button type="button" style="cursor: pointer;background-color: #a61a14;color: white;padding-left: 16px;padding-right: 16px;text-align: center;vertical-align: middle;border: 1px solid #0070d2;line-height: 30px;min-height: 32px;cursor: pointer;">Reject</a></button></center><br/>';
                body = body;
              // body = '';
            }

            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__RFQ__c'){
                mail.setTemplateId(templateId);
                list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c, Name
                                                                                                            from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                            WHERE Name = :'RFQ Configuration' and buildertek__Email_Subject__c != null
                                                                                                            limit 1];
                if (adminInterfaceNodeConfigurations.size() > 0){
                    emailsubject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
                    subject = subject + ' - ' +emailsubject + ' - [ref:' + recordId + ']';
                    system.debug('subject' + subject);
                } else{
                    subject = subject + ' RFQ - [ref:' + recordId + ']';
                }
                // subject = subject + ' RFQ - [ref:' + recordId + ']';
                body = body;
            }

            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Punch_List__c'){
                mail.setTemplateId(templateId);
                subject = subject + ' Punchlist - [ref:' + recordId + ']';
                body = body;
            }

            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__RFI__c'){
                subject = subject + ' RFI - [ref:' + recordId + ']';
                body = body.replaceAll('<p><br></p>', '<br>');
                body = body.replaceAll('<p>', '<p style="margin-top: 0em; margin-bottom: 0em; ">');
            }

            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Warranty__c'){
                mail.setTemplateId(templateId);
                subject = subject + ' Warranty - [ref:' + recordId + ']';
                body = body;
            }

            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Account'){
                //mail.setTemplateId(templateId);
                subject = subject + ' - [ref:' + recordId + ']';
                body = body;
            }
            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Project__c'){
                //mail.setTemplateId(templateId);
                subject = subject + ' - [ref:' + recordId + ']';
                body = body;
            }
            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Permit__c'){
                buildertek__Permit__c permit = new buildertek__Permit__c();
                permit = [SELECT Id, Name, buildertek__Permit_Number__c FROM buildertek__Permit__c WHERE Id =:recordId];

                if (templateId != null && templateId != '') {
                    mail.setTemplateId(templateId);
                    mail.setWhatId(recordId);
                    mail.setTargetObjectId(conList[0].Id);

                    Savepoint sp = Database.setSavepoint();
                    Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                    Database.rollback(sp);

                    body = mail.getHTMLBody();
                }

                // subject = subject + permit.Name +' - [ref:' + recordId + ']';
                subject = subject + permit.Name +' - ' + permit.buildertek__Permit_Number__c;
                body = body;
            }
            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Contract__c'){
                mail.setTemplateId(templateId);
                list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c, Name
                                                                                                            from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                            WHERE Name = :'Create Contract on Quote Acceptance' and buildertek__Email_Subject__c != null
                                                                                                            limit 1];
                if (adminInterfaceNodeConfigurations.size() > 0){
                    emailsubject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
                    subject = subject + ' - '+  emailsubject + ' - [ref:' + recordId + ']';
                } else{
                    subject = subject + ' Contract - [ref:' + recordId + ']';
                }
                body = body;

            }

            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Quote__c'){
                mail.setTemplateId(templateId);
                list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c, Name
                                                                                                            from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                            WHERE Name = :'Quote Configuration' and buildertek__Email_Subject__c != null
                                                                                                            limit 1];
                if (adminInterfaceNodeConfigurations.size() > 0){
                    emailsubject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
                    subject = subject + ' - '+  emailsubject + ' - [ref:' + recordId + ']';
                } else{
                    subject = subject + ' Quote - [ref:' + recordId + ']';
                }
                //subject = subject + ' Quote - [ref:' + recordId + ']';
                body = body;
                system.debug('Final body -------> ' + body);

            }
            system.debug('Final body -------> ' + body);

            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Submittal__c'){
                //mail.setTemplateId(templateId);
                subject = subject + ' Submittal - [ref:' + recordId + ']';
                body = body.replaceAll('<p><br></p>', '<br>');
                body = body.replaceAll('<p>', '<p style="margin-top: 0.1em; margin-bottom: 0em; ">');

            }

            //added by sai start
            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Account_Payable__c'){
                mail.setTemplateId(templateId);
                subject = subject + ' - [ref:' + recordId + ']';
                body = body;
            }
            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Billings__c'){
                mail.setTemplateId(templateId);
                subject = subject + ' - [ref:' + recordId + ']';
                body =  body.replaceAll('<p>', '<p style="margin-top: 0em; margin-bottom: 0em; ">');
            }
            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Account_Payable_Clone__c'){
                mail.setTemplateId(templateId);
                subject = subject + ' - [ref:' + recordId + ']';
                body = body;
            }

            system.debug('ObjectApiName--->'+Id.valueOf(recordId).getSObjectType().getDescribe().getName());
            system.debug('recordId-->'+recordId);
            system.debug('templateId-->'+templateId);
            system.debug('body-->'+body);
            //added by sai end

            List<File__c> flList;


            flList = [Select Id, Name, Bucket_Name__c, Amazon_File_Key__c, File_Presigned_URL__c
                      from File__c
                      where Id IN :files];


            String fileDetails = getFileDetails(flList);
            system.debug('fileDetails --------> ' + fileDetails);
            if (fileDetails != null){
                body = body + '<br/><br/><br/>' + fileDetails;
            }
            mail.setSubject(subject);

            if (wideOrgEmail.size() > 0) {
                mail.setOrgWideEmailAddressId(wideOrgEmail[0].Id);
            }

            if (body != null && String.isNotBlank(body) && body != ''){
                mail.setHtmlBody(body);
            }else{
                mail.setHtmlBody('<p></p>');
            }
            if (conList.size() > 0){
                mail.setTargetObjectId(conList[0].Id);
                mail.setSaveAsActivity(true);
                mail.setWhatId(recordId);
            }
            System.debug('Mail::' + mail);
            List<RFQ_To_Vendor__c> rfqVendorList;


            rfqVendorList = [select Id, Name
                             from RFQ_To_Vendor__c
                             where RFQ__c = :recordId];


            // Attached record pdf as an attachment
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() != 'buildertek__RFQ__c' && Id.valueOf(recordId).getSObjectType().getDescribe().getName() != 'buildertek__Permit__c' && Id.valueOf(recordId).getSObjectType().getDescribe().getName() != 'buildertek__Billings__c'){
                if (String.isNotBlank(templateId)){
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(pdfFileName + '.pdf');
                    efa.setBody(setAttachmentBody(recordId, templateId));
                    fileAttachments.add(efa);
                }
            }

            if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Billings__c' ){
                if (String.isNotBlank(templateId)){
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName('Invoice' + '.pdf');
                    efa.setBody(setAttachmentBody(recordId, templateId));
                    fileAttachments.add(efa);
                }
            }
            List<ContentVersion> docList;
            list<Id> contentVersionIds = new list<Id>();

            docList = [Select Id, ContentDocumentId, Title, VersionData
                       from ContentVersion
                       where Id IN :files]; //where ContentDocumentId IN :files];


            system.debug('docList -----------> ' + docList);
            system.debug('docList size -------> ' + docList.size());
            if (docList.size() > 0){
                for (ContentVersion docs : docList){
                    Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
                    efa1.setFileName(docs.Title);
                    efa1.setBody(docs.VersionData);
                    fileAttachments.add(efa1);
                    //fileAttachments.add(docs);
                    contentVersionIds.add(docs.Id);
                }
            }
            List<Attachment> attList;


            attList = [Select Id, Name, Body
                       from Attachment
                       where Id IN :files];


            system.debug('attList -----------> ' + attList);
            system.debug('attList size -------> ' + attList.size());
            if (docList.size() > 0){
                for (Attachment att : attList){
                    Messaging.Emailfileattachment efa2 = new Messaging.Emailfileattachment();
                    efa2.setFileName(att.Name);
                    efa2.setBody(att.Body);
                    fileAttachments.add(efa2);
                    //fileAttachments.add(docs);
                }
            }

            system.debug('fileAttachments ----->' + fileAttachments);
            system.debug('contentVersionIds ----->' + contentVersionIds);
            mail.setEntityAttachments(contentVersionIds);
            if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
            mail.setFileAttachments(fileAttachments);
            }
              if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Billings__c'){
            mail.setFileAttachments(fileAttachments);
            }

             /* Developed by Hemanth Kumar */
              if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Warranty__c'){
            mail.setFileAttachments(fileAttachments);
            }
             if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Punch_List__c'){
            mail.setFileAttachments(fileAttachments);
            }
             if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Account'){
            mail.setFileAttachments(fileAttachments);
            }
             if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Project__c'){
            mail.setFileAttachments(fileAttachments);
            }
             if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Permit__c'){
            mail.setFileAttachments(fileAttachments);
            }
             if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Contract__c'){
            mail.setFileAttachments(fileAttachments);
            }
               if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Account_Payable__c'){
            mail.setFileAttachments(fileAttachments);
            }
               if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Account_Payable_Clone__c'){
            mail.setFileAttachments(fileAttachments);
            }
              if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Submittal__c'){
            mail.setFileAttachments(fileAttachments);
            }
             if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__RFI__c'){
            mail.setFileAttachments(fileAttachments);
            }
             if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Quote__c'){
            mail.setFileAttachments(fileAttachments);
            }

            System.debug('mail ==> '+mail);

            mails.add(mail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            system.debug('results ----------> ' + results);
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
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
                        //* Date: 28/03/2023 logic added for Date Emailed for Signature
                        List<buildertek__Change_Order__c> coList = new List<buildertek__Change_Order__c>();
                        coList = [SELECT Id, Name, buildertek__Sender_Email_Response__c, buildertek__CO_Submit_Date__c FROM buildertek__Change_Order__c WHERE Id =:recordId LIMIT 1];
                        if (coList.size() > 0) {
                            if (coList[0].buildertek__CO_Submit_Date__c == null) {
                                coList[0].buildertek__CO_Submit_Date__c = System.today();
                            }
                            coList[0].buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                            update coList;
                        }
                     }
                     if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Warranty__c'){
                          buildertek__Warranty__c warRec = new buildertek__Warranty__c();
                          warRec.Id = recordId;
                          warRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                          update warRec;
                     }
                    /*if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__RFQ__c'){
                          buildertek__RFQ__c rfqRec = new buildertek__RFQ__c();
                          rfqRec.Id = recordId;
                          rfqRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                          update rfqRec;
                     }*/
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Punch_List__c'){
                          buildertek__Punch_List__c punchlistRec = new buildertek__Punch_List__c();
                          punchlistRec.Id = recordId;
                          punchlistRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                          update punchlistRec;
                     }
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Account'){
                          Account accRec = new Account();
                          accRec.Id = recordId;
                          accRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                          update accRec;
                     }
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Project__c'){
                          buildertek__Project__c proRec = new buildertek__Project__c();
                          proRec.Id = recordId;
                          proRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                          update proRec;
                     }
                      if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Permit__c'){
                          buildertek__Permit__c perRec = new buildertek__Permit__c();
                          perRec.Id = recordId;
                          perRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                          update perRec;
                     }
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Contract__c'){
                          buildertek__Contract__c conRec = new buildertek__Contract__c();
                          conRec.Id = recordId;
                          conRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                          update conRec;
                     }
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Account_Payable__c'){
                        buildertek__Account_Payable__c accpayRec = new buildertek__Account_Payable__c();
                        accpayRec.Id = recordId;
                        accpayRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                        update accpayRec;
                    }
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Account_Payable_Clone__c'){
                        buildertek__Account_Payable_Clone__c accpaycloneRec = new buildertek__Account_Payable_Clone__c();
                        accpaycloneRec.Id = recordId;
                        accpaycloneRec.buildertek__Sender_Email_Response__c  = UserInfo.getUserEmail();
                        update accpaycloneRec;
                    }
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Submittal__c'){
                        buildertek__Submittal__c sub = new buildertek__Submittal__c();
                        sub.Id = recordId;
                        sub.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                        update sub;
                    }
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__RFI__c'){
                        buildertek__RFI__c rfi = new buildertek__RFI__c();
                        rfi.Id = recordId;
                        rfi.buildertek__Status__c = 'Email Sent';
                        rfi.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                        system.debug('rfi.buildertek__Sender_Email_Response__c'+rfi.buildertek__Sender_Email_Response__c);
                        update rfi;
                    }
                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Quote__c'){
                        buildertek__Quote__c quote = new buildertek__Quote__c();
                        quote = [select Id, buildertek__Status__c, buildertek__Sender_Email_Response__c, buildertek__Date_Sent_To_Customer__c, buildertek__Date_Accepted_by_Customer__c, buildertek__Date_Rejected_by_Customer__c from buildertek__Quote__c where Id = :recordId];
                        // quote.Id = recordId;
                        quote.buildertek__Status__c = 'Sent';
                        if(quote.buildertek__Date_Accepted_by_Customer__c == null && quote.buildertek__Date_Rejected_by_Customer__c == null){
                            quote.buildertek__Date_Sent_To_Customer__c = system.today();
                        }
                        quote.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                       // if (Schema.sObjectType.buildertek__Quote__c.fields.Id.isUpdateable()
                           // && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Status__c.isUpdateable()
                          //  && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Sender_Email_Response__c.isUpdateable()){
                            update quote;
                     //   }
                    }

                    if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Billings__c'){
                        system.debug('buildertek__Billings__c');
                        buildertek__Billings__c inv;
                        if (Schema.sObjectType.buildertek__Billings__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Invoiced_Date__c.isAccessible()){

                            inv = [SELECT Id, buildertek__Invoiced_Date__c
                                   FROM buildertek__Billings__c
                                   WHERE Id = :recordId];
                        }
                        inv.buildertek__Invoiced_Date__c = system.today();
                        inv.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                            system.debug(inv.buildertek__Sender_Email_Response__c);
                        if (Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Invoiced_Date__c.isUpdateable()){

                            update inv;
                            system.debug('inv date -------> ' + inv.buildertek__Invoiced_Date__c);
                        }
                    }

                    EmailMessage caseEmailMessage = new EmailMessage();
                    caseEmailMessage.fromAddress = UserInfo.getUserEmail();
                    system.debug('caseEmailMessage.fromAddress'+caseEmailMessage.fromAddress);
                    caseEmailMessage.ToAddress = Toaddresses;
                     system.debug('caseEmailMessage.ToAddress'+caseEmailMessage.ToAddress);
                    caseEmailMessage.FromName = UserInfo.getUserName();
                    system.debug('caseEmailMessage.ToAddress'+caseEmailMessage.FromName);
                    caseEmailMessage.CcAddress = CCaddresses;
                    caseEmailMessage.Subject = subject;
                    caseEmailMessage.HtmlBody = body;
                    caseEmailMessage.Incoming = False;
                    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                    caseEmailMessage.MessageDate = system.now();
                    //caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                    //caseEmailMessage.TextBody = body;

                    system.debug('caseEmailMessage.TextBody ---------> ' + caseEmailMessage.TextBody);
                    system.debug('Content length ---------> ' + body.length());
                    /*if(body.length() >= 131000 ){
                     system.debug('Too large Content');
                     caseEmailMessage.buildertek__Email_Body__c = body.substring(0, 131000);
                     }else{
                     caseEmailMessage.buildertek__Email_Body__c = body;
                     }*/
                    caseEmailMessage.status = '5';
                    caseEmailMessage.RelatedToId = recordId;
                    caseEmailMessage.buildertek__Subject__c = 'Re: ' + subject;
                    //caseEmailMessage.ActivityId = '0011K00002S8KIbQAN';

                    insert caseEmailMessage;



                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = caseEmailMessage.id;
                    emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                    emr.relationType = 'FromAddress';
                    emr.relationAddress = caseEmailMessage.fromAddress;


                    insert emr;

                    system.debug('*****************6^^^^^^**********************');
                    system.debug(caseEmailMessage.Id);
                    system.debug(files);
                    List<ContentVersion> attachmentList = [Select id,VersionData from ContentVersion where id IN:files];




                       system.debug(attachmentList);
                       List<Attachment> newAttList = new List<Attachment>();
                    for (ContentVersion att : attachmentList){
                       Attachment attch = new Attachment();
                       attch.Body = att.VersionData;
                       attch.Name = 'test';
                       attch.ParentId = caseEmailMessage.Id;
                       newAttList.add(attch);
                    }
                    system.debug(newAttList);
                    insert(newAttList);
                    system.debug(newAttList);











                    /*List<Contact> toAddressList = [SELECT Id, Email FROM Contact WHERE Id IN: contactIdSet];
                     List<EmailMessageRelation> emrs = new List<EmailMessageRelation>();
                     for(Contact con : toAddressList){

                     EmailMessageRelation emr = new EmailMessageRelation();
                     emr.emailMessageId = caseEmailMessage.id;
                     emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                     emr.relationType = 'FromAddress';
                     emr.relationAddress = caseEmailMessage.fromAddress;
                     emrs.add(emr);

                     emr = new EmailMessageRelation();
                     emr.emailMessageId = caseEmailMessage.id;
                     emr.relationId = con.Id; // user id / contact Id of the sender
                     emr.relationType = 'ToAddress';
                     emr.relationAddress = con.Email;
                     emrs.add(emr);

                     }
                     insert emrs;*/
                }
                system.debug(body);
            }

            String message = 'Success';
            return message;
        } catch (Exception exp){
            String message = exp.getMessage();
            system.debug('message ---------> ' + exp.getMessage());
            return message;
        }
    }

    private static Blob setAttachmentBody(String recordId, String templateId){
        Pagereference pdf;
        pdf = Page.buildertek__BT_Generatepdf;
        pdf.getParameters().put('recordId', recordId);
        pdf.getParameters().put('templateId', templateId);
        pdf.setRedirect(true);
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }

    private static string getFileDetails(List<File__c> files){

        if (files.size() == 0){
            return null;
        }
        // Get AWS credentials
        AmazonS3Credential s3Credentials = new AmazonS3Credential();
        String fileDownloadURL = '';
        String emailContent = '';
        emailContent += '<table cellpadding="5"><tr style="background-color:#007fcc;color:white;font-weight:bold;">';
        emailContent += '<th>File Name</th>';
        emailContent += '<th>' + System.Label.Action + '</th><tr>';
        for (File__c file : files){
            emailContent += '<tr>';
            String fileDownloadLinkHTML = '';
            String expiryDateString = '';
            //Check for file access type and encript the link if the file is private
            if (file.File_Presigned_URL__c != null){
                fileDownloadURL = file.File_Presigned_URL__c;
            } else{
                // Get AWS credentials
                //AmazonS3Credential s3Credentials = new AmazonS3Credential();
                Datetime expiryDate = System.now().addMinutes(1);
                fileDownloadURL = FileUtils.getPresignedURL(file.Bucket_Name__c, file.Amazon_File_Key__c, System.now().addDays(100), s3Credentials.key, s3Credentials.secret);
            }
            fileDownloadLinkHTML = '<a href="' + fileDownloadURL + '">' + System.Label.Download + '</a>';
            System.debug('Download Link ----------> ' + fileDownloadLinkHTML);
            emailContent += '<td>' + file.Name + '</td>';
            emailContent += '<td>' + fileDownloadLinkHTML + '</td>';
            emailContent += '</tr>';
        }
        emailContent += '</table>';

        return emailContent;
    }

    public static String getEmailBodyFromTemplate(String parentRecordID, String vendorID, String templateId, String emailTemplateName){
        //system.debug(''+vendorID);
        // Pick a dummy Contact
        if (vendorID == null){
            Contact c;
            if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()){

                c = [select id, Email
                     from Contact
                     where email<>null
                     limit 1];
            }
            vendorID = c.id;
        }

        buildertek__RFQ_To_Vendor__c rfq;
        if (Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible()){

            rfq = [select Id, Name, buildertek__Contact__c
                   from buildertek__RFQ_To_Vendor__c
                   where Id = :parentRecordID];
        }

        List<contact> contactList;
        if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()){

            contactList = [select Id, Name, Email
                           from Contact
                           where Id = :rfq.buildertek__Contact__c];
        }

        system.debug('contactList -----> ' + contactList);

        // Construct the list of emails we want to send
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        if (templateId != null && templateId != '')
            msg.setTemplateId([select id
                               from EmailTemplate
                               where id = :templateId].id);
        else
            msg.setTemplateId([select id
                               from EmailTemplate
                               where Name = :emailTemplateName and isActive = true].id);
        msg.setWhatId(parentRecordID);

        System.debug(templateId + '---' + emailTemplateName +'==='+ parentRecordID);

        msg.setTargetObjectId(ID.valueOf(vendorID));
        msg.setToAddresses(new List<String>{'noreplay@buildertek.com'});
        List<OrgWideEmailAddress> owe;


        owe = [SELECT ID, IsAllowAllProfiles, DisplayName, Address
               FROM OrgWideEmailAddress
               WHERE IsAllowAllProfiles = TRUE
               LIMIT 1];


        if (owe != null && owe.size() > 0){
            msg.setOrgWideEmailAddressId(owe[0].Id);
            msg.setReplyTo(owe[0].Address);
        } else{
            msg.setSenderDisplayName(UserInfo.getName());
            msg.setReplyTo(UserInfo.getUserEmail());
        }
        lstMsgs.add(msg);
        // Send the emails in a transaction, then roll it back
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(lstMsgs);
        Database.rollback(sp);
        // For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
        // contents to a new SingleEmailMessage. Then send those new messages.
        string body = lstMsgs[0].getHTMLBody();
        //if(strBody == null)strBody = lstMsgs[0].getPlainTextBody();
        String strSubject = lstMsgs[0].getSubject();
        system.debug('strSubject --------> ' + strSubject);
        String strBody = lstMsgs[0].getPlainTextBody();
        system.debug('strBody --------> ' + strBody);
        EmailBodyClass emailClass = new EmailBodyClass();
        emailClass.emailBody = body;
        emailClass.emailSubject = strSubject;
        emailClass.contactId = rfq.buildertek__Contact__c;
        emailClass.templateId = emailTemplateName;

        system.debug('emailClass --------> ' + emailClass);
        String finalString = JSON.serialize(emailClass);
        return finalString;
    }

    /* @AuraEnabled
     public static Id saveTheFile(String fileName, String base64Data, String contentType) {
     base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
     Folder folders = [SELECT Id, Name FROM Folder WHERE Name = 'Buildertek Documents'];
     Document newDocument = new Document();
     if (Schema.sObjectType.Document.fields.Name.isCreateable() && Schema.sObjectType.Document.fields.Body.isCreateable()
     && Schema.sObjectType.Document.fields.ContentType.isCreateable() && Schema.sObjectType.Document.fields.FolderId.isCreateable()
     && Schema.sObjectType.Document.fields.IsPublic.isCreateable()) {

     newDocument.Name = fileName;
     newDocument.Body = EncodingUtil.base64Decode(base64Data);
     newDocument.ContentType = contentType;
     newDocument.FolderId = folders.Id;
     newDocument.IsPublic = true;

     }

     insert newDocument;

     return newDocument.Id;
     }

     @AuraEnabled
     public static Id saveTheChunk(String fileName, String base64Data, String contentType, String fileId) {
     if (fileId == '') {
     fileId = saveTheFile(fileName, base64Data, contentType);
     } else {
     appendToFile(fileId, base64Data);
     }

     return Id.valueOf(fileId);
     }

     private static void appendToFile(Id fileId, String base64Data) {
     base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

     Document doc = [
     SELECT Id, Body
     FROM Document
     WHERE Id =: fileId
     ];

     String existingBody = EncodingUtil.base64Encode(doc.Body);
     if (Schema.sObjectType.Document.fields.Body.isUpdateable()) {
     doc.Body = EncodingUtil.base64Decode(existingBody + base64Data);
     }
     update doc;
     }*/
    /*@AuraEnabled
     public static String getDocuments(String recordId){
     Document doc = [SELECT Id, Name FROM Document WHERE Id =: recordId];
     String orgId = UserInfo.getOrganizationId();
     String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
     String URL = baseURL+'/servlet/servlet.ImageServer?id='+doc.Id+'&oid='+orgId;
     return URL;


     }*/
    public class FinalFileAttachmentsClass{
        @AuraEnabled
        public List<Attachment> attachmentList{ get; set; }

        @AuraEnabled
        public List<ContentVersion> ContentVersionList{ get; set; }

        @AuraEnabled
        public List<buildertek__File__c> customFilesList{ get; set; }

        public FinalFileAttachmentsClass(List<Attachment> attachmentList, List<ContentVersion> ContentVersionList, List<buildertek__File__c> customFilesList){
            this.attachmentList = attachmentList;
            this.ContentVersionList = ContentVersionList;
            this.customFilesList = customFilesList;
        }
    }

    public class EmailBodyClass{
        public String emailBody{ get; set; }

        public String emailSubject{ get; set; }

        public String contactId{ get; set; }
        public String templateId{ get; set; }

    }

      @AuraEnabled
    public static String uploadFile(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks
        System.debug(' parentId  ++++++++++++++++++++++++++++++++++'+parentId);
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            system.debug('****'+fileId);
        } else {
            //   appendToFile(fileId, base64Data);
        }
        return string.valueOf(fileId);
    }
    public static Id saveTheFile(String parentId, String fileName, String base64Data, String contentType) {
        system.debug('parentId--->'+parentId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion conVer = new ContentVersion();
        Set<SObjectField> ContentVersionFields = new set<SObjectField>{ContentVersion.ContentLocation,
            ContentVersion.PathOnClient,
            ContentVersion.Title,
            ContentVersion.VersionData};
                conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
        insert conVer;    //Insert ContentVersion
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        Set<SObjectField> ContentDocumentLinkFields = new set<SObjectField>{ContentDocumentLink.LinkedEntityId,
            ContentDocumentLink.ContentDocumentId,
            ContentDocumentLink.shareType};
                conDocLink.LinkedEntityId = parentId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'I';
        insert conDocLink;
        system.debug('inserted--------------'+conDocLink.Id);
        return conVer.Id;
    }

    @AuraEnabled
    public static String getTemplatesBody(){

        List<EmailTemplate> et = [SELECT Id,Name,HtmlValue FROM EmailTemplate WHERE Name='Change Order'];

        // co = [SELECT Id,buildertek__CO_Number__c,buildertek__Project__r.buildertek__Customer__r.Name,buildertek__Project__r.buildertek__Customer__r.billingstreet,
        //                     buildertek__Project__r.buildertek__Customer__r.billingcity,buildertek__Project__r.buildertek__Customer__r.billingstate,buildertek__Project__r.buildertek__Customer__r.billingpostalcode,
        //                     buildertek__Project__r.buildertek__Customer__r.billingCountry,buildertek__Project__r.buildertek__Customer__r.Phone,Name,Total_Amount_Tax__c,buildertek__Status__c,
        //                     Total_Amount__c,Tax_Rate__c,(SELECT Name,Description__c,Quantity__c,Unit_Sales_Price__c,Total__c FROM Change_Order_Items__r) FROM buildertek__Change_Order__c WHERE Id='a1V1K000006vzRNUAY'];

        //  chorList = [SELECT Id,buildertek__CO_Number__c,buildertek__Project__r.buildertek__Customer__r.Name,buildertek__Project__r.buildertek__Customer__r.billingstreet,
        //                     buildertek__Project__r.buildertek__Customer__r.billingcity,buildertek__Project__r.buildertek__Customer__r.billingstate,buildertek__Project__r.buildertek__Customer__r.billingpostalcode,
        //                     buildertek__Project__r.buildertek__Customer__r.billingCountry,buildertek__Project__r.buildertek__Customer__r.Phone,Name,Total_Amount_Tax__c,buildertek__Status__c,
        //                     Total_Amount__c,Tax_Rate__c,(SELECT Name,Description__c,Quantity__c,Unit_Sales_Price__c,Total__c FROM Change_Order_Items__r) FROM Change_Order__c WHERE buildertek__Project__c = 'a1Q1K000004OIswUAG'];
        String[] toaddres;
        toaddres = new String[]{'test@testing.com'};
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(null, co.Id, new List<String> {et[0].HtmlValue});
        // Messaging.SingleEmailMessage email1 = Messaging.renderStoredEmailTemplate(et[0].Id, null, co.Id);
        // system.debug( 'em1>>>body>>>'+email1.getHTMLBody());

        // email.setTemplateId(et[0].Id);
        // email.setTargetObjectId(co.Id);
        // email.setWhatId(co.Id);
        // email.setToAddresses(toaddres);
        // email.setSaveAsActivity(false);
        // email.setHtmlBody(et[0].HtmlValue);
        // msgList.add(email);

        // System.debug('msgList>>>'+msgList);

        List<String> emailBodyList = new List<String>();
        // for (Change_Order__c chor : chorList) {
        //     Messaging.SingleEmailMessage emailChor = Messaging.renderStoredEmailTemplate(et[0].Id, null, chor.Id);
        //     emailBodyList.add(emailChor.getHTMLBody());
        // }

        System.debug('emailBodyList==>' + emailBodyList);

        String ems = '';

        for(String s : emailBodyList){
            s = s.replace('</body>','<div style="page-break-after:always !important;"></div></body>');
            ems += s;
            ems = ems.replaceAll('<span style="font-size: 14px;', '<span style="font-size: 10px !important;');
        }
        // String str = EncodingUtil.base64Encode(ems);
        // System.debug('str>>'+str);
        System.debug('ems>>>'+ems);
        Blob b = blob.valueOf(ems);

        String bs = EncodingUtil.base64Encode(b);

        // pdf = EncodingUtil.base64Encode(b);


        // Attachment att = new Attachment();
        // att.Name = 'test111.pdf';
        // att.Body = Blob.valueOf(bs);
        // att.ParentId = 'a1Q1K000004OIswUAG';
        // att.ContentType = 'application/pdf';
        // insert att;

        // ContentVersion cv = new ContentVersion();
        // cv.Title = 'Test Document';
        // cv.PathOnClient = 'TestDocument.pdf';
        // cv.VersionData = Blob.toPdf(ems);
        // cv.IsMajorVersion = true;
        // Insert cv;

        // //Get Content Documents
        // Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

        // //Create ContentDocumentLink
        // ContentDocumentLink cdl = new ContentDocumentLink();
        // cdl.LinkedEntityId = 'a1Q1K000004OIswUAG';
        // cdl.ContentDocumentId = conDocId;
        // cdl.shareType = 'V';
        // Insert cdl;

        String templateBody1;
        for (Messaging.SingleEmailMessage emailNew : msgList) {

            system.debug('em html body>>>'+emailNew.getHTMLBody());
            templateBody1 = emailNew.getHTMLBody();
        }

        return templateBody1;

    }


    @AuraEnabled
    public Static List<EmailTemplate> getTemplatesForSignedChange(){

        List<Emailtemplate> temrec;

        temrec = [Select Id, Name, folder.name from Emailtemplate where folder.name = 'BT CO' and Name !=:'Change Order1'];

        return temrec;
    }

    @AuraEnabled
    public static string getChangeOrderLines(String recordId, String templateId){

        // changeOdrList1 = getChangeOrders(recordId);
        System.debug('recordId>>>'+recordId);

         string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        Contact con ;

            con = [select id, Email from Contact where email != null order by createddate desc limit 1 ];

        String[] toaddres;
        toaddres = new String[]{con.email};
        Savepoint sp = Database.setSavepoint();
        list<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();
        list<Messaging.SingleEmailMessage> msgList1= new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        string theTemplate = [SELECT Id FROM EmailTemplate WHERE Id =: templateId].Id;
        email.setTemplateId(theTemplate);
        email.setWhatId(recordId);
        email.setTargetObjectId(con.Id);
        email.setSaveAsActivity(true);
        email.setToAddresses(toaddres);
        msgList.add(email);

        // Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        // System.debug('Email Results isSuccess = ' +  r[0].IsSuccess());
        // Database.rollback(sp);
        // for (Messaging.SingleEmailMessage emailNew : msgList) {
        //     templateBody1 = emailNew.getHTMLBody();
        // }
        // templateBody = templateBody1 ;


        //Added for signed email change

        List<String> emailBodyList = new List<String>();

        changeOdrList1 = [SELECT Id,buildertek__CO_Number__c,buildertek__Project__r.Name,buildertek__Project__r.buildertek__Customer__r.Name,buildertek__Project__r.buildertek__Customer__r.billingstreet,
                            buildertek__Project__r.buildertek__Customer__r.billingcity,buildertek__Project__r.buildertek__Customer__r.billingstate,buildertek__Project__r.buildertek__Customer__r.billingpostalcode,
                            buildertek__Project__r.buildertek__Customer__r.billingCountry,buildertek__Project__r.buildertek__Customer__r.Phone,Name,Total_Amount_Tax__c,buildertek__Status__c,
                            Total_Amount__c,Tax_Rate__c,(SELECT Name,Description__c,Quantity__c,Unit_Sales_Price__c,Total__c FROM Change_Order_Items__r) FROM Change_Order__c WHERE buildertek__Project__c=:recordId AND buildertek__Type__c = 'Customer' AND (buildertek__Status__c = 'Customer Approved' OR buildertek__Status__c = 'Paid' OR buildertek__Status__c = 'Partially Paid')];

        List<EmailTemplate> et = [SELECT Id,Name,HtmlValue FROM EmailTemplate WHERE Name='Change Order'];

        for (Change_Order__c co : changeOdrList1) {

            Messaging.SingleEmailMessage email1 = Messaging.renderStoredEmailTemplate(et[0].Id, null, co.Id);

            emailBodyList.add(email1.getHTMLBody());
        }

        for(String s : emailBodyList){

            s = s.replace('</html>','<hr></html>');
            templateBody += s;
        }

        system.debug('Final templateBody ----------> '+templateBody);
        return templateBody;

    }

    @AuraEnabled
    public static string saveSign(String recId,String base64Data, String contentType,string signName){
        system.debug('base64Data-------------'+base64Data);
        string conversn;
        if(base64Data.length() > 1696 || Test.isRunningTest()){
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = 'SignatureName.png'; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = signName; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
            system.debug('*******conVer*******'+conVer);
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'I';
            insert conDocLink;
           system.debug('conDocLink---'+conDocLink.id);

            list<buildertek__Change_Order__c> corec;
            RecordType rt;
            list<buildertek__Contract__c>  contractlist  = new list<buildertek__Contract__c>();
             rt = [SELECT Id FROM RecordType WHERE sObjectType='buildertek__Contract__c' AND Name = 'Prime Contract'];
                    corec = [select id,
                                        Name,
                                        buildertek__Customer_Accepted_Date__c,
                                        buildertek__Status__c,buildertek__Project__c,buildertek__Contract__c,
                                        buildertek__Date_Approved__c
                                        from buildertek__Change_Order__c where Id=:recId limit 1];
                 if(corec[0].buildertek__Project__c != null){
                      contractlist = [select id,Name,buildertek__Project__c from buildertek__Contract__c where buildertek__Project__c =: corec[0].buildertek__Project__c AND
                                                                   RecordTypeId =: rt.id order by CreatedDate ];
                 }

                   /* corec = [select id,
                                        Name,
                                        buildertek__Status__c,
                                        buildertek__Date_Approved__c
                                        from buildertek__Change_Order__c where Id=:recId limit 1];*/

                if(corec.size()>0){

                            corec[0].buildertek__Status__c = 'Customer Approved';

                             corec[0].buildertek__Date_Approved__c = system.now();
                             corec[0].buildertek__Customer_Accepted_Date__c = System.today();
                            if(contractlist.size() > 0){
                                corec[0].buildertek__Contract__c = contractlist[0].id;
                            }

                            update corec;
                    system.debug(corec+'corec---'+corec[0].buildertek__Date_Approved__c);
                }

             conversn = [SELECT Id,VersionData FROM ContentVersion WHERE ContentDocumentId = :conDoc AND IsLatest = true].Id;
            //system.debug('conversn[0].Id ='+conversn[0].Id);
            return conversn;
        }else{
             String message = 'NoImage';
            return message;
        }

    }


    @AuraEnabled
    public static String sendEmailApex1(List<String> to, List<String> cc, String emailsubject, String emailBody,String recordId) {

        try{

            List<Contact> tolst = [SELECT Id,Name,Email FROM Contact where ID IN:to];
            List<Contact> cclst = [SELECT Id,Name,Email FROM Contact where ID IN:cc];

            List<String> toEmaillst = new List<String>();
            List<String> ccEmaillst = new List<String>();
            for(Contact con : tolst){
                toEmaillst.add(con.Email);
            }

            for(Contact con : tolst){
                ccEmaillst.add(con.Email);
            }
            EmailServicesAddress eServices;
            eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                        FROM EmailServicesAddress
                        where LocalPart = 'projects'];

            String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;

            messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();
            mail.setToAddresses(toEmaillst);
            mail.setCcAddresses(ccEmaillst);
            mail.setReplyTo(fromAddress);
            mail.setSubject(emailsubject);
            mail.setHtmlBody(emailBody);

            PageReference vfPage = Page.generateMergePdf;
            vfPage.getParameters().put('id',recordId);

            try
            {
                vfPage.getContent();
            }
            catch(Exception ex)
            {
                System.debug(ex);
            }
            Blob pageData = vfPage.getContentAsPDF();

            ContentVersion cv = new ContentVersion();
            cv.Title = 'Create Signed Change '+'('+date.today().format()+')';
            cv.PathOnClient = 'Create Signed Change.pdf';
            cv.VersionData = pageData;
            cv.IsMajorVersion = true;
            insert cv;

            //Get Content Documents
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

            //Create ContentDocumentLink
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            insert cdl;

            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            String filename = 'Create Signed Change '+'('+date.today().format()+')'+'.pdf';
            emailAttachment.setFileName(filename);
            emailAttachment.setBody(pageData);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{emailAttachment});


            Messaging.sendEmail(new List<messaging.SingleEmailMessage> {mail});
            return 'Success';
        }
        catch (exception e){
            throw new AuraHandledException(e.getMessage());
            return null;
        }

    }

    // public class getProjectNameANDautoNumber {
    //     @AuraEnabled
    //     public String ProjectName{get;set;}
    //     @AuraEnabled
    //      public String AutoNumber{get;set;}

    // }

    @AuraEnabled
    public static String getProNameAndAutoNum(String recordId, String objectAPIName){
        // getProjectNameANDautoNumber objWrapper = new getProjectNameANDautoNumber();
        string pdfName;
        if (objectAPIName == 'buildertek__Change_Order__c'){
            buildertek__Change_Order__c changeRec = [select id, Name , buildertek__Auto_Number__c , buildertek__Project__r.Name , buildertek__Project__r.buildertek__Auto_Number__c from buildertek__Change_Order__c where Id =: recordId Limit 1];
            if(changeRec.buildertek__Project__r.Name != null || changeRec.buildertek__Project__r.buildertek__Auto_Number__c !=null ){
                    pdfName=changeRec.buildertek__Project__r.Name + '-' + changeRec.buildertek__Project__r.buildertek__Auto_Number__c +'-' + changeRec.buildertek__Auto_Number__c;
            }else{
                pdfName=changeRec.buildertek__Auto_Number__c;
            }

        }else if (objectAPIName == 'buildertek__Quote__c'){
            buildertek__Quote__c quoteRec=[Select Id , Name From buildertek__Quote__c where Id=:recordId LIMIT 1];
            pdfName=quoteRec.Name;
        }else{
            pdfName='';
        }
        return pdfName;
    }
































}