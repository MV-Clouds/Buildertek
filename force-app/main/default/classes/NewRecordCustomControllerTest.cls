@isTest
public class NewRecordCustomControllerTest {
    @testSetup
	static void setupMethod(){
		buildertek__Project__c project = new buildertek__Project__c();
        insert project;

        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.buildertek__Project__c = project.Id;
        insert budget;
	}
    
    static testMethod void  testMethod1(){
        setupMethod();
        buildertek__Budget__c budget = [Select Id
                                        FROM buildertek__Budget__c LIMIT 1];
        buildertek__Project__c project = [Select Id
                                          FROM buildertek__Project__c LIMIT 1];
        Test.startTest();
        NewRecordCustomController.getBudgetNameFromProject(project.Id);
        NewRecordCustomController.getFieldSet('buildertek__Budget__c','buildertek__BudgetFields');
        NewRecordCustomController.getParentObjRec(budget.Id);
        NewRecordCustomController.getListViews();
        Test.stopTest();
    }
}