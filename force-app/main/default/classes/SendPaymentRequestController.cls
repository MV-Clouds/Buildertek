public with sharing class SendPaymentRequestController {
    public SendPaymentRequestController() {

    }

    @AuraEnabled
    public static string sendEmailtoContact(String recordId, String toAddress, String ccAddress, String subject, String body, List<String> files) {
        list<Id> contentVersionIds = new list<Id>();
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        String templateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Payable_1'].Id;
        System.debug('templateId: ' + templateId);
        System.debug('recordId: ' + recordId);
        if(templateId != null && recordId != null){
            String attachmentId = setAttachmentBody(recordId, templateId);
            System.debug('attachmentId: ' + attachmentId);
            contentVersionIds.add(attachmentId);
        }
        //from the string toAddress, create a list of email addresses
        List<String> toAddresses = new List<String>();
        toAddresses = toAddress.split(';');
        List<String> ccAddresses = new List<String>();
        if(ccAddress != null && ccAddress != ''){
            ccAddresses = ccAddress.split(';');
        }

        System.debug('toAddresses: ' + toAddresses);
        System.debug('ccAddresses: ' + ccAddresses);


        List<ContentVersion> docList = [SELECT Id, Title, VersionData,ContentSize FROM ContentVersion WHERE ContentDocumentId IN :files];
        Integer sum=0;
        System.debug('doclist---->'+docList);
        for (ContentVersion doc : docList) {
            Messaging.Emailfileattachment attachment = new Messaging.Emailfileattachment();
            sum+=doc.ContentSize;
            attachment.setFileName(doc.Title );
            attachment.setBody(doc.VersionData);
            contentVersionIds.add(doc.Id);

            fileAttachments.add(attachment);
        }
        if(sum>3000000){ 
            List<ContentDocument> contentDocumentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :files];
            if (!contentDocumentsToDelete.isEmpty()) {
                delete contentDocumentsToDelete;
            } 
            return 'Error: The total size of the attachments exceeds the limit of 3MB. Please remove some attachments and try again.';
        }

        body = body.replaceAll('<p><br></p>', '<br>');
        body = body.replaceAll('<p>', '<p style="margin-top: 0.1em; margin-bottom: 0em; ">');



        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        if(ccAddresses.size() > 0){
            mail.setCcAddresses(ccAddresses);
        }
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setEntityAttachments(contentVersionIds);
        mail.setSaveAsActivity(true);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        List<ContentDocument> contentDocumentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :files];
        if (!contentDocumentsToDelete.isEmpty()) {
            delete contentDocumentsToDelete;
        }

        return 'Email sent successfully';

    }

    @AuraEnabled
    public static String getOwnerNameAndCompanyName(String recordId) {
        System.debug('recordId: ' + recordId);
        buildertek__Account_Payable__c inn = [SELECT Id, Name, CreatedById FROM buildertek__Account_Payable__c WHERE Id = :recordId];
        System.debug('inn: ' + inn);
        User owner = [SELECT Id, Name, CompanyName FROM User WHERE Id = :inn.CreatedById];
        System.debug('owner: ' + owner);
        List<Organization> org = [SELECT Id,Name from Organization limit 1];
        return owner.Name + ' - ' + org[0].Name;

    }

    private static String setAttachmentBody(String recordId, String templateId){
        Pagereference pdf;
        pdf = Page.buildertek__BT_Generatepdf;
        pdf.getParameters().put('recordId', recordId);
        pdf.getParameters().put('templateId', templateId);
        pdf.setRedirect(true);
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        //insert the blob as a content document and return the content document id
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.PathOnClient = 'Payment Request.pdf';
        cv.Title = 'Payment Request';
        cv.VersionData = blobbody;
        insert cv;
        System.debug('cv: ' + cv);

        return cv.Id;
    }



    
}