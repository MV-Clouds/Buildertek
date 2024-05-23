public with sharing class BT_NewCashDisbursementController {

    @AuraEnabled
    public static CollectResultWrapper getFieldSet(String objectName, String fieldSetName, String recordId){
        List<String> pickListValuesList = new List<String>();
        CollectResultWrapper storeFieldSetAndProjectId = new CollectResultWrapper();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(fieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                    if (storeFieldSetAndProjectId.fieldSet != ''){
                        storeFieldSetAndProjectId.fieldSet += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    storeFieldSetAndProjectId.fieldSet += jsonPart;
                }
            }
            BT_NewCashDisbursementController obj = new BT_NewCashDisbursementController();
            storeFieldSetAndProjectId.projectId = obj.getProjectFromContractorInvoice(recordId);
            storeFieldSetAndProjectId.vendorId = obj.getVendorFromContractorInvoice(recordId);
            storeFieldSetAndProjectId.fieldSet = '[' + storeFieldSetAndProjectId.fieldSet + ']';

            
        } catch (Exception e){
            storeFieldSetAndProjectId.fieldSet += e.getLineNumber()+' : ' + e.getMessage();
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
        }

        return storeFieldSetAndProjectId;
    }

    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }

    public String getProjectFromContractorInvoice(String recordId) {
        String result = '';
        try{
            List<buildertek__Account_Payable__c> contractorInvoiceList = [SELECT buildertek__Project__c FROM buildertek__Account_Payable__c WHERE Id =: recordId];
            if (contractorInvoiceList.size() > 0){
                result = contractorInvoiceList[0].buildertek__Project__c;
            }
        } catch (Exception ex){
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
        return result;
    }
    public String getVendorFromContractorInvoice(String recordId) {
        String result = '';
        try{
            List<buildertek__Account_Payable__c> contractorInvoiceList = [SELECT buildertek__Vendor__c FROM buildertek__Account_Payable__c WHERE Id =: recordId];
            if (contractorInvoiceList.size() > 0){
                result = contractorInvoiceList[0].buildertek__Vendor__c;
            }
        } catch (Exception ex){
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
        return result;
    }
     

@AuraEnabled
    public static Id insertRecord(String fieldValues,Id recordId) {
        Id newRecordId ;

        try { 
            Map<String, Object> fieldValuesMap = (Map<String, Object>) JSON.deserializeUntyped(fieldValues);
            System.debug(fieldValuesMap);
            System.debug(recordId);
            buildertek__Payment__c newRecord = new buildertek__Payment__c();
            buildertek__Account_Payable__c accp = [SELECT Id, Name, buildertek__Budget__c, buildertek__BT_Budget_Line__c
                                                             FROM buildertek__Account_Payable__c
                                                             WHERE Id =:recordId];
            if (fieldValuesMap.containsKey('buildertek__Payment_Amount__c')) {
                String paymentAmountStr = (String) fieldValuesMap.get('buildertek__Payment_Amount__c');
                if (!String.isEmpty(paymentAmountStr)) {
                    newRecord.buildertek__Payment_Amount__c = Decimal.valueOf(paymentAmountStr);
                }
                else {
                newRecord.buildertek__Payment_Amount__c =Decimal.valueOf('0');
                System.debug(newRecord.buildertek__Payment_Amount__c);
                    
                }
            }
            if (fieldValuesMap.containsKey('buildertek__Payable__c')) {
                newRecord.buildertek__Payable__c = (String) fieldValuesMap.get('buildertek__Payable__c');
            }
            if (fieldValuesMap.containsKey('buildertek__Project__c')) {
                newRecord.buildertek__Project__c = (String) fieldValuesMap.get('buildertek__Project__c');
            }
            if (fieldValuesMap.containsKey('buildertek__Vendor__c')) {
                newRecord.buildertek__Vendor__c = (String) fieldValuesMap.get('buildertek__Vendor__c');
            }
            if (fieldValuesMap.containsKey('buildertek__Payment_Date__c')) {
                String paymentDateStr = (String) fieldValuesMap.get('buildertek__Payment_Date__c');
                if (!String.isEmpty(paymentDateStr)) { 
                    Date paymentDate = Date.valueOf(paymentDateStr);
                    newRecord.buildertek__Payment_Date__c = paymentDate;
                }
            }
            if (fieldValuesMap.containsKey('buildertek__Type__c')) {
                newRecord.buildertek__Type__c = (String) fieldValuesMap.get('buildertek__Type__c');
            }
            if (fieldValuesMap.containsKey('buildertek__Reference__c')) {
                newRecord.buildertek__Reference__c = (String) fieldValuesMap.get('buildertek__Reference__c');
            }

            System.debug(accp.buildertek__Budget__c);
            System.debug(accp.buildertek__BT_Budget_Line__c);
            newRecord.buildertek__BT_Budget__c=accp.buildertek__Budget__c;
            newRecord.buildertek__BT_Budget_Line__c=accp.buildertek__BT_Budget_Line__c;

            System.debug('Record'+newRecord);
            

            insert newRecord;
            newRecordId = newRecord.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error inserting record: ' + e.getMessage());
        }
        return newRecordId;
    }

    public class CollectResultWrapper {
        @AuraEnabled public String fieldSet = '';
        @AuraEnabled public String projectId;
        @AuraEnabled public String vendorId; 
    }
}