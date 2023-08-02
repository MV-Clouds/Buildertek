public with sharing class BT_BudgetLineDetailPage {

    @AuraEnabled(cacheable=true)
    public static buildertek__Budget_Item__c getRecord(String recordId){
        buildertek__Budget_Item__c BudgetLine = [SELECT Id,buildertek__Product__c,buildertek__Product_Name__c, Name, buildertek__Complete__c,buildertek__Profit_Loss__c,buildertek__Cost_Code__c,buildertek__Contractor__c,buildertek__Budget__c,buildertek__Total_Costs__c,buildertek__Approved_CO__c,buildertek__Invoice_total__c,buildertek__Labor__c,buildertek__Additional_Costs__c,buildertek__Committed_Costs__c,buildertek__Original_Budget__c,buildertek__UOM__c,buildertek__Unit_Price__c,buildertek__Quantity__c,buildertek__Group__c FROM buildertek__Budget_Item__c WHERE Id =: recordId];
        return BudgetLine;
    }
    @AuraEnabled
    public static void updateRecord(buildertek__Budget_Item__c BudgetLine){
        update BudgetLine;
    }    
    @AuraEnabled
    public static String getProductName(String productId){
        String productName = [SELECT Name FROM Product2 WHERE Id =: productId].Name;
        return productName;
    }
    @AuraEnabled
    public static Decimal getunitPrice(String productId){
        List<PricebookEntry> pricebookEntries = [SELECT Id, UnitPrice,buildertek__Unit_Cost__c FROM PricebookEntry WHERE Product2Id =: productId AND IsActive = true];
        if(pricebookEntries.size() == 0){
            return null;
        }
        else if (pricebookEntries[0].buildertek__Unit_Cost__c == null){
            return pricebookEntries[0].UnitPrice;
        }
        else{
            return pricebookEntries[0].buildertek__Unit_Cost__c;
        }
    }
}