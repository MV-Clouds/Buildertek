trigger CheckInTrigger on buildertek__Check_In__c(before insert, after insert, before update, after update, before delete ){
    if (!BT_Utils.isTriggerDeactivate('buildertek__Check_In__c') && !CheckInTriggerHandler.blnSkipTrigger){
        CheckInTriggerHandler handler = new CheckInTriggerHandler(Trigger.isExecuting, Trigger.size);
        if (Trigger.isInsert){
            if (CheckInTriggerHandler.blnSkipTrigger){
                return;
            }
            if (Trigger.isBefore){
                handler.OnBeforeInsert(Trigger.new);
            } else if (Trigger.isAfter){
                handler.OnAfterInsert(Trigger.new, Trigger.newMap);
            }
        } else if (Trigger.isUpdate){
            if (CheckInTriggerHandler.blnSkipTrigger){
                return;
            }
            if (Trigger.isBefore){
                handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            } else if (Trigger.isAfter){
                handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            }
        } else if (Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
        } else if (Trigger.isDelete && Trigger.isAfter){
            handler.OnAfterDelete(Trigger.old);
        }
    }
}