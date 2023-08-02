@isTest
private class PricingRequestLinesController_TC {
@isTest
    static void method1(){
        PricingRequestLinesController.getcurrency();
    }
    @isTest
    static void method2(){
       buildertek__Pricing_Request__c PR = new buildertek__Pricing_Request__c();
        PR.Name = 'Hemanth';
        insert PR;
        List<buildertek__Pricing_Request_Line__c> PRLineList = new List<buildertek__Pricing_Request_Line__c>();
        List<String> Ids = new List<String>();
        buildertek__Pricing_Request_Line__c PRLine = new buildertek__Pricing_Request_Line__c();
        PRLine.buildertek__Description__c ='Hemanth';
        PRLine.buildertek__Pricing_Request__c = PR.Id;
        insert PRLine;
        PRLineList.add(PRLine);
        Ids.add(PRLine.Id);
        PricingRequestLinesController.getSovLines(PR.Id);
        PricingRequestLinesController.createSheetLines(PRLineList,PR.Id);
        PricingRequestLinesController.deletesheetline(Ids,PRLine.Id);
       PricingRequestLinesController.getSOVName(PR.Id);
    }
}