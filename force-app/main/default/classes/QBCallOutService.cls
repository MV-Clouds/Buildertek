public with sharing class QBCallOutService {

    public static String QBCallOutService(String APImethodName, String QBEndPoint, String JSONBody, String ReqHeader) {
        try {

            Http h = new Http();

            HttpRequest req = new HttpRequest();
            req.setMethod(APImethodName);
            req.setEndpoint(QBEndPoint);
            req.setBody(JSONBody);
            req.setHeader('Authorization',ReqHeader);
            req.setHeader('Content-Type','application/x-www-form-urlencoded');

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

    public static String QBCallOutServiceWithoutNameCred(String APImethodName, String QBEndPoint, String JSONBody) {
        try {

            Http h = new Http();

            HttpRequest req = new HttpRequest();
            req.setMethod(APImethodName);
            req.setEndpoint(QBEndPoint);
            req.setHeader('Authorization','Bearer '+ GenerateAccessToken());
            req.setHeader('Content-Type', 'application/json');
            // req.setHeader('Authorization',ReqHeader);
            req.setBody(JSONBody);
            // req.setHeader('Content-Type','application/x-www-form-urlencoded');


            HttpResponse res = new HttpResponse();
            res = h.send(req);
            String ResponseBody = res.getBody();
            System.debug('Response Status Code >> ' + res.getStatusCode() + ' || Response status >> '+ res.getStatus());
            System.debug('ResponseBody >> ' + ResponseBody);

            return ResponseBody;
            
        } catch (Exception e ) {
            System.debug('Error Drung APi QBCallOutServiceWithoutNameCred >> ' + e.getMessage());
            return null;
        } 
    }

    public static String GenerateAccessToken(){
        try {
                String accessToken = '';
                buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt];
                // QBData__c QBData = [SELECT ID, Name, Refresh_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, 	Last_Updated__c FROM QBData__c];
                String refreshToken = QBMetadata.buildertek__Refresh_Token__c;
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
                    QBCallOutService.createUpdateMetadata(QBMetadata.Name, QBMetadata.Label, mapToUpdate);           
                } 
                    else {
                    System.debug('Failed to refresh access token. Status Code: ' + res.getStatusCode());
                    System.debug('Response: ' + res.getBody());
                }
                return accessToken;
            
        } catch (Exception e) {
            System.debug('Error Drung APi GetAccessToken >> ' + e.getMessage());
            return null;
        }
    }

    public static void createUpdateMetadata(String fullName, String label, Map<String, Object> fieldWithValuesMap){
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = fullName;
        customMetadata.label = label;
        
        for(String key : fieldWithValuesMap.keySet()){
            Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
            customField.field = key;
            customField.value = fieldWithValuesMap.get(key); 
            customMetadata.values.add(customField);
        }
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        QBCallOutService callback = new QBCallOutService();
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
    }
}