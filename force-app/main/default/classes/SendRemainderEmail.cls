public with sharing class SendRemainderEmail {
    public SendRemainderEmail() {

    }

    @InvocableMethod(label='Send Remainder Email' description='Send Remainder Email')
    public static void sendEmail() {
        System.debug('Inside sendRemainderEmail');

        List<buildertek__BT_Time_Sheet__c> timeSheetList = new List<buildertek__BT_Time_Sheet__c>();
        if (Schema.sObjectType.buildertek__BT_Time_Sheet__c.isAccessible()) {
            timeSheetList = [SELECT Id, Name, buildertek__Contact__c, buildertek__Contact__r.Name, buildertek__Contact__r.Email FROM buildertek__BT_Time_Sheet__c WHERE buildertek__Send_Remainder_Email__c = true];
        }

        String baseUrl = Url.getOrgDomainURL().toExternalForm();

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate tem = [SELECT Id, DeveloperName from EmailTemplate where DeveloperName  = 'TimeSheet_Remainder' limit 1];
        for(buildertek__BT_Time_Sheet__c timeSheet : timeSheetList) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{timeSheet.buildertek__Contact__r.Email});
            mail.setTemplateId(tem.Id);
            mail.setTargetObjectId(timeSheet.buildertek__Contact__c);
            mail.setWhatId(timeSheet.Id);
            emails.add(mail);
        }

        Messaging.sendEmail(emails);

        List<buildertek__BT_Time_Sheet__c> updateList = new List<buildertek__BT_Time_Sheet__c>();
        for(buildertek__BT_Time_Sheet__c timeSheet : timeSheetList) {
            timeSheet.buildertek__Send_Remainder_Email__c = false;
            updateList.add(timeSheet);
        }

        if (!updateList.isEmpty() && Schema.sObjectType.buildertek__BT_Time_Sheet__c.isUpdateable()) {
            update updateList;
        }

    }
}