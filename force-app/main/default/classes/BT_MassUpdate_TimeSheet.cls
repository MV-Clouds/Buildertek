public with sharing class BT_MassUpdate_TimeSheet {
    public BT_MassUpdate_TimeSheet() {

    }

    @AuraEnabled
    public static boolean checkTimeSheetEntries(string timeSheetId) {
        List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntries = [SELECT Id, buildertek__BT_Time_Sheet__c FROM buildertek__BT_Time_Sheet_Entry__c WHERE buildertek__BT_Time_Sheet__c = :timeSheetId];
        if(timeSheetEntries.size() > 0) {
            return true;
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static List<buildertek__BT_Time_Sheet_Entry__c> getTimeSheetEntries(string recordId) {
        List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntries = [SELECT Id, Name, buildertek__Status__c,buildertek__Start_Time__c, buildertek__End_Time__c, buildertek__BT_Time_Sheet__c, buildertek__Duration__c, buildertek__BT_Budget__c, buildertek__BT_Budget_Line__c, buildertek__BT_Project__c, buildertek__BT_Schedule_Item__c, buildertek__Description__c, buildertek__Notes__c, buildertek__Duration_Manual__c FROM buildertek__BT_Time_Sheet_Entry__c WHERE buildertek__BT_Time_Sheet__c = :recordId];
        return timeSheetEntries;
    }

    @AuraEnabled
    public static string updateTimeSheetEntries(List<buildertek__BT_Time_Sheet_Entry__c> timeSheetEntries) {
        try {
            update timeSheetEntries;
            return 'Time Sheet Entries Updated Successfully';
        } catch(Exception e) {
            return e.getMessage();
        }
    }
}