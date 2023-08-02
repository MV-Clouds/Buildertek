@isTest
private class CreateBudgetLineItemForExpenseACTest {

	private static testMethod void test() {
	     Product2 prod1 = new Product2();
        prod1.Name='test product';
        insert prod1;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        proj.buildertek__Customer__c=acc.Id;
        insert proj;
        
        
        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.Name = 'Test Budget';
        budget.buildertek__Project__c = proj.Id;
        budget.buildertek__Type__c = 'Master';
        insert budget;
        
        buildertek__Budget_Item__c budItem = new buildertek__Budget_Item__c();
        budItem.Name = 'Test Budget';
        budItem.buildertek__Budget__c = budget.Id;
        budItem.buildertek__Quantity__c = 10;
        budItem.buildertek__Unit_Price__c = 100;
        insert budItem;
        
        buildertek__Expense__c ex = new buildertek__Expense__c();
        ex.buildertek__Budget__c = budget.id;
        ex.buildertek__Budget_Line__c = budItem.id;
        ex.buildertek__Project__c = proj.id;
        ex.buildertek__Description__c = 'test';
        ex.buildertek__Amount__c = 100;
        insert ex;
        
        buildertek__Expense_To_Budget_Item_Link__c ExpnseToBudgetItemLink = new buildertek__Expense_To_Budget_Item_Link__c();
        ExpnseToBudgetItemLink.buildertek__Expense__c = ex.Id;
        ExpnseToBudgetItemLink.buildertek__Budget_Line__c = ex.buildertek__Budget_Line__c;
        insert ExpnseToBudgetItemLink;
        buildertek__Quote_Line_Group__c quotelineRec = new buildertek__Quote_Line_Group__c();
        quotelineRec.Name = 'Expense';
        insert quotelineRec;
        
        set<id> ids = new set<id>();
        ids.add(ex.id);
        list<buildertek__Expense__c> exlist = new list<buildertek__Expense__c>();
        exlist.add(ex);
        CreateBudgetLineItemForExpenseAC.getBudgets(ex.id);
        CreateBudgetLineItemForExpenseAC.createBudgetLineFromExpense(ex.id,budget.id);
        CreateBudgetLineItemForExpenseAC.createExpenseToBudgetItemLink(exlist);
        CreateBudgetLineItemForExpenseAC.RollUpExpenseAmount(ids);

	}

}