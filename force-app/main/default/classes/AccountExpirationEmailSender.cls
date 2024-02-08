public class AccountExpirationEmailSender implements Schedulable {
    private static Map<String, Id> emailTemplateIds;

    static {
        emailTemplateIds = new Map<String, Id>();
        for (EmailTemplate template : [SELECT Id, Name FROM EmailTemplate WHERE Name IN ('Worker License Exp', 'Liability License Exp')]) {
            emailTemplateIds.put(template.Name, template.Id);
        }
    }

    private static Id contactId;

    static {
        contactId = [SELECT Id, Email FROM Contact LIMIT 1].Id;
    }

    private Account account;
    private String licenseType;

    public AccountExpirationEmailSender(Account acc, String licenseType) {
        this.account = acc;
        this.licenseType = licenseType;
    }

    public void execute(SchedulableContext sc) {
        if (account.buildertek__Email_Address__c != null && emailTemplateIds.containsKey(licenseType)) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{account.buildertek__Email_Address__c});
            email.setTemplateId(emailTemplateIds.get(licenseType));
            email.setWhatId(account.Id);
            email.setTargetObjectId(contactId);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
}