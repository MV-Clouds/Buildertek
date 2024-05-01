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

    
}