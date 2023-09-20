/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date: 15/09/2017
*/
trigger ChangeOrderTrigger on Change_Order__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    if(!BT_Utils.isTriggerDeactivate('Change_Order__c')){
        
        ChangeOrderTriggerHandler handler = new ChangeOrderTriggerHandler (Trigger.isExecuting, Trigger.size);
    
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
            handler.UpdateDateApprovedOnInsert(Trigger.New);
        }
         
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
            //handler.ManageBudgetLineOnInsert(Trigger.new);
        }
        
        else if(Trigger.isUpdate && Trigger.isBefore){
            
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
            //handler.changeOrderBeforeUpdate(Trigger.new);
            handler.checkPOBeforeUpdate(Trigger.new);
            handler.checkParentPOBeforeUpdate(Trigger.new);
            handler.UpdateDateApproved(Trigger.new, trigger.oldMap);
            //handler.BudgetLineUpdate(Trigger.new, trigger.oldMap);            
        }
        
        else if(Trigger.isUpdate && Trigger.isAfter){
            // handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            handler.DeleteBudgetLine(Trigger.old,Trigger.new, Trigger.newMap, Trigger.oldMap);
            handler.UpdateProjectValueInChangeOrder(Trigger.new, trigger.oldMap); 
            handler.UpdateContractor(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            //handler.ManageBudgetLineOnInsert(Trigger.new);     
            // handler.updateBudgetLineData(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);


              
        }
        
        else if(Trigger.isDelete && Trigger.isBefore){
           handler.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
        }
        
        else if(Trigger.isDelete && Trigger.isAfter ){
          //  handler.OnAfterDelete(Trigger.old); 
        }
    }
}