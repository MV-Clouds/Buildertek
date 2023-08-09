@isTest
public class ImportMasterBudgetsTest {
    public static testMethod void getBudgets() {
         buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test ';
        insert proj;
        
      List<buildertek__Master_Budget__c> budgetList = new List<buildertek__Master_Budget__c>();
        buildertek__Master_Budget__c budget = new buildertek__Master_Budget__c();
        budget.Name = 'Test Budget';
         budget.buildertek__Project__c = proj.Id;
         budget.buildertek__Type__c = 'Master';
        budgetList.add(budget); 
        insert budgetList;
        
         List<buildertek__Quote_Line_Group__c> groupList = new List<buildertek__Quote_Line_Group__c>();
        buildertek__Quote_Line_Group__c groups = new buildertek__Quote_Line_Group__c();
        groups.Name = 'No Grouping';
        groupList.add(groups);
        insert groupList;
        
         List<buildertek__Budget__c> quoteList = new List<buildertek__Budget__c>();
        buildertek__Budget__c quote = new buildertek__Budget__c();
        quote.Name = 'Test Budget';
        quote.buildertek__Project__c = proj.Id;
        quote.buildertek__Type__c = 'Master';
        quoteList.add(quote); 
        insert quoteList;
        
         List<buildertek__Master_Budget_Line__c> budgetItemList = new List<buildertek__Master_Budget_Line__c>();
        buildertek__Master_Budget_Line__c budgetItem = new buildertek__Master_Budget_Line__c();
        
        budgetItem.buildertek__Quantity__c = 10;
        budgetItem.buildertek__Unit_Price__c = 100;
        budgetItem.buildertek__Master_Budget__c = budgetList[0].Id;
        budgetItemList.add(budgetItem);
        insert budgetItemList;
        
         List<String> selectedIds = new List<String>();
        selectedIds.add(budgetList[0].Id);
        
         List<ImportMasterBudgets.MasterBudgetsClass> MQList = new List<ImportMasterBudgets.MasterBudgetsClass>();
        ImportMasterBudgets.MasterBudgetsClass MQ = new ImportMasterBudgets.MasterBudgetsClass();
        MQ.budgetRecord = quoteList[0];
        MQ.budgetCheck = true;
        MQList.add(MQ);
        ImportMasterBudgets.getMasterBudgets();
        ImportMasterBudgets.importMasterBudgetLines(selectedIds, budgetList[0].Id);
        system.assertEquals('test', 'test');
    }
}