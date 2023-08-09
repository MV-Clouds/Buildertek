@isTest
public class ProjectMassUpdateTest{
	@testSetup
	static void setupMethod(){
		Account acc = new Account();
		acc.Name = 'Test 1';
		insert acc;

		buildertek__Project__c project = new buildertek__Project__c();
		project.buildertek__Account__c = acc.Id;
		insert project;
	}

	@isTest
	static void testMethod1(){
		List<buildertek__Project__c> project = [Select Id
		                                  FROM buildertek__Project__c
		                                  LIMIT 1];
		ProjectMassUpdate.getCount();
		String fieldName='[]';
		ProjectMassUpdate.getFieldSet();
		ProjectMassUpdate.getRecords(fieldName, 1, 10);
		ProjectMassUpdate.updateRecords(JSON.serialize(project), fieldName, 1, 10);
		ProjectMassUpdate.deleteProject(project[0].Id, fieldName, 1, 10);
	}
}