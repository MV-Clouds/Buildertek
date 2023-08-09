public with sharing class PreviewPurchaseOrderLineController {
    
    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
        List<Emailtemplate> temrec;
        if(Schema.sObjectType.Emailtemplate.fields.Id.isAccessible()&&
           Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() &&
           Schema.sObjectType.Emailtemplate.fields.folderid.isAccessible() &&
           Schema.sObjectType.Folder.fields.Name.isAccessible()){
             //  temrec = [Select Id, Name, folder.name from Emailtemplate where Name =: 'Purchase Order Line Template'];
               temrec = [Select Id, Name, folder.name from Emailtemplate where Name =: 'Purchase Order Lien Template']; 
            //    temrec = [Select Id, Name, folder.name from Emailtemplate where folder.name = 'BT PO' and Name !=:'Purchase Order Approved Template' and  DeveloperName !=:'Purchase_Order_Template'];

           }
        return temrec;
    }
    @AuraEnabled
    public Static List<Contact> getvendorcon(string recordId){
        buildertek__Purchase_Order__c purchaseRec = [select id,Name,buildertek__Vendor__c from buildertek__Purchase_Order__c where id =: recordId];
        list<Contact> conlist = [select id,Name,AccountId,buildertek__Primary_Contact__c from Contact where AccountId =:purchaseRec.buildertek__Vendor__c AND buildertek__Primary_Contact__c = true];
        return conlist;
    }
    
    @AuraEnabled
    public static string getPurchaseOrderLines(String recordId, String templateId){
        string templateBody = '';
        string templateBody1 = '';
        string templateBody2 = '';
        Contact con ;
        if(Schema.sObjectType.Contact.fields.Id.isAccessible()&&
           Schema.sObjectType.Contact.fields.Name.isAccessible() &&
           Schema.sObjectType.Contact.fields.email.isAccessible()  ){
               con = [select id, Email from Contact where email != null order by createddate desc limit 1 ];
           }
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
        email.setSaveAsActivity(false);
        email.setToAddresses(toaddres);
        msgList.add(email);
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        System.debug('Email Results isSuccess = ' +  r[0].IsSuccess());
        Database.rollback(sp); 
        for (Messaging.SingleEmailMessage emailNew : msgList) {                   
            templateBody1 = emailNew.getHTMLBody(); 
        }
        templateBody = templateBody1 ;
        return templateBody;
    }
   
    @AuraEnabled
    public static String sendPurchaseOrderLineRelease(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc,string Emailsubject, string fileid){
        system.debug('hii' + templateId);
        //try{
            buildertek__Purchase_Order__c purchaserec = [select id,
                                                         Name,
                                                         buildertek__Status__c,
                                                         buildertek__Customer_Accepted_Date__c,
                                                         buildertek__Date_Confirmed__c,buildertek__Original_Date_Lien_Release_Sent__c
                                                         from buildertek__Purchase_Order__c where Id=: recordId];
            String body = '';
            String subject = 'PurchaseLienRelease'; 
            List<buildertek__BT_ConfirmatioPageURL__c> confirmationPageSiteURL = [Select Id, buildertek__Public_Site_Url__c FROM buildertek__BT_ConfirmatioPageURL__c];
            string SiteUrl = '';
            if(confirmationPageSiteURL.size()>0){
                SiteUrl = confirmationPageSiteURL[0].buildertek__Public_Site_Url__c;
                if(SiteUrl == null || SiteUrl == ''){
                    return 'No Public Site Found!';
                }
            }
            List<string> strTO = new List<string>();
            List<string> strCC = new List<string>();
            SET<Id> contactIdSet = new SET<Id>();
            List<Contact> conList = new List<Contact>();
            if(Schema.sObjectType.Contact.fields.Id.isAccessible()
               && Schema.sObjectType.Contact.fields.email.isAccessible()){
                   conList = [Select Id, email from Contact where Id IN:to and email != null];        
               }
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
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(strTO);
            if(strCC != null && strCC.size() > 0) {
                mail.setCcAddresses(strCC);
            }
            EmailServicesAddress eServices;
            if(Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible()&&
               Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() &&
               Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
                   eServices =  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
               } 
            string fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName;
            body += 'Hi, <br/><br/> ';
            body += '</br> Please &nbsp;'; 
            body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+recordId+'&templateId='+templateId+'&isOrderLienItem=true'+'>Click here</a>';
            body += '&nbsp;to review your Purchase Lien Release.' ;
            mail.setReplyTo(fromAddress);
            //subject = subject +'[ref:'+recordId+']'; 
            subject = purchaserec.Name + ' - Lien Release';
            mail.setSubject(subject);
            mail.setHTMLBody(body);
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName('PurchaseLienRelease.pdf');
            efa.setBody(setAttachmentBody(recordId, templateId));
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
                    EmailMessage caseEmailMessage = new EmailMessage();
                    caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                    caseEmailMessage.ToAddress = Toaddresses;
                    caseEmailMessage.FromName = UserInfo.getUserName();
                    caseEmailMessage.CcAddress = CCaddresses;
                    caseEmailMessage.Subject = subject;
                    caseEmailMessage.HtmlBody = body;
                    caseEmailMessage.Incoming= False;
                    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                    caseEmailMessage.MessageDate = system.now();
                    caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                    system.debug('Content length ---------> '+body.length());
                    caseEmailMessage.status = '5';
                    caseEmailMessage.RelatedToId = recordId;
                    caseEmailMessage.buildertek__Subject__c = 'Re: '+subject;
                    insert caseEmailMessage;        
                    
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = caseEmailMessage.id;
                    emr.relationId = UserInfo.getUserId(); 
                    emr.relationType = 'FromAddress';
                    emr.relationAddress = caseEmailMessage.fromAddress;
                    insert emr;        
                }
            }
            List<buildertek__Purchase_Order__c> porec = [select id,
                                                         Name,
                                                         buildertek__Status__c,
                                                         buildertek__Customer_Accepted_Date__c,
                                                         buildertek__Date_Confirmed__c,buildertek__Original_Date_Lien_Release_Sent__c
                                                         from buildertek__Purchase_Order__c where Id=:recordId limit 1];
            if(porec.size() > 0 ){
                porec[0].buildertek__Date_Lien_Release_Sent__c  = System.now();
                if(porec[0].buildertek__Original_Date_Lien_Release_Sent__c == null){
                    porec[0].buildertek__Original_Date_Lien_Release_Sent__c = System.now();
                }
                update porec;
            }
            return message;                   
       /* }
        catch(Exception e){
            return e.getMessage();    
        }*/
    }
    
    private static Blob setAttachmentBody(String recordId, String templateId){
        pagereference pdf;
        pdf = Page.buildertek__BT_GeneratePdf;
        pdf.getParameters().put('recordId',recordId);  
        pdf.getParameters().put('templateId',templateId); 
        pdf.setRedirect(true);
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }  
}