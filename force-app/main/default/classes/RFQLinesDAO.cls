public with sharing class RFQLinesDAO {
    @AuraEnabled
    public static string saveRFQItem(String rfqLines, String costCode, String rfqId, Integer quantity, String tradetype){
       
        List<buildertek__RFQ__c> rfqrec;
        /* if (Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() &&
         Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isAccessible()
         && Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()){*/
        rfqrec = [select id,name,buildertek__Status__c from buildertek__RFQ__c where Id=:rfqId limit 1];
      /*}*/
        if(rfqrec[0].buildertek__Status__c == 'New' ){
        buildertek__RFQ_Item__c rfqLinesToInsert = (buildertek__RFQ_Item__c)JSON.deserialize(rfqLines, buildertek__RFQ_Item__c.class);
        /*if (Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__RFQ_Package__c.isCreateable()
            && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Cost_Code__c.isCreateable()) {*/
           
            rfqLinesToInsert.buildertek__RFQ_Package__c = rfqId;
            rfqLinesToInsert.buildertek__Cost_Code__c = costCode;
            rfqLinesToInsert.buildertek__Trade_Type__c = tradetype;
            insert rfqLinesToInsert;  
            
        /*} */
        return rfqLinesToInsert.Id;
      }else{
          return 'The RFQ has already been '+'"'+rfqrec[0].buildertek__Status__c+'"'+ ' You can not add more lines';
      }
    }
    
    
    @AuraEnabled
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName, string parentId){
        system.debug('ObjectName-->' + ObjectName);
        Map<String, String> options = new Map<String, String>();
        List<sObject> returnList = new List<sObject>();

        list<string> ProdIds = new list<string>();
        if (ObjectName == 'Product2' && parentId != null){

            list<pricebookEntry> PElist;

            PElist = [select id, Product2Id
                      from pricebookEntry
                      where pricebook2Id = :parentId];

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
    
  @AuraEnabled
    public static string getpricebook(string BudgetId){
        system.debug('budgetId-------->'+BudgetId);
        list<buildertek__Purchase_Order__c> purchaseOrder;
        if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()){
            purchaseOrder = [select id, buildertek__Project__r.buildertek__Price_Book__c
                             from buildertek__Purchase_Order__c
                             where id = :BudgetId];
        }
        system.debug('changeOrder--------->'+purchaseOrder);
        if (purchaseOrder.size() > 0){
            return purchaseOrder[0].buildertek__Project__r.buildertek__Price_Book__c;
        }
        return null;
    }
    
    
    @AuraEnabled
    //get Pricebook Values
    public static Map<String, String> getpricebooks(){
        Map<String, String> options = new Map<String, String>();

        list<pricebook2> PriceList;
        if (Schema.sObjectType.pricebook2.fields.Id.isAccessible() && Schema.sObjectType.pricebook2.fields.Name.isAccessible()){
            PriceList = [select Id, Name
                         from pricebook2
                         WHERE Name != null ORDER BY Name ASC ];
        }
        for (pricebook2 p : PriceList){
            //Put Picklist Value & Label in Map
            options.put(p.name, p.Id);
        }
        return options;
    }

    
    @AuraEnabled
    public static List<buildertek__Trade_Type__c> getTradeTypes(){
        List<buildertek__Trade_Type__c> tradeTypesList = [SELECT Id, Name FROM buildertek__Trade_Type__c ORDER BY Name ASC];
        return tradeTypesList;
    }
    
    
   /*  @AuraEnabled
    public static string RFQITEM(string recordId){
        buildertek__RFQ_Item__c rfq = [SELECT Id, Name FROM buildertek__RFQ_Item__c ];
        system.debug('>>>>>'+rfq);
        return rfq.Name;
    }*/
    
      @AuraEnabled
    public static string RFQITEM(string recordId){
        buildertek__RFQ_Item__c rfq = [SELECT Id, Name, buildertek__RFQ_Package__c FROM buildertek__RFQ_Item__c where buildertek__RFQ_Package__c = :recordId];
        system.debug('>>>>>'+rfq);
        return rfq.Name;
    }
    
    
    
    @AuraEnabled
    public static buildertek__RFQ__c getRFQ(string recId){
        system.debug('>>>>>'+recId);
        buildertek__RFQ__c bc = [select id,buildertek__Description__c from buildertek__RFQ__c where id=:recId];
        system.debug('>>>>>'+bc);
        return bc;
    }
    
    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
    }

    // create a boolean method to get the value of buildertek__Admin_Interface_Node_Configuration__c objects , buildertek__RFQLines_Using_Product__c field value\
    @AuraEnabled
    public static boolean getRFQLinesUsingProduct(){
        Boolean UsingProducts = [SELECT buildertek__RFQLines_Using_Product__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'RFQ Configuration'].buildertek__RFQLines_Using_Product__c;
        System.debug('UsingProducts--->'+UsingProducts);
        return UsingProducts; 
    }
}