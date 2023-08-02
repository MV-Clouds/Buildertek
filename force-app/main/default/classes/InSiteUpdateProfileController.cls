public with sharing class InSiteUpdateProfileController {

	@AuraEnabled
	public static Object makeUpdateProfileCallout(String jsonBody) {
		Http http = new Http();
		InSiteApiRequestBuilder requestBuilder = new InSiteApiRequestBuilder();
		HttpRequest request = requestBuilder.createRequest('/api/v1/update-profile', 'POST', jsonBody);

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			String body = response.getBody();
			return (Object) JSON.deserializeUntyped(body);
		}

		System.debug('response code: ' + response.getStatusCode());
		System.debug('response code: ' + response.getBody());
		throw new InSiteCalloutFailedException('Failed to make callout');
	}
}