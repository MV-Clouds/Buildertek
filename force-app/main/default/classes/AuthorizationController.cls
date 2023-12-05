public class AuthorizationController {
    public buildertek__QuickBooks_Config__c quickObj {get;set;}
    public Map<String,Object> metadataObj {get;set;}
    public Boolean authCheck {get;set;}

    public AuthorizationController(){
		quickObj = new buildertek__QuickBooks_Config__c();
        authCheck = false;
    }

    /*To get country specific general settings from custom metadata types
    * Note: As of 31-Jan-2022, using the soql query instead of the getInstance method of custom metadatypes
    * the reason is the getInstance method only fetches the first 255 characters of text area(long) fields.
    */
    public static map<string, object> generateAccessToken(string user){
            map<string, object>  cachedGeneralSettings = new  map<string, object>();
            Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.buildertek__QuickBooks_Setting__mdt.fields.getMap();
            string query = 'SELECT ' + getCSVFields(schemaFieldMap.keySet()) + ' FROM buildertek__QuickBooks_Setting__mdt WHERE MasterLabel = ' +  '\'' + String.escapeSingleQuotes(user) + '\'';
            buildertek__QuickBooks_Setting__mdt generalSettings = Database.query(query);

            for (String fieldName: schemaFieldMap.keySet()) {
                system.debug(fieldName + '=>' + generalSettings.get(fieldName));
                cachedGeneralSettings.put(fieldName, generalSettings.get(fieldName));
            }
        return cachedGeneralSettings;
    }

    /*To get comma separated values from a list or set of strings*/
    private static string getCSVFields(set<string> fieldsList){
        string strFields = '';
        if(fieldsList != null && fieldsList.size() >0){
            for(string strField : fieldsList){
                strFields += strField + ',';
            }
            strFields = strFields.substringBeforeLast(',');
        }
        return strFields;
    }

    public void generateAccessToken(){
        String clientId = '';
        String clientSecret = '';
        List<buildertek__QuickBooks_Setting__mdt> generalSettingsList = new List<buildertek__QuickBooks_Setting__mdt>([SELECT Id, DeveloperName, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1]);

        if (generalSettingsList.size()>0) {
            clientId = generalSettingsList[0].buildertek__Client_Id__c;
            clientSecret = generalSettingsList[0].buildertek__Client_Secret__c;
        }

        if( !ApexPages.currentPage().getParameters().containskey('code') )
            return;
        String encodedString = EncodingUtil.base64Encode(Blob.valueOf(clientId+':'+clientSecret));
        String endPoint = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer';
        String redirectUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Authorization';
        String oAuthCode = ApexPages.currentPage().getParameters().get('code');
        String companyId = ApexPages.currentPage().getParameters().get('realmId');
        String stateID = ApexPages.currentPage().getParameters().get('state');
        String requestBody = 'grant_type=authorization_code&code='+oAuthCode+'&redirect_uri='+redirectUrl;
        String errorMessage ='';

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod( 'POST' );
        httpReq.setEndPoint( endPoint );
        httpReq.setHeader( 'Authorization' , 'Basic '+encodedString );
        httpReq.setHeader( 'Content-Type' , 'application/x-www-form-urlencoded' );
        httpReq.setBody( requestBody );

        try{
            httpRes = http.send(httpReq);

            system.debug('body-->'+httpRes.getBody());
            system.debug('status code-->'+httpRes.getStatusCode());
            if( httpRes.getStatusCode() == 200 ){


                Map<String, Object> response_Map = (Map<String, Object>)JSON.deserializeUntyped(httpRes.getBody());
                for(String s: response_Map.keyset()){
                    system.debug(s+'-------'+String.valueOf(response_Map.get(s)));
                }
                metadataObj = new Map<String,Object>();
                metadataObj = response_Map;
                Map<String,Object> mapToUpdate = new Map<String,Object>();
                mapToUpdate.put('buildertek__Access_Token__c',response_Map.get('access_token'));
                mapToUpdate.put('buildertek__Refresh_Token__c',response_Map.get('refresh_token'));
                mapToUpdate.put('buildertek__Company_Id__c',companyId);
                QuickbooksConfigController.handleInsertAndUpdate('buildertek__QuickBooks_Setting.QB_bc_buildertek_com','QB_bc@buildertek.com',mapToUpdate);


                ApexPages.addmessage( new ApexPages.message(ApexPages.severity.Confirm,+' '+'Successfully Authenticated with Quickbooks System!!!') );
                // update serviceObject;
                authCheck = true;

            } else {
                authCheck = false;
                ApexPages.addmessage( new ApexPages.message(ApexPages.severity.ERROR,+' '+'Unexpected Error while communicating with Quickbooks API'+
                                                            'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode()) );
            }

        } catch(System.Exception e) {

            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administrator must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }else{
                errorMessage = 'Unexpected Error while communicating with Quickbooks API. '
                    +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,errorMessage));
            }
        }
    }
}