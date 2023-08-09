trigger PreQual_Trigger on buildertek__Pre_Qual__c (after insert, after update, before delete, before insert, before update) {
    PrequalTriggerHandler handler = new PrequalTriggerHandler();
   
		if (Trigger.isUpdate && Trigger.isBefore){
			handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
		}
    

}