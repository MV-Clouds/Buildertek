public with sharing class walkThroughController {

    @AuraEnabled
    public static List<buildertek__Category__c> getCategoryRecords() {
        return [SELECT Id, Name FROM buildertek__Category__c WHERE buildertek__Use_for_Walk_Through__c = true ORDER BY buildertek__Order_Id__c ASC NULLS LAST, Name ASC];
    }

    public class FieldWrapper {
        @AuraEnabled public String fieldName { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public String fieldLabel { get; set; }
        @AuraEnabled public Object fieldValue { get; set; }
        @AuraEnabled public List<String> picklistValues { get; set; }
    }
    
    @AuraEnabled
    public static List<FieldWrapper> getFieldDetails(String objectName, String recordId) {
        List<FieldWrapper> fieldList = new List<FieldWrapper>();
        List<String> queryFields = new List<String>();
    
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
    
        for (Schema.SObjectField field : objectDescribe.fields.getMap().values()) {
            Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
            String fieldName = fieldDescribe.getName();
            String fieldType = fieldDescribe.getType().name();
            String fieldLabel = fieldDescribe.getLabel();
            queryFields.add(fieldName);
    
            FieldWrapper fieldWrapper = new FieldWrapper();
            fieldWrapper.fieldName = fieldName;
            fieldWrapper.fieldType = fieldType;
            fieldWrapper.fieldLabel = fieldLabel;
            fieldWrapper.fieldValue = null;
    
            if (fieldType == 'Picklist') {
                fieldWrapper.picklistValues = new List<String>();
                List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
                for (Schema.PicklistEntry picklistEntry : picklistValues) {
                    fieldWrapper.picklistValues.add(picklistEntry.getLabel());
                }
            }
    
            fieldList.add(fieldWrapper);
        }
    
        String query = 'SELECT ' + String.join(queryFields, ', ') + ' FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1';
        SObject record = Database.query(query);
    
        for (FieldWrapper field : fieldList) {
            field.fieldValue = record.get(field.fieldName);
        }
    
        return fieldList;
    }
    

    @AuraEnabled
    public static List<buildertek__Walk_Through_Line_Items__c> fetchWalkthroughLineData(String wtRecordId, String categoryId){
        String queryString = 'SELECT Id';
        List<buildertek__Walk_Through_Line_Items__c> accList = new List<buildertek__Walk_Through_Line_Items__c>();

        for(Schema.FieldSetMember fld :SObjectType.buildertek__Walk_Through_Line_Items__c.FieldSets.buildertek__NewfromParent.getFields()) {
            queryString += ', ' + fld.getFieldPath();
        }

        queryString += ' FROM buildertek__Walk_Through_Line_Items__c WHERE buildertek__Walk_Through_List__c =: wtRecordId AND buildertek__BT_Category__c =: categoryId';
         
        acclist = Database.query(queryString);
        return acclist;
    }

    @AuraEnabled(cacheable=true)
    public static String getFieldSetValues(String sObjectName, String fieldSetName) {
        try {
            String result = '';
            List<String> pickListValuesList = new List<String>();
            Schema.SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(fieldSetName)) {
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if (result != '') {
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + (f.getLabel()) + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '",';
                    
                    Schema.DescribeFieldResult fieldDescribe = objToken.getDescribe().fields.getMap().get(f.getFieldPath()).getDescribe();
                    jsonPart += '"editable":"' + fieldDescribe.isUpdateable() + '"';

                    if (String.valueOf(f.getType()) == 'PICKLIST') {
                        pickListValuesList = getDropDown(sObjectName, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;

                }
            }

            return '[' + result + ']';

        } catch (Exception e) {
            System.debug('Error ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return e.getMessage();
        }
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

    @AuraEnabled
    public static String updateRecord(String recordId, Map<String, Object> newFieldValues) {
        try {

            buildertek__Walk_Through_List__c recordToUpdate = [SELECT Id FROM buildertek__Walk_Through_List__c WHERE Id = :recordId LIMIT 1];

            for (String fieldName : newFieldValues.keySet()) {
                if (recordToUpdate.getSObjectType().getDescribe().fields.getMap().containsKey(fieldName)) {
                    Object fieldValue = newFieldValues.get(fieldName);
                    if (fieldValue instanceof String) {
                        Schema.DescribeFieldResult fieldDescribe = recordToUpdate.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe();
                        if (fieldDescribe.getType() == Schema.DisplayType.Integer || fieldDescribe.getType() == Schema.DisplayType.Double) {
                            recordToUpdate.put(fieldName, Decimal.valueOf((String) fieldValue));
                        } else {
                            recordToUpdate.put(fieldName, fieldValue);
                        }
                    } else {
                        recordToUpdate.put(fieldName, fieldValue);
                    }
                } else {
                    System.debug('Field ' + fieldName + ' does not exist in the object schema.');
                }
            }

            update recordToUpdate;

            return 'success';
        } catch (Exception e) {
            System.debug('error message -->'+e.getMessage());
            System.debug('error line number -->'+e.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return e.getMessage();
        }
    }

    @AuraEnabled
    //deleteRecord
    public static String deleteRecord(String recordId) {
        try {
            buildertek__Walk_Through_Line_Items__c walkthroughlineItem = new buildertek__Walk_Through_Line_Items__c(Id = recordId);
            delete walkthroughlineItem;
            return 'success';
        } catch (Exception e) {
            System.debug('error message -->'+e.getMessage());
            System.debug('error line number -->'+e.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            return e.getMessage();
        }
    }



}