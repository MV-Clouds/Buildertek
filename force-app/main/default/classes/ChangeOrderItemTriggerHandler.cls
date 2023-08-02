/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  19-Sep-2017
*/
public with sharing class ChangeOrderItemTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipChangeOrderItemUpdateTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public ChangeOrderItemTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
 	public void OnBeforeInsert(Change_Order_Item__c[] newChangeOrderItem){
 	    List<Change_Order_Item__c>coItem;
 	    if(Schema.sObjectType.Change_Order_Item__c.fields.id.isAccessible()
 	        && Schema.sObjectType.Change_Order_Item__c.fields.Auto_Number1__c.isAccessible()){
 	        coItem = [Select Id, Auto_Number1__c from Change_Order_Item__c 
 									 where Change_Order__c =:newChangeOrderItem[0].Change_Order__c 
 									 ORDER BY CREATEDDATE DESC  LIMIT 1];
 	    }							 
     	//BT_Utils.genrateAutoNumber(coItem, newChangeOrderItem, 'Auto_Number1__c');
 	}
     
 	public void OnBeforeUpdate(Change_Order_Item__c[] oldChangeOrderItem, Change_Order_Item__c[] updatedChangeOrderItem, Map<ID, Change_Order_Item__c> ChangeOrderItemMap){
     	
 	}
     
 	public void OnBeforeDelete(Change_Order_Item__c[] ChangeOrderItemToDelete, Map<ID, Change_Order_Item__c> ChangeOrderItemMap){
     	
 	}
     
 	public void OnAfterInsert(Change_Order_Item__c[] newChangeOrderItem, Map<ID, Change_Order_Item__c> newChangeOrderItemMap){ 
     	
     	// Create CO Item to Budget Item link
     	ChangeOrderDAO.createChangeOrderItemToBudgetItemLink(newChangeOrderItem);
     	ChangeOrderDAO.RollUpChangeOrderItemAmount(newChangeOrderItemMap.KeySet());
 	}
     
 	public void OnAfterUpdate(Change_Order_Item__c[] oldChangeOrderItem, Change_Order_Item__c[] updatedChangeOrderItem, Map<ID, Change_Order_Item__c> ChangeOrderItemMap, Map<Id, Change_Order_Item__c> oldChangeOrderItemMap){
    	
    	ChangeOrderDAO.RollUpChangeOrderItemAmount(ChangeOrderItemMap.KeySet());
 	}
 	
 	public void OnBeforeUpdate(Change_Order_Item__c[] newChangeOrderItem, Map<ID, Change_Order_Item__c> newChangeOrderItemMap){
     
 	}
 	
 	public void OnAfterDelete(Change_Order_Item__c[] oldChangeOrderItem){
     
 	}
}