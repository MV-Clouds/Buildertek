public with sharing class SyncVendorScheduleItem{

    @AuraEnabled
    public static vendorsAndScheduleItemsWrapper fetchVendorAndSchedulItemData(String schedulId) {
        try {
            vendorsAndScheduleItemsWrapper wrapper = new vendorsAndScheduleItemsWrapper();

            if (String.isBlank(schedulId)) {
                wrapper.Message = 'id-blank';
                return wrapper;
            }

            buildertek__Schedule__c schedule = [SELECT id, Name, buildertek__Project__c FROM buildertek__Schedule__c WHERE id = :schedulId];
            String projectId = schedule.buildertek__Project__c;

            if (!String.isBlank(projectId)) {
                wrapper.vendorList = [SELECT Id, Name, buildertek__Account__c, buildertek__Account__r.Name, buildertek__BT_Cost_Code__c, buildertek__BT_Grouping__c, buildertek__Trade_Type__c FROM buildertek__Project_Vendors__c WHERE buildertek__BT_Project__c =: projectId AND (buildertek__BT_Cost_Code__c != null OR buildertek__Trade_Type__c != null OR buildertek__BT_Grouping__c != null) LIMIT 1000];
                wrapper.schedulItemList = [SELECT Id, Name, buildertek__Start__c, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Finish__c, buildertek__Type__c, buildertek__Cost_Code__c, buildertek__Trade_Type__c, buildertek__BT_Grouping__c from buildertek__Project_task__c Where buildertek__Project__c =: projectId AND (buildertek__Cost_Code__c != null OR buildertek__Trade_Type__c != null OR buildertek__BT_Grouping__c != null) AND buildertek__Contractor__c = null AND buildertek__Type__c != 'Milestone'];
                wrapper.Message = 'success';
                return wrapper;
            } else {
                wrapper.Message = 'project-id-blank';
                return wrapper;
            }

        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }

            vendorsAndScheduleItemsWrapper wrapper = new vendorsAndScheduleItemsWrapper();
            wrapper.Message = e.getMessage();
            return wrapper;
        }
    }

    @AuraEnabled
    public static String updateScheduleItemList(List<buildertek__Project_task__c> scheduleItemList) {
        try {
            update scheduleItemList;
            return 'success';
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return e.getMessage();
        }
    }

    public class vendorsAndScheduleItemsWrapper{
        @AuraEnabled
        public List<buildertek__Project_Vendors__c> vendorList;
        @AuraEnabled
        public List<buildertek__Project_Task__c> schedulItemList;
        @AuraEnabled
        public String Message;
    }
}