/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  27-Apr-2018
 */
global with sharing class BT_Email_Services implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        system.debug('fromAddress --> ' + email.fromAddress);
        system.debug('toaddress -->'+ email.toAddresses);
        system.debug('email subject--> '+ email.subject);
        system.debug('email subject--> '+ email.plainTextBody);

        system.debug('email --> '+ email);
        system.debug('envelope -->'+ envelope);
        //system.debug('userinfo --> '+ UserInfo);
        String replyTo = email.replyTo;
        String[] toAddresses = email.toAddresses;
        String fromAddress = email.fromAddress;
        String[] ccAddresses = email.ccAddresses;
        String fromname = email.fromname;
        String emailSubject = email.Subject;
        String htmlBody = email.htmlBody;
        String plainTextBody = email.plainTextBody;
        String inReplyTo = email.inReplyTo;
        String messageId = email.messageId;
        String[] references = email.references;
        Id fromId;
        Id contactId;
        Id userId;

     /* if(email.subject.contains('PreQualification')){
       if(email.subject != null && email.subject != ''){
        string myRecordId = email.subject.split('-').get(2);
        //string objectName = myRecordId.getSObjectType().getDescribe().getName();
        Account acc = [SELECT id,buildertek__Qualification_Stage__c from Account Where id=:myRecordId];
        acc.buildertek__Qualification_Stage__c = 'Email Received';
        update acc;
        }
        }*/

       //  system.debug('reply to'+replyTo);
        try{
            fromId = [Select Id
                      from Contact
                      where Email = :fromAddress
                      LIMIT 1].Id;
            contactId = fromId;

        } catch (exception ex){
            system.debug(ex);
        }

        try{
            list<user> ulist  = [Select Id, Email from user where Email = :fromAddress limit 1];
            if(ulist.size()>0){
                userId =  ulist[0].Id;
            }


        } catch (exception ex){
            system.debug(ex);
        }
        string emailaddress;
        list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,buildertek__Email_Address__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Email Configuration'];
        if (adminInterfaceNodeConfigurations.size() > 0){
                    owea = [select Id from OrgWideEmailAddress where Address =: adminInterfaceNodeConfigurations[0].buildertek__Email_Address__c];
        }

        system.debug('owea '+owea);
        system.debug(fromId);
        system.debug(emailSubject.indexOf('[ref'));
        if (emailSubject.indexOf('[ref') != -1){
            if (emailSubject.indexOf('[ref:') != -1){
                String relatedToId = emailSubject.split('ref:')[1];
                system.debug('---relatedToId---' + relatedToId);
                relatedToId = relatedToId.split(']')[0].trim();
                system.debug('relatedToId ----------> ' + relatedToId);

                String objectAPI = Id.valueOf(relatedToId).getSObjectType().getDescribe().getName();
                system.debug('objectAPI ---------> ' + objectAPI);
                String queryString;
                String salesRepEmailId = '';
                system.debug(objectAPI.toLowerCase());
                if (objectAPI.toLowerCase() == 'buildertek__Quote__c'){

                    if(plainTextBody.contains('Action:SavePDF;')){
                        pagereference pdf;
                        pdf = Page.buildertek__BT_GenerateQuotePDF;
                        system.debug('*********' + pdf);
                        pdf.getParameters().put('recordId', plainTextBody.split('recordId:')[1].split(';')[0]);
                        pdf.getParameters().put('templateId', plainTextBody.split(';templateId:')[1].split(';')[0]);
                        // pdf.getParameters().put('fileId', 'background-image:url("data:image/png;base64,'+fileid+'");');
                        pdf.getParameters().put('fileId', plainTextBody.split(';fileId:')[1].split(';')[0]);
                        pdf.setRedirect(true);

                        Blob b = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');

                        // lob b = setAttachmentBody(recordId, templateId, ConVer.Id );
                        // Blob b = setAttachmentBody('a081K00000ykCe5QAE','00X1K000000wkgwUAA', '0681K00000e3DMhQAM' );


                        // system.debug('Blob ---> ' + b);

                        ContentVersion conVer1 = new ContentVersion();
                        conVer1.PathOnClient = 'Quote.pdf'; // The files name, extension is very important here which will help the file in preview.
                        conVer1.VersionData = b; // converting your binary string to Blog
                        insert conVer1;    //Insert ContentVersion

                        ContentDocumentLink conDocLink1 = New ContentDocumentLink();
                        conDocLink1.LinkedEntityId = plainTextBody.split('recordId:')[1].split(';')[0]; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
                        conDocLink1.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer1.Id].ContentDocumentId;  //ContentDocumentId Id from ContentVersion
                        conDocLink1.Visibility = 'AllUsers';
                        insert conDocLink1;
                    }

                    List<buildertek__Quote__c> salesRepEmail = [SELECT Id, buildertek__Sales_Rep__r.Email,buildertek__Sender_Email_Response__c
                                                                FROM buildertek__Quote__c
                                                                WHERE Id = :relatedToId
                                                                LIMIT 1];
                    if (salesRepEmail.size() > 0 && salesRepEmail[0].buildertek__Sales_Rep__r.Email != null){
                        salesRepEmailId = salesRepEmail[0].buildertek__Sales_Rep__r.Email;
                    }
                    if(salesRepEmail.size() > 0){
                        if(salesRepEmail[0].buildertek__Sender_Email_Response__c != null){
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            //system.debug('owea.size()'+owea.size());
                            if (owea.size() > 0) {
                               // system.debug('owea.size&&&&'+owea.size());
                             message.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                            message.toAddresses = new String[]{salesRepEmail[0].buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                message.subject = emailSubject + ' sales rep 1st ';
                            message.plainTextBody = plainTextBody;
                            message.htmlBody = htmlBody;
                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                // Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        }
                    }
                    if (salesRepEmailId != ''){
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        message.toAddresses = new String[]{salesRepEmailId};
                        message.optOutPolicy = 'FILTER';
                        message.subject = emailSubject + ' sales rep 2nd ';
                        message.plainTextBody = plainTextBody;
                        message.htmlBody = htmlBody;
                        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                        // Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

                        // if (results[0].success){
                        //     System.debug('The email was sent successfully.');
                        // } else{
                        //     System.debug('The email failed to send: ' + results[0].errors[0].message);
                        // }
                    }
                }

                if (objectAPI.toLowerCase() == 'buildertek__RFQ_To_Vendor__c'){
                    buildertek__RFQ_To_Vendor__c rfqtovendor;
                    if (Schema.sObjectType.buildertek__RFQ_to_vendor__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__RFQ__c.isAccessible()){
                        rfqtovendor = [Select Id, buildertek__RFQ__c
                                       from buildertek__RFQ_To_vendor__c
                                       where Id = :relatedToId];
                    }
                    string rfqId = rfqtovendor.buildertek__Rfq__c;
                    queryString = 'Select Id, OwnerId, Owner.email from buildertek__RFQ__c where id =: rfqId';
                }

                //added by sai start

                else if (objectAPI.toLowerCase() == 'buildertek__account_payable__c'){
                    buildertek__Account_Payable__c invoiceAp = new buildertek__Account_Payable__c();
                    if (Schema.sObjectType.buildertek__Account_Payable__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Account_Payable__c.fields.buildertek__Purchase_Order__c.isAccessible()){
                        invoiceAp = [Select Id, buildertek__Purchase_Order__c,buildertek__Sender_Email_Response__c
                                       from buildertek__Account_Payable__c
                                       where Id = :relatedToId];
                    }
                    system.debug(invoiceAp);
                    string PoId = invoiceAp.buildertek__Purchase_Order__c;
                    system.debug(PoId);
                    queryString = 'Select Id, OwnerId, Owner.email from buildertek__Purchase_Order__c where id =: PoId';
                    if(invoiceAp != null){
                        if(invoiceAp.buildertek__Sender_Email_Response__c != null){
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            if (owea.size() > 0) {
                             message.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                            message.toAddresses = new String[]{invoiceAp.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                            message.subject = emailSubject;
                            message.plainTextBody = plainTextBody;
                            message.htmlBody = htmlBody;
                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        }
                    }
                }
                /*else if (objectAPI.toLowerCase() == 'buildertek__billings__c'){
                    buildertek__Billings__c invoiceAr = new buildertek__Billings__c();
                    if (Schema.sObjectType.buildertek__Billings__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Change_Order__c.isAccessible()){
                        invoiceAr = [Select Id, buildertek__Change_Order__c
                                       from buildertek__Billings__c
                                       where Id = :relatedToId];
                    }
                    system.debug(invoiceAr);
                    string CoId = invoiceAr.buildertek__Change_Order__c;
                    system.debug(CoId);
                    queryString = 'Select Id, OwnerId, Owner.email from buildertek__Change_Order__c where id =: CoId';

                }*/
                // added by sai end
                else if (objectAPI.toLowerCase() == 'buildertek__RFI_Response__c'){
                    queryString = 'select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Response__c,buildertek__Response_Date__c, '+
                                                              'buildertek__Answered__c,buildertek__RFI__c,CreatedById from buildertek__RFI_Response__c '+
                                                              'where Id =: relatedToId';
                }
                else{
                    queryString = 'Select Id, Owner.Id, Owner.email from ' + objectAPI + ' where id =:relatedToId';
                }

                if (objectAPI.toLowerCase() == 'buildertek__billings__c'){
                    buildertek__Billings__c invoiceAr = new buildertek__Billings__c();
                    invoiceAr = [Select Id, buildertek__Change_Order__c,buildertek__Sender_Email_Response__c
                                       from buildertek__Billings__c
                                       where Id = :relatedToId];
                    // system.debug(invoiceAr.buildertek__Sender_Email_Response__c);
                    if(invoiceAr != null){
                        if(invoiceAr.buildertek__Sender_Email_Response__c != null){
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            if (owea.size() > 0) {
                             message.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                            message.toAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                message.subject = emailSubject;
                            message.plainTextBody = plainTextBody;
                            message.htmlBody = htmlBody;
                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        }/*else{
                            system.debug('hoil;');
                        }*/
                    }

                }
                sObject obj;

                obj = database.query(queryString);
                system.debug(obj);
                String replyEmailSubject = emailSubject;
                //replyEmailSubject = replyEmailSubject.replace('Re: ', '');
                List<EmailMessage> emsg;

                //commented by sai
                /*emsg = [SELECT Id, Subject, buildertek__Subject__c
                        FROM EmailMessage
                        WHERE Subject = :replyEmailSubject AND relatedToId = :obj.Id];*/
                //added by sai
                if(objectAPI.toLowerCase() == 'buildertek__account_payable__c'){
                   emsg = [SELECT Id, Subject, buildertek__Subject__c
                        FROM EmailMessage
                        WHERE Subject = :replyEmailSubject AND relatedToId = :relatedToId];
                }else{
                    emsg = [SELECT Id, Subject, buildertek__Subject__c
                        FROM EmailMessage
                        WHERE Subject = :replyEmailSubject AND relatedToId = :obj.Id];
                }




                system.debug(emsg.size());
                EmailMessage EmailMsg = new EmailMessage();
                if (emsg.size() > 0){
                    EmailMsg.Id = emsg[0].Id;
                    EmailMsg.FromName = fromname;
                    EmailMsg.FromAddress = fromAddress;
                    system.debug(fromAddress);

                    EmailMsg.buildertek__Is_Incoming_Email__c = true;
                    //EmailMsg.Headers
                    EmailMsg.HtmlBody = htmlBody;
                    EmailMsg.MessageDate = system.now();
                    //EmailMsg.MessageSize
                    EmailMsg.Status = '5';
                    EmailMsg.TextBody = plainTextBody;
                    //EmailMsg.ToAddress = toAddresses != null?toAddresses[0]:null;
                    //EmailMsg.ToAddress = (String)obj.getSObject('Owner').get('Email');
                    if (objectAPI.toLowerCase() == 'buildertek__RFI_Response__c'){
                        EmailMsg.ToAddress = toAddresses[0];
                    }else{
                        EmailMsg.ToAddress = (String)obj.getSObject('Owner').get('Email');
                    }
                    EmailMsg.CcAddress = ccAddresses != null ? ccAddresses[0] : null;
                    EmailMsg.Subject = emailSubject;
                     system.debug(fromAddress);
                     system.debug(EmailMsg.ToAddress);
                    update EmailMsg;
                    system.debug(EmailMsg);
                } else{
                    EmailMsg.FromName = fromname;
                    EmailMsg.FromAddress = fromAddress;
                    //EmailMsg.HasAttachment = false;
                    //EmailMsg.Headers
                    EmailMsg.HtmlBody = htmlBody;
                    EmailMsg.Incoming = true;
                    EmailMsg.buildertek__Is_Incoming_Email__c = true;
                    //EmailMsg.relatedToId = (Id)obj.Id;
                    //added by sai
                    if(objectAPI.toLowerCase() == 'buildertek__account_payable__c'){
                        EmailMsg.relatedToId = (Id)relatedToId; // response is from invoice
                    }else{
                        EmailMsg.relatedToId = (Id)obj.Id;
                    }


                    EmailMsg.MessageDate = system.now();
                    //EmailMsg.MessageSize
                    EmailMsg.Status = '5';
                    system.debug('plainTextBody'+plainTextBody);
                   if(plainTextBody == null){
                        plainTextBody = '';
                    }
                    if (plainTextBody.length() >= 131000){
                        EmailMsg.buildertek__Email_Body__c = plainTextBody.substring(0, 131000);
                    } else{
                        EmailMsg.buildertek__Email_Body__c = plainTextBody;
                    }

                    //EmailMsg.ToAddress = toAddresses != null?toAddresses[0]:null;
                    if (objectAPI.toLowerCase() == 'buildertek__RFI_Response__c'){
                        EmailMsg.ToAddress = null;
                    }else{
                        EmailMsg.ToAddress = (String)obj.getSObject('Owner').get('Email');
                    }

                    EmailMsg.CcAddress = ccAddresses != null ? ccAddresses[0] : null;
                    EmailMsg.Subject = emailSubject;
                    insert EmailMsg;
                    system.debug(fromAddress);
                     system.debug(EmailMsg.ToAddress);
                    system.debug(EmailMsg);
                }


                /*EmailMessageRelation emr = new EmailMessageRelation();
                 emr.emailMessageId = EmailMsg.id;
                 emr.relationId = UserInfo.getUserId(); // user id of the sender
                 emr.relationType = 'FromAddress';
                 insert emr;*/
                system.debug(fromId);
                if (fromId != null){
                    // Add Email Message Relation for id of the sender
                    List<EmailMessageRelation> emrs = new List<EmailMessageRelation>();
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr = new EmailMessageRelation();
                    emr.emailMessageId = EmailMsg.id;
                    if (objectAPI.toLowerCase() == 'buildertek__RFI_Response__c'){
                        emr.relationId = null;
                    }else{
                        system.debug('(String)obj.getSObject%%%%%%%%%%%%%%');
                        emr.relationId = String.valueOf(obj.get('OwnerId')); // user id / contact Id of the sender
                    }
                    emr.relationType = 'ToAddress';
                    if (objectAPI.toLowerCase() == 'buildertek__RFI_Response__c'){
                        emr.relationAddress = toAddresses[0];
                    }else{
                        system.debug('(String)obj.getSObject'+(String)obj.getSObject('Owner').get('Email'));
                        emr.relationAddress = (String)obj.getSObject('Owner').get('Email');
                    }
                    emrs.add(emr);
                   insert emrs;
                }
                system.debug('objectAPI.toLowerCase()'+objectAPI.toLowerCase());
                if (objectAPI.toLowerCase() == 'buildertek__Project__c'){
                    buildertek__Project__c proRec = new buildertek__Project__c();
                    proRec = [Select Id,buildertek__Sender_Email_Response__c
                                 from buildertek__Project__c
                                 where Id = :relatedToId];
                    if(proRec != null){
                        if(proRec.buildertek__Sender_Email_Response__c != null){
                            system.debug('buildertek__Sender_Email_Response__c'+proRec.buildertek__Sender_Email_Response__c);
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                            if (owea.size() > 0) {
                             message.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            message.toAddresses = new String[]{proRec.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                            message.subject = emailSubject;
                            message.plainTextBody = plainTextBody;
                            message.htmlBody = htmlBody;
                            system.debug('message.toAddresses'+message.toAddresses );
                            system.debug('message.subject'+message.subject );
                            system.debug('message.plainTextBody '+message.plainTextBody );
                            system.debug(' message.htmlBody'+ message.htmlBody);
                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                               Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        }
                    }
                    List<Attachment> attachmetns = new List<Attachment>();
                    List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                    if (email != null && email.binaryAttachments != null){
                        for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments){
                            ContentVersion con= new contentversion();
                            con.ContentLocation = 'S';
                            con.PathOnClient = bAttachment.filename;
                            con.VersionData = bAttachment.body;
                            con.Title = bAttachment.filename;
                            contentVersionToInsert.add(con);
                            /*Attachment att = new Attachment();
                            att.Name = bAttachment.filename;
                            att.body = bAttachment.body;
                            att.parentId = relatedToId;
                            attachmetns.add(att);*/
                        }
                        if(contentVersionToInsert.size() > 0){
                            insert contentVersionToInsert;
                            SET<Id> contentDocumentIds = new SET<Id>();
                            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                            for(ContentVersion cv : contentVersionList){
                                contentDocumentIds.add(cv.ContentDocumentId);
                            }
                            List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                                for(ContentDocument cd : conDocList){
                                    ContentDocumentLink CDL = new ContentDocumentLink();
                                    CDL .ContentDocumentId = cd.Id;
                                    CDL .LinkedEntityId = relatedToId;
                                    CDL .ShareType = 'I';
                                    CDL .Visibility = 'AllUsers';
                                    cdlList.add(CDL);
                                }
                            if(cdlList.size() > 0){
                                insert cdlList;
                            }
                        }
                    }
                } else{
                    List<Attachment> attachmetns = new List<Attachment>();
                    if (email != null && email.binaryAttachments != null){
                        for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments){
                            Attachment att = new Attachment();
                            att.Name = bAttachment.filename;
                            att.body = bAttachment.body;
                            att.parentId = EmailMsg.Id;
                            attachmetns.add(att);
                            //AmazonS3Credential s3LinkConfig = new AmazonS3Credential();
                            //BT_S3REST.PutFile(EmailMsg.Id,relatedToId, bAttachment.body, bAttachment.filename, '', bAttachment.mimeTypeSubType, '',s3LinkConfig.key, s3LinkConfig.secret);
                        }
                        insert attachmetns;
                    }
                }

                if (objectAPI.toLowerCase() == 'account'){
                    Account accRec = new Account();
                    accRec = [Select Id,buildertek__Sender_Email_Response__c
                                 from Account
                                 where Id = :relatedToId];
                    // system.debug(invoiceAr.buildertek__Sender_Email_Response__c);
                    if(accRec != null){
                        if(accRec.buildertek__Sender_Email_Response__c != null){
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            if (owea.size() > 0) {
                             message.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                            message.toAddresses = new String[]{accRec.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                message.subject = emailSubject;
                            message.plainTextBody = plainTextBody;
                            message.htmlBody = htmlBody;
                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        }
                    }
                    system.debug('account');
                    List<Attachment> attachmetns = new List<Attachment>();
                    List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                    if (email != null && email.binaryAttachments != null){
                        for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments){
                            ContentVersion con= new contentversion();
                            con.ContentLocation = 'S';
                            con.PathOnClient = bAttachment.filename;
                            con.VersionData = bAttachment.body;
                            con.Title = bAttachment.filename;
                            contentVersionToInsert.add(con);
                            /*Attachment att = new Attachment();
                            att.Name = bAttachment.filename;
                            att.body = bAttachment.body;
                            att.parentId = relatedToId;
                            attachmetns.add(att);*/
                        }
                        if(contentVersionToInsert.size() > 0){
                            insert contentVersionToInsert;
                            SET<Id> contentDocumentIds = new SET<Id>();
                            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                            for(ContentVersion cv : contentVersionList){
                                contentDocumentIds.add(cv.ContentDocumentId);
                            }
                            List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                                for(ContentDocument cd : conDocList){
                                    ContentDocumentLink CDL = new ContentDocumentLink();
                                    CDL .ContentDocumentId = cd.Id;
                                    CDL .LinkedEntityId = relatedToId;
                                    CDL .ShareType = 'I';
                                    CDL .Visibility = 'AllUsers';
                                    cdlList.add(CDL);
                                }
                            if(cdlList.size() > 0){
                                insert cdlList;
                            }
                        }
                    }
                } else{
                    system.debug('elseacc');
                    List<Attachment> attachmetns = new List<Attachment>();
                    if (email != null && email.binaryAttachments != null){
                        for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments){
                            Attachment att = new Attachment();
                            att.Name = bAttachment.filename;
                            att.body = bAttachment.body;
                            att.parentId = EmailMsg.Id;
                            attachmetns.add(att);
                            //AmazonS3Credential s3LinkConfig = new AmazonS3Credential();
                            //BT_S3REST.PutFile(EmailMsg.Id,relatedToId, bAttachment.body, bAttachment.filename, '', bAttachment.mimeTypeSubType, '',s3LinkConfig.key, s3LinkConfig.secret);
                        }
                        insert attachmetns;
                    }
                }
                if (objectAPI.toLowerCase() == 'buildertek__Contract__c'){
                    buildertek__Contract__c accRec = new buildertek__Contract__c();
                    accRec = [Select Id,buildertek__Sender_Email_Response__c
                                 from buildertek__Contract__c
                                 where Id = :relatedToId];
                    // system.debug(invoiceAr.buildertek__Sender_Email_Response__c);
                     List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    List<Attachment> attachmetns = new List<Attachment>();
                    List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                    if (email != null && email.binaryAttachments != null){
                        for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments){
                            ContentVersion con= new contentversion();
                            con.ContentLocation = 'S';
                            con.PathOnClient = bAttachment.filename;
                            con.VersionData = bAttachment.body;
                            con.Title = bAttachment.filename;
                            contentVersionToInsert.add(con);
                            /*Attachment att = new Attachment();
                            att.Name = bAttachment.filename;
                            att.body = bAttachment.body;
                            att.parentId = relatedToId;
                            attachmetns.add(att);*/
                        }
                        if(contentVersionToInsert.size() > 0){
                            insert contentVersionToInsert;
                            SET<Id> contentDocumentIds = new SET<Id>();
                            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                            for(ContentVersion cv : contentVersionList){
                                contentDocumentIds.add(cv.ContentDocumentId);
                            }
                            List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                                for(ContentDocument cd : conDocList){
                                    ContentDocumentLink CDL = new ContentDocumentLink();
                                    CDL .ContentDocumentId = cd.Id;
                                    CDL .LinkedEntityId = relatedToId;
                                    CDL .ShareType = 'I';
                                    CDL .Visibility = 'AllUsers';
                                    cdlList.add(CDL);
                                }
                            if(cdlList.size() > 0){
                                insert cdlList;
                            }
                        }
                    }
                    if(accRec != null){
                        if(accRec.buildertek__Sender_Email_Response__c != null){
                            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                            if (owea.size() > 0) {
                             message.setOrgWideEmailAddressId(owea.get(0).Id);
                            }
                            // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                            message.toAddresses = new String[]{accRec.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                message.subject = emailSubject;
                            message.plainTextBody = plainTextBody;
                            message.htmlBody = htmlBody;
                           // message.setFileAttachments(fileAttachments);
                            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                        }
                    }
                } else{
                    List<Attachment> attachmetns = new List<Attachment>();
                    if (email != null && email.binaryAttachments != null){
                        for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments){
                            Attachment att = new Attachment();
                            att.Name = bAttachment.filename;
                            att.body = bAttachment.body;
                            att.parentId = EmailMsg.Id;
                            attachmetns.add(att);
                            //AmazonS3Credential s3LinkConfig = new AmazonS3Credential();
                            //BT_S3REST.PutFile(EmailMsg.Id,relatedToId, bAttachment.body, bAttachment.filename, '', bAttachment.mimeTypeSubType, '',s3LinkConfig.key, s3LinkConfig.secret);
                        }
                        insert attachmetns;
                    }
                }
                try{
                    if (objectAPI.toLowerCase() == 'buildertek__change_order__c'){
                        system.debug('--->buildertek__change_order__c');
                        system.debug(plainTextBody.split('\n')[0]);
                        String status = plainTextBody.split('\n')[0];
                        system.debug('--->buildertek__change_order__c:' + status.toLowerCase());
                        if (status.toLowerCase() == 'approved' || status.toLowerCase() == 'approve' || status.toLowerCase() == 'accepted' || status.toLowerCase() == 'accept'){
                            buildertek__change_order__c co = new buildertek__change_Order__c();
                            co.id = relatedToId;
                            co.buildertek__Status__c = 'Customer Approved';
                            system.debug(co.buildertek__status__c);
                            co.buildertek__Date_Approved__c = system.Now();

                            update co;


                        } else if (status.toLowerCase() == 'rejected' || status.toLowerCase() == 'reject'){

                            buildertek__change_order__c co = new buildertek__change_Order__c();
                            co.id = relatedToId;
                            co.buildertek__status__c = 'Rejected';
                            if (Schema.sObjectType.buildertek__change_order__c.fields.buildertek__status__c.isUpdateable()){
                                update co;
                            }

                        }
                        buildertek__change_order__c changeorderRec = new buildertek__change_order__c();
                        changeorderRec = [Select Id,buildertek__Sender_Email_Response__c
                                     from buildertek__change_order__c
                                     where Id = :relatedToId];
                        // system.debug(invoiceAr.buildertek__Sender_Email_Response__c);
                        if(changeorderRec != null){
                            if(changeorderRec.buildertek__Sender_Email_Response__c != null){
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                if (owea.size() > 0) {
                                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                                message.toAddresses = new String[]{changeorderRec.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                message.subject = emailSubject;
                                message.plainTextBody = plainTextBody;
                                message.htmlBody = htmlBody;
                                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                            }
                        }

                    }

                    /*if(objectAPI.toLowerCase() == 'buildertek__Quote__c') {
                     system.debug('--->buildertek__Quote__c');
                     system.debug(plainTextBody.split('\n')[0]);
                     String status = plainTextBody.split('\n')[0];
                     system.debug('--->buildertek__Quote__c' + status.toLowerCase());
                     if(status.toLowerCase() == 'accepted' || status.toLowerCase() == 'accept'){
                     buildertek__Quote__c quote = new buildertek__Quote__c();
                     quote.id = relatedToId;
                     quote.status__c ='Accepted';
                     update quote;

                     } else if(status.toLowerCase() == 'rejected' || status.toLowerCase() == 'reject'){
                     buildertek__Quote__c quote = new buildertek__Quote__c();
                     quote.id = relatedToId;
                     quote.status__c ='Rejected';
                     update quote;
                     }
                     }*/


                    if (objectAPI.toLowerCase() == 'buildertek__rfq_to_vendor__c'){
                        String status = plainTextBody.split('\n')[0];

                        if (status.toLowerCase() == 'accepted'){
                            buildertek__rfq_to_vendor__c rfqToVendor;
                            rfqToVendor = [select Id, name, buildertek__status__c, buildertek__RFQ__c,buildertek__Accepted_Date__c
                                           from buildertek__rfq_to_vendor__c
                                           where id = :relatedToId];

                            if (rfqToVendor.Id != null){
                                rfqToVendor.buildertek__status__c = 'Accepted';
                                rfqToVendor.buildertek__Accepted_Date__c = system.now();
                                update rfqToVendor;

                                if (rfqToVendor.buildertek__RFQ__c != null){
                                    buildertek__RFQ__c rfqRec = [SELECT Id, Name, buildertek__Accepted_Date__c, buildertek__Awarded_Date__c, buildertek__RFQ_s_Replied_To__c
                                                                 FROM buildertek__RFQ__c
                                                                 WHERE Id = :rfqToVendor.buildertek__RFQ__c];

                                    rfqRec.buildertek__Accepted_Date__c = System.today(); // here we update the accepted date when the status is accepted
                                    rfqRec.buildertek__status__c = 'Accepted';
                                   // rfqRec.buildertek__RFQ_s_Replied_To__c += 1; // here we get the count of replied email messages
                                    update rfqRec;
                                }
                            }
                        } else if (status.toLowerCase() == 'canceled' || status.toLowerCase() == 'rejected'){
                            System.debug('Status::' + status);
                            buildertek__rfq_to_vendor__c refqVendor;
                            if (Schema.sObjectType.buildertek__rfq_to_vendor__c.fields.id.isAccessible() && Schema.sObjectType.buildertek__rfq_to_vendor__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__rfq_to_vendor__c.fields.buildertek__RFQ__c.isAccessible()){
                                refqVendor = [SELECT Id, Name, buildertek__RFQ__c
                                              FROM buildertek__rfq_to_vendor__c
                                              WHERE Id = :relatedToId];
                            }

                            buildertek__rfq_to_vendor__c rfqToVendor = new buildertek__rfq_to_vendor__c();
                            rfqToVendor.Id = relatedToId;
                            rfqToVendor.buildertek__status__c = status;
                            rfqToVendor.buildertek__Rejected_Date__c = system.now();
                            rfqToVendor.buildertek__Awarded_Date__c = null;
                            update rfqToVendor;
                            System.debug('RFQ To vendor::' + rfqToVendor);

                            buildertek__RFQ__c rfq;
                            rfq = [SELECT Id, Name, buildertek__Accepted_Date__c, buildertek__Awarded_Date__c, buildertek__RFQ_s_Replied_To__c
                                   FROM buildertek__RFQ__c
                                   WHERE Id = :refqVendor.buildertek__RFQ__c];

                            if (rfq != null){
                                rfq.buildertek__Status__c = 'Canceled';
                                rfq.buildertek__Awarded_Date__c = null;
                               /* if (rfq.buildertek__RFQ_s_Replied_To__c != null){
                                    rfq.buildertek__RFQ_s_Replied_To__c += 1;
                                } else{
                                    rfq.buildertek__RFQ_s_Replied_To__c = 1;
                                } */
                                update rfq;
                                System.debug('Updated RFQ::' + rfq);
                                System.debug([SELECT Id, Name, buildertek__Status__c
                                              FROM buildertek__rfq_to_vendor__c
                                              WHERE Id = :relatedToId]);
                            }
                        }
                    }
                } catch (exception ex){
                    system.debug('----fail---' + ex);
                    throw ex;
                }


                try{
                    if (objectAPI.toLowerCase() == 'buildertek__submittal__c'){
                        List<Attachment> attachmentList = new List<Attachment>();
                        String submittalQuery = 'Select Id, Name, buildertek__Status__c, buildertek__Responsible_Contact__c,buildertek__Responsible_Contact__r.Email from ' + objectAPI + ' where id =:relatedToId';
                        sObject sObj;
                        /* if(Schema.sObjectType.buildertek__submittal__c.fields.Id.isAccessible()
                         && Schema.sObjectType.buildertek__submittal__c.fields.Name.isAccessible()
                         && Schema.sObjectType.buildertek__submittal__c.fields.buildertek__Status__c.isAccessible()
                         && Schema.sObjectType.buildertek__submittal__c.fields.buildertek__Responsible_Contact__c.isAccessible()
                         && Schema.sObjectType.contact.fields.Email.isAccessible()){*/
                        sObj = database.query(submittalQuery);
                        /*}*/
                        system.debug('sObj --> ' + sObj);

                        buildertek__submittal__c submittal = new buildertek__submittal__c();
                        submittal.Id = relatedToId;
                        submittal.buildertek__Status__c = 'Answered';
                        submittal.buildertek__Received_Date__c = system.today();
                        if (Schema.sObjectType.buildertek__submittal__c.fields.Id.isUpdateable() && Schema.sObjectType.buildertek__submittal__c.fields.buildertek__Status__c.isUpdateable() && Schema.sObjectType.buildertek__submittal__c.fields.buildertek__Received_Date__c.isUpdateable()){

                            update submittal;
                        }
                        buildertek__submittal__c subRec = new buildertek__submittal__c();
                        subRec = [Select Id,buildertek__Sender_Email_Response__c
                                     from buildertek__submittal__c
                                     where Id = :relatedToId];
                        if(subRec != null){
                            if(subRec.buildertek__Sender_Email_Response__c != null){
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                if (owea.size() > 0) {
                                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                                message.toAddresses = new String[]{subRec.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                message.subject = emailSubject;
                                message.plainTextBody = plainTextBody;
                                message.htmlBody = htmlBody;
                                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                            }
                        }
                        if (email.textAttachments != null){
                            // Save attachments, if any
                            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                                Attachment attachment = new Attachment();
                                attachment.Name = tAttachment.fileName;
                                attachment.Body = Blob.valueOf(tAttachment.body);
                                attachment.ParentId = sObj.Id;
                                attachmentList.add(attachment);
                            }
                        }
                        if (email.binaryAttachments != null){
                            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                                Attachment attachment = new Attachment();
                                attachment.Name = bAttachment.fileName;
                                attachment.Body = bAttachment.body;
                                attachment.ParentId = sObj.Id;
                                attachmentList.add(attachment);
                            }
                        }

                        if (Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentId.isCreateable()){

                            insert attachmentList;
                        }
                    }
                } catch (Exception exp){

                }

                try{
                    if (objectAPI.toLowerCase() == 'buildertek__RFI__c'){
                        boolean isusingcommunities = false;
                        boolean isusingemail = false;
                          buildertek__RFI_Settings__c rfiSettings = new buildertek__RFI_Settings__c();
                            List<buildertek__RFI_Settings__c> rfiSettingsList = [Select Id,Name,
                                                                                 buildertek__Using_Communities__c,
                                                                                 buildertek__Using_Email__c,
                                                                                 buildertek__New_RFI_Notification_Template__c
                                                                                 from buildertek__RFI_Settings__c
                                                                                 WHERE Name ='RFI Settings'];
                        system.debug('rfiSettingsList-------'+rfiSettingsList);
                        if(rfiSettingsList.size() > 0){
                            rfiSettings = rfiSettingsList[0];
                            if(rfiSettings.buildertek__Using_Communities__c==true){
                                 isusingcommunities = true;
                            }
                            if(rfiSettings.buildertek__Using_Email__c==true){
                                 isusingemail = true;
                            }

                        }

                        System.debug('Emial Body---------------------------------'+plainTextBody);
                        if(isusingcommunities==true){
                            string textbody = '';
                            if(plainTextBody.contains('On Sun,')){
                                List<String> res1 = plainTextBody.split('On Sun,', 2);
                                textbody=res1[0];
                            }else if(plainTextBody.contains('On Mon,')){
                                 List<String> res2 = plainTextBody.split('On Mon,', 2);
                                textbody=res2[0];
                            }else if(plainTextBody.contains('On Tue,')){
                                 List<String> res3 = plainTextBody.split('On Tue,', 2);
                                textbody=res3[0];
                            }else if(plainTextBody.contains('On Wed,')){
                                 List<String> res4 = plainTextBody.split('On Wed,', 2);
                                textbody=res4[0];
                            }else if(plainTextBody.contains('On Thu,')){
                                 List<String> res5 = plainTextBody.split('On Thu,', 2);
                                textbody=res5[0];
                            }else if(plainTextBody.contains('On Fri,')){
                                 List<String> res6 = plainTextBody.split('On Fri,', 2);
                                textbody=res6[0];
                            }else if(plainTextBody.contains('On Sat,')){
                                 List<String> res7 = plainTextBody.split('On Sat,', 2);
                                textbody=res7[0];
                            }
                            //List<String> res = plainTextBody.split('On ', 2);


                            buildertek__RFI__c rfirec =  [SELECT Id, Name, buildertek__RFI_Assigned_To__c,buildertek__Sender_Email_Response__c
                                                          FROM buildertek__RFI__c
                                                          WHERE Id = :relatedToId];

                            //fromname
                            List<String> lsttest=fromname.split(' ');
                            system.debug('lsttest---'+lsttest);
                            list<buildertek__Users_Contacts__c> rficonslist = [SELECT Id,
                            Name,
                            buildertek__User__c,
                            buildertek__User__r.Email,
                            buildertek__Contact__c,
                            buildertek__Contact__r.Name,
                            buildertek__Contact__r.Email,
                            buildertek__User__r.Name,
                            buildertek__RFI__c
                            FROM buildertek__Users_Contacts__c
                            where buildertek__RFI__c =:relatedToId
                            And buildertek__Contact__r.Email =:fromAddress];
                            system.debug('rficonslist---'+rficonslist);
                            if(rficonslist.size()>0){
                                contactId = rficonslist[0].buildertek__Contact__c;
                                userId = null;
                                /*boolean check=false;
                                for(buildertek__Users_Contacts__c cont : rficonslist){
                                    for(String s: lsttest){
                                        system.debug('contact name---'+cont.buildertek__Contact__r.Name);
                                        if(cont.buildertek__Contact__r.Name.toUpperCase().contains(s.toUpperCase())){
                                            system.debug('contact name contains');
                                            check=true;
                                            userId = null;
                                            contactId  = cont.Id;
                                            break;
                                        }
                                    }
                                }*/

                            }

                            list<buildertek__Users_Contacts__c> rfiusrslist = [SELECT Id,
                            Name,
                            buildertek__User__c,
                            buildertek__User__r.Email,
                            buildertek__Contact__c,
                            buildertek__Contact__r.Name,
                            buildertek__Contact__r.Email,
                            buildertek__User__r.Name,
                            buildertek__RFI__c
                            FROM buildertek__Users_Contacts__c
                            where buildertek__RFI__c =:relatedToId
                            And buildertek__User__r.Email =:fromAddress];
                            system.debug('rfiusrslist---'+rfiusrslist);
                            if(rfiusrslist.size()>0){
                                userId = rfiusrslist[0].buildertek__User__c;
                                contactId = null;
                                /*boolean check=false;
                                for(buildertek__Users_Contacts__c usr : rfiusrslist){
                                    for(String s: lsttest){
                                        system.debug('user name---'+usr.buildertek__User__r.Name);
                                        if(usr.buildertek__User__r.Name.toUpperCase().contains(s.toUpperCase())){
                                            system.debug('user name contains');
                                            check=true;
                                            userId  = usr.Id;
                                            contactId = null;
                                            break;
                                        }
                                    }
                                }*/

                            }
                            system.debug('rficonslist'+rficonslist);
                            system.debug('rfiusrslist'+rfiusrslist);


                            buildertek__RFI_Response__c rfiresponse = new buildertek__RFI_Response__c();
                            rfiresponse.buildertek__RFI__c = relatedToId;
                            rfiresponse.buildertek__Responder__c = userId; //rfirec.buildertek__RFI_Assigned_To__c;
                            rfiresponse.buildertek__Other_Responder__c  = contactId;
                            rfiresponse.buildertek__Response__c = textbody;
                            rfiresponse.buildertek__Response_Date__c = system.today();
                            insert rfiresponse;
                            if(rfiRec != null){
                                if(rfiRec.buildertek__Sender_Email_Response__c != null){
                                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                    if (owea.size() > 0) {
                                        message.setOrgWideEmailAddressId(owea.get(0).Id);
                                    }
                                    // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                                    message.toAddresses = new String[]{rfiRec.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                        message.subject = emailSubject;
                                    message.plainTextBody = plainTextBody;
                                    message.htmlBody = htmlBody;
                                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                                }
                            }

                            List<Attachment> attachmentList = new List<Attachment>();
                            List<Attachment> attachmetns = new List<Attachment>();
                            List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                            if (email.textAttachments != null){
                                // Save attachments, if any
                                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                                    system.debug('RFI');
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = tAttachment.filename;
                                    con.VersionData = Blob.valueOf(tAttachment.body);
                                    con.Title = tAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = rfiresponse.Id;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if (email.binaryAttachments != null){

                                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                                    system.debug('RFIbAttachment');
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = bAttachment.filename;
                                    con.VersionData = bAttachment.body;
                                    con.Title = bAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = rfiresponse.Id;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if(cdlList.size() > 0){
                                system.debug('cdlList');
                                insert cdlList;
                            }



                        }

                         if(isusingemail==true){
                            string textbody = '';
                            if(plainTextBody.contains('On Sun,')){
                                List<String> res1 = plainTextBody.split('On Sun,', 2);
                                textbody=res1[0];
                            }else if(plainTextBody.contains('On Mon,')){
                                 List<String> res2 = plainTextBody.split('On Mon,', 2);
                                textbody=res2[0];
                            }else if(plainTextBody.contains('On Tue,')){
                                 List<String> res3 = plainTextBody.split('On Tue,', 2);
                                textbody=res3[0];
                            }else if(plainTextBody.contains('On Wed,')){
                                 List<String> res4 = plainTextBody.split('On Wed,', 2);
                                textbody=res4[0];
                            }else if(plainTextBody.contains('On Thu,')){
                                 List<String> res5 = plainTextBody.split('On Thu,', 2);
                                textbody=res5[0];
                            }else if(plainTextBody.contains('On Fri,')){
                                 List<String> res6 = plainTextBody.split('On Fri,', 2);
                                textbody=res6[0];
                            }else if(plainTextBody.contains('On Sat,')){
                                 List<String> res7 = plainTextBody.split('On Sat,', 2);
                                textbody=res7[0];
                            }
                            //List<String> res = plainTextBody.split('On ', 2);

                            //check from address
                                string replytoemailaddress='';
                            buildertek__RFI__c rfirec =  [SELECT Id, Name, buildertek__RFI_Assigned_To__c,
                                                          buildertek__RFI_Assigned_To__r.Email,
                                                          buildertek__Submitted_By2__c,buildertek__Submitted_By2__r.Email,
                                                          buildertek__Sender_Email_Response__c
                                                          FROM buildertek__RFI__c
                                                          WHERE Id = :relatedToId];
                            system.debug('rfirec--->'+rfirec);


                            if(rfirec.buildertek__RFI_Assigned_To__c!=null){
                                if(fromAddress==rfirec.buildertek__RFI_Assigned_To__r.Email){
                                    if(rfirec.buildertek__Submitted_By2__c!=null){
                                        replytoemailaddress=rfirec.buildertek__Submitted_By2__r.Email;
                                    }
                                }
                            }
                            if(rfirec.buildertek__Submitted_By2__c!=null){
                                if(fromAddress==rfirec.buildertek__Submitted_By2__r.Email){
                                    if(rfirec.buildertek__RFI_Assigned_To__r!=null){
                                        replytoemailaddress=rfirec.buildertek__RFI_Assigned_To__r.Email;
                                    }
                                }
                            }
                            system.debug('replytoemailaddress--->'+replytoemailaddress);

                            buildertek__RFI_Response__c rfiresponse = new buildertek__RFI_Response__c();
                            rfiresponse.buildertek__RFI__c = relatedToId;
                            rfiresponse.buildertek__Responder__c = rfirec.buildertek__RFI_Assigned_To__c;
                            rfiresponse.buildertek__Response__c = textbody;
                            rfiresponse.buildertek__Response_Date__c = system.today();
                            rfiresponse.buildertek__Show_In_Community__c=false;
                            if(rfirec.buildertek__RFI_Assigned_To__c!=null){
                                if(fromAddress==rfirec.buildertek__RFI_Assigned_To__r.Email){
                                }
                            }
                            if(rfirec.buildertek__Submitted_By2__c!=null){
                                if(fromAddress==rfirec.buildertek__Submitted_By2__r.Email){

                                }
                            }


                            insert rfiresponse;
                            if(rfiRec != null){

                                EmailServicesAddress eServices;
                                eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                                             FROM EmailServicesAddress
                                             where LocalPart = 'projects'];

                                String setreplyto = eServices.LocalPart + '@' + eServices.EmailDomainName;
                                system.debug('replytoemailaddress--->'+replytoemailaddress);
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                message.toAddresses = new String[]{replytoemailaddress}; //'sainadh.kuntsam@diligentforcelabs.com'
                                     message.setReplyTo(setreplyto);
                                message.subject = emailSubject;
                                message.plainTextBody = plainTextBody;
                                message.htmlBody = htmlBody;
                                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                            }

                            List<Attachment> attachmentList = new List<Attachment>();
                            List<Attachment> attachmetns = new List<Attachment>();
                            List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                            if (email.textAttachments != null){
                                // Save attachments, if any
                                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                                    system.debug('RFI');
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = tAttachment.filename;
                                    con.VersionData = Blob.valueOf(tAttachment.body);
                                    con.Title = tAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = rfiresponse.Id;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if (email.binaryAttachments != null){

                                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                                    system.debug('RFIbAttachment');
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = bAttachment.filename;
                                    con.VersionData = bAttachment.body;
                                    con.Title = bAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = rfiresponse.Id;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if(cdlList.size() > 0){
                                system.debug('cdlList');
                                insert cdlList;
                            }






                        }
                        else{

                            List<Attachment> attachmentList = new List<Attachment>();
                            String RFIQuery = 'Select Id, Name, buildertek__Status__c from ' + objectAPI + ' where id =:relatedToId';
                            sObject rfi;
                            if (Schema.sObjectType.buildertek__RFI__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFI__c.fields.Name.isAccessible()){
                                rfi = database.query(RFIQuery);
                            }
                            system.debug('sObj --> ' + rfi);
                            List<Attachment> attachmetns = new List<Attachment>();
                            List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                            if (email.textAttachments != null){
                                // Save attachments, if any
                                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                                    system.debug('RFI');
                                    /* Attachment attachment = new Attachment();
                                    attachment.Name = tAttachment.fileName;
                                    attachment.Body = Blob.valueOf(tAttachment.body);
                                    attachment.ParentId = rfi.Id;
                                    attachmentList.add(attachment);*/
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = tAttachment.filename;
                                    con.VersionData = Blob.valueOf(tAttachment.body);
                                    con.Title = tAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = relatedToId;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if (email.binaryAttachments != null){

                                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                                    system.debug('RFIbAttachment');
                                    /*Attachment attachment = new Attachment();
                                    attachment.Name = bAttachment.fileName;
                                    attachment.Body = bAttachment.body;
                                    attachment.ParentId = rfi.Id;
                                    attachmentList.add(attachment);*/
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = bAttachment.filename;
                                    con.VersionData = bAttachment.body;
                                    con.Title = bAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = relatedToId;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if(cdlList.size() > 0){
                                system.debug('cdlList');
                                insert cdlList;
                            }


                        }



                       /* if (Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentId.isCreateable()){

                            insert attachmentList;
                        }*/
                    }
                } catch (Exception exp){

                }

                 try{
                    if (objectAPI.toLowerCase() == 'buildertek__RFI_Response__c'){
                        system.debug('buildertek__RFI_Response__c');
                         boolean isusingcommunities = false;
                          buildertek__RFI_Settings__c rfiSettings = new buildertek__RFI_Settings__c();
                            List<buildertek__RFI_Settings__c> rfiSettingsList = [Select Id,Name,
                                                                                 buildertek__Using_Communities__c,
                                                                                 buildertek__Using_Email__c,
                                                                                 buildertek__New_RFI_Notification_Template__c
                                                                                 from buildertek__RFI_Settings__c
                                                                                 WHERE Name ='RFI Settings'];
                        system.debug('rfiSettingsList-------'+rfiSettingsList);
                        if(rfiSettingsList.size() > 0){
                            rfiSettings = rfiSettingsList[0];
                            if(rfiSettings.buildertek__Using_Communities__c==true){
                                 isusingcommunities = true;
                            }
                        }

                        System.debug('Emial Body---------------------------------'+plainTextBody);
                        if(isusingcommunities==true){
                            string textbody = '';
                            if(plainTextBody.contains('On Sun,')){
                                List<String> res1 = plainTextBody.split('On Sun,', 2);
                                textbody=res1[0];
                            }else if(plainTextBody.contains('On Mon,')){
                                 List<String> res2 = plainTextBody.split('On Mon,', 2);
                                textbody=res2[0];
                            }else if(plainTextBody.contains('On Tue,')){
                                 List<String> res3 = plainTextBody.split('On Tue,', 2);
                                textbody=res3[0];
                            }else if(plainTextBody.contains('On Wed,')){
                                 List<String> res4 = plainTextBody.split('On Wed,', 2);
                                textbody=res4[0];
                            }else if(plainTextBody.contains('On Thu,')){
                                 List<String> res5 = plainTextBody.split('On Thu,', 2);
                                textbody=res5[0];
                            }else if(plainTextBody.contains('On Fri,')){
                                 List<String> res6 = plainTextBody.split('On Fri,', 2);
                                textbody=res6[0];
                            }else if(plainTextBody.contains('On Sat,')){
                                 List<String> res7 = plainTextBody.split('On Sat,', 2);
                                textbody=res7[0];
                            }
                            //List<String> res = plainTextBody.split('On ', 2);

                            buildertek__RFI_Response__c rfirespRec = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Response__c,buildertek__Response_Date__c,
                            buildertek__Answered__c,buildertek__RFI__c,CreatedById from buildertek__RFI_Response__c
                            where Id =: relatedToId ];

                            //fromname
                            List<String> lsttest=fromname.split(' ');
                            system.debug('lsttest---'+lsttest);
                            list<buildertek__Users_Contacts__c> rficonslist = [SELECT Id,
                            Name,
                            buildertek__User__c,
                            buildertek__User__r.Email,
                            buildertek__Contact__c,
                            buildertek__Contact__r.Name,
                            buildertek__Contact__r.Email,
                            buildertek__User__r.Name,
                            buildertek__RFI__c
                            FROM buildertek__Users_Contacts__c
                            where buildertek__RFI__c =:rfirespRec.buildertek__RFI__c
                            And buildertek__Contact__r.Email =:fromAddress];
                            system.debug('rficonslist---'+rficonslist);
                            if(rficonslist.size()>0){
                                contactId = rficonslist[0].buildertek__Contact__c;
                                userId = null;
                                /*boolean check=false;
                                for(buildertek__Users_Contacts__c cont : rficonslist){
                                    for(String s: lsttest){
                                        system.debug('contact name---'+cont.buildertek__Contact__r.Name);
                                        if(cont.buildertek__Contact__r.Name.contains(s)){
                                            system.debug('contact name contains');
                                            check=true;
                                            userId = null;
                                            contactId  = cont.Id;
                                               break;
                                        }
                                    }
                                }*/

                            }

                            list<buildertek__Users_Contacts__c> rfiusrslist = [SELECT Id,
                            Name,
                            buildertek__User__c,
                            buildertek__User__r.Email,
                            buildertek__Contact__c,
                            buildertek__Contact__r.Name,
                            buildertek__Contact__r.Email,
                            buildertek__User__r.Name,
                            buildertek__RFI__c
                            FROM buildertek__Users_Contacts__c
                            where buildertek__RFI__c =:rfirespRec.buildertek__RFI__c
                            And buildertek__User__r.Email =:fromAddress];
                            system.debug('rfiusrslist---'+rfiusrslist);
                            if(rfiusrslist.size()>0){
                                contactId = null;
                                userId = rfiusrslist[0].buildertek__User__c;

                                /*boolean check=false;
                                for(buildertek__Users_Contacts__c usr : rfiusrslist){
                                    for(String s: lsttest){
                                        system.debug('user name---'+usr.buildertek__User__r.Name);
                                        if(usr.buildertek__User__r.Name.contains(s)){
                                            system.debug('user name contains');
                                            check=true;
                                            userId  = usr.Id;
                                            contactId = null;
                                            break;
                                        }
                                    }
                                }*/

                            }
                            system.debug('rficonslist'+rficonslist);
                            system.debug('rfiusrslist'+rfiusrslist);


                            buildertek__RFI__c rfirec =  [SELECT Id, Name, buildertek__RFI_Assigned_To__c
                                                          FROM buildertek__RFI__c
                                                          WHERE Id = :rfirespRec.buildertek__RFI__c];
                            buildertek__RFI_Response__c rfiresponse = new buildertek__RFI_Response__c();
                            rfiresponse.buildertek__RFI__c = rfirespRec.buildertek__RFI__c;
                            rfiresponse.buildertek__Responder__c = userId;
                            rfiresponse.buildertek__Other_Responder__c  = contactId;
                            rfiresponse.buildertek__Response__c = textbody;
                            rfiresponse.buildertek__Response_Date__c = system.today();
                            rfiresponse.buildertek__Parent__c = relatedToId;
                            rfiresponse.buildertek__Show_In_Community__c = true;
                            insert rfiresponse;


                            List<Attachment> attachmentList = new List<Attachment>();
                            List<Attachment> attachmetns = new List<Attachment>();
                            List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                            if (email.textAttachments != null){
                                // Save attachments, if any
                                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                                    system.debug('RFI');
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = tAttachment.filename;
                                    con.VersionData = Blob.valueOf(tAttachment.body);
                                    con.Title = tAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = rfiresponse.Id;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if (email.binaryAttachments != null){

                                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                                    system.debug('RFIbAttachment');
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = bAttachment.filename;
                                    con.VersionData = bAttachment.body;
                                    con.Title = bAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = rfiresponse.Id;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if(cdlList.size() > 0){
                                system.debug('cdlList');
                                insert cdlList;
                            }






                        }else{

                            List<Attachment> attachmentList = new List<Attachment>();
                            String RFIQuery = 'Select Id, Name, buildertek__Status__c from ' + objectAPI + ' where id =:relatedToId';
                            sObject rfi;
                            if (Schema.sObjectType.buildertek__RFI__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFI__c.fields.Name.isAccessible()){
                                rfi = database.query(RFIQuery);
                            }
                            system.debug('sObj --> ' + rfi);
                            List<Attachment> attachmetns = new List<Attachment>();
                            List<ContentVersion> contentVersionToInsert = new List<ContentVersion>();
                            List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
                            if (email.textAttachments != null){
                                // Save attachments, if any
                                for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                                    system.debug('RFI');
                                    /* Attachment attachment = new Attachment();
                                    attachment.Name = tAttachment.fileName;
                                    attachment.Body = Blob.valueOf(tAttachment.body);
                                    attachment.ParentId = rfi.Id;
                                    attachmentList.add(attachment);*/
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = tAttachment.filename;
                                    con.VersionData = Blob.valueOf(tAttachment.body);
                                    con.Title = tAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = relatedToId;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if (email.binaryAttachments != null){

                                for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                                    system.debug('RFIbAttachment');
                                    /*Attachment attachment = new Attachment();
                                    attachment.Name = bAttachment.fileName;
                                    attachment.Body = bAttachment.body;
                                    attachment.ParentId = rfi.Id;
                                    attachmentList.add(attachment);*/
                                    ContentVersion con= new contentversion();
                                    con.ContentLocation = 'S';
                                    con.PathOnClient = bAttachment.filename;
                                    con.VersionData = bAttachment.body;
                                    con.Title = bAttachment.filename;
                                    contentVersionToInsert.add(con);
                                }
                                if(contentVersionToInsert.size() > 0){
                                    insert contentVersionToInsert;
                                    SET<Id> contentDocumentIds = new SET<Id>();
                                    List<ContentVersion> contentVersionList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersionToInsert];
                                    for(ContentVersion cv : contentVersionList){
                                        contentDocumentIds.add(cv.ContentDocumentId);
                                    }
                                    List<ContentDocument> conDocList = [SELECT Id,Title FROM ContentDocument WHERE Id IN:contentDocumentIds];
                                    for(ContentDocument cd : conDocList){
                                        ContentDocumentLink CDL = new ContentDocumentLink();
                                        CDL .ContentDocumentId = cd.Id;
                                        CDL .LinkedEntityId = relatedToId;
                                        CDL .ShareType = 'I';
                                        CDL .Visibility = 'AllUsers';
                                        cdlList.add(CDL);
                                    }

                                }
                            }
                            if(cdlList.size() > 0){
                                system.debug('cdlList');
                                insert cdlList;
                            }


                        }



                       /* if (Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentId.isCreateable()){

                            insert attachmentList;
                        }*/
                    }
                } catch (Exception exp){

                }


                try{
                    if (objectAPI.toLowerCase() == 'buildertek__Warranty__c'){
                        buildertek__Warranty__c warRec = new buildertek__Warranty__c();
                        warRec = [Select Id,buildertek__Sender_Email_Response__c
                                     from buildertek__Warranty__c
                                     where Id = :relatedToId];
                        // system.debug(invoiceAr.buildertek__Sender_Email_Response__c);
                        if(warRec != null){
                            if(warRec.buildertek__Sender_Email_Response__c != null){
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                if (owea.size() > 0) {
                                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                                message.toAddresses = new String[]{warRec.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                message.subject = emailSubject;
                                message.plainTextBody = plainTextBody;
                                message.htmlBody = htmlBody;
                                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                            }
                        }
                        List<Attachment> attachmentList = new List<Attachment>();
                        String warrantyQuery = 'Select Id, Name, buildertek__Status__c from ' + objectAPI + ' where id =:relatedToId';
                        sObject warranty;
                        /* if(Schema.sObjectType.buildertek__Warranty__c.fields.Id.isAccessible()
                         && Schema.sObjectType.buildertek__Warranty__c.fields.Name.isAccessible()
                         && Schema.sObjectType.buildertek__Warranty__c.fields.buildertek__Status__c.isAccessible()){*/
                        warranty = database.query(warrantyQuery);
                        /*}*/
                        system.debug('sObj --> ' + warranty);
                        if (email.textAttachments != null){
                            // Save attachments, if any
                            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                                Attachment attachment = new Attachment();
                                attachment.Name = tAttachment.fileName;
                                attachment.Body = Blob.valueOf(tAttachment.body);
                                attachment.ParentId = warranty.Id;
                                attachmentList.add(attachment);
                            }
                        }
                        if (email.binaryAttachments != null){
                            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                                Attachment attachment = new Attachment();
                                attachment.Name = bAttachment.fileName;
                                attachment.Body = bAttachment.body;
                                attachment.ParentId = warranty.Id;
                                attachmentList.add(attachment);
                            }
                        }
                        if (Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentId.isCreateable()){

                            insert attachmentList;
                        }
                    }
                } catch (Exception exp){

                }


                try{
                    List<Attachment> attachmentList = new List<Attachment>();
                    if (objectAPI.toLowerCase() == 'buildertek__Punch_List__c'){
                        String punchListQuery = 'Select Id, Name, buildertek__Vendor_Contact__c,buildertek__Vendor_Contact__r.Email from ' + objectAPI + ' where id =:relatedToId';
                        sObject punchListObj;
                        /*if(Schema.sObjectType.buildertek__Punch_List__c.fields.Id.isAccessible()
                         && Schema.sObjectType.buildertek__Punch_List__c.fields.Name.isAccessible()
                         && Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Vendor_Contact__c.isAccessible()
                         && Schema.sObjectType.Contact.fields.Email.isAccessible()){ */
                        punchListObj = database.query(punchListQuery);
                        /*}*/
                        system.debug('punchListObj --> ' + punchListObj);
                        buildertek__Punch_List__c punlistRec = new buildertek__Punch_List__c();
                        punlistRec = [Select Id,buildertek__Sender_Email_Response__c
                                     from buildertek__Punch_List__c
                                     where Id = :relatedToId];
                        // system.debug(invoiceAr.buildertek__Sender_Email_Response__c);
                        if(punlistRec != null){
                            if(punlistRec.buildertek__Sender_Email_Response__c != null){
                                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                                if (owea.size() > 0) {
                                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                // message.fromAddresses = new String[]{invoiceAr.buildertek__Sender_Email_Response__c};
                                message.toAddresses = new String[]{punlistRec.buildertek__Sender_Email_Response__c}; //'sainadh.kuntsam@diligentforcelabs.com'
                                message.subject = emailSubject;
                                message.plainTextBody = plainTextBody;
                                message.htmlBody = htmlBody;
                                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                            }
                        }

                        if (email.textAttachments != null){
                            // Save attachments, if any
                            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
                                Attachment attachment = new Attachment();
                                attachment.Name = tAttachment.fileName;
                                attachment.Body = Blob.valueOf(tAttachment.body);
                                attachment.ParentId = punchListObj.Id;
                                attachmentList.add(attachment);
                                //insert attachment;
                            }
                        }
                        if (email.binaryAttachments != null){
                            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
                                Attachment attachment = new Attachment();
                                attachment.Name = bAttachment.fileName;
                                attachment.Body = bAttachment.body;
                                attachment.ParentId = punchListObj.Id;
                                attachmentList.add(attachment);

                            }
                        }
                        if (Schema.sObjectType.Attachment.fields.Name.isCreateable() && Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentId.isCreateable()){

                            insert attachmentList;
                        }

                    }
                } catch (Exception exp){

                }
                result.success = true;
            }

        }

        return result;
    }
}