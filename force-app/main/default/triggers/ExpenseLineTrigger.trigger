trigger ExpenseLineTrigger on buildertek__expense_line__C (after insert, after update, after delete) {

    ExpenseLineTriggerHandler handler = new ExpenseLineTriggerHandler();

   if(Trigger.isInsert && Trigger.isAfter){
        handler.onAfterInsert(Trigger.new);
   }

    if(Trigger.isUpdate && Trigger.isAfter){
        handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isDelete && Trigger.isAfter){
        handler.onAfterDelete(Trigger.old);
    }

}