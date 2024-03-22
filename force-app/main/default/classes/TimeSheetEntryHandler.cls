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

        List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntries = [SELECT Id, buildertek__BT_Time_Sheet__c, buildertek__BT_Time_Sheet__r.buildertek__Billable_Rate__c, buildertek__End_Time__c, buildertek__Start_Time__c, buildertek__Duration__c, buildertek__BT_Time_Sheet__r.buildertek__BT_Budget__c, buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c, buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__r.buildertek__Labor_TimeSheet__c FROM buildertek__BT_Time_Sheet_Entry__c WHERE buildertek__BT_Time_Sheet__c IN :timeSheetIds];

        Map<Id, Decimal> timeSheetTotals = new Map<Id, Decimal>();
        Map<Id, Decimal> timesheetBillableRate = new Map<Id, Decimal>();
        Map<Id, String> timeSheetBudgetItem = new Map<Id, String>();
        Map<Id, Decimal> timeSheetAmounts = new Map<Id, Decimal>();
        
        if(timeSheetEntries == null || timeSheetEntries.size() == 0) {
            return;
        }

        for (buildertek__BT_Time_Sheet_Entry__c tse : timeSheetEntries) {
            Decimal total = timeSheetTotals.get(tse.buildertek__BT_Time_Sheet__c);
            if (total == null) {
                total = 0;
            }
            if( tse.buildertek__Duration__c != null){
            total += tse.buildertek__Duration__c;
            timeSheetTotals.put(tse.buildertek__BT_Time_Sheet__c, total);
            }

            Decimal billableRate = timesheetBillableRate.get(tse.buildertek__BT_Time_Sheet__c);
            if (billableRate == null) {
                billableRate = 0;
            }
            billableRate = tse.buildertek__BT_Time_Sheet__r.buildertek__Billable_Rate__c;
            timesheetBillableRate.put(tse.buildertek__BT_Time_Sheet__c, billableRate);

            String budgetItem = timeSheetBudgetItem.get(tse.buildertek__BT_Time_Sheet__c);
            if (budgetItem == null) {
                budgetItem = '';
            }
            budgetItem = tse.buildertek__BT_Time_Sheet__r.buildertek__BT_Budget_Line__c;
            timeSheetBudgetItem.put(tse.buildertek__BT_Time_Sheet__c, budgetItem);
        }

        for (Id timeSheetId : timeSheetTotals.keySet()) {
            Decimal total = timeSheetTotals.get(timeSheetId);
            Decimal billableRate = timesheetBillableRate.get(timeSheetId);
            timeSheetAmounts.put(timeSheetId, total * billableRate);
        }

        if(timeSheetBudgetItem != null && timeSheetBudgetItem.size() > 0) {
            List<buildertek__Budget_Item__c> budgetLineItems = [SELECT Id, buildertek__Labor_TimeSheet__c FROM buildertek__Budget_Item__c WHERE Id IN :timeSheetBudgetItem.values()];
            
            for(Id timeSheetId : timeSheetBudgetItem.keySet()) {
                String budgetLineId = timeSheetBudgetItem.get(timeSheetId);
                Decimal total = timeSheetTotals.get(timeSheetId) == null ? 0 : timeSheetTotals.get(timeSheetId);
                System.debug(total);
                Decimal billableRate = timesheetBillableRate.get(timeSheetId) == null ? 0 : timesheetBillableRate.get(timeSheetId) ;
                System.debug(billableRate);
                Decimal amount = total * billableRate;
                for(buildertek__Budget_Item__c budgetLineItem : budgetLineItems) {
                    if(budgetLineItem.Id == budgetLineId) {
                        budgetLineItem.buildertek__Labor_TimeSheet__c = amount;
                    }
                }
            }
            update budgetLineItems;
            System.debug('budgetLineItems' + budgetLineItems);     
        }

        System.debug('timeSheetAmounts: ' + timeSheetAmounts);
        System.debug('timeSheetBudgetItem: ' + timeSheetBudgetItem);   

    }

}