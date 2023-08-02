@isTest
public with sharing class cloneOfCreateRFQFromPRLControllerTest {

    @isTest
    static void testMethod1(){
        
        buildertek__Pricing_Request__c PR = new buildertek__Pricing_Request__c();
        PR.Name = 'PR Testing';
        insert PR;

        buildertek__Pricing_Request_Line__c PRL = new buildertek__Pricing_Request_Line__c();
        PRL.buildertek__Description__c = 'PRL Testing';
        PRL.buildertek__Pricing_Request__c = PR.Id;
        insert PRL;

        buildertek__Pricing_Request_Line_Details__c PRLD = new buildertek__Pricing_Request_Line_Details__c();
        PRLD.buildertek__Description__c = 'PRLD Testing';
        PRLD.buildertek__Pricing_Request_Line__c = PRL.Id;
        PRLD.buildertek__Quantity__c = 3;
        PRLD.buildertek__Cost__c = 39;
        insert PRLD;

        List<buildertek__Pricing_Request_Line_Details__c> PRLDsList = new List<buildertek__Pricing_Request_Line_Details__c>{PRLD};

        buildertek__RFQ__c RFQ = new buildertek__RFQ__c();
        RFQ.Name = 'RFQ Testing';

        Test.startTest();

        cloneOfCreateRFQFromPRLController.getPRLDsData(PRL.Id);
        cloneOfCreateRFQFromPRLController.CreateRFQ(PRL.Id, RFQ, PRLDsList);
		
        Test.stopTest();

    }
}