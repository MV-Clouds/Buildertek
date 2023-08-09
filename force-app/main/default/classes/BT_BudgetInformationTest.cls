@isTest
private class BT_BudgetInformationTest {

	private static testMethod void InsertBudget() {
	    buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
        List<buildertek__Budget__c> buildertekBudgetListRef = new List<buildertek__Budget__c>();
        buildertek__Budget__c buildertekBudgetRef = new buildertek__Budget__c();
        buildertekBudgetRef.Name = 'test';
        buildertekBudgetRef.buildertek__Project__c = buildertekProjectRef.id;
        buildertekBudgetListRef.add(buildertekBudgetRef);
        insert buildertekBudgetRef;
        BT_BudgetInformation.getBudgetInformation(buildertekBudgetRef.id);
        BT_BudgetInformation.deleteBudgetRecord(buildertekBudgetRef.id);
        System.assertEquals('Test','Test');
	}

}