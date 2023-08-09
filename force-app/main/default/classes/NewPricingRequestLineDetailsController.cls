public class NewPricingRequestLineDetailsController {
    
    @AuraEnabled
    public static List<Product2> getProducts(){
        
        List<Product2> pp =  [select id,Name,ProductCode,Description,Family,(select UnitPrice,buildertek__Unit_Cost__c from PricebookEntries) from Product2];
        return pp;
        
    }
    
    @AuraEnabled
    public static Map<String, String> getpricebooks(){
        Map<String, String> options = new Map<String, String>();
        list<pricebook2> PriceList;
        /* if(Schema.sObjectType.pricebook2.fields.Id.isAccessible()&&
Schema.sObjectType.pricebook2.fields.Name.isAccessible()){ */
        PriceList = [select Id, Name
                     from pricebook2
                     ORDER BY Name ASC NULLS LAST];
        /*} */
        for (pricebook2 p : PriceList){
            //Put Picklist Value & Label in Map
            options.put(p.name, p.Id);
        }
        return options;
    }
    
    @AuraEnabled
    public static List<Product2> getProductsthroughPriceBook(string pbookId) {
        List<PriceBookEntry> pEntries;
        if(pbookId != null && pbookId != 'None'){
            pEntries = [SELECT Id, Product2Id, Product2.Name,Product2.ProductCode,Product2.Description,Product2.Family, Product2.IsActive,buildertek__Unit_Cost__c,Pricebook2.Name,UnitPrice FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND IsActive = True ORDER BY Product2.Name ASC NULLS LAST];
        }
        else{
            pEntries = [SELECT Id, Product2Id, Product2.Name,Product2.ProductCode,UnitPrice,Product2.Description,Product2.Family, Product2.IsActive,buildertek__Unit_Cost__c,Pricebook2.Name FROM PricebookEntry where IsActive = True ORDER BY Product2.Name ASC NULLS LAST];
        }  
        
        List<Product2> products = new List<Product2>();
        for (PriceBookEntry pEntry: pEntries) {
            Product2 aProduct = new Product2();
            aProduct.Id = pEntry.Product2Id;
            aProduct.Name = pEntry.Product2.Name;
            aProduct.ProductCode = pEntry.Product2.ProductCode;
            aProduct.Description = pEntry.Product2.Description;
            aProduct.Family = pEntry.Product2.Family;
            aProduct.IsActive = pEntry.Product2.IsActive;
            if(pEntry.buildertek__Unit_Cost__c != null){
                aProduct.buildertek__Available_Quantity__c = pEntry.buildertek__Unit_Cost__c;
            }
            else{
                aProduct.buildertek__Available_Quantity__c = pEntry.UnitPrice;
            }
            aProduct.buildertek__Size__c = pEntry.Pricebook2.Name;
            // add any additional fields from your query.
            products.add(aProduct);
        }
        return products;
    }
    
    @AuraEnabled
    public static List<Product2> getProductRecordsByIds(List<Id> Ids){
        List<Product2> productList = new  List<Product2>();
        productList =  [select id,Name,ProductCode,Description,Family,(select UnitPrice,Pricebook2Id,Pricebook2.Name,buildertek__Markup__c,buildertek__Multiplier__c,buildertek__Unit_Cost__c,buildertek__Discount__c,IsActive from PricebookEntries where IsActive = True  )  from Product2 where Id in :Ids ];
        return productList;
    }
    
    @AuraEnabled
    public static List<buildertek__Quote_Line_Group__c> getQuoteGrouping2(String quoteId){
        List<buildertek__Quote_Line_Group__c> quotelinegrp;
        // if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Quote__c.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.buildertek__Number__c.isAccessible()){
        quotelinegrp = [Select Id, Name, buildertek__Description__c
                        from buildertek__Quote_Line_Group__c /*where buildertek__Quote__c =: quoteId*/];
        // }
        return quotelinegrp;
    }
    
    @AuraEnabled
    
    public static List<buildertek__Pricing_Request_Line_Details__c>  insertRec(List<buildertek__Pricing_Request_Line_Details__c> PRLDetails,String recId)
    {
        System.debug('Lines : '+PRLDetails);
        buildertek__Pricing_Request_Line__c acc = [select id,buildertek__Vendor__c from buildertek__Pricing_Request_Line__c where id =:recId];
        List<buildertek__Pricing_Request_Line_Details__c> PRDList = new List<buildertek__Pricing_Request_Line_Details__c>();
        for(buildertek__Pricing_Request_Line_Details__c PRDL : PRLDetails){
            buildertek__Pricing_Request_Line_Details__c  PRDLines = new buildertek__Pricing_Request_Line_Details__c();
            PRDLines.buildertek__Product__c = PRDL.buildertek__Product__c;
            PRDLines.buildertek__Description__c = PRDL.buildertek__Description__c;
            PRDLines.buildertek__Cost__c = PRDL.buildertek__Cost__c;
            /*  if( PRDL.buildertek__Markup__c != null &&  PRDL.buildertek__Markup__c != ''){
PRDLines.buildertek__Cost__c = PRDL.buildertek__Unit_Price__c * Integer.valueof(PRDL.buildertek__Markup__c);
}
else{
PRDLines.buildertek__Cost__c = PRDL.buildertek__Unit_Price__c;
} */
            PRDLines.buildertek__Pricing_Request_Line__c = recId;
            if(acc.buildertek__Vendor__c != null){
                PRDLines.buildertek__Vendor__c = acc.buildertek__Vendor__c;
            }
            PRDLines.buildertek__Quantity__c = PRDL.buildertek__Quantity__c;
            PRDLines.buildertek__Markup__c = PRDL.buildertek__Markup__c;
            PRDLines.buildertek__Multiplier__c = PRDL.buildertek__Multiplier__c;
            PRDList.add(PRDLines);
        }
        if(PRDList.size() > 0){
            insert PRDList;
            return PRDList;
        }
        else{
            return PRDList;
        }
    }
    @AuraEnabled
    public static String priceBookInProject(String recordId){
        pricebook2[] priceBookName = [select Id, Name  from pricebook2 where Name = 'Standard Price Book'];
        buildertek__Pricing_Request_Line__c[] prlRec = [select Id,buildertek__Pricing_Request__r.buildertek__Project__c from buildertek__Pricing_Request_Line__c where Id =: recordId];
        if(prlRec.size() > 0){
            if(prlRec[0].buildertek__Pricing_Request__r.buildertek__Project__c != null){
                buildertek__Project__c[] project = [select Id,buildertek__Price_Book__c from buildertek__Project__c where Id =: prlRec[0].buildertek__Pricing_Request__r.buildertek__Project__c];
                if(project.size() > 0){
                    if(project[0].buildertek__Price_Book__c != null){
                        pricebook2[] priceBook = [select Id, Name  from pricebook2 where  Id =: project[0].buildertek__Price_Book__c];
                        if(priceBook.size() > 0){
                            return project[0].buildertek__Price_Book__c;
                        }
                        else{
                            if(priceBookName.size() > 0){
                                return priceBookName[0].Id;
                            }
                            else{
                                return '01s41000000kFZJAA2';
                            }                    
                        }
                    }
                    else{
                        if(priceBookName.size() > 0){
                            return priceBookName[0].Id;
                        }
                        else{
                            return '01s41000000kFZJAA2';
                        }                   
                    }
                }
                else{
                    if(priceBookName.size() > 0){
                        return priceBookName[0].Id;
                    }
                    else{
                        return '01s41000000kFZJAA2';
                    }               
                }
            }
            else{
                if(priceBookName.size() > 0){
                    return priceBookName[0].Id;
                }
                else{
                    return '01s41000000kFZJAA2';
                }           
            }
            
        }
        else{
            return 'ERROR';
        }
    }
    
    @AuraEnabled
public static  InnerList getproductsOne(String recordId){

String priceBookId;

 pricebook2[] priceBookName = [select Id, Name  from pricebook2 where Name = 'Standard Price Book'];
        buildertek__Pricing_Request_Line__c[] prlRec = [select Id,buildertek__Pricing_Request__r.buildertek__Project__c from buildertek__Pricing_Request_Line__c where Id =: recordId];
        if(prlRec.size() > 0){
            if(prlRec[0].buildertek__Pricing_Request__r.buildertek__Project__c != null){
                buildertek__Project__c[] project = [select Id,buildertek__Price_Book__c from buildertek__Project__c where Id =: prlRec[0].buildertek__Pricing_Request__r.buildertek__Project__c];
                if(project.size() > 0){
                    if(project[0].buildertek__Price_Book__c != null){
                        pricebook2[] priceBook = [select Id, Name  from pricebook2 where  Id =: project[0].buildertek__Price_Book__c];
                        if(priceBook.size() > 0){
                            priceBookId = project[0].buildertek__Price_Book__c;
                        }
                        else{
                            if(priceBookName.size() > 0){
                                priceBookId =  priceBookName[0].Id;
                            }
                            else{
                                priceBookId =  '01s41000000kFZJAA2';
                            }                    
                        }
                    }
                    else{
                        if(priceBookName.size() > 0){
                            priceBookId =  priceBookName[0].Id;
                        }
                        else{
                            priceBookId =  '01s41000000kFZJAA2';
                        }                   
                    }
                }
                else{
                    if(priceBookName.size() > 0){
                        priceBookId =  priceBookName[0].Id;
                    }
                    else{
                        priceBookId =  '01s41000000kFZJAA2';
                    }               
                }
            }
            else{
                if(priceBookName.size() > 0){
                    priceBookId =  priceBookName[0].Id;
                }
                else{
                    priceBookId = '01s41000000kFZJAA2';
                }           
            }
            
        }
        else{
            priceBookId = 'ERROR';
        }
    

   
    List<PriceBookEntry> pEntries = [SELECT Id, Product2Id, Product2.Name, Product2.IsActive, Product2.Description,Product2.Family,Product2.ProductCode,UnitPrice FROM PricebookEntry WHERE Pricebook2Id=:priceBookId];

List<InnerLevelList>  innerProduct =  new List<InnerLevelList>();

     for(PriceBookEntry pEntry : pEntries){
                  if(pEntry.Product2.IsActive){
                     InnerLevelList  a  = new InnerLevelList();
                     a.Id = pEntry.Product2Id;
                     a.Name = pEntry.Product2.Name;
                     a.ProductCode = pEntry.Product2.ProductCode;
                     a.UnitPrice = pEntry.UnitPrice;
                      a.Description = pEntry.Product2.Description;
                      a.Family = pEntry.Product2.Family;

innerProduct.add(a);
}


}


InnerList prod = new InnerList();
prod.productList = innerProduct;
prod.PriceBookIdForProduct = priceBookId;

return prod;
}

public class InnerList{

@AuraEnabled public List<InnerLevelList>  productList;
@AuraEnabled public String PriceBookIdForProduct;


}

public class InnerLevelList{

@AuraEnabled public  String Id;
@AuraEnabled public   String Name;
@AuraEnabled public    String ProductCode;
@AuraEnabled public    Decimal  UnitPrice;
@AuraEnabled public    String  Description;
@AuraEnabled public    String  Family;




}
}