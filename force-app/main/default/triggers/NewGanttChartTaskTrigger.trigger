trigger NewGanttChartTaskTrigger on buildertek__Project_Task__c (after insert, after update, before delete) {
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter && !NewGanttChartTaskTriggerHandler.blnSkipTaskTrigger){
        NewGanttChartTaskTriggerHandler.upsertMilestoneData(Trigger.new, Trigger.newMap);
    } else if(Trigger.isDelete && Trigger.isAfter){
        NewGanttChartTaskTriggerHandler.upsertMilestoneData(Trigger.old, Trigger.oldMap);
    }
}