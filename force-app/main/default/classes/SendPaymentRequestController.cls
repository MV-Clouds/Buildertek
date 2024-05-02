public with sharing class SendPaymentRequestController {
    public SendPaymentRequestController() {

    }

    @AuraEnabled
    public static void sendEmailtoContact(String toAddress, String ccAddress, String subject, String body) {
        //from the string toAddress, create a list of email addresses
        List<String> toAddresses = new List<String>();
        toAddresses = toAddress.split(';');
        List<String> ccAddresses = new List<String>();
        if(ccAddress != null && ccAddress != ''){
            ccAddresses = ccAddress.split(';');
        }

        System.debug('toAddresses: ' + toAddresses);
        System.debug('ccAddresses: ' + ccAddresses);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        if(ccAddresses.size() > 0){
            mail.setCcAddresses(ccAddresses);
        }
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setSubject(subject);
        mail.setHtmlBody(body);
        mail.setSaveAsActivity(true);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

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