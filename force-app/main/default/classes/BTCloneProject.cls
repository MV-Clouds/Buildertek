public with sharing class BTCloneProject {

    @AuraEnabled
    public static buildertek__Project__c getProjects(String projectId) {
        buildertek__Project__c project = [SELECT Id, Name, buildertek__County__c, buildertek__County_Text__c from buildertek__Project__c where Id = :projectId];
        return project;
    }

    public BTCloneProject() {

    }


	// ================== TO Solve "TOO many SOQL : 101" =================
    @AuraEnabled
    public static string getFieldSet(){
        try {
            String ObjectAPI = 'buildertek__Project__c';
            String FieldSetName = 'buildertek__Create_Clone_Project_Field';

            String result = '';
            List<String> pickListValuesList = new List<String>();

            SObjectType objToken = Schema.getGlobalDescribe().get(ObjectAPI);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(FieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(FieldSetName).getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (f.getFieldPath() == 'Name'){
                        jsonPart += ',"readOnly":"' + 'true' + '"';
                    }
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(ObjectAPI, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;

                }
            }
            return '[' + result + ']';
        } catch (Exception e) {
            System.debug('Error in cloneProjectNew ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
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
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }
}