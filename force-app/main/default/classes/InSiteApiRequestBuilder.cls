public with sharing class InSiteApiRequestBuilder {

	private String baseUrl;

	private String accessToken;

	private String clientId;

	public InSiteApiRequestBuilder() {
		this.baseUrl = InSiteSettings.getInSiteApiUrl();
	}

	public HttpRequest createRequest(String apiPath, String method, String jsonEncodedBody) {
		HttpRequest request = new HttpRequest();
		request.setEndpoint(this.baseUrl + apiPath);
		request.setMethod(method);
		request.setHeader('Content-Type', 'application/json;charset=UTF-8');
		request.setBody(jsonEncodedBody);

		return request;
	}
}