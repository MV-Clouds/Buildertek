public with sharing class RequestInvoiceFromPOController {

    @AuraEnabled
    public static returnWrapper sendMailtoVendor(String recordId, String quickActionName){
        returnWrapper returnWr = new returnWrapper();
        try {
            List<buildertek__Purchase_Order__c> poRecord = [SELECT Id, Name, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Vendor__r.buildertek__Email_Address__c, OwnerId FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];
            if (!poRecord.isEmpty()) {
                if (poRecord[0].buildertek__Vendor__c == null) {
                    returnWr.status = 'error';
                    returnWr.message = 'Vendor should not be null.';
                }
                if (poRecord[0].buildertek__Vendor__r.buildertek__Email_Address__c == null || poRecord[0].buildertek__Vendor__r.buildertek__Email_Address__c == '') {
                    returnWr.status = 'error';
                    returnWr.message = 'Email address of Vendor is empty.';
                }
                if (poRecord[0].buildertek__Vendor__c != null && poRecord[0].buildertek__Vendor__r.buildertek__Email_Address__c != null && poRecord[0].buildertek__Vendor__r.buildertek__Email_Address__c != '') {

                    String recipientEmail = poRecord[0].buildertek__Vendor__r.buildertek__Email_Address__c;

                    EmailTemplate template;
                    if (quickActionName == 'RequestInvoice') {
                        template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'RequestInvoiceEmail' LIMIT 1];
                    } else if(quickActionName == 'RequestInvoiceForActualQuantity'){
                        template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'RequestInvoiceEmailWithAQ' LIMIT 1];
                    }

                    String templateBody1 = '';
                    List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
                    Savepoint sp = Database.setSavepoint();
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    
                    String theTemplatebodyid = [SELECT Id  FROM EmailTemplate  WHERE DeveloperName = 'Purchase_Order_Template_1'].Id;
                    
                    email.setTemplateId(template.Id);
                    email.setTargetObjectId(poRecord[0].OwnerId);
                    email.setSaveAsActivity(false);
                    email.setWhatId(poRecord[0].Id);
                    email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
                    email.setUseSignature(false);
                    msgList.add(email);

                    Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
                    Database.rollback(sp);
                    for (Messaging.SingleEmailMessage emailNew : msgList){
                        system.debug(emailNew);
                        templateBody1 = emailNew.getHTMLBody();
                    }

                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new List<String>{recipientEmail});
                    mail.setSubject('Request Invoice');
                    mail.setHTMLBody(templateBody1);
                    mail.setSaveAsActivity(false);
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName('PurchaseOrder.pdf');
                    Blob blobBody = setAttachmentBody(recordId, theTemplatebodyid);
                    efa.setBody(blobBody);
                    fileAttachments.add(efa);
                    mail.setFileAttachments(fileAttachments);
                    mail.setUseSignature(false);
                    mails.add(mail);
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                    Messaging.SendEmailResult resultsemail = results[0];
                    System.debug('resultsemail---->' + resultsemail);
                    if (resultsemail.isSuccess()) {
                        returnWr.status = 'SUCCESS';
                        returnWr.message = 'Email successfully sent to the vendor.';

                        String anchorTagRegex = '<a href=\"(.*?)">(.*?)</a>';
                        String plainText = templateBody1.replaceAll(anchorTagRegex, ' ');
                        String plainText2 = plainText.stripHtmlTags();

                        EmailMessage caseEmailMessage = new EmailMessage();
                        caseEmailMessage.fromAddress = UserInfo.getUserEmail();
                        caseEmailMessage.ToAddress = recipientEmail;
                        caseEmailMessage.FromName = UserInfo.getName();
                        caseEmailMessage.Subject = 'Request Invoice';
                        caseEmailMessage.HtmlBody = templateBody1;
                        caseEmailMessage.Incoming = False;
                        caseEmailMessage.RelatedToId = recordId;
                        caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                        caseEmailMessage.MessageDate = system.now();
                        caseEmailMessage.TextBody = plainText2;
                        caseEmailMessage.status = '3';
                        caseEmailMessage.RelatedToId = recordId;
                        caseEmailMessage.buildertek__Subject__c = 'Request Invoice';
                        insert caseEmailMessage;

                        
                        ContentVersion conVer = new ContentVersion();
                        conVer.PathOnClient = 'PO.pdf';
                        conVer.Title = 'PurchaseOrder.pdf';
                        conVer.VersionData = blobBody;
                        insert conVer;
                        
                        ContentDocumentLink conDocLink = New ContentDocumentLink();
                        conDocLink.LinkedEntityId = caseEmailMessage.Id;
                        conDocLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                        conDocLink.Visibility = 'AllUsers';
                        insert conDocLink;
                        
                        
                        EmailMessageRelation emr = new EmailMessageRelation();
                        emr.emailMessageId = caseEmailMessage.id;
                        emr.relationId = UserInfo.getUserId();
                        emr.relationType = 'FromAddress';
                        emr.relationAddress = caseEmailMessage.fromAddress;
                        insert emr;

                    } else {
                        returnWr.status = 'ERROR';
                        returnWr.message = String.valueOf(resultsemail.getErrors());
                    }

                }
            }
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }

            returnWr.status = 'error';
            returnWr.message = e.getMessage();
        }
        return returnWr;
    }

    public class returnWrapper{
        @AuraEnabled public string status;
        @AuraEnabled public String message;
    }

    private static Blob setAttachmentBody(String recordId, String templateId){
        pagereference pdf;
        pdf = Page.buildertek__BT_GeneratePdf;
        pdf.getParameters().put('recordId',recordId);  
        pdf.getParameters().put('templateId',templateId); 
        pdf.getParameters().put('fileId','');
        pdf.setRedirect(true);
        
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }
}