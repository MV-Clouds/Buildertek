trigger ReceiptTrigger on buildertek__Receipt__c (after insert, after delete, after update) {
   if(Trigger.isInsert && Trigger.isAfter){
      
      ReceiptTriggerHandler.OnAfterInsert(Trigger.new);
      ReceiptTriggerHandler.onAfterInsertReceipt(Trigger.new);
      ReceiptTriggerHandler.QBIntegrationOnInsert(Trigger.new, Trigger.old);
      //  QBMap.MapInvoiceData(Trigger.new[0]);
   }
   if(Trigger.isDelete && Trigger.isAfter){
      
      ReceiptTriggerHandler.OnAfterInsert(Trigger.old);
      ReceiptTriggerHandler.onAfterDelete(Trigger.old);

   }  

   if(Trigger.isUpdate && Trigger.isAfter){
      ReceiptTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
   }
}