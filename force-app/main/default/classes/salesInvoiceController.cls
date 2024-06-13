public with sharing class salesInvoiceController {

    @AuraEnabled 
    public static string getpricebook(string SaleInvoiceId){
        List<buildertek__Billings__c> SaleInvoiceList; 
          if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Project__c.isAccessible() &&
			Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()){
                SaleInvoiceList= [Select Id, buildertek__Project__r.buildertek__Price_Book__c from buildertek__Billings__c where Id =: SaleInvoiceId ];
			}
        if(SaleInvoiceList.size() > 0){
            return SaleInvoiceList[0].buildertek__Project__r.buildertek__Price_Book__c ;
        }
        return null;
    }   

    @AuraEnabled 
    public static Map<String, String> getpricebooks(){
        Map<String, String> options = new Map<String, String>();
        list<pricebook2> PriceList = [Select Id, Name from pricebook2 ORDER BY Name ASC];
        for (pricebook2 p: PriceList) {
            options.put(p.name, p.Id); 
        }
        return options;
    }

    @AuraEnabled
    public static list<PricebookEntry> getProductPrice(String productId){
        List<PricebookEntry> pList = new List<PricebookEntry>();
        pList=[Select Id, UnitPrice, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Product2.buildertek__Cost_Code__c, Product2.buildertek__Cost_Code__r.Name from PricebookEntry where product2Id =: productId and isActive = true and pricebook2Id IN (select id from Pricebook2 Where isActive = true)];
        return pList;
    }

    @AuraEnabled public list<productfamilyClass> pfwrapperlst {get;set;}
    @AuraEnabled 
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName,string parentId) {
        Map<String, String> options = new Map<String, String>();
        List < sObject > returnList = new List < sObject > ();
       
        list<string> ProdIds = new list<string>();
        if(ObjectName == 'Product2' && parentId != null){
            list<pricebookEntry> PElist; 
            PElist = [Select Id,Product2Id from pricebookEntry where pricebook2Id =: parentId];
           
            for(pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
        }
        List<AggregateResult> productfamilylist =[Select family from Product2  where (Id IN :ProdIds AND family != null) group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if(productfamilylist.size() > 0 ){
            for(AggregateResult agg : productfamilylist){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('family'));
                pfwrapperlst.add(pf);
            }
            system.debug('pfwrapperlst---->'+pfwrapperlst);
        }
        return pfwrapperlst;
    }

    @AuraEnabled
    public static buildertek__Billable_Lines__c saveSalesInvoiceLine(String salesInvoice){
       
        buildertek__Billable_Lines__c salesInvoiceRec = new buildertek__Billable_Lines__c();
        salesInvoiceRec = (buildertek__Billable_Lines__c)System.JSON.deserialize(salesInvoice, buildertek__Billable_Lines__c.class);

        buildertek__Billable_Lines__c saveSalesInvoiceLineToInsert = new buildertek__Billable_Lines__c();

        if (salesInvoiceRec.buildertek__Item_Name__c != null && salesInvoiceRec.buildertek__Item_Name__c.length() > 79) {
            saveSalesInvoiceLineToInsert.buildertek__Description__c = salesInvoiceRec.buildertek__Item_Name__c.substring(0, 79);
            saveSalesInvoiceLineToInsert.buildertek__Item_Name__c = salesInvoiceRec.buildertek__Item_Name__c.substring(0, 79);
        } else {
            saveSalesInvoiceLineToInsert.buildertek__Description__c = salesInvoiceRec.buildertek__Item_Name__c;
            saveSalesInvoiceLineToInsert.buildertek__Item_Name__c = salesInvoiceRec.buildertek__Item_Name__c;
        }

        saveSalesInvoiceLineToInsert.buildertek__Product__c = salesInvoiceRec.buildertek__Product__c;
        saveSalesInvoiceLineToInsert.buildertek__Billings__c = salesInvoiceRec.buildertek__Billings__c; 
        saveSalesInvoiceLineToInsert.buildertek__Unit_Price__c = salesInvoiceRec.buildertek__Unit_Price__c;
        saveSalesInvoiceLineToInsert.buildertek__Quantity__c = salesInvoiceRec.buildertek__Quantity__c;
        saveSalesInvoiceLineToInsert.buildertek__Cost_Code__c = salesInvoiceRec.buildertek__Cost_Code__c;
         
        insert saveSalesInvoiceLineToInsert;
        return saveSalesInvoiceLineToInsert;
    }

    public class productfamilyClass{
        @AuraEnabled public string productfamilyvalues {get;set;}
    }
}