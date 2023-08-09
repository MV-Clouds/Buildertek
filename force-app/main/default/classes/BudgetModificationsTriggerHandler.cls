/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  27-Nov-2017
*/
public with sharing class BudgetModificationsTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipBudgetModificationsUpdateTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public BudgetModificationsTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
 	public void OnBeforeInsert(Budget_Modifications__c[] newBudgetModifications){
     	
 	}
     
 	public void OnBeforeUpdate(Budget_Modifications__c[] oldBudgetModifications, Budget_Modifications__c[] updatedBudgetModifications, Map<ID, Budget_Modifications__c> BudgetModificationMap){
     	
 	}
     
 	public void OnBeforeDelete(Budget_Modifications__c[] BudgetModificationsToDelete, Map<ID, Budget_Modifications__c> BudgetModificationMap){
     	
 	}
     
 	public void OnAfterInsert(Budget_Modifications__c[] newBudgetModifications, Map<ID, Budget_Modifications__c> newBudgetModificationsMap){ 
     	
 	}
     
 	public void OnAfterUpdate(Budget_Modifications__c[] oldBudgetModifications, Budget_Modifications__c[] updatedBudgetModifications, Map<ID, Budget_Modifications__c> BudgetModificationMap, Map<Id, Budget_Modifications__c> oldBudgetModificationsMap){
    	BudgetDAO.updateBudgetItemModificationInAmount(updatedBudgetModifications);
 	}
 	
 	public void OnBeforeUpdate(Budget_Modifications__c[] newBudgetModifications, Map<ID, Budget_Modifications__c> newBudgetModificationsMap){
     
 	}
 	
 	public void OnAfterDelete(Budget_Modifications__c[] oldBudgetModifications){
     
 	}
}