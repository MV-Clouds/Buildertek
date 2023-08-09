public class ImportProductsOnRfqLines {
    @AuraEnabled
    public static String getTradeTypes(String RFQRecId){
        buildertek__RFQ__c rfqRec = [select id,Name,buildertek__Trade_Type__c from buildertek__RFQ__c where id =: RFQRecId];
        return rfqRec.buildertek__Trade_Type__c;
    }
    @AuraEnabled
    public static List<Product2>  getprodlist (){
        
        List<Product2> productList= [ Select Id,Name,Family,buildertek__Product_Type__r.Name,buildertek__Category__r.Name,buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit FROM Product2 WHERE id!=NULL];
        return productList;
    }
    @AuraEnabled
    public static list<productfamilyClass> productfamilyList(String ObjectName, string parentId){
        Map<String, String> options = new Map<String, String>();
        List<sObject> returnList = new List<sObject>();

        list<string> ProdIds = new list<string>();
        if (ObjectName == 'Product2' && parentId != null){
            list<pricebookEntry> PElist;
            
            PElist = [select id, Product2Id
                      from pricebookEntry where pricebook2Id = :parentId
                     ];
            
            for (pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
        }
        //list<Product2> productfamlylst = [select id, Name,family from Product2 where Id IN :ProdIds AND family != null order by family];
        List<AggregateResult> productfamlylst = [SELECT family
                                                 FROM Product2
                                                 where (Id IN :ProdIds AND family != null)
                                                 group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if (productfamlylst.size() > 0){
            for (AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('family'));
                pfwrapperlst.add(pf);
            }
            system.debug('pfwrapperlst---->' + pfwrapperlst);
        }
        return pfwrapperlst;
    }
    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
    }

    // @AuraEnabled
    // public static List<Pricebook2>  pricebookList (){
    //     List<Pricebook2> pbList= [Select Id,Name,Description From Pricebook2 ORDER BY Name];
    //     return pbList;
    // }
    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }
    @AuraEnabled
    public static List<pricebookWrapper> pricebookList(string recordId){
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();
        
        pricebookWrapper priceWrap = new pricebookWrapper();
        priceWrap.defaultValue= new pricebook2();
        priceWrap.priceWrapList = new List<pricebook2>();
        List<Pricebook2> pbList= [Select Id,Name,Description From Pricebook2 ORDER BY Name];
        priceWrap.priceWrapList=pbList;

        if(recordId != null){
            System.debug('recordId*********' + recordId);
            buildertek__RFQ__c rfqRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__RFQ__c  WHERE Id = :recordId];
            if(rfqRecord.buildertek__Project__c != null && rfqRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
                pricebook2 selectedPriceList = [SELECT Id, Name , Description FROM pricebook2 where Id=:rfqRecord.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                priceWrap.defaultValue= selectedPriceList;
                System.debug(selectedPriceList+'selectedPriceList*********');

            }
        }
        priceWrapper.add(priceWrap);
        return priceWrapper;
    }

    @AuraEnabled
    public static RfqDataTableWrapper getProducts( string RFQRecId, String productFamily, String tradeType, String productType, String Product,String category, String priceBook, String vendor){
        List<Product2> rfqList = new List<Product2>();
        
        Integer totalRecords = 0;
        system.debug('pricebook'+priceBook);
        list<String> pB1 = new list<String>();
        
        
        if(priceBook != '' && priceBook != null){
            system.debug('pricebookAt starting'+priceBook);
           String query1 = 'select Id, Name,Pricebook2.Name,Product2Id from PricebookEntry where Pricebook2Id=: priceBook';
            system.debug('query111111111'+query1);
            list<PricebookEntry> productIdInPB = Database.Query(query1);
            
            system.debug(productIdInPB );
            for(PricebookEntry Pricebook1 : productIdInPB){
                pB1.add(Pricebook1.Product2Id);
            }
        }
        system.debug('pbe'+pB1);
        
        if(productFamily != '' || tradeType != '' || productType != '' || Product  != '' || category != '' || priceBook != '' || vendor != ''){
            String query = 'Select COUNT() FROM Product2 WHERE id!=NULL';
            if(productFamily != '' && productFamily != null){
                query = query+ ' AND toLabel(Family) LIKE \'%'+String.escapeSingleQuotes(productFamily)+'%\'';
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
            if(vendor != '' && vendor != null){
                query = query+ ' AND buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(vendor)+'%\'';
            }
            system.debug('recordList'+query);
            totalRecords = Database.countQuery(query);
            system.debug('TotalRecords'+totalRecords);
        }else{
            totalRecords = [SELECT COUNT() FROM Product2 ];
        }
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        if(productFamily != '' || tradeType != '' || productType != '' || Product  != '' || category != '' || priceBook != '' || vendor != ''){
            String queryList2 = '';
            String queryList = 'Select Id,Name,toLabel(Family),buildertek__Product_Type__r.Name,buildertek__Category__r.Name,buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit FROM Product2 WHERE id!=NULL ';
            if(productFamily != '' && productFamily != null){
                queryList = queryList+ ' AND (toLabel(Family) LIKE \'%'+productFamily+'%\')'; //String.escapeSingleQuotes(description)
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
            if(vendor != '' && vendor != null){
                queryList = queryList+ ' AND (buildertek__Vendor__r.Name LIKE \'%'+vendor+'%\')';
            }
            queryList2 = queryList+ ' ORDER BY Name';
            queryList = queryList+ ' ORDER BY Name';

            // queryList = queryList+ ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
            
            List<Product2> allProds =  Database.query(queryList2);
            objDT.recordList = new List<ProductWrapper>();
            List<Product2> productList = Database.query(queryList);
            for (Product2 prod : productList) {
                ProductWrapper productWrapper = new ProductWrapper();
                productWrapper.product = prod;
                productWrapper.isChecked = false;
                objDT.recordList.add(productWrapper);

            }  

            List<String> categoryNameList = new List<String>();
            List<String> producttypeNameList = new List<String>();
            List<String> tradeTypeNameList = new List<String>();
            List<String> vendorNameList = new List<String>();
            if(allProds.size() > 0){
                for(Product2 rec : allProds){
                    if(rec.buildertek__Category__r != null){
                        if(categoryNameList.size()>0){
                            if(categoryNameList.contains(rec.buildertek__Category__r.Name) == false){
                                categoryNameList.add(rec.buildertek__Category__r.Name);
                            }
                        }else{
                            categoryNameList.add(rec.buildertek__Category__r.Name);
                        }
                        
                    }
                    if(rec.buildertek__Product_Type__r != null){
                        if(producttypeNameList.size()>0){
                            if(producttypeNameList.contains(rec.buildertek__Product_Type__r.Name) == false){
                                producttypeNameList.add(rec.buildertek__Product_Type__r.Name);
                            }
                        }else{
                            producttypeNameList.add(rec.buildertek__Product_Type__r.Name);
                        }
                        
                    }
                    
                    if(rec.buildertek__Trade_Type__r != null){
                        if(tradeTypeNameList.size()>0){
                            if(tradeTypeNameList.contains(rec.buildertek__Trade_Type__r.Name) == false){
                                tradeTypeNameList.add(rec.buildertek__Trade_Type__r.Name);
                            }
                        }else{
                            tradeTypeNameList.add(rec.buildertek__Trade_Type__r.Name);
                        }
                    }
                    system.debug(rec.buildertek__Vendor__r);
                    if(rec.buildertek__Vendor__r != null){
                        if(vendorNameList.size()>0){
                            system.debug(rec.buildertek__Vendor__r.Name);
                            if(vendorNameList.contains(rec.buildertek__Vendor__r.Name) == false){
                                vendorNameList.add(rec.buildertek__Vendor__r.Name);
                            }
                        }else{
                            system.debug(rec.buildertek__Vendor__r.Name);
                            vendorNameList.add(rec.buildertek__Vendor__r.Name);
                        }
                    }
                    
                }
            }
            
            if(categoryNameList.size()>0){
                categoryNameList.sort();
                 objDT.categoryList = categoryNameList;
            }
            if(producttypeNameList.size()>0){
                producttypeNameList.sort();
                objDT.producttypeList = producttypeNameList;
            }
            if(tradeTypeNameList.size()>0){
                tradeTypeNameList.sort();
                objDT.tradetypeList = tradeTypeNameList;
            }
            if(vendorNameList.size()>0){
                vendorNameList.sort();
                objDT.vendorList = vendorNameList;
            }
            
        }
        else{
            System.debug('=====IN ELSE CONDITION=====');
            List<Product2> productList = [Select Id,Name, toLabel(Family),buildertek__Product_Type__r.Name,buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name,buildertek__Category__r.Name,StockKeepingUnit FROM Product2  ORDER BY Name];
            objDT.recordList = new List<ProductWrapper>();
            System.debug(productList);
            for (Product2 prod : productList) {
                ProductWrapper productWrapper = new ProductWrapper();
                productWrapper.product = prod;
                productWrapper.isChecked = false;
                objDT.recordList.add(productWrapper);

            }   
                    
        }
        
        
        return objDT;
        //return rfqList;
    }
    
    @AuraEnabled
    public static String addProductToRfq(List<String>productIds, String RfqId){
        // try{
            List<String> SelectedProductIds = productIds;
            System.debug(SelectedProductIds);
            
            String RfqRecId = RfqId;
            System.debug(RfqRecId);


            List<Product2> Products = [SELECT Id, Name,  buildertek__Trade_Type__c  FROM Product2 Where id IN :SelectedProductIds];
            System.debug(Products);
            List<buildertek__RFQ_Item__c> rfqItemList = new List<buildertek__RFQ_Item__c>();
            System.debug(rfqItemList);
            for(Product2  Product : Products){
                String sizeString = Product.Name;
                Integer maxSize = 79;
                String des = '';
                if(sizeString.length() > maxSize ){
                    des = sizeString;
                    sizeString = sizeString.substring(0, maxSize);
                   
                }
                buildertek__RFQ_Item__c rfqItem = new buildertek__RFQ_Item__c();
                rfqItem.Name = sizeString;//Product.Name;
                rfqItem.buildertek__Description__c = des;
                rfqItem.buildertek__RFQ_Package__c = RfqRecId;
                rfqItem.buildertek__Product__c = Product.Id;
                rfqItem.buildertek__Quantity__c = 1;                
                rfqItem.buildertek__Trade_Type__c = Product.buildertek__Trade_Type__c;
                rfqItemList.add(rfqItem);
            }
            system.debug(rfqItemList);
            insert rfqItemList;
            System.debug(rfqItemList + '----');
            return 'Success';
        // }catch (Exception ex){
        //     String error =ex.getMessage();
        //     Integer line = ex.getLineNumber();
        //     System.debug(line);
        //     System.debug(error);
        //     return error;
        // }
        
    }
    
    
    @AuraEnabled
    public static String addProductToPO(List<String>productIds, String RfqId){
        try{
            List<String> SelectedProductIds = productIds;
            
            String RfqRecId = RfqId;
                
            List<Product2> Products = [SELECT Id, Name,  buildertek__Trade_Type__c  FROM Product2 Where id IN :SelectedProductIds];
            List<buildertek__Purchase_Order_Item__c> PoItemList = new List<buildertek__Purchase_Order_Item__c>();
            for(Product2  Product : Products){
                buildertek__Purchase_Order_Item__c POItem = new buildertek__Purchase_Order_Item__c();
                POItem.Name = Product.Name;
                POItem.buildertek__Purchase_Order__c = RfqRecId;
                POItem.buildertek__Product__c = Product.Id;
                POItem.buildertek__Quantity__c = 1;
                PoItemList.add(POItem);
            }
            insert PoItemList;
            return PoItemList[0].id;
        }catch (Exception ex){
            String error =ex.getMessage();
            return error;
        }
        
    }
    
    public class ProductWrapper {
        @AuraEnabled
        public Product2 product { get; set; }
        @AuraEnabled
        public Boolean isChecked { get; set; }          
    }

    public class RfqDataTableWrapper{
        
        
        @AuraEnabled
        public List<ProductWrapper> recordList{ get; set; }
        
       @AuraEnabled
        public List<String> categoryList {get; set;}
        
        @AuraEnabled
        public List<String> producttypeList {get; set;}
        
        @AuraEnabled
        public List<String> tradetypeList {get; set;}
        
        @AuraEnabled
        public List<String> vendorList {get; set;}
        
      
        
    }
}