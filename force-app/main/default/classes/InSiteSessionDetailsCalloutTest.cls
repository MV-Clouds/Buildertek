@IsTest(SeeAllData=true)
private class InSiteSessionDetailsCalloutTest {

	@IsTest(SeeAllData=true)
	public static void testSessionDetailsCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteSessionResource');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);
		List<Object> response = InSiteSessionDetailsCallout.makeSessionDetailsCallout(1, 'aaa');
		System.debug(response);
		System.debug('result of isEmpty() method call');
		System.debug(response.isEmpty());

		// Verify mock response is not null
		System.assertNotEquals(null, response, 'The callout returned a null response.');
		System.assertNotEquals(true, response.isEmpty(), 'response should have data in it');
	}

	@IsTest(SeeAllData=true)
	public static void testFailSessionDetailsCallout() {
		// Create the mock response based on a static resource
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('InSiteSessionResource');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

		// Associate the callout with a mock response
		Test.setMock(HttpCalloutMock.class, mock);
		try {
			List<Object> response = InSiteSessionDetailsCallout.makeSessionDetailsCallout(1, 'aaa');
		} catch(InSiteCalloutFailedException e) {
			System.assert(true, 'this should not fail?');
		} catch(Exception e) {
			System.assertEquals(true, false, 'Captured non InSite exception');
		}
	}
}