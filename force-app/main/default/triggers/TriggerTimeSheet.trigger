trigger TriggerTimeSheet on buildertek__BT_Time_Sheet__c (before insert, before update, after insert, after update,before delete) {

    HandlerTimeSheet handler = new HandlerTimeSheet();

    //No need of Trigger as per the requirement in BUIL - 4030

    if(Trigger.isBefore && Trigger.isInsert){
        // handler.beforeInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        // handler.afterInsert(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        // handler.beforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        // handler.afterUpdate(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isBefore && Trigger.isDelete){
        // handler.beforeDelete(Trigger.old);
    }

}