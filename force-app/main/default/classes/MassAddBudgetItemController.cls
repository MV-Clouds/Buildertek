public with sharing class MassAddBudgetItemController {

    Public String recordId{ get; set; }

    public MassAddBudgetItemController() {
        recordId = ApexPages.currentPage().getParameters().get('Id');
    }

    @AuraEnabled
    public static List<buildertek__Budget_Line_Group__c> getBudgetLineGroups(){
        List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c ORDER BY Name ASC];
        return budgetLineGroups;
    }

    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }
    @AuraEnabled
    public static List<pricebookWrapper> getpricebooks(string recordId){
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();
        
        pricebookWrapper priceWrap = new pricebookWrapper();
        priceWrap.defaultValue= new pricebook2();
        priceWrap.priceWrapList = new List<pricebook2>();
        List<pricebook2> PriceList = [select Id, Name from pricebook2 Where buildertek__BT_Visible__c = true AND isActive = true ORDER BY Name ASC];
        priceWrap.priceWrapList=PriceList;

        if(recordId != null){
            buildertek__Budget__c budgetRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Budget__c  WHERE Id = :recordId];
            if(budgetRecord.buildertek__Project__c != null && budgetRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
                pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:budgetRecord.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                priceWrap.defaultValue= selectedPriceList;
            }
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
    public static List<Account> getAccounts(){
        List<Account> accounts = [SELECT Id, Name FROM Account ORDER BY Name ASC];
        return accounts;
    }

    @AuraEnabled
    public static string saveBudgetLine( List<buildertek__Budget_Item__c> budgetLineList){
        //itertate through the list and insert the records
        System.debug('budgetLineList==>'+budgetLineList);
        for(buildertek__Budget_Item__c budgetLine : budgetLineList){
            if(budgetLine.Name.length() > 79){
                budgetLine.buildertek__Item_Name__c = budgetLine.Name;
                budgetLine.Name = budgetLine.Name.substring(0,79);
            }
        }
        try{
            insert budgetLineList;
            return 'Success';
        }catch(Exception e){
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static List<String> getPicklistValues(String objectName, String fieldName){
        System.debug('objectName==>'+objectName);
        System.debug('fieldName==>'+fieldName);
        List<String> picklistValues = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        System.debug('targetType==>'+targetType);
        if (targetType != null) {
            Schema.DescribeSObjectResult targetDescribe = targetType.getDescribe();
            System.debug('targetDescribe==>'+targetDescribe);
            if (targetDescribe != null) {
                Schema.DescribeFieldResult targetField = targetDescribe.fields.getMap().get(fieldName).getDescribe();
                System.debug('targetField==>'+targetField);
                if (targetField != null) {
                    List<Schema.PicklistEntry> picklistEntries = targetField.getPicklistValues();
                    for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                        picklistValues.add(picklistEntry.getValue());
                    }
                    System.debug('picklistValues==>'+picklistValues);
                }
            }
        }
        return picklistValues;
    }



}