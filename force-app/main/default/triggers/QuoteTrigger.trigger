/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date: 15/09/2017
*/
trigger QuoteTrigger on Quote__c (before insert, before update, after insert, after update,before delete) {
    
if(!BT_Utils.isTriggerDeactivate('Quote__c')){
        
        QuoteTriggerHandler handler = new QuoteTriggerHandler (Trigger.isExecuting, Trigger.size);
    
        if(Trigger.isInsert && Trigger.isBefore){
            if(QuoteTriggerHandler.blnSkipQuoteUpdateTrigger){
                return;
            }else{
                handler.OnBeforeInsert(Trigger.new);
            }
            
        }
         
        else if(Trigger.isInsert && Trigger.isAfter){
            if(QuoteTriggerHandler.blnSkipQuoteUpdateTrigger){
                return;
            }else{
                handler.OnAfterInsert(Trigger.new, Trigger.newMap);
            }
        }
        
        else if(Trigger.isUpdate && Trigger.isBefore){
            if(QuoteTriggerHandler.blnSkipQuoteUpdateTrigger){
                return;
            }else{
                handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
            }
            
        }
        
        else if(Trigger.isUpdate && Trigger.isAfter){
            if(QuoteTriggerHandler.blnSkipQuoteUpdateTrigger){
                return;
            }else{
                handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            }
            
        }
        
        else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
        }
        
        else if(Trigger.isDelete && Trigger.isAfter){
            handler.OnAfterDelete(Trigger.old); 
        }
    }
    
}


/*trigger QuoteTrigger on Quote__c (before insert, before update, after insert, after update,before delete) {
    
    if(!BT_Utils.isTriggerDeactivate('Quote__c')){
        
        QuoteTriggerHandler handler = new QuoteTriggerHandler (Trigger.isExecuting, Trigger.size);
    
        if(Trigger.isInsert && Trigger.isBefore){
            if(QuoteTriggerHandler.blnSkipQuoteUpdateTrigger){
                return;
            }else{
                handler.OnBeforeInsert(Trigger.new);
            }
            
        }
         
        else if(Trigger.isInsert && Trigger.isAfter){
            if(QuoteTriggerHandler.blnSkipQuoteUpdateTrigger){
                return;
            }else{
                handler.OnAfterInsert(Trigger.new, Trigger.newMap);
            }
        }
        
        else if(Trigger.isUpdate && Trigger.isBefore){
            if(QuoteTriggerHandler.blnSkipQuoteUpdateTrigger){
                return;
            }else{
                handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
            }
            
        }
        
        else if(Trigger.isUpdate && Trigger.isAfter){
            if(QuoteTriggerHandler.blnSkipQuoteUpdateTrigger){
                return;
            }else{
                handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            }
            
        }
        
        else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
        }
        
        else if(Trigger.isDelete && Trigger.isAfter){
            handler.OnAfterDelete(Trigger.old); 
        }
    }
    
}*/