public with sharing class InSitePanelController {

	@AuraEnabled
	public static Map<String, Object> makeProfileCallout(Id recordId) {
		Http http = new Http();

		InSiteApiRequestBuilder requestBuilder = new InSiteApiRequestBuilder();
		HttpRequest request = requestBuilder.createRequest('/api/v1/profile', 'POST', JSON.serialize(InSitePanelController.loadCalloutDataFromRecordId(recordId)));

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			String body = response.getBody();
			return (Map<String, Object>) JSON.deserializeUntyped(body);
		}
		System.debug('response code: ' + response.getStatusCode());
		System.debug('response code: ' + response.getBody());
		throw new InSiteCalloutFailedException('Failed to make callout');
	}

	@AuraEnabled
	public static Map<String, String> getProjectId(Id recordId) {
		System.debug('getProjectId');
		Map<String, String> result = new Map<String, String>();
		pba__Request__c enquiry = InSiteEnquiryUtils.lookupPropertybaseEnquiryById(recordId);
		if(enquiry != null) {
			result.put('project_id', (String)enquiry.get('Project_Look_Up__c'));
		}

		return result;
	}

	@AuraEnabled
	public static List<Object> getSessionDetails(Long sessionId, String sku) {
		return InSiteSessionDetailsCallout.makeSessionDetailsCallout(sessionId, sku);
	}

	public static Map<String, Object> loadCalloutDataFromRecordId(Id recordId) {
		pba__Request__c enquiry = InSiteEnquiryUtils.lookupPropertybaseEnquiryById(recordId);
		System.debug(enquiry);
		Map<String, Object> result = new Map<String, Object>();
		if (enquiry != null) {
			result.put('record_id', enquiry.get('Id'));
			result.put('email', enquiry.pba__Contact__r.Email);
			result.put('project_id', enquiry.get('Project_Look_Up__c'));
		}

		return result;
	}
}