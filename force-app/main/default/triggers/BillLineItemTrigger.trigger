trigger BillLineItemTrigger on buildertek__Account_Payable_Item__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
     if(!BT_Utils.isTriggerDeactivate('buildertek__Account_Payable_Item__c')){
    	
    	BillLineItemTriggerHandler handler = new BillLineItemTriggerHandler (Trigger.isExecuting, Trigger.size);
	
		if(Trigger.isInsert && Trigger.isBefore){
		//	handler.OnBeforeInsert(Trigger.new);
		}
		 
		else if(Trigger.isInsert && Trigger.isAfter){
			handler.OnAfterInsert(Trigger.new, Trigger.newMap);
		}
		
		else if(Trigger.isUpdate && Trigger.isBefore){
		//	handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
		}
		
		else if(Trigger.isUpdate && Trigger.isAfter){
			handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
		}
		
		else if(Trigger.isDelete && Trigger.isBefore){
		//	handler.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
		}
		
		else if(Trigger.isDelete && Trigger.isAfter){
		//	handler.OnAfterDelete(Trigger.old); 
		}
    }

}