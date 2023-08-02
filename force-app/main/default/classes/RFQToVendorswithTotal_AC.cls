public with sharing class RFQToVendorswithTotal_AC {

  @AuraEnabled
   public static list<buildertek__RFQ_To_Vendor__c > getRFQvendorList(String recordId){
        list<buildertek__RFQ_To_Vendor__c > RFQVendorList;
       if (Schema.sObjectType.buildertek__RFQ_To_Vendor__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__RFQ__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Contact__c.isAccessible()
            && Schema.sObjectType.Contact.fields.Email.isAccessible()
            && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Quote_Amount__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Status__c.isAccessible()) {
            RFQVendorList = [select Id,name,buildertek__RFQ__c,buildertek__Contact__c,buildertek__Contact__r.Email,buildertek__Quote_Amount__c,buildertek__Status__c from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c = :recordId order by buildertek__Quote_Amount__c asc];
        }
        
        return RFQVendorList; 
   }
}