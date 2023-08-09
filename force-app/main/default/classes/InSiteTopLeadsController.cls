public with sharing class InSiteTopLeadsController {

	@AuraEnabled
	public static List<Object> makeTopLeadsCallout(String sortBy, Integer filter) {
		String url = '/api/v1/leads/top-ten';

		Http http = new Http();

		// handle query string
		List<String> queryStringParams = new List<String>();
		System.debug('sortBy param');
		System.debug(sortBy);
		System.debug('filter param');
		System.debug(filter);
		if (sortBy != null) { queryStringParams.add('sortby=' + sortBy); }
		if (filter != null) { queryStringParams.add('filter=' + filter); }
		if (!queryStringParams.isEmpty()) {
			String queryString = String.join(queryStringParams, '&');
			url = url + '?' + queryString;
		}

		InSiteApiRequestBuilder requestBuilder = new InSiteApiRequestBuilder();
		HttpRequest request = requestBuilder.createRequest(url, 'POST', createJsonPayload(UserInfo.getUserId()));

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			String body = response.getBody();
			return (List<Object>) JSON.deserializeUntyped(body);
		}
		System.debug('response code: ' + response.getStatusCode());
		System.debug('response code: ' + response.getBody());
		throw new InSiteCalloutFailedException('Failed to make callout');
	}

	@AuraEnabled
	public static pba__Request__c retrieveEnquiryDataForUserWithEmailAddress(String emailAddress) {
		pba__Request__c result = null;

		try {
			result = InSiteEnquiryUtils.lookupPropertybaseEnquiryByEmailAddress(emailAddress);
		} catch (Exception e) {
			System.debug(e);
		}

		return result;
	}

	@AuraEnabled
	public static List<Object> getSupportedProjectsList() {
		return InSiteLoadProjectsWithSharing.loadProjects();
	}

	@AuraEnabled
	public static Map<String, Object> makeCombinedReportingCallout(Long currentTimestamp, String timeZone, Long selectedRange) {
		Http http = new Http();
		InSiteApiRequestBuilder requestBuilder = new InSiteApiRequestBuilder();
		HttpRequest request = requestBuilder.createRequest('/api/v1/combined', 'POST', createReportPayload(currentTimestamp, timeZone, selectedRange));

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
	public static List<Object> makeSelectedProjectInSiteCallout(Id selectedProjectId) {
		Http http = new Http();
		InSiteApiRequestBuilder requestBuilder = new InSiteApiRequestBuilder();
		HttpRequest request = requestBuilder.createRequest('/api/v1/leads/top-ten', 'POST', createSingleProjectJsonPayload(UserInfo.getUserId(), selectedProjectId));

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			String body = response.getBody();
			return (List<Object>) JSON.deserializeUntyped(body);
		}
		System.debug('response code: ' + response.getStatusCode());
		System.debug('response code: ' + response.getBody());
		throw new InSiteCalloutFailedException('Failed to make callout');
	}

	private static String createJsonPayload(Id userId) {
		Map<String, Object> working = new Map<String, Object>();

		List<pba__Property__c> projectList = InSiteLoadProjectsWithSharing.loadProjects();
		List<Id> projectIdList = new List<Id>();
		for (pba__Property__c p : projectList) {
			projectIdList.add(p.Id);
		}

		working.put('agentId', String.valueOf(userId));
		working.put('projects', projectIdList);

		return JSON.serialize(working);
	}

	private static String createSingleProjectJsonPayload(Id userId, Id projectId) {
		Map<String, Object> working = new Map<String, Object>();
		List<Id> projectIdList = new List<Id>();
		projectIdList.add(projectId);
		working.put('agentId', String.valueOf(userId));
		working.put('projects', projectIdList);
		return JSON.serialize(working);
	}

	private static String createReportPayload(Long currentTimestamp, String timeZone, Long selectedRange) {
		Map<String, Object> working = new Map<String, Object>();

		List<pba__Property__c> projectList = InSiteLoadProjectsWithSharing.loadProjects();
		List<Id> projectIdList = new List<Id>();
		for (pba__Property__c p : projectList) {
			projectIdList.add(p.Id);
		}

		working.put('projects', projectIdList);
		working.put('current_timestamp', currentTimestamp);
		working.put('timezone_offset', timeZone);
		working.put('selected_range', selectedRange);

		return JSON.serialize(working);
	}
}