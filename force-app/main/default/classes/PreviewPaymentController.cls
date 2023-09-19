public with sharing class PreviewPaymentController {
   /* @AuraEnabled
    public static string getPaymentLines(String recordId){
        string templateBody = '';
        Contact con;
        if(Schema.sObjectType.Contact.fields.Id.isAccessible()&&
            Schema.sObjectType.Contact.fields.Name.isAccessible() &&
			Schema.sObjectType.Contact.fields.email.isAccessible()  ){
            con = [select id, Email from Contact where email != null order by createddate desc limit 1 ];
			}
			String[] toaddres;
			toaddres = new String[]{con.email};
			Savepoint sp = Database.setSavepoint();
                list<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>();  
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                 string theTemplate;
                 if(Schema.sObjectType.EmailTemplate.fields.Id.isAccessible()&&
                    Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
                        theTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Payment'].Id;
                }
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
                    templateBody = emailNew.getHTMLBody();         
				}
        return templateBody;
    }*/
    
     @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
     List<Emailtemplate> temrec;
      if(Schema.sObjectType.Emailtemplate.fields.Id.isAccessible()&&
            Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() &&
            Schema.sObjectType.Emailtemplate.fields.folderid.isAccessible() &&
            Schema.sObjectType.Folder.fields.Name.isAccessible()){
            temrec = [Select Id, Name, folder.name from Emailtemplate where folder.name = 'BT Payment'];
            }
		return temrec;
    }
    
    @AuraEnabled
    public static string getPaymentLines(String recordId, String templateId){
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
     public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc){
         try{
             String body = '';
             String subject = 'Payment'; 
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
        	 mail.setReplyTo(fromAddress);
        	 subject = subject +'[ref:'+recordId+']'; 
        	 mail.setSubject(subject);
             mail.setHTMLBody(body);
             List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
             Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
             efa.setFileName('Payment.pdf');
             system.debug('Blob ---> '+setAttachmentBody(recordId, templateId));
             efa.setBody(setAttachmentBody(recordId, templateId));
             fileAttachments.add(efa); 
             mail.setFileAttachments(fileAttachments);
             mails.add(mail);
             Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
             String message = 'Success';
             /*list<buildertek__Billings__c> invrec = [SELECT Id,
                                          buildertek__Invoiced_Date__c
                                          FROM buildertek__Billings__c
                                          WHERE Id =: recordId Limit 1];
                if(invrec.size() > 0 ){
                    invrec[0].buildertek__Invoiced_Date__c = System.today();
                    update invrec;
                }*/
                
             return message;                   
         }catch(Exception exp){
             system.debug('Error Message --------> '+exp);
            String message = exp.getMessage();
            return message;    
         }
         
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