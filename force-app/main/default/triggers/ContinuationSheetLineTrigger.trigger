trigger ContinuationSheetLineTrigger on SOV_Continuation_Sheet_Lines__c (after insert, after update, after Delete, before Delete) {
    
    ContinuationSheetLineTriggerHandler handler = new ContinuationSheetLineTriggerHandler();
    
        public static Boolean blnSkipforUpdate = false;
       
     if (Trigger.isdelete && Trigger.isAfter){
      //  handler.afterDelete(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        ContinuationSheetLineTriggerHandler.updatePaymentAppStatusBasedOnConSheetLinesStatus(Trigger.Old);
         ContinuationSheetLineTriggerHandler.updatePaymentApplicationbeforedelete(Trigger.old);
    }
    
    
   if (Trigger.isdelete && Trigger.isBefore){
         if (ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger ){
                system.debug('insert1'+ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger );
                return;
         }
        handler.afterDelete(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
       
    }
    
    if (Trigger.isInsert && Trigger.isAfter){
        
        handler.afterInsert(Trigger.new, Trigger.newMap);
         
        if (ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger ){
                system.debug('insert1'+ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger );
                return;
        }
        handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        ContinuationSheetLineTriggerHandler.updatePaymentAppStatusBasedOnConSheetLinesStatus(Trigger.New);
         // ContinuationSheetLineTriggerHandler.updatePaymentApplication(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isAfter){
        if (ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger ){
            system.debug('insert1'+ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger );
            return;
        }
        if (ContinuationSheetLineTriggerHandler.blnSkipconSheetLineUpdateTrigger ){
            return;
        }else{
            handler.afterUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
            ContinuationSheetLineTriggerHandler.updatePaymentAppStatusBasedOnConSheetLinesStatusOnAfterUpdate(Trigger.New, Trigger.oldMap);
        }
        
        handler.isAllLinesCompleted(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        
        
    }
    
   
    
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            ContinuationSheetLineTriggerHandler.updatePaymentApplication(Trigger.new);
        }
    }
    
}