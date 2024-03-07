public with sharing class QBCallOutService {

    // POST method
    public static HttpResponse QBAPICallOut(String QBEndPoint, String JSONBody) {
        try {

            String Access_Token;
            String SetQBEndPoint;
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Name_Credential_API_Name__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Access_Token_Expire_At__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Refresh_Token_Expire_At__c, buildertek__Scope__c, buildertek__Get_Access_Token__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = QBMetadata.buildertek__Get_Access_Token__c;
            if(Access_Token != '' || Access_Token != null){
                Http h = new Http();
                
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                if(Get_Access_Token == true){
                    //  Access_Token = 'eyJlbmMiOiJBMTI4Q0JDLUhTMjU2IiwiYWxnIjoiZGlyIn0..KatHVe6RKPA3SrQSayqm0A.8IpWhOCGdf8-7ApTGabckQpVZPOCotvl-ieKKGOz6c1pVe0DRTw8ILZ0qg72i_FFSp1PJiDR33MB5llcB_a16VZItio0EqogXKWMDEqVDOxX16KJ_KLMIWTAKs0ucDsLNx4aghtAnnA2WKqeX5AOnZ8XSd2qVzQFudEWzyA7bXr6WyaZJApZFNqRQnOFJinJgVfy1nj1XZm8hbEy5dcmZsqZLdNuG4uKEN1Qep8UOAIMLCVHS6maiUuBeaLNg0E93r0B0HMYB672VpMhWEP9pLVQGPHhwC_h2JnjSxIdlKVNUL5XbDidRqjzDy1WYVwIv0Lu1TwZ90gI6S2Ny-ljlaIKbzBRE4X-nmexBTEvjf9l2nnPFreJuxCK0i19-7YLCtEU81r08u1xs57GlamOAIXc7db_UXmz8j1_fYvG24OaSv9jxNFxB3p4v5vGUIkmut06O5MNsNFt4g5cDNlrFxns1mlvHht8sGY4p-7wW7ofk-9-4ZF0uN6IeTVs5dypLS9Vlnf2yJOdlLf4QhAmcw8Tagw99C6purTrTxwpeDWI4uUstuEMrFXUey6K87AdVjhtKNYFEspeUSBb1wTsIzrG9r6hsnWf1Ex5RghFqTMF15XLO71zAyGSOO1_d-WLKA1Z7wxDipt12Ybqh0D16wiFvanYL4ohYi0at6fI0pPHGgmjwEqJiLGghNshm-GWNXD6FMlgSctl_LekxNjTT5LFnwn9zRb1Q_acCbdW5c2ovdesbguUiHERP1KKNVjs.-KHS9JsKtx63560yGWr0tw';
                    Access_Token = QBMetadata.buildertek__Access_Token__c;
                    SetQBEndPoint = QBMetadata.buildertek__Base_Url__c + QBEndPoint;
                    System.debug('access tocken endpoint : ' + SetQBEndPoint);
                    req.setEndpoint(SetQBEndPoint);
                    req.setHeader('Authorization','Bearer '+ Access_Token );
                }
                else{
                    SetQBEndPoint = 'callout:'+ QBMetadata.buildertek__Name_Credential_API_Name__c + QBEndPoint;
                    System.debug('name cred End Point : ' + SetQBEndPoint);
                    req.setEndpoint(SetQBEndPoint);
                    req.setHeader('Authorization','Bearer ');
                }
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept','application/json');
                // req.setHeader('Authorization',ReqHeader);
                req.setBody(JSONBody);
    
    
                HttpResponse res = new HttpResponse();
                res = h.send(req);
                String ResponseBody = res.getBody();
                System.debug('Response Status Code >> ' + res.getStatusCode() + ' || Response status >> '+ res.getStatus());
                // System.debug('ResponseBody >> ' + ResponseBody);
    
                return res;
            }
            system.debug('Access Token is null');
            return null;

        } catch (Exception e ) {
            System.debug('Error Drung APi QBAPICallOut >> ' + e.getMessage());
            return null;
        }
    }

    // Get Method
    public static HttpResponse QBAPICallOut_GET(String QBEndPoint, String JSONBody ) {
        try {
            String Access_Token;
            String endpointUrl;
            String SetQBEndPoint;
    
            // Perform DML operations or other database transactions here
    
            // Query the metadata record
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__Name_Credential_API_Name__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Access_Token_Expire_At__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Get_Access_Token__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = QBMetadata.buildertek__Get_Access_Token__c;
            // Create HTTP objects
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
    
            // Set the endpoint URL for the GET request
             endpointUrl = 'callout:'+ QBMetadata.buildertek__Name_Credential_API_Name__c + QBEndPoint;
            System.debug('endpointUrl---->' + endpointUrl);
            // Set the HTTP method to GET
            if(Get_Access_Token == true){
                Access_Token = QBMetadata.buildertek__Access_Token__c;
                SetQBEndPoint = QBMetadata.buildertek__Base_Url__c + QBEndPoint;
                request.setEndpoint(SetQBEndPoint);
                request.setHeader('Authorization','Bearer '+ Access_Token );
            }
            else{
                SetQBEndPoint = 'callout:'+ QBMetadata.buildertek__Name_Credential_API_Name__c + QBEndPoint;
                System.debug('name cred End Point : ' + SetQBEndPoint);
                request.setEndpoint(SetQBEndPoint);
                request.setHeader('Authorization','Bearer ');
            }
            request.setMethod('GET');
            request.setEndpoint(endpointUrl);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept','application/json');
    
            // Send the HTTP request and get the response
            response = http.send(request);
    
            // Process the response
            String responseBody = response.getBody();
            System.debug('Response Status Code: ' + response.getStatusCode() + ' || Response Status: ' + response.getStatus());
            System.debug('ResponseBody:------> ' + responseBody);
    
            return response;
        } catch (Exception e) {
            System.debug('Error During API QBAPICallOut >> ' + e.getMessage());
            return null;
        }
    }
    

    // Post method to get access Token...
    public static String GenerateAccessToken(buildertek__QuickBooks_Setting__mdt QBMetadata){
        try {
                String accessToken = '';
                String refreshToken = QBMetadata.buildertek__Refresh_Token__c;
                System.debug('refreshToken :: ' + refreshToken);
                String newRefreshToken = '';
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer');
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                req.setBody('grant_type=refresh_token&refresh_token=' +  EncodingUtil.urlEncode(refreshToken, 'UTF-8') + '&client_id=' + QBMetadata.buildertek__Client_Id__c + '&client_secret=' + QBMetadata.buildertek__Client_Secret__c );
                HTTPResponse res = new Http().send(req);
                if (res.getStatusCode() == 200) {
                    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    System.debug(responseMap);
                    accessToken = (String) responseMap.get('access_token');
                    newRefreshToken = (String) responseMap.get('refresh_token');
                    System.debug('Tokens : '+newRefreshToken );
                    System.debug('accessToken : '+accessToken );

                    system.debug(string.valueOf(accessToken+'_'+newRefreshToken).split('_')[0]);
                    return accessToken+'_'+newRefreshToken;
                }
                    else {
                    System.debug('Failed to refresh access token. Status Code: ' + res.getStatusCode());
                    System.debug('Response: ' + res.getBody());
                    return null;
                }

        } catch (Exception e) {
            System.debug('Error During APi GetAccessToken >> ' + e.getMessage() + '\n' + e);
            return null;
        }
    }
    
}