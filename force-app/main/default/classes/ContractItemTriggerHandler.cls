/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  17-Dec-2017
*/
public with sharing class ContractItemTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipContractItemTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public ContractItemTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
 	public void OnBeforeInsert(Contract_Item__c[] newContractItems){
     	List<Contract_Item__c> cItems = new List<Contract_Item__c>();
     	for(Contract_Item__c cItem: newContractItems) {
     		if(cItem.buildertek__Contract_Item_Group__c == null) {
     			cItems.add(cItem);
     		}
     	}
     	
     	// Set default Grouping
     	if(!cItems.isEmpty()) ContractDAO.setDefaultGrouping(cItems);
     	
 	}
     
 	public void OnBeforeUpdate(Contract_Item__c[] oldContractItems, Contract_Item__c[] updatedContractItems, Map<ID, Contract_Item__c> ContractItemMap){
     	
 	}
     
 	public void OnBeforeDelete(Contract_Item__c[] ContractItemToDelete, Map<ID, Contract_Item__c> ContractItemMap){
     	
 	}
     
 	public void OnAfterInsert(Contract_Item__c[] newContractItems, Map<ID, Contract_Item__c> newContractItemsMap){ 
     	
     	// Create PO Item to Budget Item link
     	// PurchaseOrderDAO.createPurchaseOrderItemToBudgetItemLink(newContractItems);
     	// PurchaseOrderDAO.RollUpPurchaseOrderItemAmount(newContractItemsMap.KeySet());
 	}
     
 	public void OnAfterUpdate(Contract_Item__c[] oldContractItems, Contract_Item__c[] updatedContractItems, Map<ID, Contract_Item__c> ContractItemMap, Map<Id, Contract_Item__c> oldContractItemsMap){
    	
    	//PurchaseOrderDAO.RollUpPurchaseOrderItemAmount(ContractItemMap.KeySet());
 	}
 	
 	public void OnBeforeUpdate(Contract_Item__c[] newContractItems, Map<ID, Contract_Item__c> newContractItemsMap){
     
 	}
 	
 	public void OnAfterDelete(Contract_Item__c[] oldContractItems){
     
 	}
}