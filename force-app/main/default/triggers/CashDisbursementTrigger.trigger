trigger CashDisbursementTrigger on buildertek__Payment__c (before insert, before update, after insert, after update, after delete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CashDisbursementTriggerHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            CashDisbursementTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            CashDisbursementTriggerHandler.onBeforeDelete(Trigger.old);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CashDisbursementTriggerHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            CashDisbursementTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            // CashDisbursementTriggerHandler.onAfterDelete(Trigger.old);
        }
    }
}