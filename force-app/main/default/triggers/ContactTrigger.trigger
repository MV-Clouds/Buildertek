trigger ContactTrigger on Contact (after insert, after update, after delete) {

    ContactTriggerHandler handler = new ContactTriggerHandler();

    if(Trigger.isUpdate && Trigger.isAfter){
        handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }

}