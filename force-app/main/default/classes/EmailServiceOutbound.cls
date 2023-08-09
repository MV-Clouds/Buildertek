public with sharing class EmailServiceOutbound{
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
    public static ResponseBase sendMailMethod(String mMail, List<String> ccEmail, String mSubject, String mbody, string recid, String msgId, List<String> files){
        ResponseBase response = new ResponseBase();
         system.debug('cc --> ' + ccEmail);
        system.debug('files --> ' + files);
        List<string> strCC = new List<string>();
            SET<Id> contactIdSet = new SET<Id>();
            List<Contact> ccConList = [Select Id, email
                             from Contact
                             where Id IN :ccEmail and email != null];
        if(ccConList.size()>0){
            for (Contact con : ccConList){
                strCC.add(con.email);
                contactIdSet.add(con.Id);
            }
        }
        String subrec = '(' + recid + ')';
        String opcid = '';
        List<OrgWideEmailAddress> owe;
        if (Schema.sObjectType.OrgWideEmailAddress.fields.ID.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.IsAllowAllProfiles.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.DisplayName.isAccessible() && Schema.sObjectType.OrgWideEmailAddress.fields.Address.isAccessible()){
            owe = [SELECT ID, IsAllowAllProfiles, DisplayName, Address
                   FROM OrgWideEmailAddress
                   WHERE IsAllowAllProfiles = TRUE
                   LIMIT 1];
        }
        EmailMessage emsg;
        if (Schema.sObjectType.EmailMessage.fields.Id.isAccessible() && Schema.sObjectType.EmailMessage.fields.HtmlBody.isAccessible() && Schema.sObjectType.EmailMessage.fields.MessageDate.isAccessible() && Schema.sObjectType.EmailMessage.fields.FromAddress.isAccessible() && Schema.sObjectType.EmailMessage.fields.status.isAccessible()){
            emsg = [SELECT Id, HtmlBody, MessageDate, FromAddress, status
                    FROM EmailMessage
                    WHERE Id = :msgId];
        }
        String month = emsg.MessageDate.format('MMM');
        String year = emsg.MessageDate.format('YYYY');
        String day = String.valueOf(emsg.MessageDate.day());
        String dayOfWeek = emsg.MessageDate.format('E');
        String msgtime = emsg.MessageDate.format('hh:mm a');
        String oldMsgBody = 'On ' + dayOfWeek + ', ' + month + ' ' + day + ', ' + year + ' at ' + msgtime + ' ' + owe[0].DisplayName + ' ' + emsg.FromAddress + ' wrote:';
        oldMsgBody += '<br/>';
        oldMsgBody += emsg.HtmlBody;
      // mbody = mbody + '<br/>' + oldMsgBody;  
         mbody = mbody ;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (String.isNotBlank(mMail) && mMail != '' && mMail.contains(';')){
            List<String> sendTo = mMail.split(';');
            mail.setToAddresses(sendTo);
        } else{
            List<String> mailList = new List<String>();
            mailList.add(mMail);
            mail.setToAddresses(mailList);
        }
        
      /*  if (String.isNotBlank(ccEmail) && ccEmail != '' && ccEmail.contains(';')){
            List<String> CcAddresses = ccEmail.split(';');
            mail.setCcAddresses(CcAddresses);
        } else if (String.isNotBlank(ccEmail)){
            List<String> ccmailList = new List<String>();
            ccmailList.add(ccEmail);
            mail.setCcAddresses(ccmailList);
        }*/
        if (strCC != null && strCC.size() > 0){
                mail.setCcAddresses(strCC);
           }
        
        EmailServicesAddress eServices;
        eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                     FROM EmailServicesAddress
                     where LocalPart = 'projects'];
        
        String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
        mail.setReplyTo(fromAddress);
        mail.setSenderDisplayName(UserInfo.getName());
        mail.setSubject(mSubject);
        List<File__c> flList = [Select Id, Name, Bucket_Name__c, Amazon_File_Key__c, File_Presigned_URL__c
                              from File__c
                              where Id IN :files];


            String fileDetails = getFileDetails(flList);
            system.debug('fileDetails --------> ' + fileDetails);
            if (fileDetails != null){
                mbody = mbody + '<br/><br/><br/>' + fileDetails;
            }
        mail.setHtmlBody(mbody);
        if(ccConList.size()>0){
            mail.setTargetObjectId(ccConList[0].Id);
            mail.setSaveAsActivity(true);
            mail.setWhatId(recid);
        }
        mails.add(mail);

        try{
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            system.debug('results ----------> ' + results);
            if (results.size() > 0){
                //Add Inbound Email Message for contact
                /* if(Id.valueOf(recid).getSObjectType().getDescribe().getName() == 'buildertek__RFI__c'){ caseEmailMessage.RelatedToId = recid; }*/
                EmailMessage caseEmailMessage = new EmailMessage();
                caseEmailMessage.Id = msgId;
                caseEmailMessage.fromAddress = UserInfo.getUserEmail();
                caseEmailMessage.ToAddress = mMail;
                caseEmailMessage.FromName = UserInfo.getName();
                caseEmailMessage.Subject = mSubject;
                caseEmailMessage.HtmlBody = mbody;
                 if (strCC != null && strCC.size() > 0){
                     for(string emailcc : strCC){
                    caseEmailMessage.CcAddress += emailcc;
                     }
                }
                caseEmailMessage.buildertek__Is_Incoming_Email__c = False;
                caseEmailMessage.TextBody = mbody;
                caseEmailMessage.MessageIdentifier = msgId;
                caseEmailMessage.status = '5';
                caseEmailMessage.MessageDate = system.now();
                /*if(mbody.length() >= 131000 ){
                system.debug('Content too large');
                caseEmailMessage.buildertek__Email_Body__c = mbody.substring(0, 131000);
                }else{
                system.debug('Content normal');
                caseEmailMessage.buildertek__Email_Body__c = mbody;
                }*/
                
                    update caseEmailMessage;
                
                System.debug('>>>>>==------------' + caseEmailMessage);
                System.debug('>>>>>==-------------' + caseEmailMessage.Id);
                
                // Add Email Message Relation for id of the sender
                EmailMessageRelation emr = new EmailMessageRelation();
                emr.EmailMessageId = caseEmailMessage.id;
                emr.RelationAddress = UserInfo.getUserEmail();
                emr.RelationType = 'FromAddress';
                if (Schema.sObjectType.EmailMessageRelation.isCreateable() && Schema.sObjectType.EmailMessageRelation.fields.emailMessageId.isCreateable() && Schema.sObjectType.EmailMessageRelation.fields.relationAddress.isCreateable() && Schema.sObjectType.EmailMessageRelation.fields.relationId.isCreateable() && Schema.sObjectType.EmailMessageRelation.fields.RelationType.isCreateable()){
                    insert emr;
                }
                response.isSuccess = true;
                response.strMessage = 'Email sent successfully';
            }
        } catch (Exception e){
            System.debug('Error Message:------------ ' + e.getMessage());
            System.debug('Error Line: ---------------' + e.getLineNumber());
            response.isSuccess = false;
            response.strMessage = e.getMessage(); 
            
        }
        return response;
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

    
    public virtual class ResponseBase{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String strMessage;
        @AuraEnabled
        public String newRecordId;
    }
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

}