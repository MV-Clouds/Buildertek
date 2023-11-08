trigger AccountTrigger on Account (after insert, after update, before delete, before insert, before update){
	if (!BT_Utils.isTriggerDeactivate('Account') && !ProjectTaskTriggerHandler.blnSkipTaskTrigger){
		AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
		if (Trigger.isInsert && Trigger.isBefore){
			handler.OnBeforeInsert(Trigger.new);
		} else if (Trigger.isInsert && Trigger.isAfter){
			handler.OnAfterInsert(Trigger.new, Trigger.newMap);
		} else if (Trigger.isUpdate && Trigger.isBefore){
			handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
		} else if (Trigger.isUpdate && Trigger.isAfter){
			handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
		} else if (Trigger.isDelete && Trigger.isBefore){
			handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
		} else if (Trigger.isDelete && Trigger.isAfter){
			handler.OnAfterDelete(Trigger.old);
		}
	}
}