public with sharing class InSiteSessionDetailsCallout {

	public static List<Object> makeSessionDetailsCallout(Long sessionId, String sku) {
		Http http = new Http();
//		HttpRequest request = new HttpRequest();
//		request.setEndpoint('https://salesforce-service-dot-insite-land.appspot.com/api/v1/session');
//		request.setMethod('POST');
//		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
//		request.setBody(JSON.serialize(InSiteSessionDetailsCallout.generateRequestPayload(sessionId, sku)));

		InSiteApiRequestBuilder requestBuilder = new InSiteApiRequestBuilder();
		HttpRequest request = requestBuilder.createRequest('/api/v1/session', 'POST', JSON.serialize(InSiteSessionDetailsCallout.generateRequestPayload(sessionId, sku)));

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			String body = response.getBody();
			return (List<Object>) JSON.deserializeUntyped(body);
		}

		System.debug('response code: ' + response.getStatusCode());
		System.debug('response code: ' + response.getBody());
		throw new InSiteCalloutFailedException('Failed to make callout');
	}

	private static Map<String, Object> generateRequestPayload(Long sessionId, String sku) {
		Map<String, Object> result = new Map<String, Object>();
		result.put('session_id', sessionId);
		result.put('sku', sku);
		return result;
	}
}