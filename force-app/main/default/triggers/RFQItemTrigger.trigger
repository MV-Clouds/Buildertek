/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  27-Sep-2017
*/
trigger RFQItemTrigger on RFQ_Item__c (after delete, after insert, after update, before delete, before insert, before update) {
    
    if(!BT_Utils.isTriggerDeactivate('RFQ_Item__c') && !RFQItemTriggerHandler.blnSkipRFQItemUpdateTrigger){
    	
    	RFQItemTriggerHandler handler = new RFQItemTriggerHandler (Trigger.isExecuting, Trigger.size);
	
		if(Trigger.isInsert && Trigger.isBefore){
			handler.OnBeforeInsert(Trigger.new);
		}
		 
		else if(Trigger.isInsert && Trigger.isAfter){
		    
			handler.OnAfterInsert(Trigger.new, Trigger.newMap);
		}
		
		else if(Trigger.isUpdate && Trigger.isBefore){
			handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
		}
		
		else if(Trigger.isUpdate && Trigger.isAfter){
			handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
          //  handler.OnAfterUpdate2(Trigger.new);
		}
		
		else if(Trigger.isDelete && Trigger.isBefore){
			handler.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
		}
		
		else if(Trigger.isDelete && Trigger.isAfter){
			handler.OnAfterDelete(Trigger.old); 
		}
    }
}