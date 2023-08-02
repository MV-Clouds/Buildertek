public with sharing class BT_DeleteContractsController {
    @AuraEnabled
    public static void deleteContractRecord(String recordId){
        if(Schema.sObjectType.buildertek__Contract__c.fields.id.isAccessible()
            && buildertek__Contract__c.sObjectType.getDescribe().isDeletable()){
            
            buildertek__Contract__c contract = [select Id from buildertek__Contract__c where Id =: recordId];
            delete contract;    
        }
        
    }
}