public with sharing class Pricing_Request_From_Option {
    @AuraEnabled
    public static string createPR(String recordId, buildertek__Pricing_Request__c pricingRequest){

        buildertek__Question__c option = [SELECT Id, Name, buildertek__Quantity__c , buildertek__Manufacturer__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order_Line__c, buildertek__Cost__c, 
                                            buildertek__Question_Group__c, buildertek__Pricing_Request_Line_Detail__c, buildertek__Question_Group__r.Name, 
                                            buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c 
                                            FROM buildertek__Question__c WHERE Id =: recordId];          

        if (option.buildertek__Pricing_Request_Line_Detail__c != null) {
            return 'PRLD is already exist';
            
        } else {
            pricingRequest.buildertek__Status__c = 'Pending';
            pricingRequest.buildertek__Project__c = option.buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
            insert pricingRequest;

            buildertek__Pricing_Request_Line__c prLine = new buildertek__Pricing_Request_Line__c();
            prLine.buildertek__Description__c = option.buildertek__Question_Group__r.Name;
            prLine.buildertek__Pricing_Request__c = pricingRequest.Id;
            insert prLine;

            buildertek__Pricing_Request_Line_Details__c prDetail = new buildertek__Pricing_Request_Line_Details__c();
            prDetail.buildertek__Description__c = option.Name;
            prDetail.buildertek__Pricing_Request_Line__c = prLine.Id;
            prDetail.buildertek__Vendor__c = option.buildertek__Manufacturer__c;
            prDetail.buildertek__Purchase_Order__c = option.buildertek__Purchase_Order__c;
            prDetail.buildertek__Purchase_Order_Line__c = option.buildertek__Purchase_Order_Line__c;
            prDetail.buildertek__Cost__c = option.buildertek__Cost__c;
            prDetail.buildertek__Quantity__c = option.buildertek__Quantity__c;
            prDetail.buildertek__Option__c=option.Id;
            insert prDetail;

            option.buildertek__Pricing_Request_Line__c = prLine.Id;
            option.buildertek__Pricing_Request_Line_Detail__c = prDetail.Id;
            update option;

            return prDetail.Id;
        }
        
    }
}