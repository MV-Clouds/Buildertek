public class SendMSAController {
    @AuraEnabled
    public static string getCurrentStage(Id accountIds){

        Account acc = [select id,buildertek__Qualification_Stage__c from Account where id=:accountIds];
        
        
        return acc.buildertek__Qualification_Stage__c;
       
    }
    public class ResponseClass{
        @AuraEnabled public string preQualstage;
        @AuraEnabled public boolean isSendMsa;
    }
    
    @AuraEnabled
     public static void sendEmail(Id accountIds){
        system.debug('Trigger callled'+accountIds);
        buildertek__MSA_Settings__c msaSettings = [Select Id, 
                                                            buildertek__MSA_PDF_Template__c,
                                                            buildertek__MSA_Template__c,buildertek__Send_MSA_Template_Name__c
                                                            from buildertek__MSA_Settings__c
                                                            WHERE Name = :'MSA Settings' LIMIT 1];
        List<Account> acc = [select id,Name,buildertek__MSA_Additional_Email__c,buildertek__Pre_Qual_Contact__c from Account where id =: accountIds];
       // List<Contact> contacts = [SELECT Id,Email, AccountId,Account.buildertek__MSA_Additional_Email__c FROM Contact WHERE AccountId IN: accountIds];
       List<Contact> contactsList = [SELECT Id, Name, Email FROM Contact WHERE id =: acc[0].buildertek__Pre_Qual_Contact__c];
       List<EmailTemplate> template = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name =:msaSettings.buildertek__Send_MSA_Template_Name__c];
       List<String> toAddresses = new List<String>();
       string body= '';
       if(template.size()>0){
          body= template[0].htmlvalue;
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        buildertek__MSA_Settings__c sitesUrl = [SELECT Id, buildertek__Site_URL__c FROM buildertek__MSA_Settings__c LIMIT 1];
        string link ='<a href="'+sitesUrl.buildertek__Site_URL__c+'/'+msaSettings.buildertek__MSA_Template__c+'?id='+Acc[0].Id+'&isresend=true">Click here to open the Web Form</a>';
        string emailSubject;
            if(body.Contains('{!URL}')){
               body = body.replace('{!URL}',link);
            }
            if(template.size()>0){
                emailSubject = template[0].Subject;
            }
            if(contactsList.size() > 0){
                toAddresses.add(contactsList[0].Email);
             }else{
                toAddresses.add(acc[0].buildertek__MSA_Additional_Email__c);
            }
            //String[] toAddresses = new String[] {acc.buildertek__MSA_Additional_Email__c};
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toAddresses);
                //string emailSubject = 'PreQualified Email';
                email.setSubject(emailSubject);
                email.setSaveAsActivity(true);
                //String body = '<html><body><p><span>Congratulations, you have been pre-qualified. You will be receiving additional instructions shortly on next steps.  Please fill out our MSA form.  If you have any questions please let us know.';
                //body += '</span><br/><span><a href="'+sitesUrl.buildertek__Site_URL__c+'/'+msaSettings.buildertek__MSA_Template__c+'?id='+Acc.Id+'">Click here to open the Web Form</a>';
                //body += '</span></p></body></html>'; 
                email.setHtmlBody(body);
                mails.add(email);   
                string addresses= '';
                string CCaddresses= '';
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        if(results.size() > 0){
                if (results[0].isSuccess()) {
                   Account accountsList = [SELECT Id, buildertek__Qualification_Date__c,buildertek__Qualification_Stage__c FROM Account WHERE Id =: accountIds];
                    
                        accountsList.buildertek__Qualification_Date__c = system.now();
                        accountsList.buildertek__Qualification_Stage__c = 'MSA Sent'; 
                        update accountsList;
                        integer i = 0;
                        for(String Str : toAddresses){
                            addresses += Str;
                            if(toAddresses.size() > i){
                                addresses += ';';
                            }
                            i++;
                        }
    
    
                        system.debug('CCaddresses ----------> '+CCaddresses);
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
                    caseEmailMessage.RelatedToId = accountIds;
                    caseEmailMessage.buildertek__Subject__c = emailSubject;
                    
                    insert caseEmailMessage;
                    }
                   
     
                   
                }
            }
    }