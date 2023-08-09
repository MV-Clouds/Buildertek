@IsTest(SeeAllData=true)
private class InSiteUpdateProfileCalloutTest {

	@IsTest(SeeAllData=true)
	static void testUpdateProfileCallout() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteUpdateProfileResource');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		Test.setMock(HttpCalloutMock.class, mock);
		Object response = InSiteUpdateProfileController.makeUpdateProfileCallout('{"test": "test"}');
		System.debug(response);

		System.assertNotEquals(null, response, 'The callout returned a null response.');
	}

	@IsTest(SeeAllData=true)
	public static void testUpdateProfileCalloutFails() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		
		mock.setStaticResource('InSiteUpdateProfileResource');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
		
		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);

		try {
			Object response = InSiteUpdateProfileController.makeUpdateProfileCallout('{"test": "test"}');
		} catch (InSiteCalloutFailedException e) {
			System.assert(true, 'this should not fail?');
		} catch (Exception e) {
			System.assertEquals(true, false, 'Captured non InSite exception');
		}
	}
}