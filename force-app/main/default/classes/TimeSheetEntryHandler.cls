public with sharing class TimeSheetEntryHandler {

    public static boolean isExecuting = false;

    public TimeSheetEntryHandler() {

    }

    public void afterInsert(List<buildertek__BT_Time_Sheet_Entry__c> newTimeSheetEntries) {
        Set<Id> timeSheetIds = new Set<Id>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            timeSheetIds.add(tse.buildertek__BT_Time_Sheet__c);
        }
        recalculateTimeSheetTotals(timeSheetIds);
    }

    public void afterUpdate(List<buildertek__BT_Time_Sheet_Entry__c> newTimeSheetEntries , List<buildertek__BT_Time_Sheet_Entry__c>  oldTimeSheetEntries) {
        Set<Id> timeSheetIds = new Set<Id>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            timeSheetIds.add(tse.buildertek__BT_Time_Sheet__c);
        }
        recalculateTimeSheetTotals(timeSheetIds);   
    }

    public static void recalculateTimeSheetTotals(Set<Id> timeSheetIds) {

        System.debug('timeSheetIds from recalculateTimeSheetTotals: ' + timeSheetIds);
        
        //query all the time sheet 
        List<buildertek__BT_Time_Sheet__c> timeSheets = [SELECT Id, buildertek__BT_Budget__c, buildertek__BT_Budget_Line__c from buildertek__BT_Time_Sheet__c WHERE Id IN :timeSheetIds];

        //create a set of all budget line ids
        Set<Id> budgetLineIds = new Set<Id>();
        for (buildertek__BT_Time_Sheet__c ts : timeSheets) {
            if (ts.buildertek__BT_Budget_Line__c != null){
                budgetLineIds.add(ts.buildertek__BT_Budget_Line__c);
            }
        }

        //query all the timesheet entries whose parent time sheet has budget line in the set
        List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntries = [SELECT Id, buildertek__BT_Time_Sheet__c, buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c, buildertek__BT_Time_Sheet__r.buildertek__Billable_Rate__c,  buildertek__Duration__c from buildertek__BT_Time_Sheet_Entry__c WHERE buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c IN :budgetLineIds];

        //make a map where budget line id is the key and the time sheet entries are the values
        Map<Id, List<buildertek__BT_Time_Sheet_Entry__c>> budgetLineToTimeSheetEntries = new Map<Id, List<buildertek__BT_Time_Sheet_Entry__c>>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : timeSheetEntries) {
            if (!budgetLineToTimeSheetEntries.containsKey(tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c)) {
                budgetLineToTimeSheetEntries.put(tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c, new List<buildertek__BT_Time_Sheet_Entry__c>());
            }
            budgetLineToTimeSheetEntries.get(tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c).add(tse);
        }

        //iterate over the map and calculate the total amount for each budget line that is buildertek__BT_Time_Sheet__r.buildertek__Billable_Rate__c * buildertek__Duration__c
        List<buildertek__Budget_Item__c> budgetItemsToUpdate = new List<buildertek__Budget_Item__c>();
        for (Id budgetLineId : budgetLineToTimeSheetEntries.keySet()) {
            List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntriesForBudgetLine = budgetLineToTimeSheetEntries.get(budgetLineId);
            Decimal totalAmount = 0;
            for (buildertek__BT_Time_Sheet_Entry__c tse : timeSheetEntriesForBudgetLine) {
                totalAmount += tse.buildertek__BT_Time_Sheet__r.buildertek__Billable_Rate__c * tse.buildertek__Duration__c;
            }
            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
            budgetItem.Id = budgetLineId;
            budgetItem.buildertek__Labor_TimeSheet__c = totalAmount;
            budgetItemsToUpdate.add(budgetItem);
        }

        if (!budgetItemsToUpdate.isEmpty()) {
            update budgetItemsToUpdate;
        }
        
    }

    //onBeforeInsert
    public void onBeforeInsert(List<buildertek__BT_Time_Sheet_Entry__c> newTimeSheetEntries) {

        //create a set of contact ids from the newTimeSheetEntries
        Set<Id> contactIds = new Set<Id>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            contactIds.add(tse.buildertek__Contact__c);
        }

        //query all the contacts
        List<Contact> contacts = [SELECT Id, Name, buildertek__Hourly_Rate__c FROM Contact WHERE Id IN :contactIds];

        //create a map where contact id is the key and the hourly rate is the value
        Map<Id, Decimal> contactToHourlyRate = new Map<Id, Decimal>();
        for (Contact c : contacts) {
            contactToHourlyRate.put(c.Id, c.buildertek__Hourly_Rate__c);
        }

        //iterate through the new timesheet entries and set the buildertek__Billable_RateManual__c to the hourly rate of the contact
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            if (contactToHourlyRate.containsKey(tse.buildertek__BT_Time_Sheet__r.buildertek__Contact__c)) {
                tse.buildertek__Billable_RateManual__c = contactToHourlyRate.get(tse.buildertek__Contact__c);
            }
        }
        
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
        //iterate over the new list and check if the budget is not null and if the budget line is null, create a new budget line
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            if (tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c == null && tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget__c != null) {
                buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
                budgetLine.Name = tse.Name ;
                budgetLine.buildertek__Budget__c = tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget__c;
                budgetLine.buildertek__Group__c = budgetLineGroupId;
                toInsertBudgetItems.add(budgetLine);
            }
        }

        if (!toInsertBudgetItems.isEmpty()) {
            insert toInsertBudgetItems;
        }

        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            if (tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c == null) {
                for (buildertek__Budget_Item__c budgetLine : toInsertBudgetItems) {
                    if (budgetLine.buildertek__Budget__c == tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget__c && budgetLine.Name == tse.Name) {
                        tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c = budgetLine.Id;
                    }
                }
            }
        }
    }

    //onBeforeUpdate
    public void onBeforeUpdate(List<buildertek__BT_Time_Sheet_Entry__c> newTimeSheetEntries , Map<Id,buildertek__BT_Time_Sheet_Entry__c>  oldTimeSheetEntries) {
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
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            if(tse.buildertek__BT_Budget_Line__c == null && tse.buildertek__BT_Budget__c != null){
                buildertek__BT_Time_Sheet_Entry__c oldTSE = oldTimeSheetEntries.get(tse.Id);
                if(oldTSE == null || oldTSE.buildertek__BT_Budget__c == null){
                    buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
                    budgetLine.Name = tse.Name ;
                    budgetLine.buildertek__Budget__c = tse.buildertek__BT_Budget__c;
                    budgetLine.buildertek__Group__c = budgetLineGroupId;
                    toInsertBudgetItems.add(budgetLine);
                }
            }
        }

        if (!toInsertBudgetItems.isEmpty()) {
            insert toInsertBudgetItems;
        }

        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            if (tse.buildertek__BT_Budget_Line__c == null) {
                for (buildertek__Budget_Item__c budgetLine : toInsertBudgetItems) {
                    if (budgetLine.buildertek__Budget__c == tse.buildertek__BT_Budget__c && budgetLine.Name == tse.Name) {
                        tse.buildertek__BT_Budget_Line__c = budgetLine.Id;
                    }
                }
            }
        }

        Map<Id, buildertek__BT_Time_Sheet_Entry__c> toDeleteBudgetLine = new Map<Id, buildertek__BT_Time_Sheet_Entry__c>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            if(tse.buildertek__BT_Budget_Line__c == null ){
                buildertek__BT_Time_Sheet_Entry__c oldTSE = oldTimeSheetEntries.get(tse.Id);
                if(oldTSE == null || oldTSE.buildertek__BT_Budget_Line__c != null){
                    tse.buildertek__BT_Budget__c = null;
                    buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
                    budgetLine.Id = tse.buildertek__BT_Budget_Line__c;
                    toDeleteBudgetLine.put(oldTSE.buildertek__BT_Budget_Line__c, tse);
                }
            }
        }

        //iterate over map and debug the key and value
        for (Id key : toDeleteBudgetLine.keySet()) {
            System.debug('key: ' + key + ' value: ' + toDeleteBudgetLine.get(key));
        }

        if (!toDeleteBudgetLine.isEmpty()) {
            List<buildertek__Budget_Item__c> toDeleteBudgetLineList = new List<buildertek__Budget_Item__c>();
            List<buildertek__Budget_Item__c> toUpdateBudgetLineList = new List<buildertek__Budget_Item__c>();

            List<buildertek__Budget_Item__c> budgetItems = [SELECT Id, Name, buildertek__Budget__c, buildertek__Budget_Line_Group__c, buildertek__Labor_TimeSheet__c FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetLine.keySet()];

            System.debug('budgetItems: ' + budgetItems);

            //if the name of the budget line is the same as the time sheet entry name, delete the budget line
            for (buildertek__Budget_Item__c budgetLine : budgetItems) {
                if (budgetLine.Name == toDeleteBudgetLine.get(budgetLine.Id).Name) {
                    toDeleteBudgetLineList.add(budgetLine);
                }else{
                    //subtract the amount from the budget line
                    buildertek__Budget_Item__c budgetLineToUpdate = new buildertek__Budget_Item__c();
                    budgetLineToUpdate.Id = budgetLine.Id;
                    budgetLineToUpdate.buildertek__Labor_TimeSheet__c = budgetLine.buildertek__Labor_TimeSheet__c - (toDeleteBudgetLine.get(budgetLine.Id).buildertek__Billable_Rate__c * toDeleteBudgetLine.get(budgetLine.Id).buildertek__Duration__c);
                    toUpdateBudgetLineList.add(budgetLineToUpdate);
                }
            }

            if (!toDeleteBudgetLineList.isEmpty() && isExecuting == false) {
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = true;
                delete toDeleteBudgetLineList;
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = false;
            }

            if (!toUpdateBudgetLineList.isEmpty()) {
                update toUpdateBudgetLineList;
            }
        }

        
        
    }
    
    public void onBeforeDelete(List<buildertek__BT_Time_Sheet_Entry__c> oldTimeSheetEntries) {
        Map<Id, buildertek__BT_Time_Sheet_Entry__c> toDeleteBudgetLine = new Map<Id, buildertek__BT_Time_Sheet_Entry__c>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : oldTimeSheetEntries) {
            if(tse.buildertek__BT_Budget_Line__c != null){
                tse.buildertek__BT_Budget__c = null;
                toDeleteBudgetLine.put(tse.buildertek__BT_Budget_Line__c, tse);
            }
        }

        if (!toDeleteBudgetLine.isEmpty()) {
            List<buildertek__Budget_Item__c> toDeleteBudgetLineList = new List<buildertek__Budget_Item__c>();
            List<buildertek__Budget_Item__c> toUpdateBudgetLineList = new List<buildertek__Budget_Item__c>();

            List<buildertek__Budget_Item__c> budgetItems = [SELECT Id, Name, buildertek__Budget__c, buildertek__Budget_Line_Group__c, buildertek__Labor_TimeSheet__c FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetLine.keySet()];

            //if the name of the budget line is the same as the time sheet entry name, delete the budget line
            for (buildertek__Budget_Item__c budgetLine : budgetItems) {
                if (budgetLine.Name == toDeleteBudgetLine.get(budgetLine.Id).Name) {
                    toDeleteBudgetLineList.add(budgetLine);
                }else{
                    //subtract the amount from the budget line
                    buildertek__Budget_Item__c budgetLineToUpdate = new buildertek__Budget_Item__c();
                    budgetLineToUpdate.Id = budgetLine.Id;
                    budgetLineToUpdate.buildertek__Labor_TimeSheet__c = budgetLine.buildertek__Labor_TimeSheet__c - (toDeleteBudgetLine.get(budgetLine.Id).buildertek__Billable_Rate__c * toDeleteBudgetLine.get(budgetLine.Id).buildertek__Duration__c);
                    toUpdateBudgetLineList.add(budgetLineToUpdate);
                }
            }

            if (!toDeleteBudgetLineList.isEmpty()) {
                delete toDeleteBudgetLineList;
            }

            if (!toUpdateBudgetLineList.isEmpty()) {
                update toUpdateBudgetLineList;
            }
        }

    }

    public void onAfterInsert(List<buildertek__BT_Time_Sheet_Entry__c> newTimeSheetEntries) {
        Set<Id> budgetLineIds = new Set<Id>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            if (tse.buildertek__BT_Budget_Line__c != null){
                budgetLineIds.add(tse.buildertek__BT_Budget_Line__c);
            }
        }
        recalculateBudgetLineTotalAmount(budgetLineIds);
    }

    public void onAfterUpdate(List<buildertek__BT_Time_Sheet_Entry__c> newTimeSheetEntries , List<buildertek__BT_Time_Sheet_Entry__c>  oldTimeSheetEntries) {
        Set<Id> budgetLineIds = new Set<Id>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : newTimeSheetEntries) {
            if (tse.buildertek__BT_Budget_Line__c != null){
                budgetLineIds.add(tse.buildertek__BT_Budget_Line__c);
            }
        }
        recalculateBudgetLineTotalAmount(budgetLineIds);
    }

    public void recalculateBudgetLineTotalAmount(Set<Id> budgetLineIds) {
        List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntries = [SELECT Id, Name, buildertek__BT_Budget_Line__c, buildertek__BT_Time_Sheet__c, buildertek__BT_Time_Sheet__r.buildertek__Billable_Rate__c,  buildertek__Duration__c, buildertek__Billable_Rate__c from buildertek__BT_Time_Sheet_Entry__c WHERE buildertek__BT_Budget_Line__c IN :budgetLineIds];

        Map<Id, List<buildertek__BT_Time_Sheet_Entry__c>> budgetLineToTimeSheetEntries = new Map<Id, List<buildertek__BT_Time_Sheet_Entry__c>>();
        for (buildertek__BT_Time_Sheet_Entry__c tse : timeSheetEntries) {
            if (!budgetLineToTimeSheetEntries.containsKey(tse.buildertek__BT_Budget_Line__c)) {
                budgetLineToTimeSheetEntries.put(tse.buildertek__BT_Budget_Line__c, new List<buildertek__BT_Time_Sheet_Entry__c>());
            }
            budgetLineToTimeSheetEntries.get(tse.buildertek__BT_Budget_Line__c).add(tse);
        }

        List<buildertek__Budget_Item__c> budgetItemsToUpdate = new List<buildertek__Budget_Item__c>();
        for (Id budgetLineId : budgetLineToTimeSheetEntries.keySet()) {
            List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntriesForBudgetLine = budgetLineToTimeSheetEntries.get(budgetLineId);
            Decimal totalAmount = 0;
            for (buildertek__BT_Time_Sheet_Entry__c tse : timeSheetEntriesForBudgetLine) {
                totalAmount += tse.buildertek__Billable_Rate__c * tse.buildertek__Duration__c;
            }
            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
            budgetItem.Id = budgetLineId;
            budgetItem.buildertek__Labor_TimeSheet__c = totalAmount;
            budgetItemsToUpdate.add(budgetItem);
        }

        if (!budgetItemsToUpdate.isEmpty()) {
            update budgetItemsToUpdate;
        }

    }


}