/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date: 27/09/2017
*/

trigger RFQTrigger on RFQ__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if(!BT_Utils.isTriggerDeactivate('RFQ__c') && !RFQTriggerHandler.blnSkipRFQUpdateTrigger){
        
        RFQTriggerHandler handler = new RFQTriggerHandler (Trigger.isExecuting, Trigger.size);
    
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
         
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        }
        
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        }
        
        else if(Trigger.isUpdate && Trigger.isAfter){
            
            
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            if (RFQTriggerHandler.blnSkipemaileTrigger ){
                return;
            }else{
                handler.OnAfterUpdateforrejectedvendors(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
                
            }
            handler.OnAfterUpdateforAward(Trigger.new);
            handler.onAfterUpdateTheBudget(Trigger.new, Trigger.oldMap);
        }
        
        else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
        }
        
        else if(Trigger.isDelete && Trigger.isAfter){
            handler.OnAfterDelete(Trigger.old); 
        }
    }
}