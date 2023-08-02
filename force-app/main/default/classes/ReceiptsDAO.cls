public with sharing class ReceiptsDAO {
    @AuraEnabled
    public static void saveReceipt(String receipts, String invoiceId){
        buildertek__Billings__c invoice;
        if(Schema.sObjectType.buildertek__Billings__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Project__c.isAccessible()){
             invoice= [SELECT Id, buildertek__Project__c FROM buildertek__Billings__c WHERE Id =: invoiceId];
            }
        buildertek__Receipt__c receiptsToInsert = (buildertek__Receipt__c)JSON.deserialize(receipts, buildertek__Receipt__c.class);
        if (Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Billing__c.isCreateable()
            && Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Project__c.isCreateable()) {
           
            receiptsToInsert.buildertek__Billing__c = invoiceId;
            receiptsToInsert.buildertek__Project__c = invoice.buildertek__Project__c;
            insert receiptsToInsert;     
        }  
    }
}