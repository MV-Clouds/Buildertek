public with sharing class QBCallout {
    public class QBException extends Exception{}
    private String accessToken{get; set;}
    private String refreshToken{get; set;}

    public QBCallout() {
        List<String> tokens = refresh();
        System.debug('QBcallout com=nstructor call'+ tokens);
    }

    public List<String> refresh(){
        // Get custom settings 
        QBData__c QBData = [
            SELECT Id, Name, refresh_token__c, client_id__c, client_secret__c, auth_url__c FROM QBData__c
        ];

        // Initialize Request Data 
        String url = QBData.auth_url__c;
        System.debug('url ==>'+url);
        String clientId = QBData.client_id__c;
        System.debug('clientId ==>'+clientId);
        String clientSecret = QBData.client_secret__c;
        System.debug('clientSecret ==>'+clientSecret);
        String header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(clientId + ':' + clientSecret));
        System.debug('Header ==>'+header);
        String refresh_token = QBData.refresh_token__c;
        System.debug('refresh_token ==>'+refresh_token);
        String body = 'grant_type=refresh_token&refresh_token='+ refresh_token; 
        System.debug('body ==>'+body);

        // http Request 
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('Authorization',header);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        // req.setHeader('Content-Type', 'application/json');
        // req.setHeader('Accept','application/json');
        
        res = h.send(req);
        System.debug(res.getBody());
        QBRefreshJSON json = QBRefreshJSON.parse(res.getBody());
        // System.debug('JSON ==>',json);

        if (json.access_token == null) {
            throw new QBException('Refresh Token has expired.');
        } 

        List<String> tokens = new List<String>{json.access_token,json.refresh_token};
        accessToken = tokens[0];
        refreshToken = tokens[1];
        return tokens;
    }

    public void updateRefreshToken(){
        QBData__c QBData = [SELECT ID, Name, Refresh_Token__c, 	Last_Updated__c FROM QBData__c];
        QBData.Refresh_Token__c = refreshToken;
        QBData.Last_Updated__c = DateTime.now();
        update QBData;
    }
    @future(callout=true)
    public static void CreateAcc(String body , String accId , String QbId ){
        QBCallout.createCustomerCall(body,accId,QbId);
    }

    public static void createCustomerCall(String body , String accId , String QbId){

        QBCallout qbCallout = new QBCallout();
        qbCallout.refresh(); // Refresh the tokens if needed
    
        //Initialze url endpoint
        QBO_Metadata__mdt QBData = [SELECT ID,
                            base_url__c,
                            Company_Id__c,
                            minorversion__c
                    FROM QBO_Metadata__mdt];
        String url = QBData.base_url__c + '/v3/company/' + QBData.Company_Id__c + '/customer?minorversion=' + QBData.minorversion__c;

        //Start http request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        // req.setEndpoint(url);
        req.setEndpoint('callout:Quickbooks_REST_API/v3/company/4620816365353049760/customer?minorversion=69');
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('Authorization', 'Bearer ');
        req.setheader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        res = h.send(req);
        System.debug('response 2=>' + res.getBody());
        System.debug('response =>' + res);
        handleResponseError(res.getBody());
         QBCustomerResponseJSON json = QBCustomerResponseJSON.parse(res.getBody());
         String customerId = json.Customer.Id;
         String QBTokn = json.Customer.SyncToken;
         System.debug(customerId);
         System.debug(QBTokn);
         QBCallout.updateAccounts(accId, customerId, QBTokn);
        //  Account a = new Account();
        //  a.Id = accId;
        //  a.QBO_ID__c = customerId;
        //  a.QBO_SyncToken__c = QBTokn;
        //  update a;

    }
    public void updateAccounts(String accId, String customerId, String QBTokn) {
        QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
        String url = 'https://app.sandbox.qbo.intuit.com/app/customerdetail?nameId=' + customerId;
        System.debug('URL QB--------------->'+ url);
        Account a = new Account();
         a.Id = accId;
         a.QBO_ID__c = customerId;
         a.QBO_SyncToken__c = QBTokn;
         update a;
    }

    @future(callout=true)
    public static void UpdateAcc(String body , String accId , String QbId ){
        QBCallout.updateCustomerCall(body,accId,QbId);
    }
    public static void updateCustomerCall(String body, String accId, String QbId) {
        System.debug(body);
        QBCallout qbCallout = new QBCallout();
        qbCallout.refresh(); // Refresh the tokens if needed

        // Initialize URL endpoint
        QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
        String url = QBData.base_url__c + '/v3/company/' + QBData.Company_Id__c + '/customer?minorversion=' + QBData.minorversion__c;

        // Start HTTP request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('POST'); // Use POST method
        req.setBody(body);
        req.setHeader('Authorization', 'Bearer ' + qbCallout.accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json'); // Use application/json content type
        res = h.send(req);
        System.debug('response 2=>' + res.getBody());
        System.debug('response =>' + res);
        handleResponseError(res.getBody());
        QBCustomerResponseJSON json = QBCustomerResponseJSON.parse(res.getBody());
        String customerId = json.Customer.Id;
        String QBTokn = json.Customer.SyncToken;
        System.debug(customerId);
        System.debug(QBTokn);
        QBCallout.updateAccounts(accId, customerId, QBTokn);
    }

    @future(callout=true)
    public static void deleteCustomerCall(String body, String accId, String QbId) {
        System.debug(body);
        QBCallout qbCallout = new QBCallout();
        qbCallout.refresh(); // Refresh the tokens if needed

        // Initialize URL endpoint
        QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
        String url = QBData.base_url__c + '/v3/company/' + QBData.Company_Id__c + '/customer?minorversion=' + QBData.minorversion__c;

        // Start HTTP request
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint(url);
        req.setMethod('POST'); // Use POST method
        req.setBody(body);
        req.setHeader('Authorization', 'Bearer ' + qbCallout.accessToken);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json'); // Use application/json content type
        res = h.send(req);
        System.debug('response 2=>' + res.getBody());
        System.debug('response =>' + res);
        handleResponseError(res.getBody());
        QBCustomerResponseJSON json = QBCustomerResponseJSON.parse(res.getBody());
        String customerId = json.Customer.Id;
         String QBTokn = json.Customer.SyncToken;
         System.debug(customerId);
         System.debug(QBTokn);
    }

    private  static void handleResponseError(String body){
        QBOErrorJSON error = QBOErrorJSON.parse(body);
        if(error != null){
            System.debug('Error =>' +error);
            if(error.Fault != null && error.Fault.Error != null && error.Fault.Error.size() > 0)
            Throw new QBException(String.valueOf(error.Fault.Error[0]));
        }
    }

    @future(callout=true)
    public static void CreateCustomerAPICall(String JSONBody){
        try{
            // Initialize URL endpoint
            QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
            String EndPoint = QBData.base_url__c + '/v3/company/' + QBData.Company_Id__c + '/customer?minorversion=' + QBData.minorversion__c;            
            String ResponseBody = QBCallOutService.QBCallOutServiceWithoutNameCred('POST',EndPoint, JSONBody);
            System.debug('ResponseBody without Name Credential : ' + ResponseBody);
        }
        catch(Exception e){
            System.debug('error in CreateCustomerAPICall>> '+ e.getMessage());
        }
    }
}