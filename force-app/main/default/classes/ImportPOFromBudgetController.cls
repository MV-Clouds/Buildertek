public with sharing class ImportPOFromBudgetController {
    @AuraEnabled
    public static object getAllPO(){
        try {
            list<buildertek__Purchase_Order__c> POList;

            POList = [SELECT Id, Name, buildertek__PO_Total__c , buildertek__Description__c, buildertek__Vendor__c, buildertek__Vendor__r.Id, buildertek__Vendor__r.Name, buildertek__Cost_Code__c, buildertek__Cost_Code__r.Id, buildertek__Cost_Code__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Id, buildertek__Trade_Type__r.Name FROM buildertek__Purchase_Order__c 
                                                WHERE buildertek__PO_Type__c = 'Standard' AND buildertek__Type__c = 'Standard'
                                                ORDER BY Name
                                                ASC limit 50000]; 
                                                
            if (POList.size() > 0) {
                return POList;
            }  

            return null;   
        } catch (Exception e) {
            System.debug('Error--> '+e.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }                                      
    }
    
    @AuraEnabled
    public static MessageClass importPOasBudgetLine(List<String> poIds, String recordId) {
        MessageClass msg = new MessageClass();
        try {
            List<buildertek__Budget_Item__c> newBudgetLinelst = new List<buildertek__Budget_Item__c>();

            List<buildertek__Purchase_Order__c> selectedPOList = [SELECT Id, Name, buildertek__PO_Total__c , buildertek__Description__c, buildertek__Vendor__c, buildertek__Cost_Code__c, buildertek__Trade_Type__c FROM buildertek__Purchase_Order__c WHERE Id IN :poIds];

            System.debug('selectedPOList--> '+ selectedPOList);
            for (buildertek__Purchase_Order__c PO : selectedPOList) {

                buildertek__Budget_Item__c newBudgetLine = new buildertek__Budget_Item__c();

                newBudgetLine.buildertek__Budget__c = recordId;
                newBudgetLine.Name = PO.Name;
                newBudgetLine.buildertek__Quantity__c = 1;
                newBudgetLine.buildertek__Unit_Price__c = PO.buildertek__PO_Total__c;
                newBudgetLine.buildertek__Contractor__c = PO.buildertek__Vendor__c;
                newBudgetLine.buildertek__Cost_Code__c = PO.buildertek__Cost_Code__c;
                newBudgetLine.buildertek__Trade_Type__c = PO.buildertek__Trade_Type__c;                 

                newBudgetLinelst.add(newBudgetLine);
            }
            System.debug('newBudgetLinelst---> ' + newBudgetLinelst);
            if (newBudgetLinelst.size() > 0) {
                insert newBudgetLinelst;
                msg.Status = 'Success';
                msg.Message = 'Budget Line(s) created Successfully.';
            }
            return msg;
        } catch (Exception exp) {
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    } 

    @AuraEnabled
    public static string getcurrency(){
       return UserInfo.getDefaultCurrency();
    }
}