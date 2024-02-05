public with sharing class ImportSOVLineToPOController {

    @AuraEnabled
    public static object getPOInfo(String poId){
        try {

            List<buildertek__Purchase_Order__c> poRecord = [SELECT Id, buildertek__Project__c, buildertek__Status__c FROM buildertek__Purchase_Order__c WHERE Id = :poId AND buildertek__Status__c = 'Open' LIMIT 1];

            if (!poRecord.isEmpty()) {
                return poRecord;
            }  

            return null;

        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }

    @AuraEnabled
    public static WrapperClass getAllSOV(String projectId){
        try {

            WrapperClass SOVWrapperClass = new WrapperClass();

            SOVWrapperClass.SOVRecords = [SELECT Id, Name, buildertek__Type__c , buildertek__Total_Costs__c, buildertek__Status__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Project__c FROM buildertek__Schedule_of_Values__c 
                                                WHERE buildertek__Status__c IN ('Company Approved', 'Customer Approved') AND buildertek__Project__c = :projectId AND buildertek__BT_Purchase_Order__c = null
                                                ORDER BY Name
                                                ASC limit 50000]; 

            SOVWrapperClass.CurrSymbol =  UserInfo.getDefaultCurrency();                             
                                                
            if (SOVWrapperClass.SOVRecords.size() > 0) {
                return SOVWrapperClass;
            }  

            return null;   
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }                                      
    }
    
    @AuraEnabled
    public static MessageClass importSOVasPOLine(List<String> sOVIds, String recordId) {
        MessageClass msg = new MessageClass();
        try {
            List<buildertek__Purchase_Order_Item__c> newPOLinelst = new List<buildertek__Purchase_Order_Item__c>();

            List<buildertek__Schedule_of_Value_Lines__c> selectedSOVLineList = [SELECT Id, Name, buildertek__BT_Purchase_Order_Line__c, buildertek__Scheduled_Value__c, buildertek__Schedule_of_Values__c, buildertek__Description_of_Work__c, buildertek__Vendor__c, buildertek__Cost_Code__c, buildertek__Trade_Type__c FROM buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c IN :sOVIds];

            for (buildertek__Schedule_of_Value_Lines__c SOVLine : selectedSOVLineList) {

                buildertek__Purchase_Order_Item__c newBudgetLine = new buildertek__Purchase_Order_Item__c();

                newBudgetLine.buildertek__Purchase_Order__c = recordId;
                newBudgetLine.Name = SOVLine.Name;
                newBudgetLine.buildertek__SOV_Line_Id__c = SOVLine.Id;
                newBudgetLine.buildertek__Description__c = SOVLine.buildertek__Description_of_Work__c;
                newBudgetLine.buildertek__Quantity__c = 1;
                newBudgetLine.buildertek__Unit_Price__c = SOVLine.buildertek__Scheduled_Value__c;
                newBudgetLine.buildertek__Cost_Code__c = SOVLine.buildertek__Cost_Code__c;               

                newPOLinelst.add(newBudgetLine);
            }

            if (newPOLinelst.size() > 0) {
                insert newPOLinelst;
                updateSOVPOField(sOVIds, recordId);
                updateSOVLinePOLineField(selectedSOVLineList, newPOLinelst);
                msg.Status = 'Success';
                msg.Message = 'SOVLine Line(s) created Successfully.';
            } else {
                msg.Status = 'Failed';
                msg.Message = 'No SOVLine Line(s) is there to create.';
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

    public static void updateSOVPOField(List<String> sOVIds, String recordId){
        try {
            List<buildertek__Schedule_of_Values__c> sovRecordsToUpdate = [SELECT Id, buildertek__BT_Purchase_Order__c FROM buildertek__Schedule_of_Values__c WHERE Id IN :sOVIds];
        
            for (buildertek__Schedule_of_Values__c record : sovRecordsToUpdate) {
                record.buildertek__BT_Purchase_Order__c = recordId;
            }
            
            update sovRecordsToUpdate;
        } catch (Exception exp) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(exp);
            }
        }
    }

    public static void updateSOVLinePOLineField(List<buildertek__Schedule_of_Value_Lines__c> selectedSOVLineList, List<buildertek__Purchase_Order_Item__c> newPOLinelst) {
        try {
            Map<Id, buildertek__Schedule_of_Value_Lines__c> sovLineMap = new Map<Id, buildertek__Schedule_of_Value_Lines__c>(selectedSOVLineList);

            List<buildertek__Schedule_of_Value_Lines__c> sovLinesToUpdate = new List<buildertek__Schedule_of_Value_Lines__c>();

            for (buildertek__Purchase_Order_Item__c newPOItem : newPOLinelst) {
                buildertek__Schedule_of_Value_Lines__c sovLine = sovLineMap.get(newPOItem.buildertek__SOV_Line_Id__c);
                if (sovLine != null) {
                    sovLine.buildertek__BT_Purchase_Order_Line__c = newPOItem.Id;
                    sovLinesToUpdate.add(sovLine);
                }
            }
            if (!sovLinesToUpdate.isEmpty()) {
                update sovLinesToUpdate;
            }
        } catch (Exception exp) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(exp);
            }
        }
        
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    } 

    public class WrapperClass{
        @AuraEnabled
		public List<buildertek__Schedule_of_Values__c> SOVRecords;
		@AuraEnabled
		public String CurrSymbol;
        
    }

}