trigger TimeSheetEntryTrigger on BT_Time_Sheet_Entry__c (before insert, before update, after insert, after update,before delete) {

    TimeSheetEntryHandler handler = new TimeSheetEntryHandler();

    if(Trigger.isAfter && Trigger.isInsert){
        handler.afterInsert(Trigger.new);
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        handler.afterUpdate(Trigger.new, Trigger.old);
    }

}