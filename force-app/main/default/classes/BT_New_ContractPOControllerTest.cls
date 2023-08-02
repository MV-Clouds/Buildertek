@isTest
public with sharing class BT_New_ContractPOControllerTest {
    @TestSetup
    static void ContractPO() {

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'test';
        project.buildertek__Customer__c = acc.Id;
        insert project;

        buildertek__Contract__c contract = new buildertek__Contract__c();
        contract.Name = 'test';
        contract.buildertek__Description__c = 'test';
        contract.buildertek__Project__c = project.Id;
        contract.buildertek__Vendor__c = acc.Id;
        insert contract;

        buildertek__Contract_Item__c contractItem = new buildertek__Contract_Item__c();
        contractItem.Name = 'test';
        contractItem.buildertek__Contract__c = contract.Id;
        insert contractItem;

        buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
        PO.buildertek__Description__c = 'test';
        PO.buildertek__Vendor__c = acc.Id;
        insert PO;

        buildertek__Purchase_Order_Item__c POLine = new buildertek__Purchase_Order_Item__c();
        POLine.Name = 'test';
        POLine.buildertek__Purchase_Order__c = PO.Id;
        insert POLine;
    }
    @isTest
    static void ContractPO1(){
        buildertek__Contract__c contract = [SELECT Id,Name FROM buildertek__Contract__c LIMIT 1];

        BT_New_ContractPOController.createlines(contract.Id);
        BT_New_ContractPOController.create(contract.Id,2);
    }
}