public with sharing class BTCloneProject {
    @AuraEnabled
    public static buildertek__Project__c getProjects(String projectId) {
        buildertek__Project__c project = [SELECT Id, Name, buildertek__County__c, buildertek__County_Text__c,buildertek__Type__c,buildertek__Customer__c,buildertek__Customer_Contact__c, buildertek__Address__c from buildertek__Project__c where Id = :projectId];
        return project;
    }

    public BTCloneProject() {

    }


	// ================== TO Solve "TOO many SOQL : 101", BUIL-3692 & BUIL-3883 =================


    @AuraEnabled
    public static string cloneChildObj(string clonedProjectId, string sourceProjectId, string objName){

        try{
            Set<String> sourceProjectIds = new Set<String>();
            Map<String, String> sourceToProjectMap = new  Map<String, String>();

            sourceProjectIds.add(sourceProjectId);
            sourceToProjectMap.put(sourceProjectId, clonedProjectId);

            string returnValue;

                if(objName == 'Purchase Order') {
                    returnValue = ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Purchase_Order__c', 'buildertek__Purchase_Order_Item__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'Schedule') {
                    returnValue =  ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Schedule__c', 'buildertek__Project_Task__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'PunchList') {
                    returnValue =  ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Punch_List__c', 'buildertek__Punch_List_item__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'Inspections') {
                    returnValue = ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Inspection__c', 'buildertek__Inspection_Line__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'Warranty') {
                    returnValue = ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Warranty__c', 'buildertek__Warranty_Item__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'Contract') {
                    returnValue = ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Contract__c', 'buildertek__Contract_Item__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'Quote') {
                    returnValue = ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Quote__c', 'buildertek__Quote_Item__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'Budget') {
                    returnValue = ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Budget__c', 'buildertek__Budget_Item__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'Selection') {
                    returnValue = ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Selection__c', 'buildertek__Section__c', sourceProjectIds, sourceToProjectMap);
                }

                if(objName == 'Project Vendors') {
                    returnValue = ProjectTriggerHandler.CloneAny2(objName, 'buildertek__Project_Vendors__c', '', sourceProjectIds, sourceToProjectMap);
                }

                return returnValue;
            } catch (Exception e) {
                System.debug('Error in cloneChildObj ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
                return e.getMessage();
            }
    }




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