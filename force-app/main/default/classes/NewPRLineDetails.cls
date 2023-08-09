public without sharing class NewPRLineDetails {
    @AuraEnabled
    public static String createPRLineDetails(buildertek__Pricing_Request_Line_Details__c PRLineDetails) {
        try{
            System.debug('in method calling');
            insert PRLineDetails;
            return PRLineDetails.Id;
        }
        catch(Exception e){
            System.debug('error In createPRLineDetails => ' + e);
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static List<Product2> getProductDetails(String priceBookId, String searchProductFilter){
        List<PricebookEntry> pbEntryList = [SELECT Id, Name, Product2Id, Product2.Name FROM PricebookEntry WHERE Pricebook2Id =: priceBookId];
        List<Product2> productList = new List<Product2>();
        for (PricebookEntry pbEntry : pbEntryList) {
            if (pbEntry.Product2.Name.toLowerCase().contains(searchProductFilter.toLowerCase())) {
                Product2 product = new Product2();
                product.Id = pbEntry.Product2Id;
                product.Name = pbEntry.Product2.Name;
                productList.add(product);
            }
        }
        return productList;
    }

    @AuraEnabled
    public static String getOptions(String recordId){
        List<buildertek__Pricing_Request_Line__c> PricingRequestLine = [SELECT Id, Name, buildertek__Pricing_Request__c FROM buildertek__Pricing_Request_Line__c WHERE Id =: recordId];
        String PRId = PricingRequestLine[0].buildertek__Pricing_Request__c;
        List<buildertek__Pricing_Request__c> PricingRequest = [SELECT Id, Name, buildertek__BT_Selection_Option__c  FROM buildertek__Pricing_Request__c WHERE Id =: PRId];
        String BTSelectionOption = PricingRequest[0].buildertek__BT_Selection_Option__c;
        return BTSelectionOption;
        
    }
}