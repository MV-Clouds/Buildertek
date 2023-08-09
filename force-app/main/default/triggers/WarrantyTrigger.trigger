trigger WarrantyTrigger on buildertek__Warranty__c (before insert, before update) {
    if(!BT_Utils.isTriggerDeactivate('Warranty__c') && !WarrantyTriggerHandler.blnSkipTrigger){
        
        WarrantyTriggerHandler handler = new WarrantyTriggerHandler (Trigger.isExecuting, Trigger.size);
        
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }else if(Trigger.isUpdate && Trigger.isBefore){
             handler.OnAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}