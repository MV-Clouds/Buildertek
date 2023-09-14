public class ExpenseToBudgetItemTriggerHandler {

    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipExpenseUpdateTrigger = false;

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public ExpenseToBudgetItemTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }


    public void OnBeforeInsert(buildertek__Expense__c[] newExpenseList, Map<Id, buildertek__Expense__c> newExpenseMap) {
        Map<Id, buildertek__Budget_Item__c> newBudgetItemMap = new Map<Id, buildertek__Budget_Item__c>();

        for (buildertek__Expense__c expense : newExpenseList) {
            if(expense.buildertek__Budget__c != null && expense.buildertek__Budget_Line__c == null){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.buildertek__Budget__c = expense.buildertek__Budget__c;
                budgetItem.Name = expense.buildertek__Description__c;
                budgetItem.buildertek__Quantity__c = 1;
                budgetItem.buildertek__UOM__c = 'Each';
                budgetItem.buildertek__Cost_Code__c = expense.buildertek__Cost_Code__c;
                budgetItem.buildertek__Contractor__c = expense.buildertek__Vendor__c;
                newBudgetItemMap.put(expense.Id, budgetItem);
            }
        }

        if (newBudgetItemMap.size() > 0) {
            List<buildertek__Budget_Line_Group__c>  budgetlinegroup =[SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Expense'];
            String groupId = '';
            if (budgetlinegroup.size() > 0) {
                groupId = budgetlinegroup[0].Id;
            } else {
                buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
                budgetGroup.Name = 'Expense';
                insert budgetGroup;

                groupId = budgetGroup.Id;
            }

            for (Id expenseId : newBudgetItemMap.keySet()) {
                buildertek__Budget_Item__c budgetItem = newBudgetItemMap.get(expenseId);
                budgetItem.buildertek__Group__c = groupId;
            }
            insert newBudgetItemMap.Values();

            List<buildertek__Expense__c> newBudgetExpenseList = new List<buildertek__Expense__c>();
            for (Id expenseId : newBudgetItemMap.keySet()) {
                for (buildertek__Expense__c expense : newExpenseList){
                    if (expense.Id == expenseId) {
                        expense.buildertek__Budget_Line__c = newBudgetItemMap.get(expenseId).Id;
                    }
                }
            }
        }

    }

    public void OnAfterInsert(buildertek__Expense__c[] newExpense, Map<ID, buildertek__Expense__c> newExpenseMap){
        list<Id> expenseids = new list<Id>();
        list<Id> expenseprojectids = new list<Id>();
        list<Id> projectids = new list<Id>();
        list<Id> expids = new list<Id>();
        // Create Expense to Budget Item link
       CreateBudgetLineItemForExpenseAC.createExpenseToBudgetItemLink(newExpense);
       CreateBudgetLineItemForExpenseAC.RollUpExpenseAmount(newExpenseMap.KeySet());
    }
    public void AfterInsert(buildertek__Expense__c[] newExpense, Map<ID, buildertek__Expense__c> newExpenseMap){
        list<Id> expenseids = new list<Id>();
        list<Id> expenseprojectids = new list<Id>();
        list<Id> projectids = new list<Id>();
        list<Id> expids = new list<Id>();
        // Create Expense to Budget Item link
        string BudgetId = '';
       list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                  buildertek__Automatically_add_Expense_to_Budget__c
                                                                                                  from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                  WHERE Name=:'Budget Configuration' and buildertek__Automatically_add_Expense_to_Budget__c !=false limit 1];
        if(adminInterfaceNodeConfigurations.size()>0 ){
            if(adminInterfaceNodeConfigurations[0].buildertek__Automatically_add_Expense_to_Budget__c == true){
                for(buildertek__Expense__c exprec : newExpense){
                    if(exprec.buildertek__Budget__c != null){
                          BudgetId  = exprec.buildertek__Budget__c;
                        CreateBudgetLineItemForExpenseAC.createBudgetLineFromExpense(exprec.id,BudgetId);
                    }else if(exprec.buildertek__Budget__c == null && exprec.buildertek__Project__c != null){
                        expenseprojectids.add(exprec.buildertek__Project__c);
                        expenseids.add(exprec.id);
                    }else if(exprec.buildertek__Budget__c == null && exprec.buildertek__Project__c == null){
                        expids.add(exprec.id);
                    }
                }
                if(expenseprojectids.size()>0){
                  /*  list<buildertek__Project__c> projlist = [select id,Name from buildertek__Project__c where id IN:expenseprojectids];
                    for(buildertek__Project__c projRec : projlist){
                        projectids.add(projRec.id);
                    }
                    system.debug('projectids'+projectids); */
                    list<buildertek__Budget__c> budgetist = [select id,Name from buildertek__Budget__c where buildertek__Project__c =: expenseprojectids ORDER BY Name ASC limit 1];
                   // system.debug('budgetlist'+budgetist);
                    list<buildertek__Expense__c> expList = [select id,Name from buildertek__Expense__c Where ID IN: expenseids];
                    for(buildertek__Budget__c budgetRec : budgetist){
                        for(buildertek__Expense__c exp : expList){
                            BudgetId  = budgetRec.id;
                            CreateBudgetLineItemForExpenseAC.createBudgetLineFromExpense(exp.id,BudgetId);
                        }
                    }
                }
                if(expids.size()>0){
                    list<buildertek__Budget__c> budgetist = [select id,Name from buildertek__Budget__c ORDER BY CreatedDate ASC limit 1];
                    list<buildertek__Expense__c> expList = [select id,Name from buildertek__Expense__c Where Id IN: expids];
                    for(buildertek__Expense__c exp : expList){
                        for(buildertek__Budget__c budgetRec : budgetist){
                            BudgetId  = budgetRec.id;
                            CreateBudgetLineItemForExpenseAC.createBudgetLineFromExpense(exp.id,BudgetId);
                        }
                    }
                }
            }
        }
    }

    // Create by Krunal
    public void OnBeforeUpdate(buildertek__Expense__c[] newExpenseList, Map<Id, buildertek__Expense__c> newExpenseMap, Map<Id, buildertek__Expense__c> oldExpenseMap){
        // If user change budget and expense is not linked with any budget line then it's create nee budget line under that budget
        Map<Id, buildertek__Budget_Item__c> newBudgetItemMap = new Map<Id, buildertek__Budget_Item__c>();
        for (buildertek__Expense__c expense : newExpenseList) {
            if(expense.buildertek__Status__c != oldExpenseMap.get(expense.Id).buildertek__Status__c && expense.buildertek__Status__c == 'Posted' && expense.buildertek__Budget__c != oldExpenseMap.get(expense.Id).buildertek__Budget__c) {
                expense.addError('You cannot change the status to Posted and update the Budget/Project of expense at the same time.');

            }
            if(oldExpenseMap.get(expense.Id).buildertek__Date_Posted__c !=null && expense.buildertek__Date_Posted__c!= null){
                expense.addError('You cannot update this Expense.  If you would like to update this Expense, please remove the date posted value  first.');

            }

            if(oldExpenseMap.get(expense.Id).buildertek__Budget__c != expense.buildertek__Budget__c && expense.buildertek__Budget__c != null && expense.buildertek__Budget_Line__c == null){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.buildertek__Budget__c = expense.buildertek__Budget__c;
                budgetItem.Name = expense.buildertek__Description__c;
                budgetItem.buildertek__Quantity__c = 1;
                budgetItem.buildertek__UOM__c = 'Each';
                budgetItem.buildertek__Cost_Code__c = expense.buildertek__Cost_Code__c;
                budgetItem.buildertek__Contractor__c = expense.buildertek__Vendor__c;
                newBudgetItemMap.put(expense.Id, budgetItem);
            }
        }

         // create new budget line record under budget when we change budget on expense
         if (newBudgetItemMap.size() > 0) {
            List<buildertek__Budget_Line_Group__c>  budgetlinegroup =[SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Expense'];
            String groupId = '';
            if (budgetlinegroup.size() > 0) {
                groupId = budgetlinegroup[0].Id;
            } else {
                buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
                budgetGroup.Name = 'Expense';
                insert budgetGroup;

                groupId = budgetGroup.Id;
            }

            for (Id expenseId : newBudgetItemMap.keySet()) {
                buildertek__Budget_Item__c budgetItem = newBudgetItemMap.get(expenseId);
                budgetItem.buildertek__Group__c = groupId;
            }
            insert newBudgetItemMap.Values();

            List<buildertek__Expense__c> newBudgetExpenseList = new List<buildertek__Expense__c>();
            for (Id expenseId : newBudgetItemMap.keySet()) {
                for (buildertek__Expense__c expense : newExpenseList){
                    if (expense.Id == expenseId) {
                        expense.buildertek__Budget_Line__c = newBudgetItemMap.get(expenseId).Id;
                    }
                }
            }
        }

    }

    // Create by Krunal
    public void OnAfterUpdate(buildertek__Expense__c[] newExpenseList, Map<Id, buildertek__Expense__c> newExpenseMap, Map<Id, buildertek__Expense__c> oldExpenseMap){
        List<buildertek__Expense_To_Budget_Item_Link__c> expenseLinkList = [SELECT Id, Name, buildertek__Expense__c, buildertek__Budget_Line__c, Auto_Roll_Up__c FROM buildertek__Expense_To_Budget_Item_Link__c WHERE buildertek__Expense__c IN: oldExpenseMap.KeySet()];
        Map<Id, buildertek__Expense_To_Budget_Item_Link__c> expenseLinkMap = new Map<Id, buildertek__Expense_To_Budget_Item_Link__c>();

        for (buildertek__Expense_To_Budget_Item_Link__c expenseLink : expenseLinkList) {
            expenseLinkMap.put(expenseLink.buildertek__Expense__c, expenseLink);
            // update roll up field for execute work flow and update expense cost data on budget line
            expenseLink.Auto_Roll_Up__c = true;
        }

        List<buildertek__Expense__c> createExpenseList = new List<buildertek__Expense__c>();
        List<buildertek__Expense_To_Budget_Item_Link__c> deleteExpenseLinkList = new List<buildertek__Expense_To_Budget_Item_Link__c>();

        List<Id> deleteBudgetLineIdList = new List<Id>();

        for (buildertek__Expense__c expense : newExpenseList) {
            // get expense list for create new junction object
            if (expenseLinkMap.get(expense.Id) == null && expense.buildertek__Budget_Line__c != null) {
                createExpenseList.add(expense);
            }

            // when we change budget line on expense at that time we need to delete old junction object so create junction object list for delete old record
            if(oldExpenseMap.get(expense.Id).buildertek__Budget_Line__c != expense.buildertek__Budget_Line__c){
                if (expenseLinkMap.get(expense.Id) != null) {
                    if (expenseLinkMap.get(expense.Id).buildertek__Budget_Line__c == oldExpenseMap.get(expense.Id).buildertek__Budget_Line__c) {
                        deleteExpenseLinkList.add(expenseLinkMap.get(expense.Id));
                    }
                }
            }

            // if user remove budget line from the expense and that budget line is auto created from code then we need to delete that budget line record
            if(oldExpenseMap.get(expense.Id).buildertek__Budget_Line__c != null && expense.buildertek__Budget_Line__c == null){
                deleteBudgetLineIdList.add(oldExpenseMap.get(expense.Id).buildertek__Budget_Line__c);
            }

        }

        // update roll up field for execute work flow and update expense cost data on budget line
        if (expenseLinkList.size() > 0) {
            update expenseLinkList;
        }

        // delete old junction object list
        if(deleteExpenseLinkList.size () > 0){
            delete deleteExpenseLinkList;
        }

        // create new junction object record
        if (createExpenseList.size() > 0) {
            CreateBudgetLineItemForExpenseAC.createExpenseToBudgetItemLink(createExpenseList);
        }

        // if user remove budget line from the expense and that budget line is auto created from code then we need to delete that budget line record
        if (!blnSkipExpenseUpdateTrigger && deleteBudgetLineIdList.size() > 0) {
            List<buildertek__Budget_Item__c> budgetLineList = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN: deleteBudgetLineIdList];
            List<buildertek__Budget_Item__c> deleteBudgetLineList = new List<buildertek__Budget_Item__c>();

            for (buildertek__Budget_Item__c budgetLine : budgetLineList) {
                for (Id expenseId : oldExpenseMap.keySet()) {
                    if (oldExpenseMap.get(expenseId).buildertek__Budget_Line__c == budgetLine.Id && newExpenseMap.get(expenseId).buildertek__Description__c == budgetLine.Name) {
                        deleteBudgetLineList.add(budgetLine);
                    }
                }
            }
            if (deleteBudgetLineList.size() > 0) {
                delete deleteBudgetLineList;
            }
        }

        // Just remove etra budget from expense
        List<buildertek__Expense__c> newUpdatedExpenses = [SELECT Id, Name, buildertek__Budget__c, buildertek__Budget_Line__c FROM buildertek__Expense__c WHERE Id IN: newExpenseMap.keySet() AND buildertek__Budget__c != null AND buildertek__Budget_Line__c = null];
        List<buildertek__Expense__c> newUpdatedExpenseList = new List<buildertek__Expense__c>();
        for (buildertek__Expense__c expense : newUpdatedExpenses) {
            if (oldExpenseMap.get(expense.Id).buildertek__Budget_Line__c != null) {
                expense.buildertek__Budget__c = null;
                newUpdatedExpenseList.add(expense);
            }
        }
        if (newUpdatedExpenseList.size() > 0) {
            update newUpdatedExpenseList;
        }

    }

    public void OnBeforeDelete(buildertek__Expense__c[] oldExpense, Map<Id, buildertek__Expense__c> oldExpenseMap){
        System.debug('oldExpense-->>'+oldExpense);
        for(buildertek__Expense__c exp:oldExpense){
            System.debug('In For Loop');
            if(exp.buildertek__Finance_Transaction__c != null){
                exp.addError('You cannot delete this Expense because it is related to a Finance Transaction record. Please delete the Finance Transaction record first, then try again.');
            }
        }
    }
}