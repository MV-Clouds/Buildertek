trigger UpdateInvoiceOnBudgetLine on buildertek__Account_Payable_Item_Clone__c(after insert, after update, after delete, after undelete) {
    UpdateInvoiceOnBudgetLineHandler handler = new UpdateInvoiceOnBudgetLineHandler();
    if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
        handler.afterTrigger(Trigger.New);
    }

    if(trigger.isUpdate || trigger.isDelete){
        handler.afterDelete(Trigger.old);
       
    }


}