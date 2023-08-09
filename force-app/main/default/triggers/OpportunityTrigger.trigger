/*
 Developed By: Harika
 Date: 24/02/2021
 */
trigger OpportunityTrigger on Opportunity (before update, after update) {

    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    if (Trigger.isUpdate && Trigger.isBefore){
		handler.OnBeforeUpdate(Trigger.new, trigger.oldMap);
        handler.onBeforeUpdateCloseWon(Trigger.new,Trigger.old,Trigger.newMap, Trigger.oldMap);
	}

    if (Trigger.isUpdate && Trigger.isAfter){
        System.debug('in trigger after update');
		//handler.OnBeforeUpdate(Trigger.new, trigger.oldMap);
        handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
	}

}