trigger SOVLinesTrigger on buildertek__Schedule_of_Value_Lines__c (before insert, after insert, after update, before delete,before update) {
    
    if ( Trigger.isBefore && Trigger.isInsert){
        SOVLinesTriggerHandler.beforeInsert(Trigger.new);
        SOVLinesTriggerHandler.updateSOVLine(Trigger.new);
        SOVLinesTriggerHandler.updateOriginalScheduledValue(Trigger.New);
    }
    
    /* if(Trigger.isAfter && Trigger.isUpdate && SOVLinesTriggerHandler.isFirstTime){
TriggerHandler.isFirstTime = False; 
List<buildertek__Schedule_of_Value_Lines__c> SOVLines=[SELECT Id, Name, buildertek__Description_of_Work__c, buildertek__Scheduled_Value__c,buildertek__Vendor_SOV_Line__c,
buildertek__Schedule_of_Values__c, buildertek__Item__c, buildertek__Item_New__c, buildertek__Vendor_Item_Number__c, buildertek__Vendor_Item_Number_New__c,
buildertek__Is_Processed__c, buildertek__Status__c, buildertek__Vendor__c, CreatedDate 
FROM buildertek__Schedule_of_Value_Lines__c where Id IN :Trigger.new AND  buildertek__Vendor_SOV_Line__c = null AND buildertek__Status__c = 'Rejected'];
SOVLinesTriggerHandler.afterUpdate(SOVLines);
} */
    /*if ( Trigger.isBefore && Trigger.isUpdate){
SOVLinesTriggerHandler.beforeUpdate(Trigger.new);
}*/
    
    if (Trigger.isAfter){
        if(Trigger.isInsert){
            SOVLinesTriggerHandler.updateSOVStatusBasedOnSOVLinesStatus(Trigger.New);
            
        }
        if(Trigger.isUpdate){
            if(!SOVLinesTriggerHandler.blnSkipSheetLineTrigger){
                SOVLinesTriggerHandler.updateSOVStatusBasedOnSOVLinesStatusOnAfterUpdate(Trigger.New, Trigger.oldMap);
                SOVLinesTriggerHandler.afterUpdate(Trigger.New);
            }
        }
        if(Trigger.isDelete){
            SOVLinesTriggerHandler.updateSOVStatusBasedOnSOVLinesStatus(Trigger.Old);
        }
    }
    
    if(Trigger.isBefore && Trigger.isDelete){
        SOVLinesTriggerHandler.OnBeforeDelete(Trigger.old);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        SOVLinesTriggerHandler.OnBeforeupdate( Trigger.new,  trigger.oldMap);
        SOVLinesTriggerHandler.updateNewOriginalScheduledValue( Trigger.new,  trigger.oldMap);
        
            }
    
}