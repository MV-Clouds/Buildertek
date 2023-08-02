public with sharing class Create_Sales_Order_Btn {
    @AuraEnabled
    public static string createSalesOrder(String recordId) {
        try {            
            
            buildertek__Quote__c quote = [SELECT Id, buildertek__Primary_Contact__c, buildertek__Primary_Contact__r.AccountId, buildertek__Primary_Contact__r.Email, buildertek__Project__c, buildertek__Notes__c FROM buildertek__Quote__c where Id=:recordId];

            List<buildertek__Quote_Item__c> quoteItemList = [SELECT Id, buildertek__Quantity__c, buildertek__Unit_Cost__c, buildertek__Additional_Discount__c, buildertek__Markup__c FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c =: recordId];
            
            System.debug('quote => '+quote);
            buildertek__Sales_Order__c salesOrder = new buildertek__Sales_Order__c();
            salesOrder.buildertek__Contact__c = quote.buildertek__Primary_Contact__c;
            salesOrder.buildertek__Project__c = quote.buildertek__Project__c;
            salesOrder.buildertek__Customer_Notes__c = quote.buildertek__Notes__c;
            salesOrder.buildertek__Quote__c = quote.Id;
            salesOrder.buildertek__Contact_Email__c = quote.buildertek__Primary_Contact__r.Email;
            salesOrder.buildertek__Account__c = quote.buildertek__Primary_Contact__r.AccountId;
            insert salesOrder;   
            System.debug('salesOrder => '+salesOrder);
            
            List<buildertek__Sales_Order_Lines__c> salesLineList = new List<buildertek__Sales_Order_Lines__c>();

            for (buildertek__Quote_Item__c quoteItem : quoteItemList) {
                System.debug('quoteItem => '+quoteItem);
               buildertek__Sales_Order_Lines__c orderLine = new buildertek__Sales_Order_Lines__c();
               orderLine.buildertek__Sales_Order__c = salesOrder.Id;
               orderLine.buildertek__Quantity__c = quoteItem.buildertek__Quantity__c;
               orderLine.buildertek__Unit_Cost__c = quoteItem.buildertek__Unit_Cost__c;
               orderLine.buildertek__Discount__c = quoteItem.buildertek__Additional_Discount__c;
               orderLine.buildertek__Markup__c = quoteItem.buildertek__Markup__c;
               System.debug('orderLine => '+orderLine);
               salesLineList.add(orderLine);
            }            
            if(salesLineList.size()>0){
                insert salesLineList;
            }       
        
            return salesOrder.Id ; 

        } catch (Exception e) {
            System.debug('Error => '+e.getMessage());
            return 'Error';
        }
    }
}