/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date: 15/09/2017
 */
trigger PurchaseOrderTrigger on Purchase_Order__c(after delete, after insert, after undelete, after update, before delete, before insert, before update ){

    PurchaseOrderTriggerHandler handler = new PurchaseOrderTriggerHandler(Trigger.isExecuting, Trigger.size);

    if (!BT_Utils.isTriggerDeactivate('Purchase_Order__c') && !PurchaseOrderTriggerHandler.blnSkipPurchaseOrderUpdateTrigger){

        if (Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        } else if (Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
            handler.updateTotalCostOnBudgetLine(Trigger.new, Trigger.newMap,trigger.oldMap);
            handler.updateprojectonpoinsert(Trigger.new);
        } else if (Trigger.isUpdate && Trigger.isBefore){
           handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
        } else if (Trigger.isUpdate && Trigger.isAfter ){
            handler.updateTotalCostOnBudgetLine(Trigger.new, Trigger.newMap,trigger.oldMap);
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            handler.updateAmountonProject(Trigger.new, Trigger.oldMap);
            // handler.removePOFromBudgetLine(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete && Trigger.isBefore){
            // PurchaseOrder_handler.handledelete(Trigger.old);
            handler.removePOFromBudgetLine(Trigger.old, Trigger.oldMap);
        } else if (Trigger.isDelete && Trigger.isAfter){
            // handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
            handler.updateprojectonpodelete(Trigger.old);
        }
    } else {
        if (Trigger.isInsert && Trigger.isAfter){
            handler.updateprojectonpoinsert(Trigger.new);
        } else if (Trigger.isUpdate && Trigger.isAfter ){
            handler.updateAmountonProject(Trigger.new, Trigger.oldMap);
            // handler.removePOFromBudgetLine(Trigger.new, Trigger.oldMap);
        } else if (Trigger.isDelete && Trigger.isAfter){
            handler.updateprojectonpodelete(Trigger.old);
        } else if (Trigger.isBefore && Trigger.isDelete) {
            handler.removePOFromBudgetLine(Trigger.old, Trigger.oldMap);
        }
    }
}