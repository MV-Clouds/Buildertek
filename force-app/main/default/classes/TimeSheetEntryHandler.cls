public with sharing class TimeSheetEntryHandler {
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

}