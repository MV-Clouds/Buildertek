trigger MeetingTrigger on buildertek__Meeting__c (after insert, after update,before Update,before insert) {

    MeetingTriggerHandler mh = new MeetingTriggerHandler();
    mh.meetingTriggerHandler(trigger.new, trigger.OldMap);

    if(trigger.isBefore && trigger.isInsert){
        mh.OnBeforeInsertEvent();
     }

    if(trigger.isBefore && trigger.isUpdate){
        mh.OnBeforeUpdateEvent();
    }
    if(trigger.isAfter && trigger.isInsert){
        mh.OnAfterInsertEvent();
    }

    if(trigger.isAfter && trigger.isUpdate){
        mh.OnAfterUpdateEvent();
    }

}