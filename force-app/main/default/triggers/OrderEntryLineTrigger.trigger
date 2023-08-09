/*
	@ PURPOSE : 1. WHEN "Sales Order Line Status" FIELD OF ORDER ENTRY LINE IS "Shipped".
				2. FETCH Issues RELATED TO Order Entry Release.
				3. FETCH Product Items RELATED TO Trunk OF Issues AND
				4. ADJUST THE Quantity on Product Items BASED ON Quantity OF Issues.
*/
Trigger OrderEntryLineTrigger on Order_Entry_Line__c ( After Insert, After Update, After Undelete ) {
	 if(WorkOrderTriggerHandler.runcurrentTrigger('OrderEntryLineTrigger')){
	if( Trigger.isAfter ) {
		
		if( Trigger.isInsert || Trigger.isUndelete ) {
			OrderEntryLineTriggerHelper.adjustQuantitiesOnProductItems( Trigger.new );
		}
		else if( Trigger.isUpdate ) {
			OrderEntryLineTriggerHelper.adjustQuantitiesOnProductItems( Trigger.new, Trigger.oldMap );
            OrderEntryLineTriggerHelper.updateProductTransferRecords( Trigger.new, Trigger.oldMap );
		}
	}
     }
}