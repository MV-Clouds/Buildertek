/*
*   Executed:   After Update, Before Delete
*   Purpose:    When user update access type from private to public, access controls will get deleted.
                When user will try to delete File it will be deleted from the Amazon also.
*/
trigger FileTrigger on File__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(!BT_Utils.isTriggerDeactivate('File__c')){
        FileTriggerHandler objFileTriggerHandler = new FileTriggerHandler();
        if (Trigger.isInsert && Trigger.isBefore) {
            objFileTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isInsert && Trigger.isAfter) {
            objFileTriggerHandler.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate && Trigger.isBefore) {
            objFileTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        } else if (Trigger.isUpdate && Trigger.isAfter) {
            objFileTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        } else if (Trigger.isDelete && Trigger.isBefore) {
            objFileTriggerHandler.onBeforeDelete(Trigger.oldMap);
        } else if (Trigger.isDelete && Trigger.isAfter) {
            objFileTriggerHandler.onAfterDelete(Trigger.oldMap);
        }
    }
}