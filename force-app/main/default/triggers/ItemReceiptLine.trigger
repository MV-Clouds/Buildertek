trigger ItemReceiptLine on buildertek__Item_Receipt_Line__c(before insert, before update, after insert, after update ){

	ItemReceiptLineHandler handler = new ItemReceiptLineHandler(Trigger.isExecuting, Trigger.size);

	if (Trigger.isInsert && Trigger.isBefore){
		//    handler.OnBeforeInsert(Trigger.new);
	} else if (Trigger.isInsert && Trigger.isAfter){
		handler.OnAfterInsert(Trigger.new, Trigger.newMap);
	} else if (Trigger.isUpdate && Trigger.isBefore){
		//    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	} else if (Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
	} 
}