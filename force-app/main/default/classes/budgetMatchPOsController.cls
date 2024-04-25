public without sharing class budgetMatchPOsController {

    @AuraEnabled
    public static List<buildertek__Budget_Item__c> fetchBudgetLine(String budgetId) {
        try {
            List<buildertek__Budget_Item__c> budgetLineList = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE buildertek__Budget__c = :budgetId ORDER BY Name ASC];
            return budgetLineList;
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }

    @AuraEnabled
    public static List<buildertek__Purchase_Order__c> fetchAllPOs(String budgetId){
        try {
            Id projectId = [SELECT Id, buildertek__Project__c FROM buildertek__Budget__c WHERE Id = :budgetId][0].buildertek__Project__c;
            if (projectId == null) {
                return null;
            }
            List<buildertek__Purchase_Order__c> poList = [SELECT Id, Name, buildertek__Description__c, buildertek__Vendor__r.Name, buildertek__PO_Total__c FROM buildertek__Purchase_Order__c WHERE buildertek__Budget_Line__c = null AND buildertek__Project__c =:projectId ORDER BY Name ASC];
            return poList;
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }

    @AuraEnabled
    public static String setPOForbudgetLine(String budgetPO, String budgetId) {
        try {
            List<BudgetPOWrapper> wrapper = (List<BudgetPOWrapper>)JSON.deserialize(budgetPO, List<BudgetPOWrapper>.class);
            Set<Id> poIds = new Set<Id>();
            Set<Id> budgetLineIds = new Set<Id>();
            for (BudgetPOWrapper budgetPOItem : wrapper) {
                poIds.add(budgetPOItem.poId);
                budgetLineIds.add(budgetPOItem.budgetLineId);
            }
            List<buildertek__Purchase_Order__c> poList = [SELECT Id, Name, buildertek__Description__c FROM buildertek__Purchase_Order__c WHERE Id IN :poIds];
            
            for (BudgetPOWrapper budgetPOItem : wrapper) {
                for (buildertek__Purchase_Order__c po : poList) {
                    if (po.Id == budgetPOItem.poId) {
                        po.buildertek__Budget__c = budgetId;
                        po.buildertek__Budget_Line__c = budgetPOItem.budgetLineId;
                    }
                }
            }

            if (!poList.isEmpty()) {
                update poList;
            }

            return 'Success';
        } catch (Exception e) {
            System.debug('error: ' + e.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return 'Error: ' + e.getMessage();
        }
    }

    public class BudgetPOWrapper {
        @AuraEnabled
        public String budgetLineId;

        @AuraEnabled
        public String poId;
    }

}