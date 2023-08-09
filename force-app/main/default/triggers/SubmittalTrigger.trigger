trigger SubmittalTrigger on buildertek__Submittal__c (before insert, After insert, before update, after update, before delete, after delete) {
	
	if(!BT_Utils.isTriggerDeactivate('Submittal__c') && !SubmittalTriggerHandler.blnSkipTrigger){
    	
    	SubmittalTriggerHandler handler = new SubmittalTriggerHandler (Trigger.isExecuting, Trigger.size);
	
		if(Trigger.isInsert && Trigger.isBefore){
			handler.OnBeforeInsert(Trigger.new);
		}
		 
		else if(Trigger.isInsert && Trigger.isAfter){
			handler.OnAfterInsert(Trigger.new);
		}
		
		else if(Trigger.isUpdate && Trigger.isBefore){
			handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
		}
		
		else if(Trigger.isUpdate && Trigger.isAfter){
		}
		
		else if(Trigger.isDelete && Trigger.isBefore){
		}
		
		else if(Trigger.isDelete && Trigger.isAfter){
		}
    }
	   
}