@isTest
public class CloneMasterBudgetControllerTest {
    static testmethod void testCloneMasterBudgetController(){
         buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test ';
        insert proj;
        
       /* buildertek__Master_Budget__c masterBudgetRecord = new buildertek__Master_Budget__c();
        masterBudgetRecord.Name='Test Name';
        insert masterBudgetRecord;
        System.assert(masterBudgetRecord.Id!=null);*/
         List<buildertek__Master_Budget__c> budgetList = new List<buildertek__Master_Budget__c>();
        buildertek__Master_Budget__c budget = new buildertek__Master_Budget__c();
        budget.Name = 'Test Budget';
         budget.buildertek__Project__c = proj.Id;
         budget.buildertek__Type__c = 'Master';
        budgetList.add(budget); 
        insert budgetList;
        
        List<buildertek__Master_Budget_Line__c> masterBudgetLines = new List<buildertek__Master_Budget_Line__c>();
        buildertek__Master_Budget_Line__c masterBudgetLine = new buildertek__Master_Budget_Line__c(); 
        masterBudgetLine.buildertek__Master_Budget__c=budgetList[0].Id;
        masterBudgetLine.buildertek__Amount_In__c=10; 
        masterBudgetLines.add(masterBudgetLine);
        insert masterBudgetLines;
        
        List<String> selectedIds = new List<String>();
        selectedIds.add(budgetList[0].Id);
        
        System.debug('Clone Rec :: '+masterBudgetLines.deepclone());
        CloneMasterBudgetController.saveMasterBudget( budget, masterBudgetLines);
        CloneMasterBudgetController.getMasterData(budgetList[0].Id);
    }
}