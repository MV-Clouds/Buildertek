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
        List<Account> updatedWorkCompAccountList = new List<Account>();
        List<Account> updatedLiabilityAccountList = new List<Account>();
        for (Account acc : account) {
            if (acc.buildertek__Worker_s_Compensation_License_Expiration__c != null && acc.buildertek__Email_Address__c != null) {
                updatedWorkCompAccountList.add(acc);
            }
            if (acc.buildertek__General_Liability_License_Expiration__c != null && acc.buildertek__Email_Address__c != null) {
                updatedLiabilityAccountList.add(acc);
            }
        }

        if(updatedWorkCompAccountList.size() > 0){
            scheduleEmailDate(updatedWorkCompAccountList, 'Worker License Exp');
        }

        if(updatedLiabilityAccountList.size() > 0){
            scheduleEmailDate(updatedLiabilityAccountList, 'Liability License Exp');
        }
    }

    public void OnAfterUpdate(Account[] oldAccount, Account[] updatedAccount, Map<ID, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<Id> accountIds = new Set<Id>();
        List<Account> updatedWorkCompAccountList = new List<Account>();
        List<Account> updatedLiabilityAccountList = new List<Account>();
        
        for (Account acc : updatedAccount){
            if (oldAccountMap.get(acc.Id).buildertek__Trade_Type_Lookup__c != acc.buildertek__Trade_Type_Lookup__c){
                accountMap.put(acc.Id, acc);
            }
            if(oldAccountMap.get(acc.Id).buildertek__Qualification_Stage__c != acc.buildertek__Qualification_Stage__c 
                    && acc.buildertek__Qualification_Stage__c == 'Qualified'){
                accountIds.add(acc.Id); 
            }
            
            if ((oldAccountMap.get(acc.Id).buildertek__Worker_s_Compensation_License_Expiration__c != acc.buildertek__Worker_s_Compensation_License_Expiration__c) && acc.buildertek__Worker_s_Compensation_License_Expiration__c != null || (acc.buildertek__Email_Address__c != null && oldAccountMap.get(acc.Id).buildertek__Email_Address__c != acc.buildertek__Email_Address__c)) {
                updatedWorkCompAccountList.add(acc);
            }
            if ((oldAccountMap.get(acc.Id).buildertek__General_Liability_License_Expiration__c != acc.buildertek__General_Liability_License_Expiration__c) && acc.buildertek__General_Liability_License_Expiration__c != null || (acc.buildertek__Email_Address__c != null && oldAccountMap.get(acc.Id).buildertek__Email_Address__c != acc.buildertek__Email_Address__c)) {
                updatedLiabilityAccountList.add(acc);
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
        if(updatedWorkCompAccountList.size() > 0){
            scheduleEmailDate(updatedWorkCompAccountList, 'Worker License Exp');
        }
        
        if (updatedLiabilityAccountList.size() > 0){
            scheduleEmailDate(updatedLiabilityAccountList, 'Liability License Exp');
        }
    }

    public void OnBeforeDelete(Account[] accountToDelete, Map<ID, Account> accountMap){
    }

    public void OnAfterDelete(Account[] accountToDelete){
    }
    
    public static void scheduleEmailDate(List<Account> accountList, String licenseType) {
        List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [SELECT Id, Name, buildertek__Days_pior_to_expiration__c, buildertek__Notify_on_Cert_Expiration__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name = 'Account Configuration' LIMIT 1];
    
        if (adminInterfaceNodeConfigurations.size() > 0 && adminInterfaceNodeConfigurations[0].buildertek__Notify_on_Cert_Expiration__c) {
            Integer daysToSubtract = adminInterfaceNodeConfigurations[0].buildertek__Days_pior_to_expiration__c.intValue();
    
            for (Account acc : accountList) {
                if (licenseType == 'Worker License Exp') {
                    Date workerCompDate = acc.buildertek__Worker_s_Compensation_License_Expiration__c;
                    Date workerCompDateMinusDate = workerCompDate.addDays(-daysToSubtract);
                    String jobNameWorkerComp = 'EmailJob-Worker License Exp-' + Date.today();                    
                    System.schedule(jobNameWorkerComp,  '0 0 10 ' + workerCompDateMinusDate.day() + ' ' + workerCompDateMinusDate.month() + ' ? ' + workerCompDateMinusDate.year(), new AccountExpirationEmailSender(acc, 'Worker License Exp'));
                }
                if (licenseType == 'Liability License Exp') {
                    Date generalLiabilityDate = acc.buildertek__General_Liability_License_Expiration__c;
                    Date generalLiabilityMinusDate = generalLiabilityDate.addDays(-daysToSubtract);
                    String jobNameGeneralLiability = 'EmailJob-Liability License Exp-' + Date.today();
                    System.schedule(jobNameGeneralLiability,  '0 0 10 ' + generalLiabilityMinusDate.day() + ' ' + generalLiabilityMinusDate.month() + ' ? ' + generalLiabilityMinusDate.year(), new AccountExpirationEmailSender(acc, 'Liability License Exp'));
                }
            }
        }
    }
    
}