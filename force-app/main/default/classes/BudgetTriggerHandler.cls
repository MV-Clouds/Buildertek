/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  19-Sep-2017
*/
public with sharing class BudgetTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipBudgetTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public BudgetTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
 	public void OnBeforeInsert(Budget__c[] newBudgets){
     	BT_Utils.genrateAutoNumber([Select Id, Auto_Number__c from Budget__c 
 									 where Project__c =:newBudgets[0].Project__c 
 									 ORDER BY CREATEDDATE DESC  LIMIT 1], newBudgets, 'Auto_Number__c');
 	}
     
 	public void OnBeforeUpdate(Budget__c[] oldBudgets, Budget__c[] updatedBudgets, Map<ID, Budget__c> BudgetMap){
     	
 	}
     
 	public void OnBeforeDelete(Budget__c[] BudgetToDelete, Map<ID, Budget__c> BudgetMap){
     	
 	}
     
 	public void OnAfterInsert(Budget__c[] newBudgets, Map<ID, Budget__c> newBudgetsMap){
		 List<Id> lookupIds = new List<Id>();
		 for (Budget__c budget : newBudgets) {
			 lookupIds.add(budget.buildertek__Project__c);
		 }
		 System.debug('Inserted Lookup IDs: ' + lookupIds);
		//  List<Budget__c> budgets = new List<Budget__c>();
        // budgets = [SELECT Id, buildertek__Total_Costs__c, buildertek__Sales_Price__c FROM Budget__c WHERE buildertek__Project__c = :lookupIds];
		// Map<Id, Decimal> accountCurrencyMap = new Map<Id, Decimal>();
        
        // // Calculate the total currency value for each Account
        // for (Budget__c budget : budgets) {
        //     if (accountCurrencyMap.containsKey(budget.AccountId)) {
        //         Decimal totalCurrency = accountCurrencyMap.get(budget.AccountId) + budget.CurrencyField__c;
        //         accountCurrencyMap.put(budget.AccountId, totalCurrency);
        //     } else {
        //         accountCurrencyMap.put(budget.AccountId, budget.CurrencyField__c);
        //     }
        // }
        
        // // Update the Account records with the total currency values
        // List<Account> accountsToUpdate = new List<Account>();
        // for (Id accountId : accountCurrencyMap.keySet()) {
        //     Account account = new Account(Id = accountId, TotalCurrencyField__c = accountCurrencyMap.get(accountId));
        //     accountsToUpdate.add(account);
        // }
        
        // // Perform the update operation
        // if (!accountsToUpdate.isEmpty()) {
        //     update accountsToUpdate;
        // }
        
 	}
     
 	public void OnAfterUpdate(Budget__c[] oldBudgets, Budget__c[] updatedBudgets, Map<ID, Budget__c> BudgetMap, Map<Id, Budget__c> oldBudgetsMap){
    	
 	}
 	
 	public void OnBeforeUpdate(Budget__c[] newBudgets, Map<ID, Budget__c> newBudgetsMap){
     
 	}
 	
 	public void OnAfterDelete(Budget__c[] oldBudgets){
        try {
            Set<Id> projectIdsToUpdate = new Set<Id>();

            for (buildertek__Budget__c budget : oldBudgets) {
                if (budget.buildertek__Project__c != null) {
                    projectIdsToUpdate.add(budget.buildertek__Project__c);
                }
            }

            if (!projectIdsToUpdate.isEmpty()) {
                updateAmountOnProject(projectIdsToUpdate);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
 	}

    public void updateAmountOnProject(Set<Id> ProjectIds) {
        try {
            Map<Id, AggregateResult> totalAmountMap = new Map<Id, AggregateResult>();
            for (AggregateResult aggregatedResult : [SELECT buildertek__Project__c, SUM(buildertek__Original_Budget__c) originalAmount, SUM(buildertek__Total_Costs__c) totalCosts, SUM(buildertek__Total_Sales_Price__c) totalSalesPrice FROM buildertek__Budget__c WHERE buildertek__Project__c IN :ProjectIds GROUP BY buildertek__Project__c]){
                Id ProjectId = (Id)aggregatedResult.get('buildertek__Project__c');
                totalAmountMap.put(ProjectId, aggregatedResult);
            }
            
            List<buildertek__Project__c> ProjectToUpdate = new List<buildertek__Project__c>();
            
            for (Id projectID :ProjectIds) {
                if(totalAmountMap.containsKey(projectID)) {
                    AggregateResult aggregatedResult = totalAmountMap.get(projectID);
                    Decimal originalAmount = (Decimal)aggregatedResult.get('originalAmount');
                    Decimal totalCosts = (Decimal)aggregatedResult.get('totalCosts');
                    Decimal totalSalesPrice = (Decimal)aggregatedResult.get('totalSalesPrice');

                    buildertek__Project__c project = new buildertek__Project__c(Id = projectID);
                    project.buildertek__Original_Budget__c = originalAmount;
                    project.buildertek__Total_Costs__c = totalCosts;
                    project.buildertek__Total_Sales_Price__c = totalSalesPrice;
                    ProjectToUpdate.add(project);
                } else {
                    buildertek__Project__c project = new buildertek__Project__c(Id = projectID);
                    project.buildertek__Original_Budget__c = 0;
                    project.buildertek__Total_Costs__c = 0;
                    project.buildertek__Total_Sales_Price__c = 0;
                    ProjectToUpdate.add(project);
                }
            }
            System.debug('ProjectToUpdate: ' + ProjectToUpdate);
            if (!ProjectToUpdate.isEmpty()) {
                update ProjectToUpdate;
            }

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
}