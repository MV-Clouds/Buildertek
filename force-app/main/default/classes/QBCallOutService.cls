public with sharing class QBCallOutService {

    public static String QBCallOutService(String APImethodName, String QBEndPoint, String JSONBody, String ReqHeader) {
        try {

            Http h = new Http();

            HttpRequest req = new HttpRequest();
            req.setMethod(APImethodName);
            req.setEndpoint(QBEndPoint);
            req.setBody(JSONBody);
            req.setHeader('Authorization',ReqHeader);
            // req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setHeader('Content-Type','application/json');

            HttpResponse res = new HttpResponse();
            res = h.send(req);
            String ResponseBody = res.getBody();
            System.debug('Response Status Code >> ' + res.getStatusCode() + ' || Response status >> '+ res.getStatus());
            System.debug('ResponseBody >> ' + ResponseBody);

            return ResponseBody;

        } catch (Exception e ) {
            System.debug('Error Drung APi Callout >> ' + e.getMessage());
            return null;
        }
    }

    public static HttpResponse QBAPICallOut(String QBEndPoint, String JSONBody, Boolean Get_Access_Token) {
        try {

            String Access_Token;
            String SetQBEndPoint;
                        // req.setEndpoint('callout:Quickbooks_REST_API/v3/company/4620816365353049760/customer?minorversion=69');
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Name_Credential_API_Name__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            if(Access_Token != '' || Access_Token != null){
                Http h = new Http();
                
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                if(Get_Access_Token == true){
                     Access_Token = GenerateAccessToken();
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
    public static HttpResponse QBAPICallOut_GET(String QBEndPoint, String JSONBody, Boolean Get_Access_Token) {
        try {
            String Access_Token;
            String endpointUrl;
    
            // Perform DML operations or other database transactions here
    
            // Query the metadata record
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__Name_Credential_API_Name__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
    
            // Create HTTP objects
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
    
            // Set the endpoint URL for the GET request
             endpointUrl = 'callout:'+ QBMetadata.buildertek__Name_Credential_API_Name__c + QBEndPoint;
            System.debug('endpointUrl---->' + endpointUrl);
            // Set the HTTP method to GET
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
    

    public static String GenerateAccessToken(){
        try {
                String accessToken = '';
                buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName, MasterLabel, buildertek__Access_Token__c, buildertek__Qb_URL__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt];
                // QBData__c QBData = [SELECT ID, Name, Refresh_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, 	Last_Updated__c FROM QBData__c];
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
                    // buildertek__QuickBooks_Setting__mdt QBS = new buildertek__QuickBooks_Setting__mdt(buildertek__Refresh_Token__c = newRefreshToken, buildertek__Access_Token__c = accessToken, buildertek__Last_Modified_Refresh_Token__c = date.today());

                    Map<String, Object> mapToUpdate = new Map<String, Object>();
                    mapToUpdate.put('buildertek__Refresh_Token__c',newRefreshToken);
                    mapToUpdate.put('buildertek__Access_Token__c',accessToken);
                    mapToUpdate.put('buildertek__Last_Modified_Refresh_Token__c',date.today());
                    // QuickbooksConfigController.handleInsertAndUpdate('buildertek__QuickBooks_Setting.QB_bc_buildertek_com','QB_bc@buildertek.com', mapToUpdate);
                    return accessToken;
                }
                    else {
                    System.debug('Failed to refresh access token. Status Code: ' + res.getStatusCode());
                    System.debug('Response: ' + res.getBody());
                    return accessToken;
                }

        } catch (Exception e) {
            System.debug('Error During APi GetAccessToken >> ' + e.getMessage() + '\n' + e);
            return null;
        }
    }
    
}