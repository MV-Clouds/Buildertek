/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  27-Sep-2017
*/
trigger RFQTOVendorTrigger on RFQ_To_Vendor__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(!BT_Utils.isTriggerDeactivate('RFQ_To_Vendor__c') && !RFQToVendorTriggerHandler.blnSkipRFQToVendorUpdateTrigger){
    	
    	RFQToVendorTriggerHandler handler = new RFQToVendorTriggerHandler (Trigger.isExecuting, Trigger.size);
	
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
		    if(checkRecursion.runOnce())
			handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
		}
		
		else if(Trigger.isDelete && Trigger.isBefore){
			handler.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
		}
		
		else if(Trigger.isDelete && Trigger.isAfter){
			handler.OnAfterDelete(Trigger.old); 
		}
    }
}