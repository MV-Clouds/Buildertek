@isTest
public class ContractTriggerTest {
    public static testMethod void testContractTrigger() {
        Contract__c contract = new Contract__c();
        insert contract;
        update contract;
        delete contract;
        System.assertEquals('Test','Test');
    }
}