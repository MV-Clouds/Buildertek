trigger AccountTrigger on Account (after insert, after update, before delete, before insert, before update, after delete){
	if (!BT_Utils.isTriggerDeactivate('Account') && !ProjectTaskTriggerHandler.blnSkipTaskTrigger){
		AccountTriggerHandler handler = new AccountTriggerHandler(Trigger.isExecuting, Trigger.size);
		if (Trigger.isInsert && Trigger.isBefore){
			handler.OnBeforeInsert(Trigger.new);
		} else if (Trigger.isInsert && Trigger.isAfter){
			handler.OnAfterInsert(Trigger.new, Trigger.newMap);
			QBMap.mapAccountData(Trigger.new[0]);
		} else if (Trigger.isUpdate && Trigger.isBefore){
			handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
		} else if (Trigger.isUpdate && Trigger.isAfter){
			handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
			System.debug('old 0==' +Trigger.old[0]);
			System.debug('old ==' + Trigger.old);
			System.debug('New 0 ==' + Trigger.new[0]);
			System.debug('new ==' + Trigger.new);

			if (Trigger.old[0].QBO_ID__c == '' || Trigger.old[0].QBO_ID__c == null || Trigger.new[0].QBO_SyncToken__c != Trigger.old[0].QBO_SyncToken__c ) {
				// QBMap.mapAccountData2(Trigger.new[0]);
			} else{
				// QBTriggerHandler.updateAcc(Trigger.new);
				QBMap.mapAccountData2(Trigger.new[0]);
			}
		}else if (Trigger.isAfter && Trigger.isDelete){
			System.debug('IN IF');
			System.debug(Trigger.old[0]);
			QBMap.mapAccountData3(Trigger.old[0]);
			// handler.OnAfterDelete(Trigger.old);
		}
		// else if (Trigger.isDelete && Trigger.isBefore){
		// 	handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
		// } 
	}
}