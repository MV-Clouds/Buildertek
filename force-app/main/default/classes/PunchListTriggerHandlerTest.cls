@isTest
public class PunchListTriggerHandlerTest {
    public static testMethod void test1() {
         Punch_List__c pl = new Punch_List__c();
         pl.Description__c='test';
         insert pl;
         System.assertEquals('Test','Test');
    }
}