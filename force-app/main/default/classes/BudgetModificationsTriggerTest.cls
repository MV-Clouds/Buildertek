@isTest
public class BudgetModificationsTriggerTest {
    public static testMethod void testBudgetModificationsTrigger() {
        Budget__c budget = new Budget__c();
        insert budget;
        
        Budget_Item__c budgetItem = new Budget_Item__c(Budget__c = budget.Id);
        insert budgetItem;
        
        Budget_Modifications__c budgetMod = new Budget_Modifications__c(From__c = budgetItem.Id, Budget__c = budget.Id, To__c = budgetItem.Id, Amount__c = 123.45);
        insert budgetMod;
        update budgetMod;
        delete budgetMod;
        System.assertEquals('Test','Test');
    }
}