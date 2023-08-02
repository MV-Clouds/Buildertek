public class BT_EmailChangeOrderController {
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
        System.debug(String.isNotBlank(folderName));

        if(String.isNotBlank(folderName)){
            System.debug(folderName);
            List<EmailTemplate> emailTemplateList;

            System.debug(emailTemplateList);

            //  if (Schema.sObjectType.Emailtemplate.fields.Id.isAccessible() && Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){
            
            emailTemplateList = [Select Id, Name, folder.name,Body
                                 from Emailtemplate
                                 where folder.name = :folderName];
            //  }
            // system.debug(emailTemplateList[0].Body);
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
        System.debug(Id.valueOf(recordId));
        System.debug(Id.valueOf(recordId).getSObjectType());
        System.debug(Id.valueOf(recordId).getSObjectType().getDescribe());
        System.debug(Id.valueOf(recordId).getSObjectType().getDescribe().getName());
        System.debug(Id.valueOf(recordId).getSObjectType().getDescribe().getName() != 'buildertek__Quote__c');
        
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
    public Static list<buildertek__Change_Order__c> getdetails(list<string> recordId){
        //string subject = '';
        // if (objectAPIName == 'buildertek__Change_Order__c'){
        list<buildertek__Change_Order__c> changeRec = [select id, Name,buildertek__Project__c, buildertek__Status__c from buildertek__Change_Order__c where buildertek__Project__c =: recordId  ];
        // subject = changeRec.Name;
        system.debug('changeRec.............'+changeRec);
        return changeRec;
        //  }
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
        }else{
            subject = '';
        }
        return subject;
    }
    @AuraEnabled
    public Static String SendEmail(List<String> to, List<String> cc, List<String> files, String subject, String body, List<String> recordId, String templateId, String pdfFileName,List<String> emailIds,List<String> Ids){
        try{
            system.debug('recordId : '+recordId);
            List<string> strTO = new List<string>();
            List<string> strCC = new List<string>();
            SET<Id> contactIdSet = new SET<Id>();
            List<Contact> conList;
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
            if (strCC != null && strCC.size() > 0){
                mail.setCcAddresses(strCC);
            }
            
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
            
            //  System.debug('Near'+Id.valueOf(recordId).getSObjectType().getDescribe().getName());
            //   if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
            
            mail.setTemplateId(templateId);
            
            list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c, Name
                                                                                                        from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                        WHERE Name = :'Change Order Configuration' and buildertek__Email_Subject__c != null
                                                                                                        limit 1];
            
            if (adminInterfaceNodeConfigurations.size() > 0){
                emailsubject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
                // subject = subject + ' - '+ emailsubject + ' - [ref:' + 'recordId' + ']';
                subject = subject + ' - '+ emailsubject;

            } else{
                // subject = subject + ' Change Order - [ref:' + 'recordId' + ']';
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
            
            //     }
            
            
            //   system.debug('ObjectApiName--->'+Id.valueOf(recordId).getSObjectType().getDescribe().getName());
            //added by sai end
            
            List<File__c> flList;

            flList = [Select Id, Name, Bucket_Name__c, Amazon_File_Key__c, File_Presigned_URL__c
                      from File__c
                      where Id IN :files];
            String fileDetails = getFileDetails(flList);
            if (fileDetails != null){
                body = body + '<br/><br/><br/>' + fileDetails;
            }
            
            mail.setSubject(subject);
            if (body != null && String.isNotBlank(body) && body != ''){
                mail.setHtmlBody(body);
            }else{
                mail.setHtmlBody('<p></p>');
            }
            
            if (conList.size() > 0){
                mail.setTargetObjectId(conList[0].Id);
                mail.setSaveAsActivity(true);
              //  mail.setWhatId(recordId);
            }
            
            List<RFQ_To_Vendor__c> rfqVendorList;
            rfqVendorList = [select Id, Name
                             from RFQ_To_Vendor__c
                             where RFQ__c in :recordId];
            
            
            // Attached record pdf as an attachment
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
          //  for(Id recId : recordId){
          //  if (Id.valueOf(recId).getSObjectType().getDescribe().getName() != 'buildertek__RFQ__c' && Id.valueOf(recId).getSObjectType().getDescribe().getName() != 'buildertek__RFI__c'){
            if (String.isNotBlank(templateId)){
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(pdfFileName + '.pdf');
                //  for(Id recId : recordId){
                efa.setBody(setAttachmentBody(recordId, templateId));
                    // efa.setBody(setAttachmentBody(recId, templateId));   
            //    }
                fileAttachments.add(efa);
            }
         //   }
         //   }
            List<ContentVersion> docList;
            list<Id> contentVersionIds = new list<Id>();
            
            docList = [Select Id, ContentDocumentId, Title, VersionData
                       from ContentVersion
                       where Id IN :files]; //where ContentDocumentId IN :files];
            
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

            if (docList.size() > 0){
                for (Attachment att : attList){
                    system.debug(attList);

                    Messaging.Emailfileattachment efa2 = new Messaging.Emailfileattachment();
                    efa2.setFileName(att.Name);
                    efa2.setBody(att.Body);
                    fileAttachments.add(efa2);
                    //fileAttachments.add(docs);
                }
            }
            
            mail.setEntityAttachments(contentVersionIds);
            mail.setFileAttachments(fileAttachments);
            // if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
            //  } 
            mails.add(mail);
            
            //* Date: 28/03/2023 logic added for Date Emailed for Signature 
            List<buildertek__Change_Order__c> coList = new List<buildertek__Change_Order__c>();
            coList = [SELECT Id, Name, buildertek__CO_Submit_Date__c FROM buildertek__Change_Order__c WHERE Id IN :recordId LIMIT 1];
            System.debug('coList '+coList);
            if (coList.size() > 0 && coList[0].buildertek__CO_Submit_Date__c == null) {
                System.debug('coList[0].buildertek__CO_Submit_Date__c '+coList[0].buildertek__CO_Submit_Date__c);
                coList[0].buildertek__CO_Submit_Date__c = System.today();
                update coList;
            }

            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
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
                    /*if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
                        buildertek__Change_Order__c changeRec = new buildertek__Change_Order__c();
                        changeRec.Id = recordId;
                        changeRec.buildertek__Sender_Email_Response__c = UserInfo.getUserEmail();
                        update changeRec;
                    } */
                    
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

                    //caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                    //caseEmailMessage.TextBody = body;
                    
                    /*if(body.length() >= 131000 ){
                    system.debug('Too large Content');
                    caseEmailMessage.buildertek__Email_Body__c = body.substring(0, 131000);
                    }else{
                    caseEmailMessage.buildertek__Email_Body__c = body;
                    }*/
                    caseEmailMessage.status = '5';
                    caseEmailMessage.buildertek__Subject__c = 'Re: ' + subject;
                    
                    insert caseEmailMessage;
                    
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = caseEmailMessage.id;
                    emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                    emr.relationType = 'FromAddress';
                    emr.relationAddress = caseEmailMessage.fromAddress;
                    
                    insert emr;
                    
                    system.debug('*****************6^^^^^^**********************');
                    List<ContentVersion> attachmentList = [Select id,VersionData from ContentVersion where id IN:files];
                    
                    List<Attachment> newAttList = new List<Attachment>();
                    for (ContentVersion att : attachmentList){
                        Attachment attch = new Attachment();
                        attch.Body = att.VersionData;
                        attch.Name = 'test';
                        attch.ParentId = caseEmailMessage.Id; 
                        newAttList.add(attch);
                    }
                    insert(newAttList);


                    
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
            }
            
            String message = 'Success';
            return message;
        } catch (Exception exp){
            String message = exp.getMessage();
            system.debug('message ---------> ' + exp.getMessage());
            return message;
        }
    }
    
 /*  private static Blob setAttachmentBody(String recordId, String templateId){
     
      
        Pagereference pdf;
        pdf = Page.buildertek__BT_Generatepdf;
        pdf.getParameters().put('recordId', recordId);
        pdf.getParameters().put('templateId', templateId);
        pdf.setRedirect(true);
        
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
          
        
        return blobbody;
    
    } */
 /*    private static Blob setAttachmentBody(List<String> recordId, String templateId){
        System.debug('Ids : '+recordId);
        System.debug('templateId : '+templateId);
        List<Blob> pdfs = new  List<Blob>();
        Blob a = blob.valueOf('');
      //  string body = '';
        System.debug('Process started');
        for(String recId : recordId){
        Pagereference pdf;
        pdf = Page.buildertek__BT_Generatepdf;
        pdf.getParameters().put('recordId', recId);
        pdf.getParameters().put('templateId', templateId);
        pdf.setRedirect(true);
            System.debug('looooop');
      //   body += pdf.getContent().tostring();
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
            System.debug('Loop of blob : '+blobbody);
        pdfs.add(blobbody);
        }
        System.debug('List of blob : '+pdfs);
       /* for(blob e : pdfs){
            a += EncodingUtil.convertToHex(e);
            System.debug('String Loop : '+a);
        } */
      //   Blob myBIGblob;
       /*  for(Blob thisB:pdfs){
             // unfortunately can't do the following with binary types like you can
             // with strings :(
             a = blob.valueOf(EncodingUtil.base64Encode(a) + EncodingUtil.base64Encode(thisB));
         } 
       //  string bodys =  EncodingUtil.base64Encode(blob.valueof(body));
  /*      Blob b = EncodingUtil.convertFromHex(a.removeStart('0000feff') // UTF-32, big-endian
    .removeStart('fffe0000') // UTF-32, little-endian
    .removeStart('feff')     // UTF-16, big-endian
    .removeStart('fffe')     // UTF-16, little-endian
    .removeStart('efbbbf') ); */
       
     //   System.debug('Blob : '+b);
     /*   return a;
    } */
    
    private static Blob  setAttachmentBody(List<String> recordId, String templateId){
        String str = '';
        List<Blob> a = new List<Blob>();
     //   for(String recId : recordId){
            Pagereference pdf;
            pdf = Page.buildertek__COPDF;
            pdf.getParameters().put('id',JSON.serialize(recordId));
            pdf.getParameters().put('DocTemplateId', templateId);
            pdf.setRedirect(true);
            Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
    /*        a.add(blobbody);
        } */
      /*  for(Blob b : a){
            Blob d = Blob.valueOf(EncodingUtil.base64Encode(b));
            str += EncodingUtil.convertToHex(d);
        }     */
      //  str = EncodingUtil.convertToHex(Blob.valueOf(a[0].toString())) +  EncodingUtil.convertToHex(Blob.valueOf(a[1].toString()));
     /*   str = EncodingUtil.convertToHex(a[0]) + EncodingUtil.convertToHex(a[1]);
        Blob c = EncodingUtil.convertFromHex(str); */
        return blobbody;
    }
    private static string getFileDetails(List<File__c> files){
        
        if (files.size() == 0){
            return null;
        }
        // Get AWS credentials
        System.debug('outer loop');
        AmazonS3Credential s3Credentials = new AmazonS3Credential();
        System.debug(s3Credentials);
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
        System.debug(vendorID);
        
        buildertek__RFQ_To_Vendor__c rfq;
        System.debug(Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible());
        if (Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible()){
            
            rfq = [select Id, Name, buildertek__Contact__c
                   from buildertek__RFQ_To_Vendor__c
                   where Id = :parentRecordID];
        }
        System.debug(rfq);
        
        List<contact> contactList;
        System.debug(contactList);
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
    
    
}