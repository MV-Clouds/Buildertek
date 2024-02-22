public class scheduleAssignResources {
    @AuraEnabled
    public static ScheduleDataWrapper fetchScheduleData(String scheduleId, String vendorId){
        ScheduleDataWrapper wrapper = new ScheduleDataWrapper();
        
        wrapper.scheduleList = [SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_1__r.Name,buildertek__Contractor_Resource_2__c,buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_3__c,buildertek__Contractor_Resource_3__r.Name, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish_Date__c FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c = :scheduleId AND buildertek__Contractor__c = :vendorId AND buildertek__Type__c = 'Task' ORDER BY Name ASC LIMIT 10000];
        wrapper.internalResourcesList = [SELECT Id, Name FROM User WHERE isActive = TRUE ORDER BY Name ASC LIMIT 10000];
        wrapper.contractorAndResourcesList = [SELECT Id, Name, (SELECT Id, Name, LastName, FirstName FROM Contacts) FROM Account WHERE buildertek__BT_Account_Type__c = 'Vendor' ORDER BY Name ASC];
        
        return wrapper;
    }
    
    public class ScheduleDataWrapper {
        @AuraEnabled public List<buildertek__Project_Task__c> scheduleList;
        @AuraEnabled public List<User> internalResourcesList;
        @AuraEnabled public List<Account> contractorAndResourcesList;
    }
    

}