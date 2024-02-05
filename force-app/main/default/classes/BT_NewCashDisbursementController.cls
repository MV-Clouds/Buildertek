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

    public class CollectResultWrapper {
        @AuraEnabled public String fieldSet = '';
        @AuraEnabled public String projectId;
        @AuraEnabled public String vendorId;
    }
}