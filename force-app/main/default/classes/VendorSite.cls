public without sharing class VendorSite {

    public VendorSite() {


    }

    @AuraEnabled
    public static string getAccountId(String userId) {
        System.debug('userId: ' + userId);
        User u = [SELECT Id, Contact.AccountId FROM User WHERE Id = :userId];
        System.debug('AccountId: ' + u.Contact.AccountId);
        return u.Contact.AccountId;
    }

    @AuraEnabled
    public static List<buildertek__Project_Task__c> getTasks(String accountId) {
        System.debug('accountId: ' + accountId);
        List<buildertek__Project_Task__c> tasks = [SELECT id, buildertek__Schedule__r.Name, buildertek__Project__r.Name, Name, buildertek__Status__c, buildertek__Expected_Start_Date__c, buildertek__Expected_End_Date__c, buildertek__Completion__c, buildertek__Contractor__r.Name, CreatedDate from buildertek__Project_Task__c where buildertek__Contractor__r.Id = :accountId];
        System.debug('tasks: ' + tasks);
        return tasks;
    }
    

}