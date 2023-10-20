public class SyncProductWithTakeoffLines {
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
            buildertek__Project_Takeoff__c takeOffRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Project_Takeoff__c  WHERE Id = :recordId];
            if(takeOffRecord.buildertek__Project__c != null && takeOffRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
                pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:takeOffRecord.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                priceWrap.defaultValue= selectedPriceList;
            }
        }
        priceWrapper.add(priceWrap);
        return priceWrapper;
    }
    @AuraEnabled
    public static List<buildertek__Project_Takeoff_Lines__c> getTakeoffLineRecordList(String recordId) {
        
        List<buildertek__Project_Takeoff_Lines__c>  TakeoffLineList = [SELECT Id, Name, buildertek__Product__r.Id ,buildertek__Product__r.Name,buildertek__Category__c FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:recordId AND buildertek__Product__c ='' ORDER BY Name ASC];
        return TakeoffLineList;
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
    public static void massUpdateTakeoffLine(String onlyUpdatedTakeoffLines){
        List<buildertek__Project_Takeoff_Lines__c> UpdateTakeoffline = (list<buildertek__Project_Takeoff_Lines__c>)JSON.deserialize(onlyUpdatedTakeoffLines, List<buildertek__Project_Takeoff_Lines__c>.class);
        update UpdateTakeoffline;
        List<buildertek__Project_Takeoff_Lines__c> UpdateTakeofflineList = new List<buildertek__Project_Takeoff_Lines__c>();
        Set<Id> takofLineIds = new Set<Id>();
        Set<Id> prodIds = new Set<Id>();
        for(buildertek__Project_Takeoff_Lines__c Ql: UpdateTakeoffline){
            takofLineIds.add(Ql.Id);
            prodIds.add(Ql.buildertek__Product__c);
        }
        List<Product2> prdList = [SELECT Id,Name FROM Product2 WHERE ID IN:prodIds];
        List<buildertek__Project_Takeoff_Lines__c> UpTakeofflne = [SELECT Id,Name ,buildertek__Product__c FROM buildertek__Project_Takeoff_Lines__c WHERE Id IN:takofLineIds ];

        for(buildertek__Project_Takeoff_Lines__c ql : UpTakeofflne){
            for(Product2 prd: prdList){
                if (ql.buildertek__Product__c == prd.Id) {
                    UpdateTakeofflineList.add(ql);
                }
            }
        }
        update UpdateTakeofflineList;
    }  

    @AuraEnabled
    public static Boolean checkTakeoffLineItems(String takeOffId){
        Boolean allTakeoffLineItemsHaveProducts = true;
        List<buildertek__Project_Takeoff_Lines__c> takeoffLineItems = [SELECT Id, buildertek__Product__c FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId];
        for(buildertek__Project_Takeoff_Lines__c quoteLineItem : takeoffLineItems){
            if(quoteLineItem.buildertek__Product__c == null){
                allTakeoffLineItemsHaveProducts = false;
            }
        }
        return allTakeoffLineItemsHaveProducts;
    }
}