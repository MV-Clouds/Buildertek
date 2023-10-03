public class BT_SyncProductsController {
    @AuraEnabled
    public static List<buildertek__Quote_Item__c> getQuoteLineRecordList(String recordId) {
       
        List<buildertek__Quote_Item__c>  QuoteLineList = [SELECT Id, Name, buildertek__Product__c FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c =:recordId AND buildertek__Product__c =''];
        return QuoteLineList;
    }
    @AuraEnabled
    public static Product2 getProduct(String productId){
        Product2 prod = [SELECT Id, Name, buildertek__Manufacturer__c, (select Id, Name, UnitPrice, buildertek__Unit_Cost__c,Product2Id from PricebookEntries) FROM Product2 WHERE Id =: productId LIMIT 1];
        return prod;
    }

}