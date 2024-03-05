public class AddProductsToPurchaseOrder {
    @AuraEnabled
    public static RfqDataTableWrapper getProducts(Integer pageNumber, Integer pageSize, String RFQRecId, String productFamily, String tradeType, String productType, String Product, String category, String priceBook) {

        List<Product2> rfqList = new List<Product2>();
        Integer offset = (pageNumber - 1) * pageSize;
        Integer totalRecords = 0;
        
        List<String> pB1 = new List<String>();
        
        if (priceBook != null && priceBook != '') {
            String query1 = 'SELECT Id, Name, Product2Id FROM PricebookEntry WHERE Pricebook2.Name LIKE \'%' + String.escapeSingleQuotes(priceBook) + '%\'';
            List<PricebookEntry> productIdInPB = Database.query(query1);
            
            for (PricebookEntry Pricebook1 : productIdInPB) {
                pB1.add(Pricebook1.Product2Id);
            }
        }
        
        if (productFamily != null || tradeType != null || productType != null || Product != null || category != null || priceBook != null) {
            String query = 'SELECT COUNT() FROM Product2 WHERE Id != NULL';
            
            if (productFamily != null && productFamily != '') {
                query += ' AND Family LIKE \'%' + String.escapeSingleQuotes(productFamily) + '%\'';
            }
            if (tradeType != null && tradeType != '') {
                query += ' AND buildertek__Trade_Type__r.Name LIKE \'%' + String.escapeSingleQuotes(tradeType) + '%\'';
            }
            if (productType != null && productType != '') {
                query += ' AND buildertek__Product_Type__r.Name LIKE \'%' + String.escapeSingleQuotes(productType) + '%\'';
            }
            if (Product != null && Product != '') {
                query += ' AND Name LIKE \'%' + String.escapeSingleQuotes(Product) + '%\'';
            }
            if (category != null && category != '') {
                query += ' AND buildertek__Category__r.Name LIKE \'%' + String.escapeSingleQuotes(category) + '%\'';
            }
            if (priceBook != null && priceBook != '') {
                query += ' AND Id IN :pB1';
            }
            System.debug('query--->'+query);
            totalRecords = Database.countQuery(query);
        } else {
            totalRecords = [SELECT COUNT() FROM Product2];
        }
        
        Integer recordEnd = Math.min(pageSize * pageNumber, totalRecords);
        
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = recordEnd;
        objDT.totalRecords = totalRecords;
        
        if (productFamily != null || tradeType != null || productType != null || Product != null || category != null || priceBook != null) {
            String queryList = 'SELECT Id, Name, Family, buildertek__Product_Type__r.Name, buildertek__Category__r.Name, buildertek__Trade_Type__r.Name, buildertek__Vendor__r.Name, StockKeepingUnit FROM Product2 WHERE Id != NULL';
            
            if (productFamily != null && productFamily != '') {
                queryList += ' AND Family LIKE \'%' + productFamily + '%\'';
            }
            if (tradeType != null && tradeType != '') {
                queryList += ' AND buildertek__Trade_Type__r.Name LIKE \'%' + tradeType + '%\'';
            }
            if (productType != null && productType != '') {
                queryList += ' AND buildertek__Product_Type__r.Name LIKE \'%' + productType + '%\'';
            }
            if (Product != null && Product != '') {
                queryList += ' AND Name LIKE \'%' + Product + '%\'';
            }
            if (category != null && category != '') {
                queryList += ' AND buildertek__Category__r.Name LIKE \'%' + category + '%\'';
            }
            if (priceBook != null && priceBook != '') {
                queryList += ' AND Id IN :pB1';
            }
            
            queryList += ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
            
            objDT.recordList = Database.query(queryList);
        } else {
            objDT.recordList = [
                SELECT Id, Name, Family, buildertek__Product_Type__r.Name, buildertek__Trade_Type__r.Name, buildertek__Vendor__r.Name, buildertek__Category__r.Name, StockKeepingUnit 
                FROM Product2  
                ORDER BY Name 
                LIMIT :pageSize 
                OFFSET :offset
            ];
        }
        
        return objDT;
    }
    
    
    @AuraEnabled
    public static String addProductToPO(List<String>productIds, String RfqId){
      // try{
            List<String> SelectedProductIds = productIds;
            
            String RfqRecId = RfqId;
                
            List<Product2> Products = [SELECT Id, Name,  buildertek__Trade_Type__c  FROM Product2 Where id IN :SelectedProductIds];
            List<buildertek__Purchase_Order_Item__c> PoItemList = new List<buildertek__Purchase_Order_Item__c>();
            for(Product2  Product : Products){
                buildertek__Purchase_Order_Item__c POItem = new buildertek__Purchase_Order_Item__c();
                // POItem.Name = Product.Name;
                if(Product.Name.length() > 80){
                    POItem.Name = Product.Name.substring(0,79);
                    PoItem.buildertek__Description__c = Product.Name;
                }else{
                    POItem.Name = Product.Name;
                }
                POItem.buildertek__Purchase_Order__c = RfqRecId;
                POItem.buildertek__Product__c = Product.Id;
                POItem.buildertek__Quantity__c = 1;
                PoItemList.add(POItem);
            }
            insert PoItemList;
        system.debug(PoItemList);
            return PoItemList[0].id;
            
       // }catch (Exception ex){
          // String error =ex.getMessage();
            
          //  return error;
        //}
        
    }
    
    

    
    public class RfqDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords{ get; set; }
        
        @AuraEnabled
        public Integer recordStart{ get; set; }
        
        @AuraEnabled
        public Integer recordEnd{ get; set; }
        
        @AuraEnabled
        public List<Product2> recordList{ get; set; }
    }
}