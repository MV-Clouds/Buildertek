public with sharing class BT_MassUpdate_TimeSheet {

    @AuraEnabled
    public static Map<String, Object> fetchDataAndFieldSetValues(String RecordId, String sObjectName, String fieldSetName) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Set<String> queryFields = new Set<String>();
            List<Map<String, Object>> fieldSetValues = new List<Map<String, Object>>();
            Schema.SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            Map<String, Schema.SObjectField> mapFields = d.fields.getMap();

            Set<String> requiredFields = new Set<String>();
            for (String fieldName : mapFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = mapFields.get(fieldName).getDescribe();
                if (!fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate()) {
                    requiredFields.add(fieldName);
                }
            }

            if (FsMap.containsKey(fieldSetName)) {
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    String fieldPath = f.getFieldPath();
                    if (!queryFields.contains(fieldPath)) {
                        Map<String, Object> fieldData = new Map<String, Object>();
                        fieldData.put('label', f.getLabel());
                        fieldData.put('required', f.getDBRequired() || f.getRequired());
                        fieldData.put('type', String.valueOf(f.getType().name()));
                        fieldData.put('name', fieldPath);
                        queryFields.add(fieldPath);

                        Schema.DescribeFieldResult fieldDescribe = mapFields.get(fieldPath).getDescribe();
                        fieldData.put('editable', fieldDescribe.isUpdateable());

                        if (String.valueOf(f.getType()) == 'PICKLIST') {
                            List<String> pickListValuesList = getDropDown(sObjectName, fieldPath);
                            fieldData.put('pickListValuesList', pickListValuesList);
                        }
                        fieldSetValues.add(fieldData);
                    }
                }
            }

            for (String requiredField : requiredFields) {
                if (!queryFields.contains(requiredField)) {
                    Map<String, Object> requiredFieldData = new Map<String, Object>();
                    requiredFieldData.put('label', mapFields.get(requiredField).getDescribe().getLabel());
                    requiredFieldData.put('required', true);
                    requiredFieldData.put('type', mapFields.get(requiredField).getDescribe().getType().name());
                    requiredFieldData.put('name', requiredField);
                    queryFields.add(requiredField);
                    fieldSetValues.add(requiredFieldData);
                }
            }

            String QueryString = 'SELECT ' + String.join(new List<String>(queryFields), ', ') + ' FROM buildertek__BT_Time_Sheet_Entry__c WHERE buildertek__BT_Time_Sheet__c =: RecordId ORDER BY Name';
            List<buildertek__BT_Time_Sheet_Entry__c> timesheetentries = Database.query(QueryString);

            result.put('FieldSetValues', fieldSetValues);
            result.put('timesheetentryObject', timesheetentries);
        } catch (Exception e) {
            System.debug('Error...' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            result.put('Error', e.getMessage());
        }
        return result;
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
    public static string updateTimeSheetEntries(List<buildertek__BT_Time_Sheet_Entry__c> upsertTimeSheetEntries, List<buildertek__BT_Time_Sheet_Entry__c> deletedTimeSheetEntries) {
        List<buildertek__BT_Time_Sheet_Entry__c> toInsert = new List<buildertek__BT_Time_Sheet_Entry__c>();
        List<buildertek__BT_Time_Sheet_Entry__c> toUpdate = new List<buildertek__BT_Time_Sheet_Entry__c>();
        List<buildertek__BT_Time_Sheet_Entry__c> toDelete = new List<buildertek__BT_Time_Sheet_Entry__c>();

        for (buildertek__BT_Time_Sheet_Entry__c entry : upsertTimeSheetEntries) {
            if (entry.Id == null) {
                toInsert.add(entry);
            } else {
                toUpdate.add(entry);
            }
        }
        for (buildertek__BT_Time_Sheet_Entry__c entry : deletedTimeSheetEntries) {
            toDelete.add(entry);
        }

        if (toInsert.size() > 0) {
            try {
                insert toInsert;
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        if (toUpdate.size() > 0) {
            try {
                update toUpdate;
            } catch (Exception e) {
                return e.getMessage();
            }
        }
        if (toDelete.size() > 0) {
            try {
                delete toDelete;
            } catch (Exception e) {
                return e.getMessage();
            }
        }

        return 'success';

    }

}