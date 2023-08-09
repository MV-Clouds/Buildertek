public with sharing class BT_DeleteInspectionsController {
    @AuraEnabled
    public static void deleteInspectionRecord(String recordId){
        if(Schema.sObjectType.buildertek__Inspection__c.fields.id.isAccessible()
            && buildertek__Inspection__c.sObjectType.getDescribe().isDeletable()){
                
            buildertek__Inspection__c inspection = [select Id from buildertek__Inspection__c where Id =: recordId];
            delete inspection;
        }
    }
}