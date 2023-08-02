public class cloneOfCreateRFQFromPRLController {

    @AuraEnabled
    public static List<buildertek__Pricing_Request_Line_Details__c> getPRLDsData(String recordId){
        List<buildertek__Pricing_Request_Line_Details__c> prldList = [SELECT Id, Name, buildertek__Description__c, buildertek__Quantity__c, buildertek__Cost__c, buildertek__Product__c, buildertek__Vendor__c, 
                                                                        buildertek__Pricing_Request_Line__c, buildertek__Pricing_Request_Line__r.buildertek__RFQ__c, 
                                                                        buildertek__Pricing_Request_Line__r.buildertek__Pricing_Request__r.buildertek__Project__c 
                                                                        FROM buildertek__Pricing_Request_Line_Details__c WHERE buildertek__Pricing_Request_Line__c =: recordId];
        return prldList;
    }

    @AuraEnabled
    public static String CreateRFQ(String recordId,buildertek__RFQ__c RFQ, List<buildertek__Pricing_Request_Line_Details__c> PRLDsList){
        RFQ.buildertek__Pricing_Request_Line__c = recordId;
        RFQ.buildertek__Project__c = PRLDsList[0].buildertek__Pricing_Request_Line__r.buildertek__Pricing_Request__r.buildertek__Project__c;
        insert RFQ;

        buildertek__Pricing_Request_Line__c PRL = new buildertek__Pricing_Request_Line__c();
        PRL.Id = recordId;
        PRL.buildertek__RFQ__c = RFQ.Id;
        update PRL;

        Map<Id, buildertek__RFQ_Item__c> RFQItemMap = new Map<Id, buildertek__RFQ_Item__c>();
        for (buildertek__Pricing_Request_Line_Details__c PRLD : PRLDsList) {
            buildertek__RFQ_Item__c RFQItem = new buildertek__RFQ_Item__c();
            RFQItem.Name = PRLD.buildertek__Description__c;
            RFQItem.buildertek__RFQ_Package__c = RFQ.Id;
            RFQItem.buildertek__Pricing_Request_Line_Detail__c = PRLD.Id;
            RFQItem.buildertek__Quantity__c = PRLD.buildertek__Quantity__c;
            RFQItem.buildertek__Unit_Price__c = PRLD.buildertek__Cost__c;
            RFQItem.buildertek__Product__c = PRLD.buildertek__Product__c;
            RFQItem.buildertek__Vendor__c = PRLD.buildertek__Vendor__c;
            RFQItemMap.put(PRLD.Id, RFQItem);
        }
        insert RFQItemMap.values();

        for (buildertek__Pricing_Request_Line_Details__c PRLD : PRLDsList) {
            PRLD.buildertek__RFQ_Lines__c = RFQItemMap.get(PRLD.Id).Id;
            PRLD.buildertek__RFQ__c = RFQ.Id;
        }
        update PRLDsList;

        return RFQ.Id;
    }
}