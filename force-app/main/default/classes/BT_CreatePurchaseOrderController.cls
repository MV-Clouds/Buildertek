public with sharing class BT_CreatePurchaseOrderController {
    /*
     * @Created Date:- 25th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getAllProducts
     * @ReturnType : List
     * @param : recordId
     * @Description : Get all the Products from Quote Line Item based on Quote Id
    */
    @AuraEnabled
    public static List<PurchaseOrderClass> getAllProducts(String recordId){
        system.debug('recordId --> '+recordId);  
        List<buildertek__Quote_Item__c> quoteItemsList;
        if (Schema.sObjectType.buildertek__Quote_Item__c.fields.id.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible()
            && Schema.sObjectType.Product2.fields.buildertek__Available_Quantity__c.isAccessible()) {
            
            quoteItemsList = [select Id, buildertek__Product__c, buildertek__Product__r.buildertek__Available_Quantity__c, 
                                                                        buildertek__Quantity__c from buildertek__Quote_Item__c 
                                                                        where buildertek__Quote__c =: recordId];
                
        }
        
        Set<Id> ProductIdSet = new Set<Id>();
        Map<Id, Decimal> productQuoteMap = new Map<Id, Decimal>();
        for(buildertek__Quote_Item__c quote : quoteItemsList){
            ProductIdSet.add(quote.buildertek__Product__c); 
            productQuoteMap.put(quote.buildertek__Product__c, quote.buildertek__Quantity__c);
        } 
        List<Product2> productList;
        if (Schema.sObjectType.Product2.fields.id.isAccessible() 
            && Schema.sObjectType.Product2.fields.Name.isAccessible() 
            && Schema.sObjectType.Product2.fields.buildertek__Available_Quantity__c.isAccessible()){
            
            productList = [select Id, Name, buildertek__Available_Quantity__c from Product2 where Id IN: ProductIdSet];
                
        }
        
        list<PurchaseOrderClass> PurchaseOrderClassList = new list<PurchaseOrderClass>();
        for(Product2 products : productList){
            if(products.buildertek__Available_Quantity__c == null){
               products.buildertek__Available_Quantity__c = 0;    
            }
            PurchaseOrderClass PurchaseOrderClassRecord = new PurchaseOrderClass();
            PurchaseOrderClassRecord.product = products;
            PurchaseOrderClassRecord.ProductCheck = false;
            PurchaseOrderClassRecord.Quantity = productQuoteMap.get(products.Id);
            PurchaseOrderClassRecord.POQuantity = 0;
            PurchaseOrderClassList.add(PurchaseOrderClassRecord);
        }
        system.debug('PurchaseOrderClassList --> '+PurchaseOrderClassList);
        return PurchaseOrderClassList;
    }
    
    /*
     * @Created Date:- 25th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : createPurchseOrderAndLines
     * @ReturnType : InsertPurchaseOrderClass
     * @param : recordId
     * @Description : Create Purchase Order and Punchase Order Lines
    */
    
    @AuraEnabled
    public static InsertPurchaseOrderClass createPurchseOrderAndLines(List<String> ProductIds, String recordId, String projectId){
        InsertPurchaseOrderClass purchaseOrderRecord = new InsertPurchaseOrderClass();
        try{
            List<String> recordIdsList = new List<String>();
            Map<String, String> recordIdMap = new Map<String, String>();
            for(string productId : ProductIds){
                List<String> recordIdList = productId.split('-'); 
                recordIdsList.add(recordIdList[0]);
                recordIdMap.put(recordIdList[0], recordIdList[1]);
            }
            system.debug('recordIdMap --> '+recordIdMap); 
            buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c();
            if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isCreateable()
                && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Quote__c.isCreateable()
                && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Date_Created__c.isCreateable()
                && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Type__c.isCreateable()) {
                
                purchaseOrder.buildertek__Project__c = projectId;
                purchaseOrder.buildertek__Quote__c = recordId;
                purchaseOrder.buildertek__Date_Created__c = system.today();
                purchaseOrder.buildertek__Type__c = 'Material';
                    
            }
            
            insert purchaseOrder;
            buildertek__Purchase_Order__c purchaseOrd;
             if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible()
                && Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible()){
                 purchaseOrd = [select Id, Name from buildertek__Purchase_Order__c where Id =: purchaseOrder.Id];
                }
            system.debug('purchaseOrder ---> '+purchaseOrd.Name);
            List<buildertek__Purchase_Order_Item__c> purchaseOrderItemList = new List<buildertek__Purchase_Order_Item__c>();
            for(String productId : recordIdsList){
                if (Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Name.isCreateable()
                    && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Purchase_Order__c.isCreateable()
                    && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Product__c.isCreateable()
                    && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Quantity__c.isCreateable()){
                    
                    buildertek__Purchase_Order_Item__c purchaseOrderItem = new buildertek__Purchase_Order_Item__c(); 
                    purchaseOrderItem.Name = purchaseOrd.Name+' - '+system.Today();
                    purchaseOrderItem.buildertek__Purchase_Order__c = purchaseOrder.Id;
                    purchaseOrderItem.buildertek__Product__c = productId;
                    purchaseOrderItem.buildertek__Quantity__c = Decimal.valueOf(recordIdMap.get(productId));
                    purchaseOrderItemList.add(purchaseOrderItem);   
                       
                }
                
                purchaseOrderRecord.Status = 'Success';
                purchaseOrderRecord.Message = 'Purchase Order Created Successfully';
                purchaseOrderRecord.recordName = purchaseOrd.Name;
                purchaseOrderRecord.recordId = purchaseOrder.Id;
            }
            insert purchaseOrderItemList;    
        }catch(Exception exp){
            purchaseOrderRecord.Status = 'Error';
            purchaseOrderRecord.Message = exp.getMessage();
        }
        
        return purchaseOrderRecord;
        
    }
    
    /*
     * @Created Date:- 25th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : updateAvailableQuantity
     * @ReturnType : 
     * @param : recordId
     * @Description : Update the Available Quantity field in Product
     * @LastModifiedDate : 26th OCTOBER 2018
    */
    
    @AuraEnabled
    public static void updateAvailableQuantity(String recordId){
        List<buildertek__Purchase_Order_Item__c> purchaseOrderItemsList;
        if (Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.id.isAccessible()
            && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Product__c.isAccessible()
            && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Quantity__c.isAccessible()
            && Schema.sObjectType.Product2.fields.buildertek__Available_Quantity__c.isAccessible()) {
            
            purchaseOrderItemsList = [select Id, buildertek__Product__c, buildertek__Product__r.buildertek__Available_Quantity__c, 
                                                                        buildertek__Quantity__c from buildertek__Purchase_Order_Item__c 
                                                                        where buildertek__Purchase_Order__c =: recordId];
                
        }
        
        system.debug('Purchase Orders  --> '+purchaseOrderItemsList);
        Set<Id> productIdSet = new Set<Id>();
        List<Product2> productList = new List<Product2>();
        Map<Id, Decimal> productPurchaseOrderMap = new Map<Id, Decimal>();
        Map<Id, Decimal> productPurchaseOrderOldQuantityMap = new Map<Id, Decimal>();
        for(buildertek__Purchase_Order_Item__c purchaseOrderItems : purchaseOrderItemsList){
            productIdSet.add(purchaseOrderItems.buildertek__Product__c);
            productPurchaseOrderMap.put(purchaseOrderItems.buildertek__Product__c, purchaseOrderItems.buildertek__Quantity__c);
            productPurchaseOrderOldQuantityMap.put(purchaseOrderItems.buildertek__Product__c,purchaseOrderItems.buildertek__Product__r.buildertek__Available_Quantity__c);
        }
        
        List<Product2> productsList;
        if (Schema.sObjectType.Product2.fields.Id.isAccessible()
                && Schema.sObjectType.Product2.fields.buildertek__Available_Quantity__c.isAccessible()){
                productsList = [select Id, buildertek__Available_Quantity__c from Product2 where Id IN: productIdSet];
                }
        for(Product2 products : productsList){
          
                
               Product2 product = new  Product2();    
               product.Id = products.Id;
               if(products.buildertek__Available_Quantity__c != null){
                product.buildertek__Available_Quantity__c = products.buildertek__Available_Quantity__c + productPurchaseOrderMap.get(products.Id);
               }
               productList.add(product);
                    
           } 
           
          
        
         if (Schema.sObjectType.Product2.fields.buildertek__Available_Quantity__c.isUpdateable() ){
        update productList;
        }
        buildertek__Purchase_Order__c purchaseOrder;
         if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible()
                && Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible()
                && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isAccessible()){
                purchaseOrder = [select Id, Name, buildertek__Status__c from buildertek__Purchase_Order__c where Id =: recordId];
                }
        if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isUpdateable() ){
            purchaseOrder.buildertek__Status__c = 'Received';    
        }
        update purchaseOrder;
        List<buildertek__Inventory_Tracking__c> inventoryTrackingList = new List<buildertek__Inventory_Tracking__c>();
        for(Product2 products : productList){
            system.debug('Old Quantity'+productPurchaseOrderOldQuantityMap.get(products.Id));
            
                
                buildertek__Inventory_Tracking__c inventoryTracking = new buildertek__Inventory_Tracking__c();
                inventoryTracking.buildertek__Product__c = products.Id;
                inventoryTracking.buildertek__Description__c = productPurchaseOrderMap.get(products.Id)+' Quantity is added to the Available Quantity';
                inventoryTracking.buildertek__Purchase_Order__c = purchaseOrder.Id;
                inventoryTracking.buildertek__Old_Quantity__c = productPurchaseOrderOldQuantityMap.get(products.Id);
                inventoryTracking.buildertek__New_Quantity__c = products.buildertek__Available_Quantity__c;
                inventoryTrackingList.add(inventoryTracking);
                    
            
            
        }
        if (Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__Product__c.isCreateable() 
                && Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__Description__c.isCreateable() 
                && Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__Purchase_Order__c.isCreateable() 
                && Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__Old_Quantity__c.isCreateable() 
                && Schema.sObjectType.buildertek__Inventory_Tracking__c.fields.buildertek__New_Quantity__c.isCreateable() ){
            insert inventoryTrackingList;
                }
        
    }
    
    /*
     * @Created Date:- 26th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getPurchaseOrderRecordData
     * @ReturnType : buildertek__Purchase_Order__c
     * @param : recordId
     * @Description : Get all the Purchase Order Information based on Purchase Order Id
    */
    
    @AuraEnabled
    public static buildertek__Purchase_Order__c getPurchaseOrderRecordData(String recordId){
        buildertek__Purchase_Order__c purchaseOrder;
        if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.id.isAccessible() 
            && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isAccessible()){
            
            purchaseOrder = [select Id, buildertek__Status__c from buildertek__Purchase_Order__c where Id =: recordId];
                
        } 
        
        return purchaseOrder;
    }
    
     public class PurchaseOrderClass{
         @AuraEnabled
         public Product2 product {get;set;}
         @AuraEnabled
         public Boolean ProductCheck {get;set;}
         @AuraEnabled
         public Decimal Quantity {get;set;}
         @AuraEnabled
         public Decimal POQuantity {get;set;}
    }
    
    public class InsertPurchaseOrderClass{
         @AuraEnabled
         public String Status {get;set;}
         @AuraEnabled
         public String Message {get;set;}
         @AuraEnabled
         public String recordName { get;set; }
         @AuraEnabled
         public String recordId { get;set; }
    }
}