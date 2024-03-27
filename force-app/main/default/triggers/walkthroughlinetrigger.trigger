trigger walkthroughlinetrigger on buildertek__Walk_Through_Line_Items__c (after insert, after update, after delete,before insert, before update) {
    
    
    if (Trigger.isBefore) {
        System.debug(Trigger.isBefore);
        if (Trigger.isInsert || Trigger.isUpdate) { 
            walkthroughlinetriggerhandler.updateDescriptionFromProduct(Trigger.new);
        }
    } 

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