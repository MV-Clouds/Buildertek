trigger ExpenseToBudgetlineTrigger on buildertek__Expense__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {

     if(!BT_Utils.isTriggerDeactivate('buildertek__Expense__c')){

        ExpenseToBudgetItemTriggerHandler handler = new ExpenseToBudgetItemTriggerHandler (Trigger.isExecuting, Trigger.size);

        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new, Trigger.newMap);
        }

        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
            if(!BudgetDAO.isCreateExpense){
                handler.AfterInsert(Trigger.new, Trigger.newMap);
            }
        }

        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }

        else if(Trigger.isUpdate && Trigger.isAfter){
            handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }

        else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
        }

        else if(Trigger.isDelete && Trigger.isAfter){
        //  handler.OnAfterDelete(Trigger.oldMap , Trigger.new);
        }
    }

}