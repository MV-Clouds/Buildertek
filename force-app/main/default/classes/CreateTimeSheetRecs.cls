public without sharing class CreateTimeSheetRecs {
    public CreateTimeSheetRecs() {

    }

    @InvocableMethod(label='Create Time Sheet Records' description='Create Time Sheet Records')
    public static void createTimeSheetRecs() {
        System.debug('Inside createTimeSheetRecs');
        List<Contact> contactList = [SELECT Id, Name, buildertek__Create_Time_Sheets__c, Email FROM Contact WHERE buildertek__Create_Time_Sheets__c = true];

        List<buildertek__BT_Time_Sheet__c> timeSheetList = new List<buildertek__BT_Time_Sheet__c>();
        Map<Id, String> contactEmailMap = new Map<Id, String>();
        Map<Id, String> contactNameMap = new Map<Id, String>();

        String BaseURL = Url.getOrgDomainURL().toExternalForm();

        for(Contact contact : contactList) {
            buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
            timeSheet.buildertek__Contact__c = contact.Id;
            timeSheet.Name = contact.Name + ' ' + Date.today().format() ;
            timeSheet.buildertek__Status__c = 'New';
            timeSheetList.add(timeSheet);

            contactEmailMap.put(contact.Id, contact.Email);
            contactNameMap.put(contact.Id, contact.Name);
        }

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

        if(!successTimeSheetList.isEmpty()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            for(buildertek__BT_Time_Sheet__c timeSheet : successTimeSheetList) {
                if(contactEmailMap.containsKey(timeSheet.buildertek__Contact__c)) {
                    mail.setToAddresses(new String[] {contactEmailMap.get(timeSheet.buildertek__Contact__c)});
                    mail.setSubject('Time Sheet record created for ' + contactNameMap.get(timeSheet.buildertek__Contact__c));
                    mail.setHtmlBody('Hello ' + contactNameMap.get(timeSheet.buildertek__Contact__c) + ',<br><br>Time Sheet record created for you. here is the link to the record <a href="' + BaseURL + '/' + timeSheet.Id + '">Click here</a>');
                    mails.add(mail);
                }
            }
            Messaging.sendEmail(mails);
        }

    }
}