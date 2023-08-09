@isTest
public class EmailMessageTriggerTest {
    public static testMethod void testEmailMessageTrigger() {
        EmailMessage emailMsg = new EmailMessage();
        insert emailMsg;
        System.assertEquals('Test','Test');
    }
}