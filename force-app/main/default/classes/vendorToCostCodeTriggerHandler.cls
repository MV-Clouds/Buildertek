/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  27-Sep-2017
*/
public with sharing class vendorToCostCodeTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipVendorToCostCodeUpdateTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public vendorToCostCodeTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
 	public void OnBeforeInsert(buildertek__Vendor_To_Cost_Code_Link__c[] newLink){
		 		
 	}
     
 	public void OnBeforeUpdate(buildertek__Vendor_To_Cost_Code_Link__c[] oldLink, buildertek__Vendor_To_Cost_Code_Link__c[] updatedLink, Map<ID, buildertek__Vendor_To_Cost_Code_Link__c> LinkMap){
     	
 	}
     
 	public void OnBeforeDelete(buildertek__Vendor_To_Cost_Code_Link__c[] LinkToDelete, Map<ID, buildertek__Vendor_To_Cost_Code_Link__c> LinkMap){
     	updateCostCode(LinkToDelete);
 	}
     
 	public void OnAfterInsert(buildertek__Vendor_To_Cost_Code_Link__c[] newLink, Map<ID, buildertek__Vendor_To_Cost_Code_Link__c> newLinkMap){ 
 		updateCostCode(newLink);
 	}
     
 	public void OnAfterUpdate(buildertek__Vendor_To_Cost_Code_Link__c[] oldLink, buildertek__Vendor_To_Cost_Code_Link__c[] updatedLink, Map<ID, buildertek__Vendor_To_Cost_Code_Link__c> LinkMap, Map<Id, buildertek__Vendor_To_Cost_Code_Link__c> oldLinkMap){
 		updateCostCode(updatedLink);
 	}
 	
 	public void OnBeforeUpdate(buildertek__Vendor_To_Cost_Code_Link__c[] newLink, Map<ID, buildertek__Vendor_To_Cost_Code_Link__c> newLinkMap){
     
 	}
 	
 	public void OnAfterDelete(buildertek__Vendor_To_Cost_Code_Link__c[] oldLink){
     
 	}
 	
 	private void updateCostCode(buildertek__Vendor_To_Cost_Code_Link__c[] Links){
 		Map<Id, Account> vendors = new Map<Id, Account>();
 		for(buildertek__Vendor_To_Cost_Code_Link__c vendorLink:[Select Id, buildertek__Vendor__c, buildertek__Cost_Code__c, buildertek__Cost_Code__r.Name from buildertek__Vendor_To_Cost_Code_Link__c where buildertek__vendor__c IN:getVendorIds(Links)]){
 			
 			if(vendors.containsKey(vendorLink.buildertek__Vendor__c)){
 				vendors.get(vendorLink.buildertek__Vendor__c).buildertek__Cost_Code__c = vendors.get(vendorLink.buildertek__Vendor__c).buildertek__Cost_Code__c + ';'+vendorLink.Cost_Code__r.Name;
 			}else {
 				Account objAccount = new Account();
	 			objAccount.Id = vendorLink.buildertek__Vendor__c;
	 			objAccount.buildertek__cost_code__c = vendorLink.buildertek__Cost_Code__r.Name;
	 			vendors.put(vendorLink.buildertek__Vendor__c, objAccount);
 			}
 		}
 		if(Schema.sObjectType.Account.fields.Id.isUpdateable() &&
            Schema.sObjectType.Account.fields.buildertek__cost_code__c.isUpdateable()){
 		update vendors.values();
 	}
 	} 
 	
 	private set<Id> getVendorIds(buildertek__Vendor_To_Cost_Code_Link__c[] Links){
 		set<Id> vendorIds = new set<Id>();
 		for(buildertek__Vendor_To_Cost_Code_Link__c link:Links){
 			vendorIds.add(link.buildertek__vendor__c);
 		}
 		return vendorIds;
 	}
 	
}