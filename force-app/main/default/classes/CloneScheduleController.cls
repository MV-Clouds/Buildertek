public without sharing class CloneScheduleController {

    @AuraEnabled
    public static string cloneScheduleRecords(Id oldScheduleId){

        if(oldScheduleId !=null){

            String scheduleObj = 'buildertek__Schedule__c'; 
            String scheduleQuery = 'SELECT ';
            Map<String, Schema.SObjectField> ScheduleFieldMap = Schema.getGlobalDescribe().get(scheduleObj).getDescribe().fields.getMap();
            for (String fieldName : ScheduleFieldMap.keySet()) {
                scheduleQuery += fieldName + ', ';
            }
            scheduleQuery = scheduleQuery.removeEnd(', ') + ' FROM ' + scheduleObj +' WHERE id=\'' + oldScheduleId + '\'';
            buildertek__Schedule__c originalScheduleRec = Database.query(scheduleQuery);
            buildertek__Schedule__c scheduleCopy  = originalScheduleRec.clone(false, false, false, false);     
            insert scheduleCopy;
    
            Date initialStartDate =scheduleCopy.buildertek__Start_Date__c;
            if(scheduleCopy.buildertek__Start_Date__c == null){
                initialStartDate = System.today();
            }
    
            bryntumGanttController.createScheduleLineFromMasterSchedule(scheduleCopy.Id, oldScheduleId, initialStartDate);
            return scheduleCopy.Id;
        }else{
            return null;
        }


    }
    
}