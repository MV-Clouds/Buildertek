trigger PaymentLineTrigger on buildertek__BT_Payment_Lines__c (before insert, before update, after insert, after update,before delete) {

    PaymentLineTriggerHandler handler = new PaymentLineTriggerHandler(Trigger.isExecuting, Trigger.size);

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new);
    }


}