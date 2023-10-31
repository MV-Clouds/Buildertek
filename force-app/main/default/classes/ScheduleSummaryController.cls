public with sharing class ScheduleSummaryController {
    @AuraEnabled
    public static List<buildertek__Project_Task__c> gettaskOfSchedules(String recordId){
        List<buildertek__Project_Task__c> projecttask =  [SELECT Id, Name, buildertek__Finish__c, buildertek__Type__c, buildertek__Project__c, buildertek__Completion__c FROM buildertek__Project_Task__c WHERE buildertek__Project__c =: recordId AND buildertek__Type__c = 'Task'];
        return projecttask;
    }
    
}