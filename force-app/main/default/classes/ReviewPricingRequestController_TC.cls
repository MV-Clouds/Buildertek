@isTest
private class ReviewPricingRequestController_TC {
    
    @isTest
    static void method1(){
    ReviewPricingRequestController.getcurrency();
        }
    @isTest
    static void method2(){
          buildertek__Pricing_Request__c PR = new buildertek__Pricing_Request__c();
        PR.Name = 'Hemanth';
        insert PR;
        ReviewPricingRequestController.getSOVName(PR.Id);
          buildertek__Pricing_Request_Line__c PRLine = new buildertek__Pricing_Request_Line__c();
        PRLine.buildertek__Description__c ='Hemanth';
        PRLine.buildertek__Pricing_Request__c = PR.Id;
        insert PRLine;
        List<buildertek__Pricing_Request_Line__c> PRLineList = new List<buildertek__Pricing_Request_Line__c>();
        PRLineList.add(PRLine);
           List<String> Ids = new List<String>();
         Ids.add(PRLine.Id);
        ReviewPricingRequestController.getVendorSOVLines(PRLine.Id);
        ReviewPricingRequestController.ApproveSovLines(PRLine.Id);
        ReviewPricingRequestController.rejectSovLines(PRLine.Id,'Test');
        ReviewPricingRequestController.createSheetLines(PRLineList,PR.Id);
        ReviewPricingRequestController.getAllApproved(Ids);
       // ReviewPricingRequestController.getAllRejected(Ids);
         ReviewPricingRequestController.clearAllLines(Ids);
    }
}