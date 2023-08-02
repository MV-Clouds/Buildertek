public without sharing class SendPaymentEmailController {
    public class innerClass{
        @AuraEnabled public buildertek__Billings__c order{get;set;}
        
    }
    @AuraEnabled
    public static innerClass getSalesOrderDetails(String salesOrderId,String templateId){
        innerClass inner1 = new innerClass();
        System.debug(salesOrderId);
        buildertek__Billings__c salesOrder = [SELECT Id, Name,buildertek__Project__c , buildertek__Project__r.buildertek__Customer__c , buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c , buildertek__Customer_Account__c,buildertek__Customer_Account__r.buildertek__Email_Address__c,buildertek__Customer_Account__r.Name,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =: salesOrderId];
        //buildertek__Billings__c salesOrder = [SELECT Id, Name,buildertek__Customer_Account__r.buildertek__Email_Address__c,buildertek__Customer_Account__r.Name FROM buildertek__Billings__c where id = 'a0t1K00000Tfe02QAB'];
        system.debug('salesOrder--'+salesOrder);
        inner1.order = salesOrder;
        return inner1;
    }
    
    public static Blob setAttachmentBody(String recordId, String templateId){
        system.debug('recordId-------'+recordId);
        Pagereference pdf;
        String TmpID = '';
        //string tempName = '';
        //buildertek__Stripe_Settings__c stripeData = [Select id,name,buildertek__Emial_Template_Name__c from buildertek__Stripe_Settings__c];
        //tempName = stripeData.buildertek__Emial_Template_Name__c;
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Invoice' ];
        TmpID = emailTemplate.Id;
        pdf = Page.buildertek__BT_Generatepdf;
        pdf.getParameters().put('recordId',recordId );
        pdf.getParameters().put('templateId', TmpID );
        pdf.setRedirect(true);
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }
    
    @AuraEnabled    
    public static string sendEmail(String ids,String mailBody,String mailSub){
        string msg='';
        try{
        System.debug('Con Id---->'+ids+'Body--->'+mailBody+'Sub--->'+mailSub);
        String RecId = '';
        String TempId = '';
        string tempName = '';
        Contact Condata = new Contact();
        buildertek__Stripe_Settings__c stripeData = [Select id,name,buildertek__Email_Template_Name__c from buildertek__Stripe_Settings__c];
        tempName = stripeData.buildertek__Email_Template_Name__c;
        EmailTemplate emailTemplate1 = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =: tempName];
        TempId = emailTemplate1.Id;
        buildertek__Billings__c salesOrder = [SELECT Id, Name, buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c , buildertek__invoice_number__c,buildertek__Customer_Account__r.buildertek__Email_Address__c,buildertek__Customer_Account__r.Name,LastModifiedById FROM buildertek__Billings__c where id =:ids ];
        
        system.debug('salesOrderAcc ----------'+salesOrder.buildertek__Customer_Account__c );
        RecId = salesOrder.Id;
        //if(salesOrder.buildertek__Customer_Account__c == null){
            Condata = [Select id,name, Email  from contact  limit 1];
        //}else{
         //Condata = [Select id,buildertek__Primary_Contact__c from contact where AccountId =:salesOrder.buildertek__Customer_Account__c and buildertek__Primary_Contact__c = true Limit 1];
        //}
        
        /*List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        string htmlBody ='';
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress  LIMIT 1].Id);
        message.setTargetObjectId(UserInfo.getUserId()); 
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(true); 
        //EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Invoice Paymnent']; 
        message.setTemplateID(emailTemplate1.Id);   
        message.setWhatId(salesOrder .Id);
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setFileName(salesOrder.buildertek__invoice_number__c+'.pdf');
        efa.setBody(setAttachmentBody(RecId,TempId));
        fileAttachments.add(efa);
        message.setFileAttachments(fileAttachments);
        message.toAddresses = new String[] { salesOrder.buildertek__Customer_Account__r.buildertek__Email_Address__c};
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                */
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment efa = new Messaging.EmailfileAttachment();
        efa.setFileName(salesOrder.buildertek__invoice_number__c+'.pdf');
        efa.setBody(setAttachmentBody(RecId,TempId));
        fileAttachments.add(efa);
        message.setFileAttachments(fileAttachments);
    
        //message.setOrgWideEmailAddressId([SELECT Id FROM OrgWideEmailAddress  LIMIT 1].Id);
        message.toAddresses = new String[] { salesOrder.buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c};
        message.setTemplateID(emailTemplate1.Id);     
        message.setSaveAsActivity(true);
        message.setWhatId(salesOrder .Id);
        message.setTargetObjectId(Condata.Id /* UserInfo.getUserId() */);
        messageList.add(message);
        
         Savepoint sp = Database.setSavepoint();
        
        Messaging.sendEmail(messageList);
        
        Database.rollback(sp);
        
        List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
        
        // loop through the previous message list and set the email fields
        for (Messaging.SingleEmailMessage email : messageList) {
            Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
            emailToSend.setToAddresses(email.getToAddresses());
            emailToSend.setHTMLBody(email.getHTMLBody());
            emailToSend.setSaveAsActivity(true);
            emailToSend.setSubject(email.getSubject());
            emailToSend.setWhatId(salesOrder .Id);
            emailToSend.setTargetObjectId(Condata.Id /* UserInfo.getUserId() */);
            //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
            emailToSend.setFileAttachments(email.getFileAttachments());
            actualMessageList.add(emailToSend);
        }
        
            System.debug('actualMessageList' + actualMessageList);
            Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
            msg = 'Email Sent';
        }catch(Exception e){
            string error = e.getMessage()+''+e.getLineNumber();
            //if(error.toLowerCase().contains('invalid')){
                msg=error;
            //}
            
        }
        
        return msg;
               
    }
}