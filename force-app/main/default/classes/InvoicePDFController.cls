public without sharing class InvoicePDFController{
    public String emailBody{ get; set; }

    public Id recordId{ get; set; }

    public string templateBody{ get; set; }

    public Contact con{ get; set; }
    
    public string TemptId{ get; set; }
    
    public boolean isMobile { get; set; }

    public InvoicePDFController(){
        if(UserInfo.getUiTheme() == 'Theme4t'){
           isMobile = true; 
        }else{
            isMobile = false;
        }
        if(ApexPages.currentPage().getParameters().get('id') != null){
            recordId = ApexPages.currentPage().getParameters().get('id');
            system.debug('1111-->'+ApexPages.currentPage().getParameters());
            TemptId = ApexPages.currentPage().getParameters().get('TempId');
            system.debug('TemptId'+TemptId);
            if(TemptId!= null){
                TemptId = TemptId ;
            }
        }
        
        /*List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
            con = [SELECT Id, Email
                   FROM Contact
                   WHERE Email != null
                   Order By CreatedDate DESC
                   LIMIT 1];
        }
        String templateId;
        if(recordId.getSObjectType().getDescribe().getName() == 'buildertek__Billings__c'){
            if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                templateId = [SELECT Id
                               FROM EmailTemplate
                               WHERE DeveloperName = :'Bill2'].Id;
            }
        }else if(recordId.getSObjectType().getDescribe().getName() == 'buildertek__Contract__c'){
            if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                templateId = [SELECT Id
                               FROM EmailTemplate
                               WHERE DeveloperName = :'Contract_Template_2'].Id;
            }
        }else if(recordId.getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
            if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                templateId = [SELECT Id
                               FROM EmailTemplate
                               WHERE DeveloperName = :'Change_Order_1'].Id;
            }
        }
        email.setTemplateId(templateId);
        email.setWhatId(recordId);
        email.setTargetObjectId(con.Id);
        email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
        msgList.add(email);
        SavePoint sp = Database.setSavePoint();
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody = emailNew.getHTMLBody();
        }
        Database.rollback(sp); */
    }
    public PageReference generatePDF(){
        system.debug('hai......');
            list<buildertek__ConfirmationPageSiteURL__c> settingslist = New list<buildertek__ConfirmationPageSiteURL__c>();
            settingslist = [select id, name, buildertek__SiteURL__c from buildertek__ConfirmationPageSiteURL__c where name = 'Siteurl' limit 1];
        system.debug('settingslist'+settingslist);
            string sites = '';
            if(settingslist.size() >0){
                sites = settingslist[0].buildertek__SiteURL__c;
            }
            PageReference pr = new PageReference(sites+'/buildertek__BT_Invoice?id='+recordId);
        system.debug('pr'+pr);
            pr.setRedirect(true);
         system.debug(pr);
            return pr;
       
        }
    Public void PDFInvoice(){
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        List<String> templateList = new List<String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
            con = [SELECT Id, Email
                   FROM Contact
                   WHERE Email != null
                   Order By CreatedDate DESC
                   LIMIT 1];
        }
        String templateId;
        if(recordId.getSObjectType().getDescribe().getName() == 'buildertek__Billings__c'){
            if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                templateId = [SELECT Id
                               FROM EmailTemplate
                               WHERE DeveloperName = :'Bill2'].Id;
            }
        }else if(recordId.getSObjectType().getDescribe().getName() == 'buildertek__Contract__c'){
            //if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                templateId = [SELECT Id
                               FROM EmailTemplate
                               WHERE DeveloperName = :'Contract_Template_2'].Id;
            system.debug(templateId);
            //}
        }else if(recordId.getSObjectType().getDescribe().getName() == 'buildertek__Change_Order__c'){
            if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                templateId = [SELECT Id
                               FROM EmailTemplate
                               WHERE DeveloperName = :'Change_Order_1'].Id;
            }
        }
        else if(recordId.getSObjectType().getDescribe().getName() == 'buildertek__Account_Payable_Clone__c'){
            if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
                system.debug('TemptId---->'+TemptId);
                if(TemptId != null){
                    system.debug('error------>');
                    templateId =  TemptId;                 
                }else{
                    system.debug('comming');
                    templateId = [SELECT Id
                               FROM EmailTemplate
                               WHERE DeveloperName = :'Invoice_AP'].Id;
                }
                system.debug('templateId=====>'+templateId);
                
            }
        }
        email.setTemplateId(templateId);
        email.setWhatId(recordId);
        email.setTargetObjectId(con.Id);
       // email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
        email.setToAddresses(new List<String>{'info@buildertek.com'});
        msgList.add(email);
        SavePoint sp = Database.setSavePoint();
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody = emailNew.getHTMLBody();
        }
        Database.rollback(sp);
        
    }
}