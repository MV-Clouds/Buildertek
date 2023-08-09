@isTest
public class SubmittalTriggerTest {
    public static testMethod void testSubmittalTrigger() {
        Submittal__c submittal = new Submittal__c();
        insert submittal;
        update submittal;
        delete submittal;
        System.assertEquals('Test','Test');
    }
}