public class AddProductsToPurchaseOrder {
    @AuraEnabled
    public static RfqDataTableWrapper getProducts(Integer pageNumber, Integer pageSize, string RFQRecId, String productFamily, String tradeType, String productType, String Product, String category, String priceBook){
        List<Product2> rfqList = new List<Product2>();
        
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records 
        Integer totalRecords = 0;
        system.debug('pricebook'+priceBook);
        list<String> pB1 = new list<String>();
        
        
        if(priceBook != '' && priceBook != null){
            system.debug('pricebookAt starting'+priceBook);
            String query1 = 'select Id, Name,Pricebook2.Name,Product2Id from PricebookEntry where Pricebook2.Name LIKE  \'%'+String.escapeSingleQuotes(priceBook)+'%\'';
            system.debug('query111111111'+query1);
            list<PricebookEntry> productIdInPB = Database.Query(query1);
            
            
            for(PricebookEntry Pricebook1 : productIdInPB){
                pB1.add(Pricebook1.Product2Id);
            }
        }
        system.debug('pbe'+pB1);
        
        if(productFamily != '' || tradeType != '' || productType != '' || Product  != '' || category != '' || priceBook != ''){
            String query = 'Select COUNT() FROM Product2 WHERE id!=NULL';
            if(productFamily != '' && productFamily != null){
                query = query+ ' AND Family LIKE \'%'+String.escapeSingleQuotes(productFamily)+'%\'';
            }
            if(tradeType != '' && tradeType != null){
                query = query+ ' AND buildertek__Trade_Type__r.Name LIKE \'%'+String.escapeSingleQuotes(tradeType)+'%\'';
            }
            if(productType != '' && productType != null){
                query = query+ ' AND buildertek__Product_Type__r.Name LIKE \'%'+String.escapeSingleQuotes(productType)+'%\'';
            }
            if(Product != '' && Product != null){
                query = query+ ' AND Name LIKE \'%'+String.escapeSingleQuotes(Product)+'%\'';
            }
            if(category != '' && category != null){
                query = query+ ' AND buildertek__Category__r.Name LIKE \'%'+String.escapeSingleQuotes(category)+'%\'';
            }
            if(priceBook != '' && priceBook != null){
                query = query+ ' AND Id IN:pB1';
            }
            system.debug('111111111111111111111111'+query);
            totalRecords = Database.countQuery(query);
            system.debug('TotalRecords'+totalRecords);
        }
        else{
            totalRecords = [SELECT COUNT() FROM Product2 ];
        }
        
        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        if(productFamily != '' || tradeType != '' || productType != '' || Product  != '' || category != '' || priceBook != ''){
            String queryList = 'Select Id,Name,Family,buildertek__Product_Type__r.Name,buildertek__Category__r.Name,buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit FROM Product2 WHERE id!=NULL ';
            if(productFamily != '' && productFamily != null){
                queryList = queryList+ ' AND (Family LIKE \'%'+productFamily+'%\')'; //String.escapeSingleQuotes(description)
            }
            if(tradeType != '' && tradeType != null){
                queryList = queryList+ ' AND (buildertek__Trade_Type__r.Name LIKE \'%'+tradeType+'%\')';
            }
            if(productType != '' && productType != null){
                queryList = queryList+ ' AND (buildertek__Product_Type__r.Name LIKE \'%'+productType+'%\')';
            }
            if(Product != '' && Product != null){
                queryList = queryList+ ' AND (Name LIKE \'%'+Product+'%\')';
            }
            if(category != '' && category != null){
                queryList = queryList+ ' AND (buildertek__Category__r.Name LIKE \'%'+category+'%\')';
            }
            if(priceBook != '' && priceBook != null){
                queryList = queryList+ ' AND Id IN:pB1';
            }
            queryList = queryList+ ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
            // system.debug(queryList);
            objDT.recordList = Database.query(queryList);
            // system.debug(objDT.recordList);
            
        }
        else{
            objDT.recordList = [Select Id,Name,Family,buildertek__Product_Type__r.Name,buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name,buildertek__Category__r.Name,StockKeepingUnit 
                                FROM Product2  ORDER BY Name 
                                LIMIT :pageSize
                                OFFSET :offset];
        }
        
        
        return objDT;
        //return rfqList;
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