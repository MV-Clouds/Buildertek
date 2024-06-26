trigger PaymentTrigger on BT_Payment__c (before insert, after insert, before update, after update, after undelete, after delete) {
    PaymentTriggerHandler handler = new PaymentTriggerHandler();
    PaymentTriggerHandler.isSkipExecution=false;

    if (Trigger.isBefore && Trigger.isInsert){
        handler.onBeforeInsert(Trigger.new, Trigger.newMap);
    }

    if (Trigger.isInsert && Trigger.isAfter){
         handler.afterInsert(Trigger.new, Trigger.newMap);
    }

    if (Trigger.isBefore && Trigger.isUpdate){
        handler.onBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
    
    if (Trigger.isUpdate && Trigger.isAfter){
        handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
    }  
    
    if (Trigger.isDelete){ 
        System.debug('Is before Delete');
        handler.onBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    PaymentTriggerHandler.isSkipExecution=false;

   
}