public with sharing class SendPaymentRequestController {
    public SendPaymentRequestController() {

    }

    @AuraEnabled
    public static string sendEmailtoContact(String toAddress, String ccAddress, String subject, String body, List<String> files) {
        //from the string toAddress, create a list of email addresses
        List<String> toAddresses = new List<String>();
        toAddresses = toAddress.split(';');
        List<String> ccAddresses = new List<String>();
        if(ccAddress != null && ccAddress != ''){
            ccAddresses = ccAddress.split(';');
        }

        System.debug('toAddresses: ' + toAddresses);
        System.debug('ccAddresses: ' + ccAddresses);

        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

        List<ContentVersion> docList = [SELECT Id, Title, VersionData,ContentSize FROM ContentVersion WHERE ContentDocumentId IN :files];
        list<Id> contentVersionIds = new list<Id>();
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



    
}