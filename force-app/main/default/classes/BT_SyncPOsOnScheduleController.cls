public without sharing class BT_SyncPOsOnScheduleController {
    
    @AuraEnabled
    public static List<buildertek__Project_Task__c> fetchScheduleItem(String scheduleId){
        try {
            List<buildertek__Project_Task__c> scheduleItemList = [SELECT Id, Name, buildertek__Type__c FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c = :scheduleId AND buildertek__Type__c = 'Task' AND buildertek__Purchase_Order__c = null ORDER BY Name ASC];
            return scheduleItemList;
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }
    
    @AuraEnabled
    public static List<buildertek__Purchase_Order__c> fetchAllPOs(String scheduleId){
        try {
            Id projectId = [SELECT Id, buildertek__Project__c FROM buildertek__Schedule__c WHERE Id = :scheduleId].buildertek__Project__c;
            if (projectId == null) {
                return null;
            }
            List<buildertek__Purchase_Order__c> poList = [SELECT Id, Name, buildertek__Description__c, buildertek__Vendor__r.Name, buildertek__PO_Total__c FROM buildertek__Purchase_Order__c WHERE buildertek__Schedule_Item__c = null AND buildertek__Project__c =:projectId ORDER BY Name ASC];
            return poList;
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }
    
    @AuraEnabled
    public static String setPOForScheduleItem(String schedulePO, String scheduleId) {
        try {
            List<SchedulePOWrapper> schedulePOList = (List<SchedulePOWrapper>)JSON.deserialize(schedulePO, List<SchedulePOWrapper>.class);
            Set<Id> poIds = new Set<Id>();
            Set<Id> scheduleItemIds = new Set<Id>();
    
            for (SchedulePOWrapper schedulePOItem : schedulePOList) {
                poIds.add(schedulePOItem.poId);
                scheduleItemIds.add(schedulePOItem.scheduleItemId);
            }
            
            List<buildertek__Purchase_Order__c> poList = [SELECT Id, Name, buildertek__Description__c, buildertek__Schedule__c, buildertek__Completion__c, buildertek__Schedule_Item__c,buildertek__Projected_Start_Date__c, buildertek__Projected_Completion_Date__c FROM buildertek__Purchase_Order__c WHERE Id IN :poIds];
            List<buildertek__Project_Task__c> scheduleItemList = [SELECT Id, Name, buildertek__Completion__c, buildertek__Purchase_Order__c, buildertek__Start__c, buildertek__Finish__c FROM buildertek__Project_Task__c WHERE Id IN :scheduleItemIds];
            Map<Id, buildertek__Project_Task__c> scheduleItemMap = new Map<Id, buildertek__Project_Task__c>();
            for (SchedulePOWrapper schedulePOItem : schedulePOList) {
                
                for (buildertek__Project_Task__c scheduleItem : scheduleItemList) {
                    if (schedulePOItem.scheduleItemId == scheduleItem.Id) {
                        scheduleItem.buildertek__Purchase_Order__c = schedulePOItem.poId;
                        scheduleItemMap.put(scheduleItem.Id, scheduleItem);
                        System.debug('scheduleItem: ' + scheduleItem);
                    }
                }

                for (buildertek__Purchase_Order__c po : poList) {
                    if (schedulePOItem.poId == po.Id) {
                        po.buildertek__Schedule__c = scheduleId;
                        po.buildertek__Schedule_Item__c = schedulePOItem.scheduleItemId;
                        po.buildertek__Completion__c = scheduleItemMap.get(schedulePOItem.scheduleItemId).buildertek__Completion__c; 
                        po.buildertek__Projected_Start_Date__c = scheduleItemMap.get(schedulePOItem.scheduleItemId).buildertek__Start__c;
                        po.buildertek__Projected_Completion_Date__c = scheduleItemMap.get(schedulePOItem.scheduleItemId).buildertek__Finish__c; 
                        System.debug('po: ' + po);
                    }
                }

            }

            if (!poList.isEmpty()) {
                update poList;
            }
    
            if (!scheduleItemList.isEmpty()) {
                update scheduleItemList;
            }
    
            return 'Success';
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return 'Error: ' + e.getMessage();
        }
    }
    
    public class SchedulePOWrapper {
        @AuraEnabled
        public String scheduleItemId;
    
        @AuraEnabled
        public String poId;
    }
    

}