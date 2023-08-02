trigger TimecardTrigger on buildertek__Time_Cards__c(before insert,before update,after insert, after update, after delete, before delete){
    if (!BT_Utils.isTriggerDeactivate('buildertek__Time_Cards__c') && !TimeCardTriggerHandler.blnSkipTimecardTrigger){

        TimeCardTriggerHandler handler = new TimeCardTriggerHandler(Trigger.isExecuting, Trigger.size);

        if (Trigger.isInsert && Trigger.isBefore){
           // handler.OnBeforeInsert(Trigger.new);
            handler.beforeInsert(Trigger.new);
        }
        if (Trigger.isInsert && Trigger.isAfter){
            handler.afterInsert(Trigger.new, Trigger.newMap);
           // handler.onafterInsert(Trigger.new,Trigger.newMap);
        }
        if (Trigger.isUpdate && Trigger.isAfter){
            handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            handler.onafterUpdate(Trigger.new, Trigger.oldMap);
            if(!System.isFuture()){
           handler.contactupdate(Trigger.new);
           }
        }
        if (Trigger.isUpdate && Trigger.isBefore){
            handler.onbeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap);
            //If(!checkRecursion.runOnce())
            // if(!System.isFuture() && !System.isBatch())
             //   {
            //handler.contactupdate(Trigger.new);
            //}
        }
        if(Trigger.isDelete && Trigger.isAfter){
            handler.afterDelete(Trigger.old,Trigger.oldMap);
            //handler.contactupdate(Trigger.old);
            if(!System.isFuture()){
           handler.contactupdate(Trigger.old);
           }
        }
        /*if(Trigger.isDelete && Trigger.isBefore){
           handler.contactupdate1(Trigger.old);
        }*/
    }
}