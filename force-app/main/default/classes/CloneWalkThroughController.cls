public with sharing class CloneWalkThroughController{
    @AuraEnabled
    public static ErrorClass cloneWalkThrough(String recordId){
        ErrorClass err = new ErrorClass();
        try{
            buildertek__Walk_Through_List__c walkThrough = new buildertek__Walk_Through_List__c();
            List<buildertek__Walk_Through_Line_Items__c> newWtLineList = new List<buildertek__Walk_Through_Line_Items__c>();
            String querySt = buildDynamicQuery(recordId, 'buildertek__Walk_Through_List__c', 'buildertek__Walk_Through_Line_Items__c');
            walkThrough = Database.query(querySt);
            buildertek__Walk_Through_List__c walkThroughClone = walkThrough.clone(false, false, false, false);
            insert walkThroughClone;
            for (buildertek__Walk_Through_Line_Items__c wtLine : walkThrough.buildertek__Walk_Through_Line_Items__r) {
                wtLine.Id = null;
                wtLine.buildertek__Walk_Through_List__c = walkThroughClone.Id;
                newWtLineList.add(wtLine);
            }
            insert newWtLineList;
            err.Message = 'Success';
            err.RecordId = walkThroughClone.Id;
            return err;
        } catch (Exception e){
            BT_ExceptionHandler.Store_Exception(e);
            err.Message = e.getMessage();
            err.RecordId = '';
            return err;
        }
    }

    // Method to get all fields of a given SObject type
    public static List<String> getAllFields(String sObjectName){
        List<String> fieldNames = new List<String>();

        // Describe the SObject
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        if (sObjectType != null){
            Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();

            // Get all fields
            Map<String, Schema.SObjectField> fieldsMap = sObjectDescribe.fields.getMap();
            for (String fieldName : fieldsMap.keySet()){
                fieldNames.add(fieldName);
            }
        }

        return fieldNames;
    }

    // Method to get the relationship name between parent and child objects
    private static String getChildRelationshipName(String parentObjectName, String childObjectName){
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(parentObjectName);
        if (sObjectType != null){
            Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
            List<Schema.ChildRelationship> childRelationships = sObjectDescribe.getChildRelationships();
            for (Schema.ChildRelationship childRel : childRelationships){
                if (childRel.getChildSObject().getDescribe().getName() == childObjectName){
                    return childRel.getRelationshipName();
                }
            }
        }
        return null;
    }

    // Method to build the dynamic SOQL query
    public static String buildDynamicQuery(String parentRecordId, String parentObjectName, String childObjectName){
        // Get fields of the main SObject
        List<String> parentFields = getAllFields(parentObjectName);
        String parentFieldList = String.join(parentFields, ', ');

        // Build the query for the main SObject
        String query = 'SELECT ' + parentFieldList;

        // Get fields of the child object
        List<String> childFields = getAllFields(childObjectName);
        String childFieldList = String.join(childFields, ', ');
        String relationshipName = getChildRelationshipName(parentObjectName, childObjectName);

        if (relationshipName != null){
            query += ', (SELECT ' + childFieldList + ' FROM ' + relationshipName + ')';
        }

        query += ' FROM ' + parentObjectName + ' WHERE Id = \'' + parentRecordId + '\'';
        return query;
    }

    public class ErrorClass{
        @AuraEnabled
        public String Message{ get; set; }

        @AuraEnabled
        public String RecordId{ get; set; }

    }

}