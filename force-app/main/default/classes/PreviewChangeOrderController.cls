public with sharing class PreviewChangeOrderController {
    
    @AuraEnabled
   public Static List<EmailTemplate> getTemplates(){
    List<Emailtemplate> temrec;
   
           temrec = [Select Id, Name, folder.name from Emailtemplate where folder.name = 'BT CO' and Name !=:'Change Order1'];
           
       return temrec;
   }

   @AuraEnabled
   public static List<Contact> getObjectContact(String recordId){
       List<Contact> con;
       buildertek__Change_Order__c  corecs;
       Set<Id> projectAccId= new Set<Id>();
       
       corecs = [SELECT Id, Name, buildertek__Project__c , buildertek__Project__r.buildertek__Customer__c FROM buildertek__Change_Order__c WHERE Id = :recordId];

       System.debug('corecs.buildertek__Project__c' + corecs.buildertek__Project__c);
       System.debug('corecs.buildertek__Project__c' + corecs.buildertek__Project__r.buildertek__Customer__c);

       if (corecs.buildertek__Project__c != null && corecs.buildertek__Project__r.buildertek__Customer__c != null){
           if(corecs.buildertek__Project__r.buildertek__Customer__c != null){
               projectAccId.add(corecs.buildertek__Project__r.buildertek__Customer__c);
           }
           
       }

       System.debug('projectAccId' + projectAccId);
       if(!projectAccId.isEmpty()){
           con = [SELECT Id, Name, Email , buildertek__Primary_Contact__c, AccountId FROM Contact WHERE AccountId IN: projectAccId];
       }
       return con;
   }
   
   @AuraEnabled
   public static string getChangeOrderLines(String recordId, String templateId){
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
       System.debug('templateId' + templateId);
       System.debug('theTemplate' + theTemplate);

       email.setTemplateId(theTemplate);
       email.setWhatId(recordId);                        
       email.setTargetObjectId(con.Id);       
       email.setSaveAsActivity(true);
       email.setToAddresses(toaddres);
       msgList.add(email);
       
       Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
       System.debug('Email Results isSuccess = ' +  r[0].IsSuccess());
       Database.rollback(sp); 
       for (Messaging.SingleEmailMessage emailNew : msgList) {                   
           templateBody1 = emailNew.getHTMLBody(); 
       }
       templateBody = templateBody1 ;
       system.debug('Final templateBody ----------> '+templateBody);

       /* ====AC-34 changes ===*/
       List<buildertek__Change_Order__c> corec=[SELECT id,  buildertek__TemplateId__c , buildertek__Template_Name__c  from buildertek__Change_Order__c where Id=:recordId limit 1];
       List<EmailTemplate> emailTemp = [SELECT Id,Name,Subject FROM EmailTemplate WHERE Id =:templateId];
       if(corec.size()>0){
            corec[0].buildertek__TemplateId__c = templateId;
            if(!emailTemp.isEmpty()){
                corec[0].buildertek__Template_Name__c= emailTemp[0].Name;
            }
        }
        update corec;
       /* ==== End AC-34 changes ===*/

       return templateBody;
       
   }
   
    @AuraEnabled
    public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc,string Emailsubject){
       Blob filebody;
       try{
            string fileid = '';
            String body = '';
            string templateBody1 = '';

            //String subject =  Emailsubject;  
           // String subject = ' Change Order [ref:' + recordId + ']';
           

           buildertek__Change_Order__c changeRec = [select id, Name ,buildertek__Auto_Number__c , buildertek__Project__r.Name , buildertek__Project__r.buildertek__Auto_Number__c from buildertek__Change_Order__c where Id =: recordId Limit 1];

            String subject='';
            list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                 buildertek__Quote_Configuration__c,buildertek__Email_Subject__c 
                                                                                                 from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                 WHERE Name=:'Change Order Configuration' and buildertek__Email_Subject__c !=null limit 1];
           if(adminInterfaceNodeConfigurations.size()>0){
               subject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
           }else{
               subject = 'Change Order'; 
           } 

           /*==== AC-34 changes === */
           buildertek__WideOrgEmailsettings__c getEmail = buildertek__WideOrgEmailsettings__c.getOrgDefaults();
           String wideOrgEmailName = getEmail.buildertek__WideEmail__c;
           List<OrgWideEmailAddress> wideOrgEmail =[select Id,Address from OrgWideEmailAddress WHERE Address =:wideOrgEmailName];
           /* ====AC-34 changes === */

           List<string> strTO = new List<string>();
           List<string> strCC = new List<string>();
           SET<Id> contactIdSet = new SET<Id>();
           List<Contact> conList = new List<Contact>();
           if(Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
               conList = [Select Id, email from Contact where Id IN:to and email != null];        
           }
           system.debug('conList -------> '+conList);
           for(Contact con: conList){
               strTO.add(con.email);
           }
           List<Contact> ccConList = new List<Contact>(); 
           if(cc.size() > 0 && Schema.sObjectType.Contact.fields.Id.isAccessible()
               && Schema.sObjectType.Contact.fields.Email.isAccessible()){
               ccConList = [Select Id, email from Contact where Id IN:cc and Email != null];        
           }
           if(ccConList.size() > 0){
               for(Contact con: ccConList){
                   strCC.add(con.email);
               }    
           }
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
           /*==== AC-34 changes === */
           List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
            Savepoint sp = Database.setSavepoint();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            string theTemplatebodyid = [SELECT Id  FROM EmailTemplate  WHERE DeveloperName = 'PreviewChangeOrderTemplate'].Id;
            email.setTemplateId(theTemplatebodyid);
            email.setTargetObjectId(conList[0].Id);
            email.setSaveAsActivity(false);
            email.setWhatId(recordId);
            email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
            msgList.add(email);
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            Database.rollback(sp);
            for (Messaging.SingleEmailMessage emailNew : msgList){
                system.debug(emailNew);
                templateBody1 = emailNew.getHTMLBody();
            }
           /*==== AC-34 changes === */


            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            system.debug('strTO ---------> '+strTO);
            mail.setToAddresses(strTO);
            if(conList.size()>0){
                mail.setTargetObjectId(conList[0].Id);
               //  mail.setWhatId(recordId);
            }
            if(strCC != null && strCC.size() > 0) {
                system.debug('strCC -------> '+strCC);
               mail.setCcAddresses(strCC);
            }
            EmailServicesAddress eServices =  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
           
            string fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName; 
             List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
            string SiteUrl;
            if(confirmationurl.size() > 0){
              SiteUrl = confirmationurl[0].buildertek__SiteURL__c ;
            }
           //  body += 'Hello, <br/><br/> ';
           //  body += '</br> Please &nbsp;'; 
           //  body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+recordId+'&templateId='+templateId+'>Click here</a>';
           //  body += '&nbsp;to confirm your Change Order details. <br/> <br/> <br/>' ;   
          // body += '<br/><center><a href="mailto:'+fromAddress+'?subject='+subject+'&body=Approved"><button type="button" style="cursor: pointer;background-color: #005fb2;color: white;padding-left: 16px;padding-right: 16px;text-align: center;vertical-align: middle;border: 1px solid #0070d2;line-height: 30px;min-height: 32px;cursor: pointer;">Approve</button></a> &nbsp;&nbsp;&nbsp;<a href="mailto:'+fromAddress+'?subject='+subject+'&body=Rejected"><button type="button" style="cursor: pointer;background-color: #a61a14;color: white;padding-left: 16px;padding-right: 16px;text-align: center;vertical-align: middle;border: 1px solid #0070d2;line-height: 30px;min-height: 32px;cursor: pointer;">Reject</a></button></center><br/>';

            mail.setReplyTo(fromAddress);
            subject = subject +'[ref:'+recordId+']';
            mail.setSubject(subject);
            mail.setHTMLBody(templateBody1);
            mail.setSaveAsActivity(false);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();


            efa.setFileName(changeRec.buildertek__Project__r.Name +'-' + changeRec.buildertek__Project__r.buildertek__Auto_Number__c +'-' + changeRec.buildertek__Auto_Number__c+'.pdf');
           // system.debug('templateid-----'+templateId+'record---> '+recordId);
           //  system.debug('Blob ---> '+setAttachmentBody(recordId, templateId,fileid));
            filebody = setAttachmentBody(recordId, templateId,fileid);
            efa.setBody(setAttachmentBody(recordId, templateId,fileid));
            fileAttachments.add(efa); 
            mail.setFileAttachments(fileAttachments);
            mails.add(mail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            String message = 'Success';

            
        if(results.size() > 0){
               if (results[0].isSuccess()) {
                   string Toaddresses= '';
                   string CCaddresses= '';
                   integer i = 0;
                   for(String Str : strTO){
                       Toaddresses += Str;
                       if(strTO.size() > i){
                           Toaddresses += ';';
                       }
                       i++;
                   }
                   for(String Str : strCC){
                       CCaddresses += Str;
                       if(strCC.size() > i){
                           CCaddresses += ';';
                       }
                       i++;
                       
                   }
                   system.debug('CCaddresses ----------> '+CCaddresses);
                   /*==== AC-34 changes === */
                   String anchorTagRegex = '<a href=\"(.*?)">(.*?)</a>';
                   String plainText = templateBody1.replaceAll(anchorTagRegex, ' ');
                   String plainText2 = plainText.stripHtmlTags();
                   /*==== AC-34 changes === */


               
                   EmailMessage caseEmailMessage = new EmailMessage();
                   caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                   caseEmailMessage.ToAddress = Toaddresses;
                   caseEmailMessage.FromName = UserInfo.getUserName();
                   caseEmailMessage.CcAddress = CCaddresses;
                   caseEmailMessage.Subject = subject;
                   caseEmailMessage.HtmlBody = templateBody1;
                   caseEmailMessage.Incoming= False;
                   //caseEmailMessage.IsTracked = true; 
                   caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                   caseEmailMessage.MessageDate = system.now();
                   caseEmailMessage.TextBody = plainText2;                    
                   caseEmailMessage.status = '5';
                   caseEmailMessage.RelatedToId = recordId;
                   caseEmailMessage.buildertek__Subject__c = 'Re: '+subject;
                   insert caseEmailMessage;   
                      
                   ContentVersion conVer1 = new ContentVersion();
                   conVer1.PathOnClient = 'CO.pdf'; // The files name, extension is very important here which will help the file in preview.
                   conver1.Title = 'CO.pdf';
                   conVer1.VersionData = filebody; // converting your binary string to Blog
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

           List<buildertek__Change_Order__c> corec=[SELECT id,  Name,  buildertek__Customer_Accepted_Date__c,  buildertek__TemplateId__c , buildertek__Template_Name__c , buildertek__Status__c,   buildertek__Date_Approved__c,  buildertek__CO_Submit_Date__c from buildertek__Change_Order__c where Id=:recordId limit 1];
           System.debug('CO LIST 1-------->' + corec);
           if(corec.size()>0){
            //    corec[0].buildertek__Date_Approved__c = system.now();
               if (corec[0].buildertek__CO_Submit_Date__c == null) {
               corec[0].buildertek__CO_Submit_Date__c = System.today();  
               } 
               
               update corec; 
           }
           
           return message;                   
       }catch(Exception exp){
            system.debug('Error Message --------> '+exp);
           String message = exp.getMessage();
           return message;    
        }
        
    }
    
     @AuraEnabled
    public static String acceptandsendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc,string Emailsubject, string fileid){
        try{
            String body = '';
            string templateBody1 = '';

           buildertek__Change_Order__c changeRec = [select id, Name , buildertek__Auto_Number__c , buildertek__Project__r.Name , buildertek__Project__r.buildertek__Auto_Number__c from buildertek__Change_Order__c where Id =: recordId Limit 1];

          //  String subject =  Emailsubject;  
            String subject='';
            list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                 buildertek__Quote_Configuration__c,buildertek__Email_Subject__c 
                                                                                                 from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                 WHERE Name=:'Change Order Configuration' and buildertek__Email_Subject__c !=null limit 1];
           if(adminInterfaceNodeConfigurations.size()>0){
               subject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
           }else{
               subject = 'Change Order'; 
           }

           /*==== AC-34 changes === */
           buildertek__WideOrgEmailsettings__c getEmail = buildertek__WideOrgEmailsettings__c.getOrgDefaults();
           String wideOrgEmailName = getEmail.buildertek__WideEmail__c;
           List<OrgWideEmailAddress> wideOrgEmail =[select Id,Address from OrgWideEmailAddress WHERE Address =:wideOrgEmailName];
           /* ====AC-34 changes === */

           List<string> strTO = new List<string>();
           List<string> strCC = new List<string>();
           SET<Id> contactIdSet = new SET<Id>();
           List<Contact> conList = new List<Contact>();
           if(Schema.sObjectType.Contact.fields.Id.isAccessible()
               && Schema.sObjectType.Contact.fields.email.isAccessible()){
               conList = [Select Id, email from Contact where Id IN:to and email != null];        
           }
           system.debug('conList -------> '+conList);
           for(Contact con: conList){
               strTO.add(con.email);
           }
            
           List<Contact> ccConList = new List<Contact>(); 
           if(cc.size() > 0 && Schema.sObjectType.Contact.fields.Id.isAccessible()
               && Schema.sObjectType.Contact.fields.Email.isAccessible()){
               ccConList = [Select Id, email from Contact where Id IN:cc and Email != null];        
           }
           if(ccConList.size() > 0){
               for(Contact con: ccConList){
                   strCC.add(con.email);
               }    
           }
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
             /*==== AC-34 changes === */
             List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
             Savepoint sp = Database.setSavepoint();
             Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
             string theTemplatebodyid = [SELECT Id
                                         FROM EmailTemplate
                                         WHERE DeveloperName = 'PreviewChangeOrderTemplate'].Id;
             email.setTemplateId(theTemplatebodyid);
             email.setTargetObjectId(conList[0].Id);
             // email.setSaveAsActivity(true);
             email.setSaveAsActivity(false);
             email.setWhatId(recordId);
             email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
             msgList.add(email);
 
             Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
             System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
             Database.rollback(sp);
             for (Messaging.SingleEmailMessage emailNew : msgList){
                 system.debug(emailNew);
                 templateBody1 = emailNew.getHTMLBody();
             }
            /*==== AC-34 changes === */

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            system.debug('strTO ---------> '+strTO);
            if(conList.size()>0){
                mail.setTargetObjectId(conList[0].Id);
                mail.setWhatId(recordId);
            }
            mail.setToAddresses(strTO);
            if(strCC != null && strCC.size() > 0) {
                system.debug('strCC -------> '+strCC);
               mail.setCcAddresses(strCC);
            }
            mail.setSaveAsActivity(false);
            EmailServicesAddress eServices;
            if(Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible()&&
               Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
                eServices =  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
           } 
            string fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName; 
              List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
            string SiteUrl;
            if(confirmationurl.size() > 0){
              SiteUrl = confirmationurl[0].buildertek__SiteURL__c ;
            }
           
           //  body += 'Hi, <br/><br/> ';
           //  body += '</br> Please &nbsp;'; 
           //  body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+recordId+'&templateId='+templateId+'>Click here</a>';
           //  body += '&nbsp;to confirm your Change Order details. <br/> <br/> <br/>' ; 
           //body += '<br/><center><a href="mailto:'+fromAddress+'?subject='+subject+'&body=Approved"><button type="button" style="cursor: pointer;background-color: #005fb2;color: white;padding-left: 16px;padding-right: 16px;text-align: center;vertical-align: middle;border: 1px solid #0070d2;line-height: 30px;min-height: 32px;cursor: pointer;">Approve</button></a> &nbsp;&nbsp;&nbsp;<a href="mailto:'+fromAddress+'?subject='+subject+'&body=Rejected"><button type="button" style="cursor: pointer;background-color: #a61a14;color: white;padding-left: 16px;padding-right: 16px;text-align: center;vertical-align: middle;border: 1px solid #0070d2;line-height: 30px;min-height: 32px;cursor: pointer;">Reject</a></button></center><br/>';

            mail.setReplyTo(fromAddress);
           // subject = subject ; 
            subject = subject +'[ref:'+recordId+']'; 
            mail.setSubject(subject);
            mail.setHTMLBody(templateBody1);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName(changeRec.buildertek__Project__r.Name +'-' + changeRec.buildertek__Project__r.buildertek__Auto_Number__c +'-' + changeRec.buildertek__Auto_Number__c+'.pdf');
             system.debug('templateid-----'+templateId+'record---> '+recordId);
            system.debug('Blob ---> '+setAttachmentBody(recordId, templateId,fileid));

            Blob b = setAttachmentBody(recordId, templateId, fileid);
           system.debug('Blob ---> ' + b);

           ContentVersion conVer = new ContentVersion();
           conVer.PathOnClient = 'ChangeOrder.pdf'; // The files name, extension is very important here which will help the file in preview.
           conVer.VersionData = b; // converting your binary string to Blog
           insert conVer;    //Insert ContentVersion

           ContentDocumentLink conDocLink = New ContentDocumentLink();
           conDocLink.LinkedEntityId = recordId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
           conDocLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;  //ContentDocumentId Id from ContentVersion
           conDocLink.Visibility = 'AllUsers';
           insert conDocLink;

            efa.setBody(setAttachmentBody(recordId, templateId,fileid));             
            fileAttachments.add(efa); 
            mail.setFileAttachments(fileAttachments);
            mails.add(mail);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            String message = 'Success';
             if(results.size() > 0){
               if (results[0].isSuccess()) {
                   string Toaddresses= '';
                   string CCaddresses= '';
                   integer i = 0;
                   for(String Str : strTO){
                       Toaddresses += Str;
                       if(strTO.size() > i){
                           Toaddresses += ';';
                       }
                       i++;
                   }
                   for(String Str : strCC){
                       CCaddresses += Str;
                       if(strCC.size() > i){
                           CCaddresses += ';';
                       }
                       i++;
                       
                   }
                   system.debug('CCaddresses ----------> '+CCaddresses);
                   
                 /*==== AC-34 changes === */
                 String anchorTagRegex = '<a href=\"(.*?)">(.*?)</a>';
                 String plainText = templateBody1.replaceAll(anchorTagRegex, ' ');
                 String plainText2 = plainText.stripHtmlTags();
                 /*==== AC-34 changes === */

               
                   EmailMessage caseEmailMessage = new EmailMessage();
                   caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                   caseEmailMessage.ToAddress = Toaddresses;
                   caseEmailMessage.FromName = UserInfo.getUserName();
                   caseEmailMessage.CcAddress = CCaddresses;
                   caseEmailMessage.Subject = subject;
                   caseEmailMessage.HtmlBody = templateBody1;
                   caseEmailMessage.Incoming= False;
                   caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                   caseEmailMessage.MessageDate = system.now();
                   caseEmailMessage.TextBody = plainText2;
                   system.debug('Content length ---------> '+body.length());
                   caseEmailMessage.status = '5';
                   caseEmailMessage.RelatedToId = recordId;
                   caseEmailMessage.buildertek__Subject__c = 'Re: '+subject;
                   insert caseEmailMessage;        

                   ContentVersion conVer1 = new ContentVersion();
                   conVer1.PathOnClient = 'ChangeOrder.pdf'; // The files name, extension is very important here which will help the file in preview.
                   conver1.Title = 'ChangeOrder.pdf';
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
           list<buildertek__Change_Order__c> corec;
           RecordType rt;
           //string primeContract = '';
           list<buildertek__Contract__c>  contractlist  = new list<buildertek__Contract__c>();
            rt = [SELECT Id FROM RecordType WHERE sObjectType='buildertek__Contract__c' AND Name = 'Prime Contract'];
                   corec = [select id,
                                       Name,
                                       buildertek__Customer_Accepted_Date__c,
                                       buildertek__Status__c,buildertek__Project__c,buildertek__Contract__c,
                                       buildertek__Date_Approved__c, buildertek__TemplateId__c, buildertek__Template_Name__c
                                       from buildertek__Change_Order__c where Id=:recordId limit 1];
                if(corec[0].buildertek__Project__c != null){
                     contractlist = [select id,Name,buildertek__Project__c from buildertek__Contract__c where buildertek__Project__c =: corec[0].buildertek__Project__c AND
                                                                  RecordTypeId =: rt.id order by CreatedDate ];
                }
               
               if(corec.size()>0){
                   
                           //corec[0].buildertek__Status__c = 'Sent';
                            corec[0].buildertek__Status__c ='Customer Accepted'; 
                            corec[0].buildertek__Date_Approved__c = system.now();
                            corec[0].buildertek__Customer_Accepted_Date__c = System.today();
                            if(contractlist.size() > 0){
                             corec[0].buildertek__Contract__c = contractlist[0].id;
                            }//else{
                              // corec[0].buildertek__Contract__c = contractlist[0].id; 
                           // }
                           update corec;
                   
               }
               
            return message;                   
        }catch(Exception exp){
            system.debug('Error Message --------> '+exp);
           String message = exp.getMessage();
           return message;    
        }
        
    }
    
    
    
    private static Blob setAttachmentBody(String recordId, String templateId, String fileid){
       pagereference pdf;
       pdf = Page.buildertek__BT_GeneratePdf;
       pdf.getParameters().put('recordId',recordId);  
       pdf.getParameters().put('templateId',templateId);
       pdf.getParameters().put('fileId',fileId);
       pdf.setRedirect(true);
       
       Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
       return blobbody;
   }
   

   
       /* To Save the Signature in Files */
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
                   
                           corec[0].buildertek__Status__c = 'Customer Accepted';
                          
                            // corec[0].buildertek__Date_Approved__c = system.now();
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
   
}