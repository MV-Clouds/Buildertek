public with sharing class CreateRFQFromOpportunity {
    @AuraEnabled
    public static buildertek__RFQ__c saveRFQRecord(String rfqRecord, String projectId, string opprecid){
        buildertek__RFQ__c rfqToInsert = (buildertek__RFQ__c)JSON.deserialize(rfqRecord, buildertek__RFQ__c.class);
        if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isCreateable()) {
            rfqToInsert.buildertek__Project__c = projectId;
            rfqToInsert.buildertek__Opportunity__c = opprecid; 
            insert rfqToInsert; 
        }
        return rfqToInsert;         
    }
}