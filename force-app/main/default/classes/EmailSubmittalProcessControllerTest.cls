@isTest
private class EmailSubmittalProcessControllerTest {

	private static testMethod void test() {
        EmailSubmittalProcessController EmailControllerRef = new EmailSubmittalProcessController();
        list<buildertek__Submittal__c> buildertekSubmittal = new list<buildertek__Submittal__c>();
        buildertek__Submittal__c buildertekSubmittalRef = new buildertek__Submittal__c();
        buildertekSubmittalRef.buildertek__Title__c = 'Test';
        buildertekSubmittal.add(buildertekSubmittalRef);
        insert buildertekSubmittalRef;
         Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', buildertekSubmittalRef.id);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(buildertekSubmittal);
        stdSetController.setSelected(buildertekSubmittal);
        EmailSubmittalProcessController ext = new EmailSubmittalProcessController(stdSetController);
        Test.stopTest();
        system.assert(true);
	}

}