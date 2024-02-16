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
            
            if ((oldAccountMap.get(acc.Id).buildertek__Worker_s_Compensation_License_Expiration__c != acc.buildertek__Worker_s_Compensation_License_Expiration__c) && (acc.buildertek__Worker_s_Compensation_License_Expiration__c != null || (acc.buildertek__Email_Address__c != null && oldAccountMap.get(acc.Id).buildertek__Email_Address__c != acc.buildertek__Email_Address__c))) {
                updatedWorkCompAccountList.add(acc);
            }

            if ((oldAccountMap.get(acc.Id).buildertek__General_Liability_License_Expiration__c != acc.buildertek__General_Liability_License_Expiration__c) && (acc.buildertek__General_Liability_License_Expiration__c != null || (acc.buildertek__Email_Address__c != null && oldAccountMap.get(acc.Id).buildertek__Email_Address__c != acc.buildertek__Email_Address__c))) {
                updatedLiabilityAccountList.add(acc);
            }
            
            if (acc.buildertek__Worker_s_Compensation_License_Expiration__c == null ) {
                abortJobIfLicenseExpirationIsNull(acc, 'Worker License Exp');
            }

            if (acc.buildertek__General_Liability_License_Expiration__c == null ) {
                abortJobIfLicenseExpirationIsNull(acc, 'Liability License Exp');
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
        Set<String> jobNames = new Set<String>();
        for (Account acc : accountToDelete) {
            jobNames.add('EmailJob-Worker License Exp-' + acc.Id);
            jobNames.add('EmailJob-Liability License Exp-' + acc.Id);
        }
        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name IN :jobNames];
        for (CronTrigger job : jobs) {
            System.abortJob(job.Id);
        }
    }

    public void OnAfterDelete(Account[] accountToDelete){
    }
    
    public static void scheduleEmailDate(List<Account> accountList, String licenseType) {
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfiguration = [SELECT Id, buildertek__Days_pior_to_expiration__c, buildertek__Notify_on_Cert_Expiration__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name = 'Account Configuration' LIMIT 1];
        
        if (adminInterfaceNodeConfiguration != null && adminInterfaceNodeConfiguration.buildertek__Notify_on_Cert_Expiration__c) {
            Integer daysToSubtract = adminInterfaceNodeConfiguration.buildertek__Days_pior_to_expiration__c.intValue();
            
            Set<String> existingJobNames = new Set<String>();
            Map<String, Id> jobNameToIdMap = new Map<String, Id>();
    
            for (CronTrigger job : [SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE 'EmailJob-%']) {
                existingJobNames.add(job.CronJobDetail.Name);
                jobNameToIdMap.put(job.CronJobDetail.Name, job.Id);
            }
    
            for (Account acc : accountList) {
                String jobName;
                if (licenseType == 'Worker License Exp') {
                    jobName = 'EmailJob-Worker License Exp-' + acc.Id;                    
                } else if (licenseType == 'Liability License Exp') {
                    jobName = 'EmailJob-Liability License Exp-' + acc.Id;
                } else {
                    continue;
                }
                
                if (existingJobNames.contains(jobName)) {
                    Id jobId = jobNameToIdMap.get(jobName);
                    System.abortJob(jobId);
                }
    
                Date expirationDate = (licenseType == 'Worker License Exp') ? acc.buildertek__Worker_s_Compensation_License_Expiration__c : acc.buildertek__General_Liability_License_Expiration__c;
                Date jobDate = expirationDate.addDays(-daysToSubtract);
                String cronExp = '0 0 10 ' + jobDate.day() + ' ' + jobDate.month() + ' ? ' + jobDate.year();
                if (jobDate < Date.today() || (jobDate == Date.today() && System.now().hour() > 10)) {
                    continue;
                }
                System.schedule(jobName,  cronExp, new AccountExpirationEmailSender(acc, licenseType));
            }
        }
    }
    
    private void abortJobIfLicenseExpirationIsNull(Account acc, String licenseType) {
        String jobName = 'EmailJob-' + licenseType + '-' + acc.Id;
        List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName LIMIT 1];

        if (jobs.size() > 0) {
            System.abortJob(jobs[0].Id);
        }
    }
    
}