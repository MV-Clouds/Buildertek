global class BT_createAuthByCode_POC extends Auth.AuthProviderPluginClass {

    public String redirectUrl; // use this URL for the endpoint that the authentication provider calls back to for configuration
    private String key;
    private String secret;
    private String authUrl;    // application redirection to the concur / class website for authentication and authorization
    private String accessTokenUrl; // uri to get the new access token from concur / class  using the GET verb
    private String customMetadataTypeApiName; // api name for the custom metadata type created for this auth provider
    private String userAPIUrl; // api url to access the user in concur / class
    private String userAPIVersionUrl; // version of the user api url to access data from concur / class
    
    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<string,string> authProviderConfiguration, String stateToPropagate) {
        authUrl = authProviderConfiguration.get('Auth_Url__c');
        key = authProviderConfiguration.get('Key__c');
        //Here the developer can build up a request of some sort
        //Ultimately they’ll return a URL where we will redirect the user
        String url = authUrl + '?client_id='+ key +'&scope=USER,EXPRPT,LIST&redirect_uri='+ redirectUrl + '&state=' + stateToPropagate;
        return new PageReference(url);
     }

     global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {
        //Here, the developer will get the callback with actual protocol.  
        //Their responsibility is to return a new object called AuthProviderToken
        //This will contain an optional accessToken and refreshToken
        key = authProviderConfiguration.get('Key__c');
        secret = authProviderConfiguration.get('Secret__c');
        accessTokenUrl = authProviderConfiguration.get('Access_Token_Url__c');
        
        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');
        
        HttpRequest req = new HttpRequest();
        String url = accessTokenUrl+'?code=' + code + '&client_id=' + key + '&client_secret=' + secret;
        req.setEndpoint(url);
        req.setHeader('Content-Type','application/xml');
        req.setMethod('GET');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        String accessToken = getTokenValueFromResponse(responseBody, 'AccessToken', null);
        //Parse access token value
        String refreshToken = getTokenValueFromResponse(responseBody, 'RefreshToken', null);
        //Parse refresh token value
        
        return new Auth.AuthProviderTokenResponse('BT_createAuthByCode_POC', accessToken, 'refreshToken', sfdcState);
        //don’t hard-code the refresh token value!
     }

     global Auth.UserData  getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
        //Here the developer is responsible for constructing an Auth.UserData object
        String token = response.oauthToken;
        HttpRequest req = new HttpRequest();
        userAPIUrl = authProviderConfiguration.get('API_User_Url__c');
        userAPIVersionUrl = authProviderConfiguration.get('API_User_Version_Url__c');
        req.setHeader('Authorization', 'OAuth ' + token);
        req.setEndpoint(userAPIUrl);
        req.setHeader('Content-Type','application/xml');
        req.setMethod('GET');
    
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responseBody = res.getBody();
        String id = getTokenValueFromResponse(responseBody, 'LoginId',userAPIVersionUrl);
        String fname = getTokenValueFromResponse(responseBody, 'FirstName', userAPIVersionUrl);
        String lname = getTokenValueFromResponse(responseBody, 'LastName', userAPIVersionUrl);
        String flname = fname + ' ' + lname;
        String uname = getTokenValueFromResponse(responseBody, 'EmailAddress', userAPIVersionUrl);
        String locale = getTokenValueFromResponse(responseBody, 'LocaleName', userAPIVersionUrl);
        Map<String,String> provMap = new Map<String,String>();
        provMap.put('what1', 'noidea1');
        provMap.put('what2', 'noidea2');
        return new Auth.UserData(id, fname, lname, flname, uname,
             'what', locale, null, 'Concur', null, provMap);
   }

   private String getTokenValueFromResponse(String response, String token, String ns) {
    Dom.Document docx = new Dom.Document();
    docx.load(response);
    String ret = null;

    dom.XmlNode xroot = docx.getrootelement() ;
    if(xroot != null){
       ret = xroot.getChildElement(token, ns).getText();
    }
    return ret;
}  


   
}