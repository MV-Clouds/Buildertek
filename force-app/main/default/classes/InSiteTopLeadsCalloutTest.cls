@IsTest(SeeAllData=true)
private class InSiteTopLeadsCalloutTest {

	@IsTest(SeeAllData=true)
	public static void testTopLeadsCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteTopResource');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);

		// Call method to test
		//Id recordId = TestUtility.getFakeId(Lead.getSObjectType());
		List<Object> result = InSiteTopLeadsController.makeTopLeadsCallout(null, null);

		// Verify mock response is not null
		System.assertNotEquals(null, result, 'The callout returned a null response.');

		System.assertEquals(20, result.size(), 'The response does not have 20 records in it');
	}

	@IsTest(SeeAllData=true)
	public static void testTopLeadsFailsCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteTopResource');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);

		List<Object> result = null;
		try {
			result = InSiteTopLeadsController.makeTopLeadsCallout(null, null);
		} catch (InSiteCalloutFailedException e) {
			System.assert(true, 'this should not fail?');
		} catch (Exception e) {
			System.assertEquals(true, false, 'Captured non InSite exception');
		}
	}

	@IsTest(SeeAllData=true)
	public static void testGetRecordInformation() {
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
		Id testId = test.Id;
		test = Database.query('SELECT Id, pba__Contact__r.Email FROM pba__Request__c WHERE id=:testId');

		pba__Request__c loaded = InSiteTopLeadsController.retrieveEnquiryDataForUserWithEmailAddress((String) test.pba__Contact__r.Email);
		System.assertEquals(test.Id, loaded.Id, 'records should have the same ID');
	}

	@IsTest(SeeAllData=true)
	public static void testMakeSelectedProjectInSiteCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteTopResource');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);

		// Call method to test
		//Id recordId = TestUtility.getFakeId(Lead.getSObjectType());

		Id projectId = TestUtility.getFakeId(pba__Property__c.getSObjectType());
		List<Object> result = InSiteTopLeadsController.makeSelectedProjectInSiteCallout(projectId);

		// Verify mock response is not null
		System.assertNotEquals(null, result, 'The callout returned a null response.');

		System.assertEquals(20, result.size(), 'The response does not have 20 records in it');
	}

	@IsTest(SeeAllData=true)
	public static void testCombinedReportingCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteCombinedResource');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);

		Map<String,Object> response = InSiteTopLeadsController.makeCombinedReportingCallout(1590463232, 'Australia/Melbourne', 7);

		// Verify mock response is not null
		System.assertNotEquals(null, response, 'The callout returned a null response.');
		System.assert(response.containsKey('total'), 'Response does not have overview key');
	}

	@IsTest(SeeAllData=true)
	public static void testFailCombinedReportingCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteCombinedResource');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);

		try {
			Map<String,Object> response = InSiteTopLeadsController.makeCombinedReportingCallout(1590463232, 'Australia/Melbourne', 7);
		} catch(InSiteCalloutFailedException e) {
			System.assert(true, 'this should not fail?');
		} catch(Exception e) {
			System.assertEquals(true, false, 'Captured non InSite exception');
		}
	}

	@IsTest(SeeAllData=true)
	public static void testGettingProjectList() {
		List<Object> r = InSiteTopLeadsController.getSupportedProjectsList();
		System.assertNotEquals(true, r.isEmpty(), 'response should have data in it');
	}
}