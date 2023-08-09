public with sharing class PreviewRFQController {
   
     @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
     List<Emailtemplate> temrec;
      if(Schema.sObjectType.Emailtemplate.fields.Id.isAccessible()&&
            Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() &&
            Schema.sObjectType.Emailtemplate.fields.folderid.isAccessible() &&
            Schema.sObjectType.Folder.fields.Name.isAccessible()){
            temrec = [Select Id, Name, folder.name from Emailtemplate where folder.name = 'BT PO'];
            }
		return temrec;
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
		system.debug('Final templateBody ----------> '+templateBody);
        return templateBody;
        
    }
    
    @AuraEnabled
     public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc,String fileid){
         try{
             String body = '';
             String subject = 'PurchaseOrder'; 
            List<buildertek__BT_ConfirmatioPageURL__c> confirmationPageSiteURL = [Select Id, buildertek__Public_Site_Url__c FROM buildertek__BT_ConfirmatioPageURL__c];
            System.debug('confirmationPageSiteURL---------------->'+confirmationPageSiteURL);
            string SiteUrl = '';
            if(confirmationPageSiteURL.size()>0){
                SiteUrl = confirmationPageSiteURL[0].buildertek__Public_Site_Url__c;
            }
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
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             system.debug('strTO ---------> '+strTO);
             mail.setToAddresses(strTO);
             if(strCC != null && strCC.size() > 0) {
                 system.debug('strCC -------> '+strCC);
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
             body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+recordId+'&templateId='+templateId+'>Click here</a>';
             body += '&nbsp;to confirm your Purchase Order details.' ;
        	 mail.setReplyTo(fromAddress);
        	 subject = subject +'[ref:'+recordId+']'; 
        	 mail.setSubject(subject);
             mail.setHTMLBody(body);
             List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
             Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
             efa.setFileName('PurchaseOrder.pdf');
             system.debug('Blob ---> '+setAttachmentBody(recordId, templateId,fileid));
             efa.setBody(setAttachmentBody(recordId, templateId,fileid));
             fileAttachments.add(efa); 
             mail.setFileAttachments(fileAttachments);
             mails.add(mail);
             Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
             System.debug('results=========>===='+results);
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
                    emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                    emr.relationType = 'FromAddress';
                    emr.relationAddress = caseEmailMessage.fromAddress;
                    insert emr;        
                   
                }
            }
                
             return message;                   
         }
         catch(Exception exp){
             system.debug('Error Message --------> '+exp);
            String message = exp.getMessage();
            return message;    
         }
     }
     
      @AuraEnabled
    public static String acceptandsendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc,string Emailsubject, string fileid){
         try{
             String body = '';
             String subject = 'PurchaseOrder'; 
             List<buildertek__BT_ConfirmatioPageURL__c> confirmationPageSiteURL = [Select Id, buildertek__Public_Site_Url__c FROM buildertek__BT_ConfirmatioPageURL__c];
             string SiteUrl = '';
             if(confirmationPageSiteURL.size()>0){
                 SiteUrl = confirmationPageSiteURL[0].buildertek__Public_Site_Url__c;
             }
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
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             system.debug('strTO ---------> '+strTO);
             mail.setToAddresses(strTO);
             if(strCC != null && strCC.size() > 0) {
                 system.debug('strCC -------> '+strCC);
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
             body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+recordId+'&templateId='+templateId+'>Click here</a>';
             body += '&nbsp;to confirm your Purchase Order details.' ;
        	 mail.setReplyTo(fromAddress);
        	 subject = subject +'[ref:'+recordId+']'; 
        	 mail.setSubject(subject);
             mail.setHTMLBody(body);
             List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
             Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
             efa.setFileName('PurchaseOrder.pdf');
             system.debug('Blob ---> '+setAttachmentBody(recordId, templateId,fileid));
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
                    emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                    emr.relationType = 'FromAddress';
                    emr.relationAddress = caseEmailMessage.fromAddress;
                    insert emr;        
                   
                }
            }
             list<buildertek__Purchase_Order__c> porec = [select id,
                                                                Name,
                                                                buildertek__Status__c,
                                                                buildertek__Customer_Accepted_Date__c,
                                                                buildertek__Date_Confirmed__c
                                                                from buildertek__Purchase_Order__c where Id=:recordId limit 1];
                if(porec.size() > 0 ){
                    porec[0].buildertek__Date_Confirmed__c = System.today();
                    update porec;
                }
                
             return message;                   
         }
         catch(Exception exp){
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
           
           list<buildertek__Purchase_Order__c> porec = [select id,
                                                                Name,
                                                                buildertek__Status__c,
                                                                buildertek__Customer_Accepted_Date__c,
                                                                buildertek__Date_Confirmed__c,
                                                        		buildertek__Rejection_Reason__c
                                                                from buildertek__Purchase_Order__c where Id=:recId limit 1];
                if(porec.size() > 0 ){
                    porec[0].buildertek__Date_Confirmed__c = System.today();
                    porec[0].buildertek__Status__c = 'Vendor Accepted';
                    update porec;
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
    public static string rejectSign(String recId,String base64Data, String contentType,string signName,String rejectionReason){
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
           
           list<buildertek__Purchase_Order__c> porec = [select id,
                                                                Name,
                                                                buildertek__Status__c,
                                                                buildertek__Customer_Accepted_Date__c,
                                                                buildertek__Date_Confirmed__c,
                                                        		buildertek__Rejection_Reason__c
                                                                from buildertek__Purchase_Order__c where Id=:recId limit 1];
                if(porec.size() > 0 ){
                    porec[0].buildertek__Date_Confirmed__c = System.today();
                    porec[0].buildertek__Status__c = 'Vendor Rejected';
                    porec[0].buildertek__Rejection_Reason__c = rejectionReason;
                    update porec;
                }
             conversn = [SELECT Id,VersionData FROM ContentVersion WHERE ContentDocumentId = :conDoc AND IsLatest = true].Id;
            //system.debug('conversn[0].Id ='+conversn[0].Id);
            return conversn;
        }else{
             String message = 'NoImage';
            return message;
        }
        
    } 
    
     /* To Save the Signature in Files */
    @AuraEnabled
    public static string rejectionWithReason(String recId,String base64Data, String contentType,string signName,String rejectionReason){
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
           
           list<buildertek__Purchase_Order__c> porec = [select id,
                                                                Name,
                                                                buildertek__Status__c,
                                                                buildertek__Customer_Accepted_Date__c,
                                                                buildertek__Date_Confirmed__c,
                                                        		buildertek__Rejection_Reason__c
                                                                from buildertek__Purchase_Order__c where Id=:recId limit 1];
                if(porec.size() > 0 ){
                    porec[0].buildertek__Date_Confirmed__c = System.today();
                    porec[0].buildertek__Status__c = 'Vendor Rejected';
                    porec[0].buildertek__Rejection_Reason__c = rejectionReason;
                    
                    update porec;
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