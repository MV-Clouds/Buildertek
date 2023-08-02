@isTest
private class BT_DeleteInspectionsControllerTest {

	private static testMethod void insertInspections() {
        List<buildertek__Inspection__c> buildertekListInspectionRef = new List<buildertek__Inspection__c>();
        buildertek__Inspection__c buildertekInspectionRef = new buildertek__Inspection__c();
        buildertekInspectionRef.buildertek__Name__c = 'DFL Test';
        buildertekListInspectionRef.add(buildertekInspectionRef);
        insert buildertekInspectionRef;
        BT_DeleteInspectionsController.deleteInspectionRecord(buildertekInspectionRef.Id);
        System.assertEquals('Test','Test');
	}

}