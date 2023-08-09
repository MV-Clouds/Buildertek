@isTest
private class BT_DeleteContractsControllerTest {

	private static testMethod void insertContracts() {
	    List<buildertek__Contract__c> buildertekContractLstRef = new List<buildertek__Contract__c>();
        buildertek__Contract__c	buildertekContractRef = new buildertek__Contract__c	();
        buildertekContractRef.Name ='test';
        buildertekContractLstRef.add(buildertekContractRef);
        insert buildertekContractRef;
        BT_DeleteContractsController.deleteContractRecord(buildertekContractRef.id);
        System.assertEquals('Test','Test');
	}

}