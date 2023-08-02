/**
 * This is a trigger sample for using CaseStatusChangeTriggerHandler
 * Ideally, only one trigger on each Object, if in your org, there is
 * already a Case trigger, please use the CaseStatusChangeTriggerHandler in it directly
 * to avoid multiple triggers on the same object
 */
trigger CaseStatusChangeTrigger on Case (after insert, after update) {

    if(Trigger.isInsert && Trigger.isAfter){
        CaseStatusChangeTriggerHandler.OnAfterInsert(Trigger.new);
    } 
    else if (Trigger.isUpdate && Trigger.isAfter) {
        
        /* David Bell: Harshada, consider changing to implemenet check that 
        Case Status actually changed before calling CaseStatusChangeTriggerHandler.OnAfterUpdate() */
        CaseStatusChangeTriggerHandler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
        DeleteEntitySubscriptions.deleteEntitySubscriptionsCase(Trigger.new,Trigger.oldMap);
    }

}