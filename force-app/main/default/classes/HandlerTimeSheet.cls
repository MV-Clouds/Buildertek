public with sharing class HandlerTimeSheet {

    public static boolean blnSkipTimeSheetUpdateTrigger = false;

    public HandlerTimeSheet() {

    }

    public void beforeInsert(List<buildertek__BT_Time_Sheet__c> newTimeSheets) {
        String budgetLineGroupId ;
        List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Labor' LIMIT 1];
        if(budgetLineGroups.size() == 0){
            buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c();
            budgetLineGroup.Name = 'Labor';
            insert budgetLineGroup;
            budgetLineGroupId = budgetLineGroup.Id;
        }else{
            budgetLineGroupId = budgetLineGroups[0].Id;
        }
        System.debug('budgetLineGroupId: ' + budgetLineGroupId);
        List<buildertek__Budget_Item__c> toInsertBudgetItems = new List<buildertek__Budget_Item__c>();
        for (buildertek__BT_Time_Sheet__c ts : newTimeSheets) {
            if(ts.buildertek__BT_Budget__c != null && ts.buildertek__BT_Budget_Line__c == null ){
                System.debug('ts.Name: ' + ts.Name);
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.Name = ts.Name;
                budgetItem.buildertek__Budget__c = ts.buildertek__BT_Budget__c;
                budgetItem.buildertek__Group__c = budgetLineGroupId;
                toInsertBudgetItems.add(budgetItem);
            }
        }
        if(toInsertBudgetItems.size() > 0){
            insert toInsertBudgetItems;
        }

        for (buildertek__BT_Time_Sheet__c ts : newTimeSheets) {
            if(ts.buildertek__BT_Budget__c != null && ts.buildertek__BT_Budget_Line__c == null ){
                for (buildertek__Budget_Item__c bi : toInsertBudgetItems) {
                    if(bi.buildertek__Budget__c == ts.buildertek__BT_Budget__c && bi.Name == ts.Name){
                        ts.buildertek__BT_Budget_Line__c = bi.Id;
                    }
                }
            }
        }
        
    }

    
    public void afterInsert(List<buildertek__BT_Time_Sheet__c> newTimeSheets) {
        Set<Id> timeSheetIds = new Set<Id>();
        for (buildertek__BT_Time_Sheet__c ts : newTimeSheets) {
            if(ts.buildertek__BT_Budget_Line__c != null){
                timeSheetIds.add(ts.Id);
            }
        }
        TimeSheetEntryHandler.recalculateTimeSheetTotals(timeSheetIds);
    }

    public void beforeUpdate(List<buildertek__BT_Time_Sheet__c> newTimeSheets, Map<Id, buildertek__BT_Time_Sheet__c> oldTimeSheets) {

        String budgetLineGroupId ;
        List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'Labor' LIMIT 1];
        if(budgetLineGroups.size() == 0){
            buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c();
            budgetLineGroup.Name = 'Labor';
            insert budgetLineGroup;
            budgetLineGroupId = budgetLineGroup.Id;
        }else{
            budgetLineGroupId = budgetLineGroups[0].Id;
        }

        List<buildertek__Budget_Item__c> toInsertBudgetItems = new List<buildertek__Budget_Item__c>();
        for (buildertek__BT_Time_Sheet__c ts : newTimeSheets) {
            if(ts.buildertek__BT_Budget__c != null && ts.buildertek__BT_Budget_Line__c == null ){
                buildertek__BT_Time_Sheet__c oldTimeSheet = oldTimeSheets.get(ts.Id);
                if(oldTimeSheet != null && oldTimeSheet.buildertek__BT_Budget__c == null){
                    System.debug('ts.Name: ' + ts.Name);
                    buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                    budgetItem.Name = ts.Name;
                    budgetItem.buildertek__Budget__c = ts.buildertek__BT_Budget__c;
                    budgetItem.buildertek__Group__c = budgetLineGroupId;
                    toInsertBudgetItems.add(budgetItem);
                }
            }
        }
        if(toInsertBudgetItems.size() > 0){
            insert toInsertBudgetItems;
        }

        for (buildertek__BT_Time_Sheet__c ts : newTimeSheets) {
            if(ts.buildertek__BT_Budget__c != null && ts.buildertek__BT_Budget_Line__c == null ){
                for (buildertek__Budget_Item__c bi : toInsertBudgetItems) {
                    if(bi.buildertek__Budget__c == ts.buildertek__BT_Budget__c && bi.Name == ts.Name){
                        ts.buildertek__BT_Budget_Line__c = bi.Id;
                    }
                }
            }
        }

        Map<Id, buildertek__BT_Time_Sheet__c> toDeleteBudgetItems = new Map<Id, buildertek__BT_Time_Sheet__c>();
        for (buildertek__BT_Time_Sheet__c ts : newTimeSheets) {
            buildertek__BT_Time_Sheet__c oldTimeSheet = oldTimeSheets.get(ts.Id);
            if(oldTimeSheet != null && oldTimeSheet.buildertek__BT_Budget_Line__c != null && ts.buildertek__BT_Budget_Line__c != oldTimeSheet.buildertek__BT_Budget_Line__c){
                ts.buildertek__BT_Budget__c = null;
                toDeleteBudgetItems.put(oldTimeSheet.buildertek__BT_Budget_Line__c, oldTimeSheet);
            }
        }
        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetItems.keySet()];
            List<buildertek__Budget_Item__c> toDeleteBudgetLine = new List<buildertek__Budget_Item__c>();
            for (buildertek__Budget_Item__c bi : toDeleteBudgetItemsList) {
                if(bi.Name == toDeleteBudgetItems.get(bi.Id).Name){
                    toDeleteBudgetLine.add(bi);
                    toDeleteBudgetItems.remove(bi.Id);
                }
            }
            if(toDeleteBudgetLine.size() > 0 && blnSkipTimeSheetUpdateTrigger == false){
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = true;
                delete toDeleteBudgetLine;
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = false;
            }
        }
        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name,buildertek__Labor_TimeSheet__c  FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetItems.keySet()];
            for (buildertek__Budget_Item__c bi : toDeleteBudgetItemsList) {
                bi.buildertek__Labor_TimeSheet__c -= toDeleteBudgetItems.get(bi.Id).buildertek__Total_Labor_Cost__c;
            }
            update toDeleteBudgetItemsList;
        }
    }

    public void afterUpdate(List<buildertek__BT_Time_Sheet__c> newTimeSheets, Map<Id, buildertek__BT_Time_Sheet__c> oldTimeSheets) {
        Set<Id> timeSheetIds = new Set<Id>();
        for (buildertek__BT_Time_Sheet__c ts : newTimeSheets) {
            if(ts.buildertek__BT_Budget_Line__c != null){
                timeSheetIds.add(ts.Id);
            }
        }
        TimeSheetEntryHandler.recalculateTimeSheetTotals(timeSheetIds);
    }

    public void beforeDelete(List<buildertek__BT_Time_Sheet__c> oldTimeSheets) {
        //if the name of time sheet and budget line matches then delete the budget line, or else subtract the total labor cost from the budget line
        Map<Id, buildertek__BT_Time_Sheet__c> toDeleteBudgetItems = new Map<Id, buildertek__BT_Time_Sheet__c>();
        for (buildertek__BT_Time_Sheet__c ts : oldTimeSheets) {
            if(ts.buildertek__BT_Budget_Line__c != null){
                toDeleteBudgetItems.put(ts.buildertek__BT_Budget_Line__c, ts);
            }
        }
        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name,buildertek__Labor_TimeSheet__c  FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetItems.keySet()];
            List<buildertek__Budget_Item__c> toDeleteBudgetLine = new List<buildertek__Budget_Item__c>();
            for (buildertek__Budget_Item__c bi : toDeleteBudgetItemsList) {
                if(bi.Name == toDeleteBudgetItems.get(bi.Id).Name){
                    toDeleteBudgetLine.add(bi);
                    toDeleteBudgetItems.remove(bi.Id);
                }
            }
            if(toDeleteBudgetLine.size() > 0){
                delete toDeleteBudgetLine;
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name,buildertek__Labor_TimeSheet__c  FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetItems.keySet()];
            for (buildertek__Budget_Item__c bi : toDeleteBudgetItemsList) {
                bi.buildertek__Labor_TimeSheet__c -= toDeleteBudgetItems.get(bi.Id).buildertek__Total_Labor_Cost__c;
            }
            update toDeleteBudgetItemsList;
        }


    }
}