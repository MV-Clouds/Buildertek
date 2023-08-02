trigger PunchListTrigger on buildertek__Punch_List__c (after insert, after update, before insert, before update) {
    if(!BT_Utils.isTriggerDeactivate('Punch_List__c') && !PunchListTriggerHandler.blnSkipPLUpdateTrigger){
    	
    	PunchListTriggerHandler handler = new PunchListTriggerHandler (Trigger.isExecuting, Trigger.size);
	
		if(Trigger.isInsert && Trigger.isBefore){
			handler.OnBeforeInsert(Trigger.new);
		}
    }
}