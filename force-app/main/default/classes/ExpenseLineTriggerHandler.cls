public with sharing class ExpenseLineTriggerHandler {

    public void onAfterInsert(List<buildertek__Expense_Line__c> newExpenseLineList) {
        try {
            Set<Id> ExpenseIds = new Set<Id>();
            for (buildertek__Expense_Line__c expenseLine : newExpenseLineList) {
                if(expenseLine.buildertek__BT_Expense__c != null) {
                    ExpenseIds.add(expenseLine.buildertek__BT_Expense__c);
                }
            }
            updateAmountOnExpense(ExpenseIds);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
    
    public void onAfterUpdate(List<buildertek__Expense_Line__c> newExpenseLineList, Map<Id, buildertek__Expense_Line__c> oldExpenseLineMap) {
        try {
            Set<Id> expenseIdsToUpdate = new Set<Id>();
    
            for (buildertek__Expense_Line__c expenseLine : newExpenseLineList) {
                buildertek__Expense_Line__c oldExpenseLine = oldExpenseLineMap.get(expenseLine.Id);
    
                if (expenseLine.buildertek__BT_Expense__c != oldExpenseLine.buildertek__BT_Expense__c ||
                    expenseLine.buildertek__Total__c != oldExpenseLine.buildertek__Total__c) {
                        if(oldExpenseLine.buildertek__BT_Expense__c != null){
                            expenseIdsToUpdate.add(oldExpenseLine.buildertek__BT_Expense__c);
                        }
                        
                        if(expenseLine.buildertek__BT_Expense__c != null){
                            expenseIdsToUpdate.add(expenseLine.buildertek__BT_Expense__c);
                        }
                }
            }
    
            if (!expenseIdsToUpdate.isEmpty()) {
                updateAmountOnExpense(expenseIdsToUpdate);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
    
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }    

    public void onAfterDelete(List<buildertek__Expense_Line__c> oldExpenseLineList) {
        try {
            Set<Id> ExpenseIds = new Set<Id>();
            for (buildertek__Expense_Line__c expenseLine : oldExpenseLineList) {
                if(expenseLine.buildertek__BT_Expense__c != null){
                    ExpenseIds.add(expenseLine.buildertek__BT_Expense__c);
                }
            }
            updateAmountOnExpense(ExpenseIds);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public void updateAmountOnExpense(Set<Id> ExpenseIds) {
        try {
            Map<Id, AggregateResult> totalAmountMap = new Map<Id, AggregateResult>();
            for (AggregateResult aggregatedResult : [SELECT buildertek__BT_Expense__c, SUM(buildertek__Total__c) totalAmount FROM buildertek__Expense_Line__c WHERE buildertek__BT_Expense__c IN :ExpenseIds GROUP BY buildertek__BT_Expense__c]){
                Id ExpenseId = (Id)aggregatedResult.get('buildertek__BT_Expense__c');
                totalAmountMap.put(ExpenseId, aggregatedResult);
            }
            
            List<buildertek__Expense__c> expenseToUpdate = new List<buildertek__Expense__c>();
            
            for (Id expenseId :ExpenseIds) {
                if(totalAmountMap.containsKey(expenseId)) {
                    AggregateResult aggregatedResult = totalAmountMap.get(expenseId);
                    Decimal totalAmount = (Decimal)aggregatedResult.get('totalAmount');

                    buildertek__Expense__c expense = new buildertek__Expense__c(Id = expenseId);
                    expense.buildertek__Amount__c = totalAmount;
                    expenseToUpdate.add(expense);
                } else {
                    buildertek__Expense__c expense = new buildertek__Expense__c(Id = expenseId);
                    expense.buildertek__Amount__c = 0;
                    expenseToUpdate.add(expense);
                }
            }
            System.debug('expenseToUpdate: ' + expenseToUpdate);
            if (!expenseToUpdate.isEmpty()) {
                update expenseToUpdate;
            }

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

}