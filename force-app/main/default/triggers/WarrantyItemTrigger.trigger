trigger WarrantyItemTrigger on Warranty_Item__c (before insert, before update) {
    if(!BT_Utils.isTriggerDeactivate('Warranty_Item__c') && !WarrantyItemTriggerHandler.blnSkipTrigger){
    	
    	WarrantyItemTriggerHandler handler = new WarrantyItemTriggerHandler (Trigger.isExecuting, Trigger.size);
	
		if(Trigger.isInsert && Trigger.isBefore){
			handler.OnBeforeInsert(Trigger.new);
		}
        else if(Trigger.isUpdate && Trigger.isBefore){
			handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
		}
    }
}