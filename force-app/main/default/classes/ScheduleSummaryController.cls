public class ScheduleSummaryController {
    @AuraEnabled
    public static List<buildertek__Project_Task__c> gettaskOfSchedules(String recordId){
        List<buildertek__Project_Task__c> projecttask =  [SELECT Id, Name, buildertek__Finish__c, buildertek__Type__c, buildertek__Project__c, buildertek__Completion__c,buildertek__Contractor__c FROM buildertek__Project_Task__c WHERE buildertek__Project__c =: recordId AND buildertek__Type__c = 'Task' AND buildertek__Completion__c < 100 AND buildertek__Schedule__r.buildertek__Active__c = True];
        return projecttask;
    }
    @AuraEnabled
    public static List<Account> getContractorRecords() {
        List<Account> ContractorList =  [SELECT Id, Name FROM Account ORDER BY Name ASC];
        return ContractorList;
    }
}