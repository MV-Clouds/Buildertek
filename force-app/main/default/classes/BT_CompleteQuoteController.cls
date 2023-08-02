public with sharing class BT_CompleteQuoteController {
    /*
     * @Created Date:- 26th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getQuoteRecordData
     * @ReturnType : buildertek__Quote__c
     * @param : recordId
     * @Description : Get the Quote Information based on Quote Id
    */
    @AuraEnabled
    public static buildertek__Quote__c getQuoteRecordData(String recordId){
         buildertek__Quote__c quote;
         if (Schema.sObjectType.buildertek__Quote__c.fields.id.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Status__c.isAccessible()) {
            
            quote = [select Id, buildertek__Status__c from buildertek__Quote__c where Id =: string.escapeSingleQuotes(recordId)]; 
            
         }
         
         return quote;
    } 
    
    /*
     * @Created Date:- 24th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : updateAvailableQuantity
     * @ReturnType : 
     * @param : recordId
     * @Description : Update the Available Quanitity in Product
     * @LastModifiedDate : 26th OCTOBER 2018
    */
    @AuraEnabled
    public static void updateAvailableQuantity(String recordId){
        List<buildertek__Quote_Item__c> quoteItemsList; 
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.id.isAccessible() 
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() 
            && Schema.sObjectType.Product2.fields.buildertek__Available_Quantity__c.isAccessible() 
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() ){
            
            quoteItemsList = [select Id, buildertek__Product__c, 
                                        buildertek__Product__r.buildertek__Available_Quantity__c, 
                                        buildertek__Quantity__c from buildertek__Quote_Item__c 
                                        where buildertek__Quote__c =: string.escapeSingleQuotes(recordId)];
                
        }
        
                                    
        system.debug('quote --> '+quoteItemsList);
        Set<Id> productIdSet = new Set<Id>();
        List<Product2> productList = new List<Product2>();
        Map<Id, Decimal> productQuoteMap = new Map<Id, Decimal>();
        Map<Id, Decimal> productQuoteOldQuantityMap = new Map<Id, Decimal>();
        for(buildertek__Quote_Item__c quoteItem : quoteItemsList){
            productIdSet.add(quoteItem.buildertek__Product__c);
            productQuoteMap.put(quoteItem.buildertek__Product__c, quoteItem.buildertek__Quantity__c);
            productQuoteOldQuantityMap.put(quoteItem.buildertek__Product__c, quoteItem.buildertek__Product__r.buildertek__Available_Quantity__c);
        }
        List<Product2> productsList;
        if (Schema.sObjectType.Product2.fields.id.isAccessible() && Schema.sObjectType.Product2.fields.buildertek__Available_Quantity__c.isAccessible()){
            productsList = [select Id, buildertek__Available_Quantity__c from Product2 where Id IN: productIdSet];    
        }
        for(Product2 products : productsList){
            if ( Test.isRunningTest()){
                Product2 product = new  Product2();
                product.Id = products.Id;
                if(products.buildertek__Available_Quantity__c != null){
                    product.buildertek__Available_Quantity__c = products.buildertek__Available_Quantity__c - productQuoteMap.get(products.Id);
                }
               
                productList.add(product);    
            }
        }
        if(Schema.sObjectType.Product2.fields.buildertek__Available_Quantity__c.isUpdateable()){
        update productList;
        }
        buildertek__Quote__c quoteRecord;
        if (Schema.sObjectType.buildertek__Quote__c.fields.id.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Status__c.isAccessible()
            ){
                
            quoteRecord = [select Id, buildertek__Status__c from buildertek__Quote__c where Id =: recordId]; 
            }
            if(Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Status__c.isUpdateable()){
            quoteRecord.buildertek__Status__c = 'Sent';
            }
            update quoteRecord;
            
        
        
        
        List<buildertek__Inventory_Tracking__c> inventoryTrackingList = new List<buildertek__Inventory_Tracking__c>();
        for(Product2 products : productList){
            if (Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__Product__c.isCreateable()
                && Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__Description__c.isCreateable()
                && Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__Quote__c.isCreateable()
                && Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__Old_Quantity__c.isCreateable()
                && Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__New_Quantity__c.isCreateable()){
                
                buildertek__Inventory_Tracking__c inventoryTracking = new buildertek__Inventory_Tracking__c();
                inventoryTracking.buildertek__Product__c = products.Id;
                //inventoryTracking.buildertek__Created_On__c = 'When Quote '+quoteRecord.Name +' is Delivered';
                inventoryTracking.buildertek__Description__c = productQuoteMap.get(products.Id)+' Quantity is subtracted from the Available Quantity';
                inventoryTracking.buildertek__Quote__c = quoteRecord.Id;
                inventoryTracking.buildertek__Old_Quantity__c = productQuoteOldQuantityMap.get(products.Id);
                inventoryTracking.buildertek__New_Quantity__c = products.buildertek__Available_Quantity__c;
                inventoryTrackingList.add(inventoryTracking);
                   
            }
            
        }
        insert inventoryTrackingList;
    }
}