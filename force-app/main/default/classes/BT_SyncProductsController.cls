public class BT_SyncProductsController {
    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }
    public class productWrapper{
        @AuraEnabled
        public Id Id;

        @AuraEnabled
        public String Name;

        @AuraEnabled
        public String ProductCode;

        @AuraEnabled
        public String Description;

        @AuraEnabled
        public String Family;

        @AuraEnabled
        public Boolean IsActive;

        @AuraEnabled
        public Decimal UnitPrice;

        @AuraEnabled
        public String Size;

        @AuraEnabled
        public Boolean Selected;
        
        @AuraEnabled
        public Decimal UnitCost;
        
        @AuraEnabled
        public String Phase;
        
        @AuraEnabled
        public Decimal MarkUp;

        @AuraEnabled
        public Decimal Discount;

        @AuraEnabled
        public String QuantityUnitOfMeasure;
    }
    @AuraEnabled
    public static List<pricebookWrapper> getPricebookList(string recordId){
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();
        
        pricebookWrapper priceWrap = new pricebookWrapper();
        priceWrap.defaultValue= new pricebook2();
        priceWrap.priceWrapList = new List<pricebook2>();
        List<pricebook2> PriceList = [SELECT Id, Name FROM pricebook2 ORDER BY Name ASC ];
        priceWrap.priceWrapList=PriceList;
        if(recordId != null){
            buildertek__Quote__c quoteRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Quote__c  WHERE Id = :recordId];
            if(quoteRecord.buildertek__Project__c != null && quoteRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
                pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:quoteRecord.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                priceWrap.defaultValue= selectedPriceList;
            }
        }
        priceWrapper.add(priceWrap);
        return priceWrapper;
    }
    @AuraEnabled
    public static List<buildertek__Quote_Line_Group__c> getQuoteLineGroups(){
        List<buildertek__Quote_Line_Group__c> quoteLineGrouping = [SELECT Id, Name FROM buildertek__Quote_Line_Group__c ORDER BY Name ASC];
        return quoteLineGrouping;
        
    }
    @AuraEnabled
    public static List<buildertek__Quote_Item__c> getQuoteLineRecordList(String recordId) {
       
        List<buildertek__Quote_Item__c>  QuoteLineList = [SELECT Id, Name, buildertek__Product__r.Id ,buildertek__Product__r.Name,buildertek__Grouping__r.Name FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c =:recordId AND buildertek__Product__c ='' ORDER BY Name ASC];
        return QuoteLineList;
    }
    @AuraEnabled
    public static List<Product2> getProduct(String prodName){
        String filterValue='%'+prodName+'%';
        List<Product2> prodList = new List<Product2>();
        if(prodName !=null ){
            prodList= [SELECT Id, Name FROM Product2 WHERE  Product2.Name LIKE :filterValue ORDER BY Name ASC LIMIT 100  ];
        }else{
            prodList=[SELECT Id, Name FROM Product2 ORDER BY Name ASC LIMIT 100  ];
        }
        return prodList;
    }
    @AuraEnabled
    public static List<productWrapper> getProductsthroughPriceBook2(string pbookId) {


        List<PriceBookEntry> pEntries = [SELECT Id,Product2Id, Product2.buildertek__Quote_Group__c , Product2.Name, Product2.ProductCode, Product2.Description, toLabel(Product2.Family), 
                                            Product2.IsActive,buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure  
                                            FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND IsActive = True 
                                            ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 1000];

        List<productWrapper> products = new List<productWrapper>();
        for (PriceBookEntry pEntry: pEntries) {
            productWrapper aProduct = new productWrapper();
            aProduct.Id = pEntry.Product2Id;
            aProduct.Name = pEntry.Product2.Name;
            aProduct.ProductCode = pEntry.Product2.ProductCode;
            aProduct.Description = pEntry.Product2.Description;
            aProduct.Family = pEntry.Product2.Family;
            aProduct.IsActive = pEntry.Product2.IsActive;
            aProduct.UnitPrice = pEntry.UnitPrice;            
            aProduct.Size = pEntry.Pricebook2.Name;
            aProduct.Selected = false;
            aProduct.MarkUp = pEntry.buildertek__Markup__c;
            aProduct.Discount = pEntry.buildertek__Discount__c;
            aProduct.UnitCost = pEntry.buildertek__Unit_Cost__c;
            aProduct.Phase = pEntry.Product2.buildertek__Quote_Group__c;
            aProduct.QuantityUnitOfMeasure = pEntry.Product2.QuantityUnitOfMeasure;     
            products.add(aProduct);
        }

        return products;
    }
    @AuraEnabled
    public static List<productWrapper> getProductsthroughProductFamily(string pbookId, string pfId) {


        List<PriceBookEntry> pEntries = [SELECT Id,Product2Id, Product2.buildertek__Quote_Group__c , Product2.Name, Product2.ProductCode, Product2.Description, toLabel(Product2.Family), 
                                            Product2.IsActive,buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure  
                                            FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND IsActive = True AND toLabel(Product2.Family)=:pfId
                                            ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 1000];

        List<productWrapper> products = new List<productWrapper>();
        for (PriceBookEntry pEntry: pEntries) {
            productWrapper aProduct = new productWrapper();
            aProduct.Id = pEntry.Product2Id;
            aProduct.Name = pEntry.Product2.Name;
            aProduct.ProductCode = pEntry.Product2.ProductCode;
            aProduct.Description = pEntry.Product2.Description;
            aProduct.Family = pEntry.Product2.Family;
            aProduct.IsActive = pEntry.Product2.IsActive;
            aProduct.UnitPrice = pEntry.UnitPrice;            
            aProduct.Size = pEntry.Pricebook2.Name;
            aProduct.Selected = false;
            aProduct.MarkUp = pEntry.buildertek__Markup__c;
            aProduct.Discount = pEntry.buildertek__Discount__c;
            aProduct.UnitCost = pEntry.buildertek__Unit_Cost__c;
            aProduct.Phase = pEntry.Product2.buildertek__Quote_Group__c;
            aProduct.QuantityUnitOfMeasure = pEntry.Product2.QuantityUnitOfMeasure; 
            products.add(aProduct);
        }

        return products;
    }
    @AuraEnabled
    public static List<productWrapper> getProductsbyName(string pbookId, string pName) {
        String[] searchTerms = pName.split(' ');
        List<String> searchKeyParts = new List<String>();
        
        for (String term : searchTerms) {
            searchKeyParts.add('Product2.Name LIKE \'%' + term + '%\'');
        }
        
        String searchKey = String.join(searchKeyParts, ' AND ');
        
        String sQuery = 'SELECT Id, Product2Id, Product2.buildertek__Quote_Group__c, Product2.Name, Product2.ProductCode, Product2.Description, toLabel(Product2.Family), Product2.IsActive, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure FROM PricebookEntry WHERE Pricebook2Id = :pbookId AND IsActive = True AND (' + searchKey + ') ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 1000';
        
        List<PriceBookEntry> pEntries = Database.query(sQuery);
    
        List<productWrapper> products = new List<productWrapper>();
        for (PriceBookEntry pEntry : pEntries) {
            productWrapper aProduct = new productWrapper();
            aProduct.Id = pEntry.Product2Id;
            aProduct.Name = pEntry.Product2.Name;
            aProduct.ProductCode = pEntry.Product2.ProductCode;
            aProduct.Description = pEntry.Product2.Description;
            aProduct.Family = pEntry.Product2.Family;
            aProduct.IsActive = pEntry.Product2.IsActive;
            aProduct.UnitPrice = pEntry.UnitPrice;
            aProduct.Size = pEntry.Pricebook2.Name;
            aProduct.Selected = false;
            aProduct.MarkUp = pEntry.buildertek__Markup__c;
            aProduct.Discount = pEntry.buildertek__Discount__c;
            aProduct.UnitCost = pEntry.buildertek__Unit_Cost__c;
            aProduct.Phase = pEntry.Product2.buildertek__Quote_Group__c;
            aProduct.QuantityUnitOfMeasure = pEntry.Product2.QuantityUnitOfMeasure;
            products.add(aProduct);
        }    
        return products;
    } 
    @AuraEnabled
    public static List<productWrapper> getProductsbyNameandFamily(string pbookId, string pName, string pfId) {
        String[] searchTerms = pName.split(' ');
        List<String> searchKeyParts = new List<String>();
        
        for (String term : searchTerms) {
            searchKeyParts.add('Product2.Name LIKE \'%' + term + '%\'');
        }
        
        String searchKey = String.join(searchKeyParts, ' AND ');
        
        String sQuery = 'SELECT Id, Product2Id, Product2.buildertek__Quote_Group__c, Product2.Name, Product2.ProductCode, Product2.Description, toLabel(Product2.Family), Product2.IsActive, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure FROM PricebookEntry WHERE Pricebook2Id = :pbookId AND IsActive = True AND toLabel(Product2.Family)=:pfId AND (' + searchKey + ') ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 1000';
        
        List<PriceBookEntry> pEntries = Database.query(sQuery);
    
        List<productWrapper> products = new List<productWrapper>();
        for (PriceBookEntry pEntry : pEntries) {
            productWrapper aProduct = new productWrapper();
            aProduct.Id = pEntry.Product2Id;
            aProduct.Name = pEntry.Product2.Name;
            aProduct.ProductCode = pEntry.Product2.ProductCode;
            aProduct.Description = pEntry.Product2.Description;
            aProduct.Family = pEntry.Product2.Family;
            aProduct.IsActive = pEntry.Product2.IsActive;
            aProduct.UnitPrice = pEntry.UnitPrice;
            aProduct.Size = pEntry.Pricebook2.Name;
            aProduct.Selected = false;
            aProduct.MarkUp = pEntry.buildertek__Markup__c;
            aProduct.Discount = pEntry.buildertek__Discount__c;
            aProduct.UnitCost = pEntry.buildertek__Unit_Cost__c;
            aProduct.Phase = pEntry.Product2.buildertek__Quote_Group__c;
            aProduct.QuantityUnitOfMeasure = pEntry.Product2.QuantityUnitOfMeasure;
            products.add(aProduct);
        }
    
        return products;
    } 
    @AuraEnabled
    public static void massUpdateQuoteLine(String onlyUpdatedQuoteLines){
       List<buildertek__Quote_Item__c> UpdateQl = (list<buildertek__Quote_Item__c>)JSON.deserialize(onlyUpdatedQuoteLines, List<buildertek__Quote_Item__c>.class);
       update UpdateQl;
       List<buildertek__Quote_Item__c> UpdateQlList = new List<buildertek__Quote_Item__c>();
       Set<Id> qlIds = new Set<Id>();
       Set<Id> prodIds = new Set<Id>();
       for(buildertek__Quote_Item__c Ql: UpdateQl){
            qlIds.add(Ql.Id);
            prodIds.add(Ql.buildertek__Product__c);
       }
       List<Product2> prdList = [SELECT Id,Name FROM Product2 WHERE ID IN:prodIds];
       List<buildertek__Quote_Item__c> UpQl = [SELECT ID,Name , buildertek__Item_Name__c,buildertek__Product__c FROM buildertek__Quote_Item__c WHERE Id IN:qlIds ];

       for(buildertek__Quote_Item__c ql : UpQl){
            for(Product2 prd: prdList){
                if ((ql.buildertek__Product__c == prd.Id) && (ql.buildertek__Item_Name__c == null || ql.buildertek__Item_Name__c == '')) {
                    ql.buildertek__Item_Name__c = prd.Name;
                    UpdateQlList.add(ql);
                }
            }
        }
        update UpdateQlList;
    }  

}