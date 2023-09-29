public without sharing class CloneScheduleController {

    @AuraEnabled
    public static string cloneScheduleRecords(Id oldScheduleId){
        if (oldScheduleId == null) {
            return null;
        }


        buildertek__Schedule__c oldSchedule= new buildertek__Schedule__c();
        oldSchedule.Id=oldScheduleId;
        oldSchedule.buildertek__Active__c=false;
        update oldSchedule;

        String scheduleObj = 'buildertek__Schedule__c'; 
        String scheduleQuery = 'SELECT ';
        Map<String, Schema.SObjectField> ScheduleFieldMap = Schema.getGlobalDescribe().get(scheduleObj).getDescribe().fields.getMap();
        for (String fieldName : ScheduleFieldMap.keySet()) {
            scheduleQuery += fieldName + ', ';
        }
        scheduleQuery = scheduleQuery.removeEnd(', ') + ' FROM ' + scheduleObj +' WHERE id=\'' + oldScheduleId + '\'';
        buildertek__Schedule__c originalScheduleRec = Database.query(scheduleQuery);
        buildertek__Schedule__c scheduleCopy  = originalScheduleRec.clone(false, false, false, false);    
        scheduleCopy.buildertek__Active__c=true;
 
        insert scheduleCopy;



        String scheduleItemObj = 'buildertek__Project_Task__c'; 
        String scheduleItemQuery = 'SELECT ';

        Map<String, Schema.SObjectField> ScheduleItemFieldMap = Schema.getGlobalDescribe().get(scheduleItemObj).getDescribe().fields.getMap();
        for (String fieldName : ScheduleItemFieldMap.keySet()) {
            scheduleItemQuery += fieldName + ', ';
        }
        scheduleItemQuery = scheduleItemQuery.removeEnd(', ') + ' FROM ' + scheduleItemObj +' WHERE buildertek__Schedule__c=\'' + oldScheduleId + '\'';
        List<buildertek__Project_Task__c> originalScheduleItemRec = Database.query(scheduleItemQuery);

        Map<String, String> predecessorMap = new Map<String, String>();
        Map<Id, buildertek__Project_Task__c> projectInsertTaskMap = new Map<Id,buildertek__Project_Task__c>();

        for(buildertek__Project_Task__c Masterscheduleitem:originalScheduleItemRec){
            if (!Masterscheduleitem.buildertek__Milestone__c){
                
                if (Masterscheduleitem.buildertek__Dependency__c != null) {
                    predecessorMap.put(Masterscheduleitem.Id, Masterscheduleitem.buildertek__Dependency__c);
                }
                
                buildertek__Project_Task__c projectTask=Masterscheduleitem.clone(false, false, false, false);  
                projectTask.buildertek__Schedule__c=scheduleCopy.Id;
                projectTask.buildertek__Reference_for_Import__c = Masterscheduleitem.Id;
                projectTask.buildertek__Dependency__c = null;
                projectInsertTaskMap.put(Masterscheduleitem.Id, projectTask);
            }
        }

        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        insert projectInsertTaskMap.values();
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

        for (String key : predecessorMap.keySet()) {
            projectInsertTaskMap.get(key).buildertek__Dependency__c = projectInsertTaskMap.get(predecessorMap.get(key)).Id;
        }

        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        update projectInsertTaskMap.values();
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
    
        return scheduleCopy.Id;
    
    }
    
}