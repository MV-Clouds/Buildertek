trigger ReceiptTrigger on buildertek__Receipt__c(before insert,after insert, after delete ){

   ReceiptTriggerHandler handler = new ReceiptTriggerHandler();

   if (Trigger.isInsert && Trigger.isAfter){

      //* commented out because this method updates records in bulk unnecessary do any thing Commented By Nishit Suthar on 29/01/2024
      //  ReceiptTriggerHandler.OnAfterInsert(Trigger.new);

      //  ReceiptTriggerHandler.QBIntegrationOnInsert(Trigger.new, Trigger.old);
      //  QBMap.MapInvoiceData(Trigger.new[0]);
   }

   if (Trigger.isDelete && Trigger.isAfter){

      //* commented out because this method updates records in bulk unnecessary do any thing Commented By Nishit Suthar on 29/01/2024
      //  ReceiptTriggerHandler.OnAfterInsert(Trigger.old);

   }
   if (Trigger.isInsert && Trigger.isBefore){
       ReceiptTriggerHandler.updateCOFieldOnReciepts(Trigger.new);
   }
}