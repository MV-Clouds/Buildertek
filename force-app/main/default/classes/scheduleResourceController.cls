public with sharing class scheduleResourceController {
    @AuraEnabled
    public static ScheduleDataWrapper fetchScheduleData(String scheduleId){
        ScheduleDataWrapper wrapper = new ScheduleDataWrapper();
        
        try {
            wrapper.scheduleList = [SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_1__r.Name,buildertek__Contractor_Resource_2__c,buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_3__c,buildertek__Contractor_Resource_3__r.Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Schedule__r.buildertek__Start_Date__c, buildertek__Schedule__r.buildertek__End_Date__c FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c = :scheduleId AND buildertek__Type__c = 'Task' ORDER BY Name ASC LIMIT 10000];

            Date scheduleStartDate = wrapper.scheduleList[0].buildertek__Schedule__r.buildertek__Start_Date__c;
            Date scheduleEndDate = wrapper.scheduleList[0].buildertek__Schedule__r.buildertek__End_Date__c;

            wrapper.internalResourcesList = [SELECT Id, Name FROM User WHERE isActive = TRUE ORDER BY Name ASC LIMIT 10000];
            
            wrapper.contractorAndResourcesList = [SELECT Id, Name, (SELECT Id, Name, LastName, FirstName FROM Contacts) FROM Account WHERE buildertek__BT_Account_Type__c = 'Vendor' ORDER BY Name ASC];
            
            wrapper.conflictingSchedulesList = [SELECT Id, Name, buildertek__Schedule__c, buildertek__Start__c, buildertek__Finish__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_1__r.Name,buildertek__Contractor_Resource_2__c,buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_3__c,buildertek__Contractor_Resource_3__r.Name FROM buildertek__Project_Task__c WHERE buildertek__Type__c = 'Task' AND (buildertek__Start__c <= :scheduleEndDate AND buildertek__Finish__c >= :scheduleStartDate) AND buildertek__Schedule__r.buildertek__Active__c = TRUE AND buildertek__Schedule__c != :scheduleId];

            return wrapper;

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            return null;
        }
    }
    
    @AuraEnabled
    public static String updateScheduleItemResources(buildertek__Project_Task__c scheduleItem){
        try {
            buildertek__Project_Task__c scheduleItemToUpdate = new buildertek__Project_Task__c(Id = scheduleItem.Id);
            scheduleItemToUpdate.buildertek__Contractor__c = scheduleItem.buildertek__Contractor__c;
            scheduleItemToUpdate.buildertek__Contractor_Resource_1__c = scheduleItem.buildertek__Contractor_Resource_1__c;
            scheduleItemToUpdate.buildertek__Contractor_Resource_2__c = scheduleItem.buildertek__Contractor_Resource_2__c;
            scheduleItemToUpdate.buildertek__Contractor_Resource_3__c = scheduleItem.buildertek__Contractor_Resource_3__c;
            update scheduleItemToUpdate;
            return 'Success';
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            return 'Error';
        }
    }

    @AuraEnabled
    public static List<buildertek__Project_Task__c> checkForConflictingSchedules(Date startDate, Date endDate) {
        try {
            List<buildertek__Project_Task__c> conflictingSchedules = [SELECT Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Schedule__r.buildertek__Description__c FROM buildertek__Project_Task__c WHERE buildertek__Type__c = 'Task' AND (buildertek__Start__c <= :endDate AND buildertek__Finish__c >= :startDate) AND buildertek__Schedule__r.buildertek__Active__c = TRUE];

            return conflictingSchedules;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            return null;
        }
    }

    public class ScheduleDataWrapper {
        @AuraEnabled public List<buildertek__Project_Task__c> scheduleList;
        @AuraEnabled public List<User> internalResourcesList;
        @AuraEnabled public List<Account> contractorAndResourcesList;
        @AuraEnabled public List<buildertek__Project_Task__c> conflictingSchedulesList;
    }
}