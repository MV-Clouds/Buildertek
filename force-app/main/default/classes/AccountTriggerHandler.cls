public with sharing class AccountTriggerHandler{
    public static Boolean isFirstTime = true;
    public static Boolean isTask = true;
    public static Boolean blnSkipTaskTrigger = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public AccountTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(Account[] newAccount){
  
    }

    public void OnBeforeUpdate(Account[] oldAccount, Account[] updatedAccount, Map<ID, Account> newAccountMap, Map<Id, Account> oldAccountMap){
      for(Account acc:updatedAccount){
       if(acc.buildertek__Qualification_Stage__c == 'Fully Executed'){
              acc.buildertek__Pre_Qualified__c = true;
             
              
              
          }
         
      }
       //update accountList;
    }

    public void OnAfterInsert(Account[] account, Map<ID, Account> accountMap){
        List<buildertek__Project_Task__c> projectTaskList = [Select Id, Name, buildertek__Contractor__c
                                                             FROM buildertek__Project_Task__c
                                                             WHERE buildertek__Contractor__c IN :accountMap.keySet()];
        for (buildertek__Project_Task__c projectTask : projectTaskList){
            if (accountMap.get(projectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c != null){
                projectTask.buildertek__Trade_Type__c = accountMap.get(projectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c;
            }
           
        }
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        update projectTaskList;
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
        
      /* if(!Test.isRunningTest()){
        if(isFirstTime){
            boxAPICall_handler.getboxFolderID(accountMap.Keyset());
        }
        }*/
    }

    public void OnAfterUpdate(Account[] oldAccount, Account[] updatedAccount, Map<ID, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : updatedAccount){
            if (oldAccountMap.get(acc.Id).buildertek__Trade_Type_Lookup__c != acc.buildertek__Trade_Type_Lookup__c){
                accountMap.put(acc.Id, acc);
            }
            if(oldAccountMap.get(acc.Id).buildertek__Qualification_Stage__c != acc.buildertek__Qualification_Stage__c 
                    && acc.buildertek__Qualification_Stage__c == 'Qualified'){
                accountIds.add(acc.Id); 
            } 
        }
        if(accountIds.size() > 0){
            //QualifiedEmailController.sendEmail(accountIds);   
        }
        List<buildertek__Project_Task__c> projectTaskList = [Select Id, Name, buildertek__Contractor__c
                                                             FROM buildertek__Project_Task__c
                                                             WHERE buildertek__Contractor__c IN :accountMap.keySet()];
        for (buildertek__Project_Task__c projectTask : projectTaskList){
            projectTask.buildertek__Trade_Type__c = accountMap.get(projectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c;
        }
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        update projectTaskList;
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
        ProjectTaskTriggerHandler.isFirstTime = false;
    }

    public void OnBeforeDelete(Account[] accountToDelete, Map<ID, Account> accountMap){
    }

    public void OnAfterDelete(Account[] accountToDelete){
    }
}