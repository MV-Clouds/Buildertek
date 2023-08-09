@isTest
private class EmailPunchListsControllerTest {

	private static testMethod void test() {
        EmailPunchListsController EmailPunchListsController = new EmailPunchListsController();
        list<buildertek__Punch_List__c> buildertekPunchList = new list<buildertek__Punch_List__c>();
        buildertek__Punch_List__c PunchListRef = new buildertek__Punch_List__c();
        PunchListRef.buildertek__Description__c = 'test';
        buildertekPunchList.add(PunchListRef);
        insert PunchListRef;
        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', PunchListRef.id);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(buildertekPunchList);
        stdSetController.setSelected(buildertekPunchList);
        EmailPunchListsController ext = new EmailPunchListsController(stdSetController);
        Test.stopTest();
        System.assert(true);
	}

}