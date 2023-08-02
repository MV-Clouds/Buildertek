trigger ScheduleOfValueTrigger on  buildertek__Schedule_of_Values__c (before update, after update, before insert, after insert, before delete) {
    scheduleOfValueTriggerHandler SOVHandler = new scheduleOfValueTriggerHandler();
    
    // if(Trigger.isUpdate){
    // if (Trigger.isBefore){
    //  system.debug('hai');
    //  SOVHandler.isBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
    
    // }else
    if(Trigger.isBefore && Trigger.isUpdate){
        SOVHandler.OnBeforeupdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
    }
    else{ if (Trigger.isAfter){
        if (scheduleOfValueTriggerHandler.blnSkipSOVTrigger ){
            system.debug('insert1'+scheduleOfValueTriggerHandler.blnSkipSOVTrigger );
            return;
        }
        system.debug('after update');
        SOVHandler.isAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
    }
        }
    
    if(Trigger.isInsert){
        if (Trigger.isBefore){
            SOVHandler.isBeforeInsert(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
        }else if (Trigger.isAfter){
            system.debug('is after');
            SOVHandler.isAfterInsert(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
        }
    }
    
    /*    if(Trigger.isBefore && Trigger.isUpdate){
SOVHandler.OnBeforeupdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
}*/
    
    /* if(Trigger.isDelete){
if (Trigger.isBefore){
SOVHandler.isBeforeDelete(Trigger.old);
}
} */
    
}