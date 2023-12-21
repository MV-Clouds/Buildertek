public with sharing class ImportMasterWalkThroughController {
    @AuraEnabled
    public static object getMasterWalkThrough(String rfqId){
        try {

            buildertek__RFQ__c rfqRecord = [SELECT Id, buildertek__Project__c FROM buildertek__RFQ__c WHERE Id = :rfqId LIMIT 1];

            Id ProjectId = rfqRecord.buildertek__Project__c;

            list<buildertek__Walk_Through_List__c> masterWTList = [SELECT Id, Name, buildertek__Type__c, buildertek__Notes__c, buildertek__Description__c, buildertek__Contact__c, buildertek__Contact__r.Name, buildertek__Project__c FROM buildertek__Walk_Through_List__c 
                                                WHERE buildertek__Type__c = 'Master' AND buildertek__Project__c = :ProjectId
                                                ORDER BY Name
                                                ASC limit 50000]; 
                                                
            if (masterWTList.size() > 0) {
                return masterWTList;
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
    public static MessageClass importMasterWTLines(List<String> wtIds, String recordId) {
        MessageClass msg = new MessageClass();
        try {
            List<buildertek__RFQ_Item__c> newRFQLines = new List<buildertek__RFQ_Item__c>();
            List<buildertek__Walk_Through_Line_Items__c> walkthroughlines = [SELECT Id, Name, buildertek__Details__c, buildertek__Description__c FROM buildertek__Walk_Through_Line_Items__c WHERE 	buildertek__Walk_Through_List__c IN :wtIds];
            if (walkthroughlines.size() > 0) {
                for (buildertek__Walk_Through_Line_Items__c walkthroughline : walkthroughlines) {
                    buildertek__RFQ_Item__c newRFQLine = new buildertek__RFQ_Item__c();
                    newRFQLine.buildertek__RFQ_Package__c = recordId;
                    newRFQLine.Name = walkthroughline.Name;
                    newRFQLine.buildertek__Quantity__c = 1;
                    newRFQLine.buildertek__Description__c = walkthroughline.buildertek__Description__c;

                    newRFQLines.add(newRFQLine);
                }

                if (newRFQLines.size() > 0) {
                    insert newRFQLines;
                    msg.Status = 'Success';
                    msg.Message = 'RFQ Lines are Created Successfully';
                }
            } else {
                msg.Status = 'Failed';
                msg.Message = 'No RFQ lines to create';
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
}