@isTest
private class BT_ImportMasterPRLClassTest {
    @TestSetup
    static void makeData(){
        buildertek__Pricing_Request__c PR = new buildertek__Pricing_Request__c();
        PR.Name = 'PR Testing';
        insert PR;

        buildertek__Pricing_Request_Line__c PRL = new buildertek__Pricing_Request_Line__c();
        PRL.buildertek__Description__c = 'PRL Testing';
        PRL.buildertek__Pricing_Request__c = PR.Id;
        PRL.buildertek__Type__c = 'Master';
        insert PRL;

        buildertek__Pricing_Request_Line_Details__c PRLD = new buildertek__Pricing_Request_Line_Details__c();
        PRLD.buildertek__Description__c = 'PRLD Testing';
        PRLD.buildertek__Pricing_Request_Line__c = PRL.Id;
        PRLD.buildertek__Quantity__c = 3;
        PRLD.buildertek__Cost__c = 39;
        insert PRLD;

        List<buildertek__Pricing_Request_Line_Details__c> PRLDsList = new List<buildertek__Pricing_Request_Line_Details__c>{PRLD};

        
    }
    @isTest
    public static void testMethod1() {
        buildertek__Pricing_Request__c PR =[Select Id , name From buildertek__Pricing_Request__c LIMIT 1];
        buildertek__Pricing_Request_Line__c PRL=[Select id , name ,buildertek__Pricing_Request__c, buildertek__Type__c, buildertek__Description__c From buildertek__Pricing_Request_Line__c];
        List<String> itList =new List<String>();
        itList.add(PRL.Id);
        Test.startTest();
        BT_ImportMasterPRLClass.getMasterBudgets();
        BT_ImportMasterPRLClass.importRFQItems(itList , PR.Id );

        Test.stopTest();
        
    }
    
}