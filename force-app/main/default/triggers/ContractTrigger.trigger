/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date: 15/09/2017
*/
trigger ContractTrigger on Contract__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    ContractTriggerHandler handler = new ContractTriggerHandler (Trigger.isExecuting, Trigger.size);
    
    if(!BT_Utils.isTriggerDeactivate('Contract__c')){
    
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }
         
        else if(Trigger.isInsert && Trigger.isAfter){
            // handler.OnAfterInsert(Trigger.new, Trigger.newMap);
            handler.onAfterInsertForProject(Trigger.new);
        }
        
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        }
        
        else if(Trigger.isUpdate && Trigger.isAfter){
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
            handler.AfterUpdateRSalesPrice(Trigger.new);
            handler.onAfterUpdateForProject(Trigger.new, Trigger.oldMap);
        }
        
        else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
            
        }
        
        else if(Trigger.isDelete && Trigger.isAfter){
            handler.OnAfterDelete(Trigger.old); 
            handler.onAfterDeleteForProject(Trigger.old);
        }
        
        // if(Trigger.isInsert || Trigger.isUpdate){
        //     handler.updateProjectContractAmount(Trigger.new);
        // }
    } else {
        if(Trigger.isInsert && Trigger.isAfter){
            handler.onAfterInsertForProject(Trigger.new);
        }
    
        if(Trigger.isUpdate && Trigger.isAfter){
            handler.onAfterUpdateForProject(Trigger.new, Trigger.oldMap);
        }
    
        if(Trigger.isDelete && Trigger.isAfter){
            handler.onAfterDeleteForProject(Trigger.old);
        }
    }
}