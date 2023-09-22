public without sharing class CloneScheduleController {

    @AuraEnabled
    public static string cloneScheduleRecords(Id scheduleId){

        String scheduleObj = 'buildertek__Schedule__c'; 
        String scheduleItemObj = 'buildertek__Project_Task__c'; 

        String scheduleQuery = 'SELECT ';
        String scheduleItemQuery = 'SELECT ';


        Map<String, Schema.SObjectField> ScheduleFieldMap = Schema.getGlobalDescribe().get(scheduleObj).getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> ScheduleItemFieldMap = Schema.getGlobalDescribe().get(scheduleItemObj).getDescribe().fields.getMap();

        for (String fieldName : ScheduleFieldMap.keySet()) {
            scheduleQuery += fieldName + ', ';
        }

        for (String fieldName : ScheduleItemFieldMap.keySet()) {
            if(fieldName!='buildertek__Dependency__c'){
                scheduleItemQuery += fieldName + ', ';
            }
        }

        scheduleQuery = scheduleQuery.removeEnd(', ') + ' FROM ' + scheduleObj +' WHERE id=\'' + scheduleId + '\'';

        scheduleItemQuery = scheduleItemQuery.removeEnd(', ') + ' FROM ' + scheduleItemObj +' WHERE buildertek__Schedule__c=\'' + scheduleId + '\'';

        buildertek__Schedule__c originalScheduleRec = Database.query(scheduleQuery);
        buildertek__Schedule__c scheduleCopy  = originalScheduleRec.clone(false, false, false, false);     
        insert scheduleCopy;

        List<buildertek__Project_Task__c> originalScheduleItemRec = Database.query(scheduleItemQuery);
        List<buildertek__Project_Task__c> newScheduleItemRecList = new  List<buildertek__Project_Task__c>();

        for(buildertek__Project_Task__c scheduleItem:originalScheduleItemRec){
            buildertek__Project_Task__c newScheduleItem=scheduleItem.clone(false, false, false, false);  
            newScheduleItem.buildertek__Schedule__c=scheduleCopy.Id;
            newScheduleItem.buildertek__Dependency__c=

            newScheduleItemRecList.add(newScheduleItem);
        }

        if(newScheduleItemRecList.size() > 0){
            insert newScheduleItemRecList;
        }

        return scheduleCopy.Id;

    }
    
}