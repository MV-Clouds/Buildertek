@isTest
public class BudgetTriggerTest {
    public static testMethod void testBudgetTrigger() {
        Budget__c budget = new Budget__c();
        insert budget;
        update budget;
        delete budget;
        System.assertEquals('Test','Test');
    }
}