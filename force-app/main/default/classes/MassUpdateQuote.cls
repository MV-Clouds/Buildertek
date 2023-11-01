public with sharing class MassUpdateQuote{
    Public String recordId{ get; set; }
    
    Private ApexPages.StandardController controller;
    
    Public MassUpdateQuote(){
        recordId = ApexPages.currentPage().getParameters().get('Id');
    }
    
    @AuraEnabled
    public static string getName(String recordId){
        try{
            List<buildertek__Quote__c> record = [Select Id, Name
                                                 From buildertek__Quote__c
                                                 WHERE Id = :recordId];
            if (record.size() > 0){
                return record[0].Name;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    @AuraEnabled
    public static Integer getCount(String recordId){
        try{
            if(String.isNotBlank(recordId)){
                return [Select COUNT()
                        FROM buildertek__Quote_Item__c
                        WHERE buildertek__Quote__c = :recordId];
                
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static String getRecords(String parentRecordId, String fieldNameJson,Integer pageNumber, Integer pageSize){
        
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            if(String.isNotBlank(parentRecordId)){
                Integer offset = (pageNumber - 1) * pageSize;
                List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
                Set<String> setFieldNames = new Set<String>();
                String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM buildertek__Quote_Item__c';
                query += ' WHERE buildertek__Quote__c= : parentRecordId ORDER BY Name ASC NULLS LAST';
                query += ' LIMIT : pageSize OFFSET : offset';
                for (sObject s : Database.query(query)){
                    lstResult.add(s);
                    system.debug('result'+lstResult);
                }
                if (lstResult.size() > 0){
                    result = JSON.serialize(lstResult);
                    return result;
                }
            }
        } catch (Exception e){
            System.debug('Error' + e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        try{
            List<String> pickListValuesList = new List<String>();
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Quote_Item__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__Mass_add_Quote_Item'))
                for (Schema.FieldSetMember f : FsMap.get('buildertek__Mass_add_Quote_Item').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__Quote_Item__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
        }
        return '[' + result + ']';
    }
    
    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static String updateRecords(String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize, List<String> deleteLineitems){
        try{
            if (String.isNotBlank(updatedRecords)){
                List<buildertek__Quote_Item__c> items = (List<buildertek__Quote_Item__c>)JSON.deserialize(updatedRecords, List<buildertek__Quote_Item__c>.class);
                for (buildertek__Quote_Item__c item : items){
                    if(item.Id == null){
                        item.buildertek__Quote__c = recordId;
                    }
                }
                if (items.size() > 0){
                    upsert items;
                }
                List<buildertek__Quote_Item__c> deleteList = [SELECT Id from buildertek__Quote_Item__c WHERE Id IN: deleteLineitems];
               // system.debug('delete==>'+deleteList);
                if(deleteList.Size()>0){
                    delete deleteList;
                }
                return getRecords(recordId, fieldSetName, pageNumber, pageSize);
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static String deleteQuoteItem(String quoteId, String recordId, String fieldSetName, Integer pageNumber, Integer pageSize){
        try{
            if (String.isNotBlank(recordId)){
                delete [Select Id
                        FROM buildertek__Quote_Item__c
                        WHERE Id = :recordId];
                return getRecords(quoteId, fieldSetName, pageNumber, pageSize);
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }    

    @AuraEnabled
    public static List<Boolean> getadminvalues(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Remove_Single_Quote_Line_Option__c, buildertek__Hide_Global_Margin__c, buildertek__Hide_Global_Markup__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Quote Configuration'];
        Boolean checkSingleQLine = adminInterfaceNodeConfigurations.buildertek__Remove_Single_Quote_Line_Option__c ;
        Boolean checkButtonMargin = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Margin__c;
        Boolean checkButtonMarkup = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Markup__c;
        List<Boolean> islien = new List<Boolean>{checkSingleQLine, checkButtonMargin,checkButtonMarkup};
        return islien;
    }  
    public class pricebookWrapper{
        @AuraEnabled
        public Map<String, String> optionMap;

        @AuraEnabled
        public Map<String, String> defaultValue;
    }

    @AuraEnabled
    public static List<pricebookWrapper> getpricebooks(string recordId){
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();
        
        pricebookWrapper priceWrap = new pricebookWrapper();

        buildertek__Quote__c quoteRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Quote__c  WHERE Id = :recordId];
        if(quoteRecord.buildertek__Project__c != null && quoteRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
            priceWrap.defaultValue= new Map<String, String>();
            pricebook2 selectedPriceList = [select Id, Name from pricebook2 where Id=:quoteRecord.buildertek__Project__r.buildertek__Price_Book__c];
            priceWrap.defaultValue.put(selectedPriceList.Name , quoteRecord.buildertek__Project__r.buildertek__Price_Book__c);
        }

        priceWrap.optionMap = new Map<String, String>();
        list<pricebook2> PriceList = [select Id, Name from pricebook2  Where buildertek__BT_Visible__c = true AND isActive = true ORDER BY Name ASC];
        for (pricebook2 p : PriceList){
            priceWrap.optionMap.put(p.name, p.Id);
        }
        priceWrapper.add(priceWrap);
        

      
        return priceWrapper;
    }

    @AuraEnabled
    public static List<productWrapper> ProductsthroughPB(string pbookId) {
        List<PriceBookEntry> pEntries = [SELECT Id,Product2Id, Product2.buildertek__Quote_Group__c , Product2.Name, Product2.ProductCode, Product2.Description, toLabel(Product2.Family), 
                                            Product2.IsActive,buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Pricebook2.Name, UnitPrice
                                            FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND IsActive = True 
                                            ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST];
        
        System.debug('pEntries==>'+pEntries);

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
            products.add(aProduct);
        }

        return products;
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
    }

    @AuraEnabled
    public static List<buildertek__Quote_Line_Group__c> QLGroups(){
        List<buildertek__Quote_Line_Group__c> quoteLineGrouping = [SELECT Id, Name FROM buildertek__Quote_Line_Group__c ORDER BY Name ASC];
        return quoteLineGrouping;
        
    }

    @AuraEnabled
    public static Boolean saveQuoteLine(List<buildertek__Quote_Item__c> quotelineList){
        // System.debug('quotelineList==>'+quotelineList);
        List<buildertek__Quote_Item__c> quoteLineItems = new List<buildertek__Quote_Item__c>();
        for(buildertek__Quote_Item__c obj : quotelineList){
            buildertek__Quote_Item__c quoteLine = new buildertek__Quote_Item__c();
            System.debug('obj==>'+obj);
            System.debug('obj Name ==>'+obj.Name);
            if(obj.Name != null){
                // quoteLine.Name = obj.Name;
                quoteLine.Name = obj.Name.length() > 80 ? obj.Name.substring(0,79) : obj.name;
                quoteLine.buildertek__Item_Name__c = obj.Name;
            }
            if(obj.buildertek__Grouping__c != null){
                quoteLine.buildertek__Grouping__c = obj.buildertek__Grouping__c;
            }
            if(obj.buildertek__Margin__c != null){
                quoteLine.buildertek__Margin__c = obj.buildertek__Margin__c;
            }
            if(obj.buildertek__Markup__c != null){
                quoteLine.buildertek__Markup__c = obj.buildertek__Markup__c;
            }
            if(obj.buildertek__Notes__c != null){
                quoteLine.buildertek__Notes__c = obj.buildertek__Notes__c;
            }
            if(obj.buildertek__Product__c != null){
                quoteLine.buildertek__Product__c = obj.buildertek__Product__c;
            }
            if(obj.buildertek__Quantity__c != null){
                quoteLine.buildertek__Quantity__c = obj.buildertek__Quantity__c;
            }
            if(obj.buildertek__Quote__c != null){
                quoteLine.buildertek__Quote__c = obj.buildertek__Quote__c;
            }
            if(obj.buildertek__Unit_Cost__c != null){
                quoteLine.buildertek__Unit_Cost__c = obj.buildertek__Unit_Cost__c;
            }
            // System.debug('quoteLine==>'+quoteLine);
            quoteLineItems.add(quoteLine);
        }
        System.debug('quoteLineItems==>'+quoteLineItems);
        
        try{
            insert quoteLineItems;
            return true;
        }catch(Exception e){
            System.debug('Exception==>'+e);
            return false;
        }
    }

    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
    }

    @AuraEnabled
    public list<productfamilyClass> pfwrapperlst{ get; set; }

    //get product family Values
    @AuraEnabled
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName, string parentId){
        system.debug('ObjectName-->' + ObjectName);
        Map<String, String> options = new Map<String, String>();
        List<sObject> returnList = new List<sObject>();

        list<string> ProdIds = new list<string>();
        if (ObjectName == 'Product2' && parentId != null){

            list<pricebookEntry> PElist =[select id, Product2Id   from pricebookEntry  where pricebook2Id = :parentId];
            for (pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
        }
        //list<Product2> productfamlylst = [select id, Name,family from Product2 where Id IN :ProdIds AND family != null order by family];
        List<AggregateResult> productfamlylst = [SELECT toLabel(Family) familyLabel  FROM Product2 where (Id IN :ProdIds AND family != null) group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if (productfamlylst.size() > 0){
            for (AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('familyLabel'));
                pfwrapperlst.add(pf);
            }
        }
        return pfwrapperlst;
    }

    public class wrapperClass{
        @AuraEnabled
         public  list<PricebookEntry> priceBookList{get;set;}

         @AuraEnabled
         public  list<Product2> productList{get;set;}
    }

    @AuraEnabled
    public static wrapperClass getProductPrice(String productId, List<String> pricebookId){
        Boolean containsEmptyString = false;
        list<string> ProdIds = new list<string>();
        wrapperClass wrapper= new wrapperClass();
        wrapper.priceBookList= new List<PricebookEntry>();
        wrapper.productList= new List<Product2>();

        for (String id : pricebookId) {
            if (String.isBlank(id)) { // Check if the string is empty or only whitespace
                containsEmptyString = true;
                break; // Exit the loop if an empty string is found
            }
        }
        
        if (containsEmptyString) {
            System.debug('The pricebookId list contains empty strings.');
            list<PricebookEntry> price = [select id, Product2Id, product2.family from pricebookEntry];
            for (pricebookEntry PE :  price){
                ProdIds.add(PE.Product2Id);
            } 
            wrapper.productList=[Select Id , Name From Product2 WHERE ID NOT IN:ProdIds LIMIT 800];

        } else {
            wrapper.priceBookList = [select id, UnitPrice, pricebook2Id, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Product2Id, Product2.Name ,Product2.buildertek__Quote_Group__r.Name, Product2.QuantityUnitOfMeasure	
                    FROM PricebookEntry where product2Id = :productId and pricebook2Id =: pricebookId LIMIT 800];
        }
        return wrapper;

    }


}