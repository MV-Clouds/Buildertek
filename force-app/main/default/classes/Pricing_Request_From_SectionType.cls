// Test Class - PR_From_OptionTest
public with sharing class Pricing_Request_From_SectionType {

    @AuraEnabled
    public static List<buildertek__Question__c> getRecord(String recordId) {
        List<buildertek__Question__c> optionList = [SELECT Id, Name, buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name, 
                                                    buildertek__Purchase_Order_Line__c, buildertek__Cost__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c =: recordId AND buildertek__Pricing_Request_Line_Detail__c = null];                           
        System.debug('optionList => '+optionList);
        return optionList;
    }

    @AuraEnabled
    public static string createPR(String recordId, buildertek__Pricing_Request__c pricingRequest, List<buildertek__Question__c> optionList){

        buildertek__Question_Group__c section = [SELECT Id, Name, buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c FROM buildertek__Question_Group__c WHERE Id =: recordId];

        pricingRequest.buildertek__Status__c = 'Pending';
        pricingRequest.buildertek__Project__c = section.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
        insert pricingRequest;

        buildertek__Pricing_Request_Line__c prLine = new buildertek__Pricing_Request_Line__c();
        prLine.buildertek__Description__c = section.Name;
        prLine.buildertek__Pricing_Request__c = pricingRequest.Id;
        insert prLine;

        Map<Id, buildertek__Pricing_Request_Line_Details__c> prDetailsMap = new Map<Id, buildertek__Pricing_Request_Line_Details__c>();
        for (buildertek__Question__c option : optionList) {
            buildertek__Pricing_Request_Line_Details__c prDetail = new buildertek__Pricing_Request_Line_Details__c();
            prDetail.buildertek__Description__c = option.Name;
            prDetail.buildertek__Pricing_Request_Line__c = prLine.Id;
            prDetail.buildertek__Vendor__c = option.buildertek__Manufacturer__c;
            prDetail.buildertek__Purchase_Order__c = option.buildertek__Purchase_Order__c;
            prDetail.buildertek__Purchase_Order_Line__c = option.buildertek__Purchase_Order_Line__c;
            prDetail.buildertek__Cost__c = option.buildertek__Cost__c;
            prDetailsMap.put(option.Id, prDetail);
        }
        insert prDetailsMap.values();

        for (buildertek__Question__c option : optionList) {
            option.buildertek__Pricing_Request_Line__c = prLine.Id;
            option.buildertek__Pricing_Request_Line_Detail__c = prDetailsMap.get(option.Id).Id;
        }
        update optionList;

        return prLine.Id;
    }
}