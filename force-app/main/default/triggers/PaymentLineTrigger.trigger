trigger PaymentLineTrigger on buildertek__BT_Payment_Lines__c (before insert, before update, after insert, after update, before delete, after delete) {

    PaymentLineTriggerHandler handler = new PaymentLineTriggerHandler(Trigger.isExecuting, Trigger.size);

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.onAfterInsert(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.onAfterUpdate(Trigger.new , Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isDelete) {
        handler.onAfterDelete(Trigger.old);
    }


}