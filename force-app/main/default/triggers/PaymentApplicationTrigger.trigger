trigger PaymentApplicationTrigger on buildertek__SOV_Payment_Application__c (before insert,before update,before Delete, after insert,after update) {
    
    PaymentApplicationTriggerHandler handler = new PaymentApplicationTriggerHandler();
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.beforeInsert(Trigger.new); 
        }
    }
    else if (Trigger.isInsert && Trigger.isAfter){
        if (PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger){
            return;
        }else{
            
            handler.afterInsert(Trigger.new, Trigger.newMap);
        } 
    }
    if(Trigger.isBefore && Trigger.isDelete){
        if (PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger){
            return;
        }else{
            
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
        } 
        
    }
    /* if(Trigger.isBefore && Trigger.isUpdate){
handler.OnBeforeupdate(Trigger.new, Trigger.oldMap);
}*/
    if(Trigger.isAfter && Trigger.isUpdate){
        if (PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger ){
            system.debug('insert1'+PaymentApplicationTriggerHandler.blnSkipPayAppInsertTrigger );
            return;
        }else{
            handler.OnAfterupdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            handler.updateSheetLinesStatusWhenPaymentAppStatusChanges(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            
        }
        
    }
}