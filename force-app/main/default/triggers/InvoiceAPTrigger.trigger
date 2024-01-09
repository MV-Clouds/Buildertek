trigger InvoiceAPTrigger on buildertek__Account_Payable_Clone__c (before update , after insert, after update, after delete) {

    InvoiceAPTriggerHandler handler = new  InvoiceAPTriggerHandler();

    if(Trigger.isBefore && Trigger.isUpdate && !PaymentTriggerHandler.isSkipExecution){
        handler.RestrictToUpdatePI(Trigger.new, Trigger.newMap , Trigger.oldMap); 
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.OnAfterInsert(Trigger.new, Trigger.newMap); 
        } else if (Trigger.isUpdate){
            if(InvoiceAPTriggerHandler.isFirstTime){
                handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap); 
            }
        } else if (Trigger.isDelete){
            handler.OnAfterDelete(Trigger.old); 
        }  
    }
}