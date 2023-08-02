trigger ReceiptTrigger on buildertek__Receipt__c (after insert, after delete) {
    if(Trigger.isInsert && Trigger.isAfter){
       
       ReceiptTriggerHandler.OnAfterInsert(Trigger.new);
    }
    if(Trigger.isDelete && Trigger.isAfter){
        
       ReceiptTriggerHandler.OnAfterInsert(Trigger.old);

    }    
}