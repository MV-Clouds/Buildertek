public class PreQualObject_SubmitMSAFormController {
	@AuraEnabled 
    public static Innerclass  checkSignature(String recordId){
        List<buildertek__Pre_Qual__c> acc = [select id,name,buildertek__Qualification_Stage__c from buildertek__Pre_Qual__c where id=:recordId];
          list<string> contentdocIds = new list<string>();
        List<ContentDocumentLink> conlink = [select id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:recordId];
        system.debug('^^conlink'+conlink);
        if(conlink.size()>0){
            for(ContentDocumentLink con:conlink){
                contentdocIds.add(con.ContentDocumentId);
            }
        }
        
        system.debug('contentdocIds'+contentdocIds);
        List<ContentVersion> conversion = new List<ContentVersion>();
        
        
        if(contentdocIds.size()>0){
            conversion = [select id,title,VersionData from ContentVersion where title = 'CompanySignature' AND ContentDocumentId IN:contentdocIds order by CreatedDate desc];
        }
        system.debug(conversion);
        Innerclass inn = new Innerclass();
        inn.conver = conversion;
        inn.stagename = acc[0].buildertek__Qualification_Stage__c;
        return inn;
    }
     public class Innerclass{
           @AuraEnabled public list<ContentVersion>  conver;
           @AuraEnabled public string stagename;
     }
    
    
    @AuraEnabled 
    public static void sendUploadedAttachment(String accountId, List<String> documentIds){
    
        system.debug(accountId);
        string name = '';
        Organization org = [SELECT Id,Name from Organization limit 1];
        buildertek__MSA_Settings__c sitesUrl = [SELECT Id,buildertek__Submit_MSA_template_Name__c FROM buildertek__MSA_Settings__c LIMIT 1];
        List<buildertek__Pre_Qual__c> act = [SELECT Id,buildertek__MSA_Additional_Email__c,buildertek__Pre_Qual_Contact__c FROM buildertek__Pre_Qual__c WHERE id =: accountId ];
        List<Contact> contactsList = [SELECT Id, Name, Email FROM Contact WHERE id =: act[0].buildertek__Pre_Qual_Contact__c];
        List<EmailTemplate> template = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name =:sitesUrl.buildertek__Submit_MSA_template_Name__c];
        List<String> toAddresses = new List<String>();
        if(contactsList.size() > 0){
            name = contactsList[0].Name;
            toAddresses.add(contactsList[0].Email);
        }else{
             name = act[0].buildertek__MSA_Additional_Email__c;
             toAddresses.add(act[0].buildertek__MSA_Additional_Email__c);
        }

        
        string emailSubject;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(toAddresses);
            if(template.size()>0){
                 emailSubject = template[0].Subject;
            }
            
            email.setSubject(emailSubject);
            email.setSaveAsActivity(true);
           //String body = '<html><body><p><span>Hi '+Name+',</span><br/><br/>';
           // body += '<span> Congratulations! You have completed the pre-qualification process.Please keep the attached document for your records.we look forward to doing bussiness with you and your team.<br/><br/></span></p></body></html>';
           string body;
           if(!template.isEmpty()){
                body = template[0].htmlvalue;
           }
           if(body.contains('{!Contact.Name}')){
           body = body.replace('{!Contact.Name}',name);
           }
            email.setHtmlBody(body);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (ContentVersion docs : [Select Id, ContentDocumentId, Title, VersionData,FileType from ContentVersion where Id IN: documentIds]) {
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(docs.Title+'.'+docs.FileType);
                efa.setBody(docs.VersionData);
                fileAttachments.add(efa);
            }
            email.setFileAttachments(fileAttachments);
            mails.add(email);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            if(results.size() > 0){
                if (results[0].isSuccess()) {
                    buildertek__Pre_Qual__c acc = [SELECT Id, buildertek__Qualification_Stage__c FROM buildertek__Pre_Qual__c WHERE Id =: accountId];
                    acc.buildertek__Qualification_Stage__c = 'Fully Executed';
                    update acc;

                    string addresses= '';
                string CCaddresses= '';
                integer i = 0;
                for(String Str : toAddresses){
                    addresses += Str;
                    if(toAddresses.size() > i){
                        addresses += ';';
                    }
                    i++;
                }
                EmailMessage caseEmailMessage = new EmailMessage();
                 caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                 caseEmailMessage.ToAddress = addresses;
                 caseEmailMessage.FromName = UserInfo.getUserName();
                 caseEmailMessage.CcAddress = CCaddresses;
                 caseEmailMessage.Subject = emailSubject;
                 caseEmailMessage.HtmlBody = body;
                 caseEmailMessage.Incoming= False;
                 caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                 caseEmailMessage.MessageDate = system.now();
                 caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                 system.debug('Content length ---------> '+body.length());
                 caseEmailMessage.status = '5';
                 caseEmailMessage.RelatedToId = accountId;
                 caseEmailMessage.buildertek__Subject__c = emailSubject;
                 
                 insert caseEmailMessage;
 
               
               

                }    
            }
           

        }
}