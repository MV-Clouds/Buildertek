trigger RFITriggerNew on buildertek__RFI__c (after insert, after update, before insert, before update, before delete,after delete) {
        RFITriHandler handler = new RFITriHandler (Trigger.isExecuting, Trigger.size);

    if(!BT_Utils.isTriggerDeactivate('RFI__c') && !RFITriHandler.blnSkipRFIUpdateTrigger){
        
        
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
          RFITriHandler.openRFICount(Trigger.new); 
          handler.updaterfiaccount(Trigger.new); 
        }
        else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
            
        }
    }
   if(Trigger.isUpdate && Trigger.isAfter){
        System.debug('Trigger*********************************************'+Trigger.new);
        RFITriHandler.sharingRecord(Trigger.new,Trigger.oldMap);  
        RFITriHandler.openRFICount(Trigger.new);    
        
    } 
    if(Trigger.isUpdate && Trigger.isBefore){
       handler.OnBeforeUpdate(Trigger.new);    
        
    } 
    if(Trigger.isInsert && Trigger.isAfter){
          RFITriHandler.openRFICount(Trigger.new); 
        }
        if(Trigger.isDelete && Trigger.isAfter){
          RFITriHandler.openRFICount(Trigger.old); 
        }
}