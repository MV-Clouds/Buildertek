@IsTest(SeeAllData=true)
private class InSiteProfileCalloutTest {

	@IsTest(SeeAllData=true)
	public static void testProfileCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteProfileResource');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);

		// Call method to test
		Id recordId = TestUtility.getFakeId(pba__Request__c.getSObjectType());
		Map<String, Object> result = InSitePanelController.makeProfileCallout(recordId);

		// Verify mock response is not null
		System.assertNotEquals(null, result, 'The callout returned a null response.');

		System.assert(result.containsKey('overview'), 'Response does not have overview key');
	}

	@IsTest(SeeAllData=true)
	public static void testProfileFailsCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteProfileResource');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);

		Id recordId = TestUtility.getFakeId(pba__Request__c.getSObjectType());
		Map<String, Object> result = null;
		try {
			result = InSitePanelController.makeProfileCallout(recordId);
		} catch (InSiteCalloutFailedException e) {
			System.assert(true, 'this should not fail?');
		} catch (Exception e) {
			System.assertEquals(true, false, 'Captured non InSite exception');
		}
	}

	@IsTest(SeeAllData=true)
	public static void testGettingRequestPayload() {
		Contact testContact = new Contact(Salutation='Mr', FirstName='Test', LastName='Person', Email='test.person@email.com', MobilePhone='0400000000', LeadSource='Project Website');
		insert testContact;

		pba__Property__c testProject = new pba__Property__c(RecordTypeId='0122w000001HieuAAC', Name='Test Project');
		insert testProject;

		Id contactId = Id.valueOf(testContact.Id);
		Id projectId = Id.valueOf(testProject.Id);
		pba__Request__c test = new pba__Request__c();
		test.put('pba__Contact__c', contactId);
		test.put('Project_Look_Up__c', projectId);
		insert test;

		Map<String, Object> data = InSitePanelController.loadCalloutDataFromRecordId(test.Id);
		System.assertEquals(test.Id, data.get('record_id'), 'record_id should match test ID');
	}

	@IsTest(SeeAllData=true)
	public static void testGetProjectId() {
		Contact testContact = new Contact(Salutation='Mr', FirstName='Test', LastName='Person', Email='test.person@email.com', MobilePhone='0400000000', LeadSource='Project Website');
		insert testContact;

		pba__Property__c testProject = new pba__Property__c(RecordTypeId='0122w000001HieuAAC', Name='Test Project');
		insert testProject;

		Id contactId = Id.valueOf(testContact.Id);
		Id projectId = Id.valueOf(testProject.Id);
		pba__Request__c test = new pba__Request__c();
		test.put('pba__Contact__c', contactId);
		test.put('Project_Look_Up__c', projectId);
		insert test;

		Map<String, String> result = InSitePanelController.getProjectId(test.Id);
		System.assertEquals(testProject.Id, result.get('project_id'));
	}
}