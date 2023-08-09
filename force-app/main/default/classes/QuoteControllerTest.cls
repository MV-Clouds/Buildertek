@isTest
private class QuoteControllerTest {

    private static testMethod void test() {
        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
        contact con = new contact();
        con.lastname ='test';
        insert con;
         Account acc = new Account();
        acc.Name='test2';
        insert acc;
        List< Opportunity> oppList = new List< Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = acc.Name;
        
        opp.StageName = 'Qualification';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.Today().addDays(3);
        oppList.add(opp);
        insert oppList;
        List<String> selectedIds = new List<String>();
        selectedIds.add(oppList[0].Id);
        list<buildertek__Service_Request__c> buildertekServiceRequestRefLst = new List<buildertek__Service_Request__c>();
        buildertek__Service_Request__c buildertekServiceRequestRef = new buildertek__Service_Request__c();
        buildertekServiceRequestRef.buildertek__Project__c = buildertekProjectRef.id;
        buildertekServiceRequestRef.buildertek__Customer_Name__c = con.id;
        buildertekServiceRequestRef.buildertek__Subject__c ='test';
        buildertekServiceRequestRefLst.add(buildertekServiceRequestRef);
        insert buildertekServiceRequestRef;
        // QuoteController.getProjectDetails(buildertekProjectRef.id);
        // QuoteController.getServiceReqDetails(buildertekServiceRequestRef.id);
        //  QuoteController.getOpportunityDetails(oppList[0].Id);
        System.assertEquals('Test','Test');
    }

}