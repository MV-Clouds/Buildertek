trigger ProductRequestTrigger on ProductRequest (after update) {

    if(Trigger.isAfter && Trigger.isUpdate) {
        ProductRequestTriggerHandler.doAfterUpdate(Trigger.old, Trigger.new);
    }

}