public with sharing class BT_POlineCustomDetailPageController {

    @AuraEnabled
    public static String getFieldSet(String objectName, String fieldSetName){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(fieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
            
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Error::' + e.getMessage());
            System.debug('Error At Line::' + e.getLineNumber());
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
    public static buildertek__Purchase_Order_Item__c getRecordData(String recordId, String FieldsToQuery){
        try {
            buildertek__Purchase_Order_Item__c POline = [SELECT Id, Name, buildertek__Product__c,buildertek__Unit_Price__c,buildertek__Quantity__c,buildertek__Cost_Code__c, buildertek__Product__r.Name, buildertek__Product__r.buildertek__Cost_Code__c FROM buildertek__Purchase_Order_Item__c WHERE Id =: recordId LIMIT 1];
            System.debug('recordId : ' + recordId);
            System.debug('FieldsToQuery : ' + FieldsToQuery);
            return POline;

        } catch (Exception e) {
            System.debug('Exception : ' + e);
            return null;
        }
    }

    @AuraEnabled
    public static String updateRecord(String updatedData, String recordID){
        System.debug('recordID' + recordID);
        buildertek__Purchase_Order_Item__c UpdatedRecord = (buildertek__Purchase_Order_Item__c) JSON.deserialize(updatedData, buildertek__Purchase_Order_Item__c.class);
        UpdatedRecord.Id = recordID;
        update UpdatedRecord;
        return 'Updated Record : ' + UpdatedRecord.Name;
    }

    @AuraEnabled
    public static list<pricebook2> getPricebooks(){
        list<pricebook2> procebooks = [select Id, Name from pricebook2 where buildertek__BT_Visible__c = true AND isActive = true ORDER BY Name ASC];
           if(procebooks.size() > 0){
            return procebooks;
           }
           else {
            return null;
           }
    }

    @AuraEnabled
    public static List<productWrapper> getProductRelatedtoPB(String PricebookId){
        try {
            system.debug('PricebookId >> ' +  PricebookId);
            List<PriceBookEntry> pEntries = [SELECT Id,Product2Id, Product2.buildertek__Quote_Group__c , Product2.Name, Product2.ProductCode, Product2.Description,Product2.buildertek__Cost_Code__c, toLabel(Product2.Family), 
            Product2.IsActive,buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure  
            FROM PricebookEntry WHERE Pricebook2Id=:PricebookId AND IsActive = True 
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
            aProduct.CostCode = pEntry.Product2.buildertek__Cost_Code__c;     
            products.add(aProduct);
            }

            system.debug('products >> ' +  products);

            return products;
        } catch (Exception e) {
            System.debug('Exception : ' + e);
            return null;
        }
    }

    @AuraEnabled
    public static List<productWrapper> getProductRelatedToPF(String PricebookId, String Product_Family){
        try {
            List<PriceBookEntry> pEntries = [SELECT Id,Product2Id, Product2.buildertek__Quote_Group__c , Product2.Name, Product2.ProductCode, Product2.Description,Product2.buildertek__Cost_Code__c, toLabel(Product2.Family), 
            Product2.IsActive,buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure  
            FROM PricebookEntry WHERE Pricebook2Id=:PricebookId AND Product2.Family =: Product_Family AND IsActive = True 
            ORDER BY Product2.Name ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 1000];

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
            aProduct.CostCode = pEntry.Product2.buildertek__Cost_Code__c;          
            products.add(aProduct);
            }

            system.debug('products >> ' +  products);

            return products;
            
        } catch (Exception e) {
            System.debug('Exception : ' + e);
            return null;
        }
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

        @AuraEnabled
        public String CostCode;
    }
}