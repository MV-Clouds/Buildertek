public with sharing class BT_DeleteRFQsController {
    @AuraEnabled
    public static void deleteRFQsRecord(String recordId){
        if(Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()
            && buildertek__RFQ__c.sObjectType.getDescribe().isDeletable()){
                
            buildertek__RFQ__c RFQ = [select Id from buildertek__RFQ__c where Id =: recordId];
            delete RFQ;
        }    
    }
}