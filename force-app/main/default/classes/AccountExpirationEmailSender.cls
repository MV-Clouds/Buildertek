public class AccountExpirationEmailSender implements Schedulable {
    private static Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE Name = 'Worker License Exp' LIMIT 1].Id;
    private static Id contactId = [SELECT Id, Email FROM Contact limit 1].Id;
    private Account account;

    public AccountExpirationEmailSender(Account acc) {
        this.account = acc;
    }

    public void execute(SchedulableContext sc) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (account.buildertek__Email_Address__c != null) {
            email.setToAddresses(new List<String>{account.buildertek__Email_Address__c});
            email.setTemplateId(emailTemplateId);
            email.setWhatId(account.Id);
            email.setTargetObjectId(contactId);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
        }
    }
}
