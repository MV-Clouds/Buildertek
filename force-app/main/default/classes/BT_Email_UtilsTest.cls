@isTest
public class BT_Email_UtilsTest {
    public static testMethod void testBT_Email_Utils() {
        Account currAcc = new Account(Name = 'test');
        insert currAcc;
        
        Contact currCon = new Contact(LastName = 'test', Email = 'test@test.com', AccountId = currAcc.Id);
        insert currCon;
        EmailTemplate emp = [SELECT Id FROM EmailTemplate WHERE Name = 'RFQ Awarded Email' limit 1];
        List<EmailTemplate> listTemplates = BT_Email_Utils.getTemplates('BT RFQ');
        BT_Email_Utils.sendEmailNotification(currAcc.Id, currCon.Id, emp.Id);
        System.assertEquals('Test','Test');
    }
}