@isTest
public with sharing class Create_PO_From_OptionTest {

    @isTest
    static void testMethod1() {

        Account acc = new Account();
        acc.Name = 'testing Account';
        insert acc;

        Product2 pr = new Product2();
        pr.Name = 'Product';
        insert pr;

        buildertek__Question__c option = new buildertek__Question__c();
        option.Name = 'Optoin Testing';
        option.buildertek__Upgrade_Costs__c = 35;
        option.buildertek__Quantity__c = 10;
        option.buildertek__Upgrade__c = true;
        option.buildertek__Selected__c = true;
        option.buildertek__Product__c = pr.Id;
        option.buildertek__Manufacturer__c = acc.Id;
        insert option;


        Test.startTest();

        Create_PO_From_Option.createPO(option.Id);

        Test.stopTest();
    }
}