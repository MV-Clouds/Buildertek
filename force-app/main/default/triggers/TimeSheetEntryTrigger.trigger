trigger TimeSheetEntryTrigger on BT_Time_Sheet_Entry__c (before insert, before update, after insert, after update,before delete) {

    TimeSheetEntryHandler handler = new TimeSheetEntryHandler();

    //New Requirement based in BUIL - 4030
    // if(Trigger.isAfter && Trigger.isInsert){
    //     handler.afterInsert(Trigger.new);
    // }

    // if(Trigger.isAfter && Trigger.isUpdate){
    //     handler.afterUpdate(Trigger.new, Trigger.old);
    // }

    if(Trigger.isBefore && Trigger.isInsert){
        handler.onBeforeInsert(Trigger.new);
    }

    if(Trigger.isBefore && Trigger.isUpdate){
        handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isBefore && Trigger.isDelete){
        handler.onBeforeDelete(Trigger.old);
    }

    if(Trigger.isAfter && Trigger.isInsert){
        handler.onAfterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        handler.onAfterUpdate(Trigger.new, Trigger.old);
    }


}