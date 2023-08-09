public without sharing class ConfirmationpageAsPDFController{
    public string recordID{ get; set; }
    
    public String templateId;
    
    public string checkcustomerview{ get; set; }
    
    public String acceptedDate{ get; set; }
    
    public transient string strBody{ get; set; }
    
    public DateTime customerAcceptedDate{ get; set; }
    
    public String imgId{ get; set; }
    
    public ConfirmationpageAsPDFController(){
        recordID = ApexPages.currentPage().getParameters().get('Id');
        templateId = apexpages.currentPage().getParameters().get('templateId');
        recordID = apexpages.currentPage().getParameters().get('Id');
        checkcustomerview = apexpages.currentPage().getParameters().get('view'); 
        system.debug('&&');
        if (ApexPages.currentPage().getParameters().get('imgURL') != null){
            system.debug('&&&&&&&&&&&&&&&&&&&&&&&&&&');
            imgId = ApexPages.currentPage().getParameters().get('imgURL');
             system.debug('**********'+imgId);
        }
        
        if (ApexPages.currentPage().getParameters().get('customerAcceptedDate') != null){
            customerAcceptedDate = DateTime.valueOf(ApexPages.currentPage().getParameters().get('customerAcceptedDate'));
            acceptedDate = customerAcceptedDate.format();
        }
        
        String vendorID;
        String templateBody = '';
        String templateBody1 = '';
        String templateBody2 = '';
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
        
        if (vendorID == null){
            Contact c = [SELECT Id, Email
                         FROM Contact
                         WHERE Email<>null
                         LIMIT 1];
            vendorID = c.id;
        }
        
       
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        string theTemplate;
        if (templateId != null){
            theTemplate = [SELECT Id
                           FROM EmailTemplate
                           WHERE Id = :templateId].Id;
        }
        if (templateId == null && Checkcustomerview != null){
            EmailTemplate emailtemrec = [Select Id, Name, Body, DeveloperName
                                         from EmailTemplate
                                         where DeveloperName = :'Quote_Template_2'
                                         limit 1];
            theTemplate = emailtemrec.Id;
        }
        email.setTemplateId(theTemplate);
        email.setWhatId(recordId);
        email.setTargetObjectId(vendorID);
        email.setSaveAsActivity(false);
        email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
        msgList.add(email);
        //Add Eail into Transaction.
        //SavePoint sp = Database.setSavePoint();
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
        //Database.rollback(sp);
        //Roll Back Transaction.
        for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody1 = emailNew.getHTMLBody();
        }
        
        Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
        string theTemplate1 = [SELECT Id
                               FROM EmailTemplate
                               WHERE Name = 'BT Proposal Images'].Id;
        email1.setTemplateId(theTemplate1);
        email1.setWhatId(recordId);
        email1.setTargetObjectId(vendorID);
        email1.setSaveAsActivity(false);
        msgList1.add(email1);
        //sp = Database.setSavePoint();
        Messaging.SendEmailResult[] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email1});
        //Database.rollback(sp);
        for (Messaging.SingleEmailMessage emailNew1 : msgList1){
            templateBody2 = emailNew1.getHTMLBody();
        } 
        templateBody = templateBody1 + templateBody2;
        strBody = templateBody;
        Document doc = [SELECT ID
                        FROM Document
                        WHERE DeveloperName = 'Company_Logo'
                        LIMIT 1];
        
        String imageid = doc.id;
        imageid = imageid.substring(0, 15);
        strBody = strBody.replace('###############', imageid);
     }
}