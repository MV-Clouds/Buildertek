public with sharing class BT_MassUpdate_TimeSheet {
    public BT_MassUpdate_TimeSheet() {

    }

    @AuraEnabled
    public static List<buildertek__BT_Time_Sheet_Entry__c> getTimeSheetEntries(string recordId) {
        List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntries = [SELECT Id, Name, buildertek__Status__c,buildertek__Start_Time__c, buildertek__End_Time__c, buildertek__BT_Time_Sheet__c, buildertek__Duration__c, buildertek__BT_Budget__c, buildertek__BT_Budget_Line__c, buildertek__BT_Project__c, buildertek__BT_Schedule_Item__c, buildertek__Description__c, buildertek__Notes__c, buildertek__Duration_Manual__c FROM buildertek__BT_Time_Sheet_Entry__c WHERE buildertek__BT_Time_Sheet__c = :recordId];
        return timeSheetEntries;
    }

    // var action = component.get("c.updateTimeSheetEntries");
    // action.setParams({
    //     "upsertTimeSheetEntries": JSON.stringify(timeSheetEntries),
    //     "deletedTimeSheetEntries": JSON.stringify(deletedTimeSheetEntries)
    // });

    @AuraEnabled
    public static string updateTimeSheetEntries(List<buildertek__BT_Time_Sheet_Entry__c> upsertTimeSheetEntries, List<buildertek__BT_Time_Sheet_Entry__c> deletedTimeSheetEntries) {
        List<buildertek__BT_Time_Sheet_Entry__c> toInsert = new List<buildertek__BT_Time_Sheet_Entry__c>();
        List<buildertek__BT_Time_Sheet_Entry__c> toUpdate = new List<buildertek__BT_Time_Sheet_Entry__c>();
        List<buildertek__BT_Time_Sheet_Entry__c> toDelete = new List<buildertek__BT_Time_Sheet_Entry__c>();

        for (buildertek__BT_Time_Sheet_Entry__c entry : upsertTimeSheetEntries) {
            System.debug('entry: ' + entry);
            if (entry.Id == null) {
                toInsert.add(entry);
            } else {
                toUpdate.add(entry);
            }
        }
        for (buildertek__BT_Time_Sheet_Entry__c entry : deletedTimeSheetEntries) {
            System.debug('deleted entry: ' + entry);
            toDelete.add(entry);
        }

        if (toInsert.size() > 0) {
            try {
                insert toInsert;
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        if (toUpdate.size() > 0) {
            try {
                update toUpdate;
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        if (toDelete.size() > 0) {
            try {
                delete toDelete;
            } catch (Exception e) {
                return e.getMessage();
            }
        }

        return 'success';

    }

}
