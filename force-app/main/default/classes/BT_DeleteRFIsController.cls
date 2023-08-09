public with sharing class BT_DeleteRFIsController {
    @AuraEnabled
    public static void deleteRFIsRecord(String recordId){
        if(Schema.sObjectType.buildertek__RFI__c.fields.id.isAccessible()
            && buildertek__RFI__c.sObjectType.getDescribe().isDeletable()){
                
            buildertek__RFI__c RFIs = [select Id from buildertek__RFI__c where Id =: recordId];
            delete RFIs;
        }    
    }
}