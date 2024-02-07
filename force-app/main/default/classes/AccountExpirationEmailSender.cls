public class AccountExpirationEmailSender implements Schedulable {
    private List<Account> accountList;

    public AccountExpirationEmailSender(List<Account> accounts) {
        this.accountList = accounts;
    }

    public void execute(SchedulableContext sc) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{'karan.pa@mvclouds.com'});
        email.setSubject('Notification');
        email.setPlainTextBody('This is a notification email for the following accounts:\n');
        
        for(Account acc : accountList) {
            email.setPlainTextBody(email.getPlainTextBody() + acc.Name + '\n');
        }

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }
}
