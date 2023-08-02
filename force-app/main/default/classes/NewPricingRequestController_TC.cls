@isTest
private class NewPricingRequestController_TC {

    @isTest
    static void method1(){
        contact con = new contact();
        con.lastname = 'hemanth';
        con.Email = 'hemanth.chintada@diligentforcelabs.com';
        insert con;
          buildertek__Pricing_Request__c PR = new buildertek__Pricing_Request__c();
        PR.Name = 'Hemanth';
        PR.buildertek__Quoted_By__c = con.Id;
        insert PR;
          buildertek__Pricing_Request_Line__c PRLine = new buildertek__Pricing_Request_Line__c();
        PRLine.buildertek__Description__c ='Hemanth';
        PRLine.buildertek__Pricing_Request__c = PR.Id;
        PRLine.buildertek__Status__c = 'Accepted';
        insert PRLine;
        NewPricingRequestController.approvepricingRequest(PR.Id);
        NewPricingRequestController.getprrec(PR.Id);
        NewPricingRequestController.getpricingRequest(PR.Id);
        NewPricingRequestController.getobjectName(PR.Id);
        NewPricingRequestController.getFieldSet('buildertek__Meeting__c','buildertek__MeetingFields');
        NewPricingRequestController.getDropDown('Opportunity','StageName');
        //  NewPricingRequestController.getDropDown('Opportunity','StageNam');
        
    }
}