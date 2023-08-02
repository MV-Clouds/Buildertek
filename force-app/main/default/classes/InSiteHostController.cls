public with sharing class InSiteHostController {
    public String getIframeUrl() {
        Map<String, String> iframeParams = new Map<String, String>();

        String baseUrl = InSiteSettings.getRemoteGatewayUrl();
        String userId = UserInfo.getUserId();

        iframeParams.put('user', userId);

        Map<String, String> params = Apexpages.currentPage().getParameters();
        System.debug(params);
        if(params.containsKey('project')) {
            iframeParams.put('sfpid', params.get('project'));
        }

        if(params.containsKey('lead')) {
            iframeParams.put('sfid', params.get('lead'));
        }

        System.PageReference pr = new System.PageReference('');
        pr.getParameters().putAll(iframeParams);

        return baseUrl + pr.getUrl();
    }
}