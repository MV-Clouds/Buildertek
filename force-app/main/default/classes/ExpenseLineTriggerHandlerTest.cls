@isTest
public class ExpenseLineTriggerHandlerTest {

    @isTest
    static void testOnAfterInsert() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        buildertek__Project__c proj1 = new buildertek__Project__c();
        proj1.Name = 'Test Project';
        proj1.buildertek__Customer__c=acc.Id;
        insert proj1;

        buildertek__Expense__c exp = new buildertek__Expense__c();
        exp.buildertek__Description__c = 'test';
        exp.buildertek__Project__c = proj1.Id;
        insert exp;

        List<buildertek__Expense_Line__c> newExpenseLineList = new List<buildertek__Expense_Line__c>{
            new buildertek__Expense_Line__c(
                buildertek__Product_Description__c = 'Test ExpenseLine',
                buildertek__Quantity__c = 5,
                buildertek__Price__c = 100,
                buildertek__BT_Expense__c = exp.id
            )
        };

        Test.startTest();
        new ExpenseLineTriggerHandler().onAfterInsert(newExpenseLineList);
        Test.stopTest();

    }

    @isTest
    static void testOnAfterUpdate() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        buildertek__Project__c proj1 = new buildertek__Project__c();
        proj1.Name = 'Test Project';
        proj1.buildertek__Customer__c=acc.Id;
        insert proj1;

        buildertek__Expense__c exp = new buildertek__Expense__c();
        exp.buildertek__Description__c = 'test';
        exp.buildertek__Project__c = proj1.Id;
        insert exp;

        buildertek__Expense__c exp1 = new buildertek__Expense__c();
        exp1.buildertek__Description__c = 'test 1';
        exp1.buildertek__Project__c = proj1.Id;
        insert exp1;

        buildertek__Expense_Line__c oldExpenseLine = new buildertek__Expense_Line__c(
            buildertek__Product_Description__c = 'Test ExpenseLine',
            buildertek__Quantity__c = 5,
            buildertek__Price__c = 100,
            buildertek__BT_Expense__c = exp.Id
        );
        insert oldExpenseLine;

        List<buildertek__Expense_Line__c> newExpenseLineList = new List<buildertek__Expense_Line__c>{
            new buildertek__Expense_Line__c(
                Id = oldExpenseLine.Id,
                buildertek__Product_Description__c = 'Test ExpenseLine Updated',
                buildertek__Quantity__c = 8,
                buildertek__Price__c = 120,
                buildertek__BT_Expense__c = exp1.Id
            )
        };

        Map<Id, buildertek__Expense_Line__c> oldExpenseLineMap = new Map<Id, buildertek__Expense_Line__c>{
            oldExpenseLine.Id => oldExpenseLine
        };

        Test.startTest();
        new ExpenseLineTriggerHandler().onAfterUpdate(newExpenseLineList, oldExpenseLineMap);
        Test.stopTest();

    }

    @isTest
    static void testOnAfterDelete() {
        
        buildertek__Expense_Line__c oldExpenseLine = new buildertek__Expense_Line__c(
            buildertek__Product_Description__c = 'Test ExpenseLine',
            buildertek__Quantity__c = 5,
            buildertek__Price__c = 100
        );
        insert oldExpenseLine;

        List<buildertek__Expense_Line__c> oldExpenseLineList = new List<buildertek__Expense_Line__c>{
            oldExpenseLine
        };

        Test.startTest();
        new ExpenseLineTriggerHandler().onAfterDelete(oldExpenseLineList);
        Test.stopTest();

    }

    @isTest
    static void testUpdateAmountOnExpense() {
        buildertek__Expense_Line__c expenseLine = new buildertek__Expense_Line__c(
            buildertek__Product_Description__c = 'Test ExpenseLine',
            buildertek__Quantity__c = 5,
            buildertek__Price__c = 100
        );
        insert expenseLine;

        Set<Id> expenseIds = new Set<Id>{expenseLine.buildertek__BT_Expense__c};

        Test.startTest();
        new ExpenseLineTriggerHandler().updateAmountOnExpense(expenseIds);
        Test.stopTest();

    }
}