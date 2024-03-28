trigger walkthroughlinetrigger on buildertek__Walk_Through_Line_Items__c (after insert, after update, after delete) {
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            walkthroughlinetriggerhandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            walkthroughlinetriggerhandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            walkthroughlinetriggerhandler.onAfterDelete(Trigger.old);
        }
    }
}