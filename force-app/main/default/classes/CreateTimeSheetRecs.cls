public without sharing class CreateTimeSheetRecs {
    public CreateTimeSheetRecs() {

    }

    @InvocableMethod(label='Create Time Sheet Records' description='Create Time Sheet Records')
    public static void createRecords() {
        System.debug('Inside createTimeSheetRecs');

        List<Contact> contactList = getContactList();

        if (contactList.isEmpty()) {
            return;
        }

        List<buildertek__BT_Time_Sheet__c> timeSheetList = createTimeSheetList(contactList);
        Map<Id, ContactInfo> contactInfoMap = createContactInfoMap(contactList);

        String baseUrl = Url.getOrgDomainURL().toExternalForm();

        List<Database.SaveResult> saveResults = Database.insert(timeSheetList, false);
        List<buildertek__BT_Time_Sheet__c> successTimeSheetList = new List<buildertek__BT_Time_Sheet__c>();
        List<buildertek__BT_Time_Sheet__c> errorTimeSheetList = new List<buildertek__BT_Time_Sheet__c>();

        for(Integer i = 0; i < saveResults.size(); i++) {
            if(saveResults.get(i).isSuccess()) {
                successTimeSheetList.add(timeSheetList.get(i));
            } else {
                errorTimeSheetList.add(timeSheetList.get(i));
            }
        }

        sendSuccessEmails(successTimeSheetList, contactInfoMap, baseUrl);
        sendErrorEmails(errorTimeSheetList, contactInfoMap, saveResults, baseUrl);
    }

    private static List<Contact> getContactList() {
        List<Contact> contactList = new List<Contact>();

        if (Schema.sObjectType.Contact.isAccessible()) {
            contactList = [SELECT Id, Name, buildertek__Create_Time_Sheets__c, Email FROM Contact WHERE buildertek__Create_Time_Sheets__c = true];
        }

        return contactList;
    }

    private static List<buildertek__BT_Time_Sheet__c> createTimeSheetList(List<Contact> contactList) {
        List<buildertek__BT_Time_Sheet__c> timeSheetList = new List<buildertek__BT_Time_Sheet__c>();

        for(Contact contact : contactList) {
            buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
            timeSheet.buildertek__Contact__c = contact.Id;
            timeSheet.Name = contact.Name + ' ' + Date.today().format() ;
            timeSheet.buildertek__Status__c = 'New';
            timeSheetList.add(timeSheet);
        }

        return timeSheetList;
    }

    private static Map<Id, ContactInfo> createContactInfoMap(List<Contact> contactList) {
        Map<Id, ContactInfo> contactInfoMap = new Map<Id, ContactInfo>();

        for(Contact contact : contactList) {
            ContactInfo info = new ContactInfo(contact.Email, contact.Name);
            contactInfoMap.put(contact.Id, info);
        }

        return contactInfoMap;
    }

    private static void sendSuccessEmails(List<buildertek__BT_Time_Sheet__c> successTimeSheetList, Map<Id, ContactInfo> contactInfoMap, String baseUrl) {
        if(!successTimeSheetList.isEmpty()) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            EmailTemplate tem = [SELECT Id, DeveloperName from EmailTemplate where DeveloperName  = 'TimeSheet_Created' limit 1];
            for(buildertek__BT_Time_Sheet__c timeSheet : successTimeSheetList) {
                if(contactInfoMap.containsKey(timeSheet.buildertek__Contact__c)) {
                    ContactInfo info = contactInfoMap.get(timeSheet.buildertek__Contact__c);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(new String[] {info.email});
                    mail.setTemplateId(tem.Id);
                    mail.setTargetObjectId(timeSheet.buildertek__Contact__c);
                    mail.setWhatId(timeSheet.Id);
                    mails.add(mail);
                }
            }
            Messaging.sendEmail(mails);
        }
    }

    private static void sendErrorEmails(List<buildertek__BT_Time_Sheet__c> errorTimeSheetList, Map<Id, ContactInfo> contactInfoMap, List<Database.SaveResult> saveResults, String baseUrl) {
        if(!errorTimeSheetList.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {'jaimin.s@mvclouds.com'});
            mail.setSubject('Error while creating Time Sheet records');
            mail.setHtmlBody(mail.getHtmlBody() + 'Hello Admin,<br><br>There was an error while creating Time Sheet records. Please find the details below:<br><br>');
            mail.setHtmlBody(mail.getHtmlBody() + 'Base URL: ' + baseUrl + '<br><br>');
            for(buildertek__BT_Time_Sheet__c timeSheet : errorTimeSheetList) {
                if(contactInfoMap.containsKey(timeSheet.buildertek__Contact__c)) {
                    ContactInfo info = contactInfoMap.get(timeSheet.buildertek__Contact__c);
                    mail.setHtmlBody(mail.getHtmlBody() + 'Error while creating Time Sheet record for ' + info.name + '<br>');
                    mail.setHtmlBody(mail.getHtmlBody() + 'Error Message: ' + saveResults.get(errorTimeSheetList.indexOf(timeSheet)).getErrors() + '<br><br>');
                }
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
    }

    public class ContactInfo {
        public String email;
        public String name;

        public ContactInfo(String email, String name) {
            this.email = email;
            this.name = name;
        }
    }
}