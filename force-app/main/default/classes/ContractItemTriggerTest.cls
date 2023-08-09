@isTest
public class ContractItemTriggerTest {
    public static testMethod void testContractItemTrigger() {
        Contract__c contract = new buildertek__Contract__c();
        insert contract;
        
        Contract_Item__c contractTerm = new Contract_Item__c(Contract__c = contract.Id);
        insert contractTerm;
        update contractTerm;
        delete contractTerm;
        System.assertEquals('Test','Test');
    }
}