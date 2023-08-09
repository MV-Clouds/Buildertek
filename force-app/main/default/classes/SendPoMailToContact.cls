global class SendPoMailToContact implements Database.Batchable<sObject>, Database.Stateful {
    
    private List<String> setIds;
    global SendPoMailToContact(List <String> setPOIds) {
        setIds = setPOIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, buildertek__Vendor__c FROM buildertek__Purchase_Order__c where Id IN: setIds ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<buildertek__Purchase_Order__c> PoList) {    
        //List<buildertek__Purchase_Order__c> updatePoList = new List<buildertek__Purchase_Order__c>();
        try{
            for(buildertek__Purchase_Order__c PoItem : PoList){   
                string templateBody = '';
                string templateBody1 = '';
                string templateBody2 = '';
                system.debug('PO:---->'+PoItem);
                Contact con ;
                Account acc;
                if(PoItem.buildertek__Vendor__c != null){
                    if(Schema.sObjectType.Contact.fields.Id.isAccessible()&&
                       Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                       Schema.sObjectType.Contact.fields.email.isAccessible()  ){
                           acc = [SELECT Id, (SELECT Id,Name,Email FROM Contacts where buildertek__Primary_Contact__c = true) FROM Account WHERE Id =: PoItem.buildertek__Vendor__c ];
                           con = acc.Contacts[0];   //[select id, Email from Contact where email != null order by createddate desc limit 1 ];
                       }
                    String[] toaddres;
                    String templateId = '00X1K000000wks4UAA';
                    system.debug(acc+'  '+con.Email);
                    toaddres = new String[]{con.Email};
                        Savepoint sp = Database.setSavepoint();
                    list<Messaging.SingleEmailMessage> msgList= new List<Messaging.SingleEmailMessage>(); 
                    list<Messaging.SingleEmailMessage> msgList1= new List<Messaging.SingleEmailMessage>(); 
                    List<String> templateList = new List<String>();
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    string theTemplate = [SELECT Id FROM EmailTemplate WHERE Id =: templateId].Id; 
                    email.setTemplateId(theTemplate);
                    email.setWhatId(PoItem.Id);                        
                    email.setTargetObjectId(con.Id);       
                    email.setSaveAsActivity(true);
                    email.setToAddresses(toaddres);
                    msgList.add(email);
                    
                    system.debug(email);
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
                    System.debug('Email Results isSuccess = ' +  r[0].IsSuccess());
                    Database.rollback(sp); 
                    for (Messaging.SingleEmailMessage emailNew : msgList) {                   
                        templateBody1 = emailNew.getHTMLBody(); 
                    }
                    templateBody = templateBody1 ;
                    system.debug('Final templateBody ----------> '+templateBody);
                    
                    String body = '';
                    String fileid = '';
                    //String subject = 'PurchaseOrder';
                    String subject = ''; 
                    list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                                buildertek__Quote_Configuration__c,buildertek__Email_Subject__c 
                                                                                                                from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                                WHERE Name=:'Purchase Order Configuration' and buildertek__Email_Subject__c !=null limit 1];
                    if(adminInterfaceNodeConfigurations.size()>0){
                        subject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
                    }else{
                        subject = 'PurchaseOrder'; 
                    } 
                    List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
                    string SiteUrl;
                    if(confirmationurl.size() > 0){
                        SiteUrl = confirmationurl[0].buildertek__SiteURL__c ;
                    }
                    List<string> strTO = new List<string>();
                    List<string> strCC = new List<string>();
                    SET<Id> contactIdSet = new SET<Id>();
                    strTO.add(con.email);
                    
                    
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    system.debug('strTO ---------> '+strTO);
                    mail.setToAddresses(strTO);
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
                    body += '<a href='+ SiteUrl +'buildertek__ConfirmationPage?Id='+PoItem.Id+'&templateId='+templateId+'>Click here</a>';
                    body += '&nbsp;to confirm your Purchase Order details.' ;
                    mail.setReplyTo(fromAddress);
                    subject = subject +'[ref:'+PoItem.Id+']'; 
                    mail.setSubject(subject);
                    mail.setHTMLBody(body);
                    mail.setSaveAsActivity(true);
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName('PurchaseOrder.pdf');
                    
                    pagereference pdf;
                    pdf = Page.buildertek__BT_GeneratePdf;
                    pdf.getParameters().put('recordId',PoItem.Id);  
                    pdf.getParameters().put('templateId',templateId); 
                    pdf.getParameters().put('fileId',fileId);
                    pdf.setRedirect(true);
                    
                    // Take the PDF content
                    Blob pdfContent = pdf.getContent();
                    system.debug(pdfContent);
                    //system.debug('Blob ---> '+setAttachmentBody(PoItem.Id, templateId,fileid));
                    efa.setBody(pdfContent);
                    
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
                            //system.debug('CCaddresses ----------> '+CCaddresses);
                            EmailMessage caseEmailMessage = new EmailMessage();
                            caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                            caseEmailMessage.ToAddress = Toaddresses;
                            caseEmailMessage.FromName = UserInfo.getUserName();
                            caseEmailMessage.CcAddress = CCaddresses;
                            caseEmailMessage.Subject = subject;
                            caseEmailMessage.HtmlBody = body;
                            caseEmailMessage.Incoming= False;
                            //caseEmailMessage.IsTracked=true;
                            caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                            caseEmailMessage.MessageDate = system.now();
                            caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                            system.debug('Content length ---------> '+body.length());
                            caseEmailMessage.status = '5';
                            caseEmailMessage.RelatedToId = PoItem.Id;
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
                    PoItem.buildertek__Last_Emailed__c = System.now();
                    update PoItem;
                }
            }
            
        }catch (Exception e) {
            
            throw e;
        }
    }  
    
    global void finish(Database.BatchableContext BC) {
    }
    
}