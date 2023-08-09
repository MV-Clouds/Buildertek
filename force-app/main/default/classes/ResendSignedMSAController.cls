public class ResendSignedMSAController {
 
    @AuraEnabled
    public static string getFiledata(string AccountId)
    {
   
        string emailSubject = '';
         string body = '';
         string name = '';
        List<string> ContentDocumentIdList = new List<String>();
        List<ContentDocumentLink> Cdoclink = [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId =:AccountId];
        for(ContentDocumentLink cd:Cdoclink)
        {
            ContentDocumentIdList.add(cd.ContentDocumentId);    
        }
        List<ContentDocument> cdoc;
        if(!ContentDocumentIdList.isEmpty())
        {
            cdoc = [select id,title from ContentDocument where id In:ContentDocumentIdList AND title Like '%Vendor Signed%' order by Createddate desc];
        } 
        
        List<ContentVersion> ConVersion = [select id,VersionData,title,FileType from ContentVersion where ContentDocumentId =:cdoc[0].id];
        //return ConVersion[0].VersionData;
        
        
if(ConVersion.size()>0){
        List<Account> act = [SELECT Id,buildertek__MSA_Additional_Email__c,buildertek__Pre_Qual_Contact__c FROM Account WHERE id =: accountId ];
         List<Contact> contactsList = [SELECT Id, Name, Email FROM Contact WHERE id =: act[0].buildertek__Pre_Qual_Contact__c];
         buildertek__MSA_Settings__c sitesUrl = [SELECT Id,buildertek__Submit_MSA_template_Name__c FROM buildertek__MSA_Settings__c LIMIT 1];
         List<EmailTemplate> template = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name =:sitesUrl.buildertek__Submit_MSA_template_Name__c];
         List<String> toAddresses = new List<String>();
          if(contactsList.size() > 0){
            name = contactsList[0].Name;
             toAddresses.add(contactsList[0].Email);
        }else{
             name = act[0].buildertek__MSA_Additional_Email__c;
             toAddresses.add(act[0].buildertek__MSA_Additional_Email__c);
        }
         
         List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         
          /*for(Account ac : act){
              toAddresses.add(ac.buildertek__MSA_Additional_Email__c);
          }*/
          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
          email.setToAddresses(toAddresses);
          if(template.size()>0){
                 emailSubject = template[0].Subject;
          }
          email.setSubject(emailSubject);
          email.setSaveAsActivity(true);
          if(!template.isEmpty()){
                body = template[0].htmlvalue;
          }
          if(body.contains('{!Contact.Name}')){
               body = body.replace('{!Contact.Name}',name);
          }
          email.setHtmlBody(body);
           List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName(ConVersion[0].Title+'.'+ConVersion[0].FileType);
                efa.setBody(ConVersion[0].VersionData);
                fileAttachments.add(efa);
           
            email.setFileAttachments(fileAttachments);
            mails.add(email);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            if(results.size() > 0){
                if (results[0].isSuccess()) {
                    /*Account acc = [SELECT Id, buildertek__Qualification_Stage__c FROM Account WHERE Id =: accountId];
                    acc.buildertek__Qualification_Stage__c = 'Fully Executed';
                    update acc;*/

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
            return 'success';
        }else{
            return 'ERROR';
        }
          
           
        
    }
    

}