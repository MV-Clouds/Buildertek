public without sharing class BT_SyncPOsOnScheduleController {
    
    @AuraEnabled
    public static POAndScheduleItemWrapper fetchPOAndScheduleItem(String scheduleId){
        POAndScheduleItemWrapper poAndScheduleItemWrapper = new POAndScheduleItemWrapper();
        try {
            if (String.isBlank(scheduleId)) {
                poAndScheduleItemWrapper.Message = 'id-blank';
                return poAndScheduleItemWrapper;
            }
            List<buildertek__Schedule__c> scheduleList = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Schedule__c WHERE Id = :scheduleId];
            List<buildertek__Project_Task__c> scheduleItemList = [SELECT Id, Name, buildertek__Contractor__c, buildertek__BT_Category__c, buildertek__Cost_Code__c, buildertek__Schedule__r.buildertek__Project__c FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c = :scheduleId AND buildertek__Type__c = 'Task' AND buildertek__Purchase_Order__c = null ORDER BY Name ASC];
            
            String projectId;
            if (!scheduleList.isEmpty()) {
                projectId = scheduleList[0].buildertek__Project__c;
            }

            List<buildertek__Purchase_Order__c> poList = new List<buildertek__Purchase_Order__c>();
            if (projectId != null) {
                poAndScheduleItemWrapper.poList = [SELECT Id, Name, buildertek__Description__c, buildertek__Vendor__c, buildertek__PO_Total__c, buildertek__Projected_Start_Date__c, buildertek__Projected_Completion_Date__c, buildertek__Completion__c, buildertek__Schedule__c,buildertek__Schedule_Item__c,buildertek__Category__c, buildertek__Cost_Code__c FROM buildertek__Purchase_Order__c WHERE buildertek__Schedule_Item__c = null AND buildertek__Project__c =:projectId AND (buildertek__Category__c != null OR buildertek__Cost_Code__c != null)];

                poAndScheduleItemWrapper.scheduleItemList = [SELECT Id, Name, buildertek__Contractor__c, buildertek__BT_Category__c, buildertek__Cost_Code__c, buildertek__Completion__c, buildertek__Start__c,buildertek__Finish__c, buildertek__Schedule__c  FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c = :scheduleId AND buildertek__Type__c = 'Task' AND buildertek__Purchase_Order__c = null AND (buildertek__Cost_Code__c != null OR buildertek__Contractor__c != null OR buildertek__BT_Category__c != null) ORDER BY Name ASC];
                
                poAndScheduleItemWrapper.Message = 'Success';
                
                return poAndScheduleItemWrapper;
            } else {
                poAndScheduleItemWrapper.Message = 'project-id-blank';
                return poAndScheduleItemWrapper;
            }
            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            poAndScheduleItemWrapper.Message = 'An error occurred: ' + e.getMessage();
        }
        return poAndScheduleItemWrapper;
    }

    @AuraEnabled
    public static String updateScheduleItemAndPOList( List<buildertek__Project_Task__c> scheduleItemList, List<buildertek__Purchase_Order__c> poList){
        try {
            if (!poList.isEmpty()) {
                update poList;
            }
    
            if (!scheduleItemList.isEmpty()) {
                update scheduleItemList;
            }
    
            return 'Success';
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return 'Error: ' + e.getMessage();
        }

    }

    public class POAndScheduleItemWrapper {
        @AuraEnabled
        public List<buildertek__Project_Task__c> scheduleItemList;

        @AuraEnabled
        public List<buildertek__Purchase_Order__c> poList;

        @AuraEnabled
        public String Message;
    }
    

}