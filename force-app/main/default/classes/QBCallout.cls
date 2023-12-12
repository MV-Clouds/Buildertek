public with sharing class QBCallout {
    // public class QBException extends Exception{}
    // private String accessToken{get; set;}
    // private String refreshToken{get; set;}

    // public QBCallout() {
    //     List<String> tokens = refresh();
    //     System.debug('QBcallout com=nstructor call'+ tokens);
    // }

    // public List<String> refresh(){
    //     // Get custom settings 
    //     QBData__c QBData = [
    //         SELECT Id, Name, refresh_token__c, client_id__c, client_secret__c, auth_url__c FROM QBData__c
    //     ];

    //     // Initialize Request Data 
    //     String url = QBData.auth_url__c;
    //     System.debug('url ==>'+url);
    //     String clientId = QBData.client_id__c;
    //     System.debug('clientId ==>'+clientId);
    //     String clientSecret = QBData.client_secret__c;
    //     System.debug('clientSecret ==>'+clientSecret);
    //     String header = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(clientId + ':' + clientSecret));
    //     System.debug('Header ==>'+header);
    //     String refresh_token = QBData.refresh_token__c;
    //     System.debug('refresh_token ==>'+refresh_token);
    //     String body = 'grant_type=refresh_token&refresh_token='+ refresh_token; 
    //     System.debug('body ==>'+body);

    //     // http Request 
    //     Http h = new Http();
    //     HttpRequest req = new HttpRequest();
    //     HttpResponse res = new HttpResponse();
    //     req.setEndpoint(url);
    //     req.setMethod('POST');
    //     req.setBody(body);
    //     req.setHeader('Authorization',header);
    //     req.setHeader('Content-Type','application/x-www-form-urlencoded');
    //     // req.setHeader('Content-Type', 'application/json');
    //     // req.setHeader('Accept','application/json');
        
    //     res = h.send(req);
    //     System.debug(res.getBody());
    //     QBRefreshJSON json = QBRefreshJSON.parse(res.getBody());
    //     // System.debug('JSON ==>',json);

    //     if (json.access_token == null) {
    //         throw new QBException('Refresh Token has expired.');
    //     } 

    //     List<String> tokens = new List<String>{json.access_token,json.refresh_token};
    //     accessToken = tokens[0];
    //     refreshToken = tokens[1];
    //     return tokens;
    // }

    // public void updateRefreshToken(){
    //     QBData__c QBData = [SELECT ID, Name, Refresh_Token__c, 	Last_Updated__c FROM QBData__c];
    //     QBData.Refresh_Token__c = refreshToken;
    //     QBData.Last_Updated__c = DateTime.now();
    //     update QBData;
    // }
    // @future(callout=true)
    // public static void CreateAcc(String body , String accId , String QbId ){
    //     QBCallout.createCustomerCall(body,accId,QbId);
    // }

    // public static void createCustomerCall(String body , String accId , String QbId){

    //     QBCallout qbCallout = new QBCallout();
    //     qbCallout.refresh(); // Refresh the tokens if needed
    
    //     //Initialze url endpoint
    //     QBO_Metadata__mdt QBData = [SELECT ID,
    //                         base_url__c,
    //                         Company_Id__c,
    //                         minorversion__c
    //                 FROM QBO_Metadata__mdt];
    //     String url = QBData.base_url__c + '/v3/company/' + QBData.Company_Id__c + '/customer?minorversion=' + QBData.minorversion__c;

    //     //Start http request
    //     Http h = new Http();
    //     HttpRequest req = new HttpRequest();
    //     HttpResponse res = new HttpResponse();
    //     // req.setEndpoint(url);
    //     req.setEndpoint('callout:Quickbooks_REST_API/v3/company/4620816365353049760/customer?minorversion=69');
    //     req.setMethod('POST');
    //     req.setBody(body);
    //     req.setHeader('Authorization', 'Bearer ');
    //     req.setheader('Accept', 'application/json');
    //     req.setHeader('Content-Type', 'application/json');
    //     res = h.send(req);
    //     System.debug('response 2=>' + res.getBody());
    //     System.debug('response =>' + res);
    //     handleResponseError(res.getBody());
    //      QBCustomerResponseJSON json = QBCustomerResponseJSON.parse(res.getBody());
    //      String customerId = json.Customer.Id;
    //      String QBTokn = json.Customer.SyncToken;
    //      System.debug(customerId);
    //      System.debug(QBTokn);
    //      QBCallout.updateAccounts(accId, customerId, QBTokn);
    //     //  Account a = new Account();
    //     //  a.Id = accId;
    //     //  a.buildertek__QB_Id__c = customerId;
    //     //  a.QBO_SyncToken__c = QBTokn;
    //     //  update a;

    // }
    // public void updateAccounts(String accId, String customerId, String QBTokn) {
    //     QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
    //     String url = 'https://app.sandbox.qbo.intuit.com/app/customerdetail?nameId=' + customerId;
    //     System.debug('URL QB--------------->'+ url);
    //     Account a = new Account();
    //      a.Id = accId;
    //      a.buildertek__QB_Id__c = customerId;
    //      a.QBO_SyncToken__c = QBTokn;
    //      update a;
    // }

    // @future(callout=true)
    // public static void UpdateAcc(String body , String accId , String QbId ){
    //     QBCallout.updateCustomerCall(body,accId,QbId);
    // }
    // public static void updateCustomerCall(String body, String accId, String QbId) {
    //     System.debug(body);
    //     QBCallout qbCallout = new QBCallout();
    //     qbCallout.refresh(); // Refresh the tokens if needed

    //     // Initialize URL endpoint
    //     QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
    //     String url = QBData.base_url__c + '/v3/company/' + QBData.Company_Id__c + '/customer?minorversion=' + QBData.minorversion__c;

    //     // Start HTTP request
    //     Http h = new Http();
    //     HttpRequest req = new HttpRequest();
    //     HttpResponse res = new HttpResponse();
    //     req.setEndpoint(url);
    //     req.setMethod('POST'); // Use POST method
    //     req.setBody(body);
    //     req.setHeader('Authorization', 'Bearer ' + qbCallout.accessToken);
    //     req.setHeader('Accept', 'application/json');
    //     req.setHeader('Content-Type', 'application/json'); // Use application/json content type
    //     res = h.send(req);
    //     System.debug('response 2=>' + res.getBody());
    //     System.debug('response =>' + res);
    //     handleResponseError(res.getBody());
    //     QBCustomerResponseJSON json = QBCustomerResponseJSON.parse(res.getBody());
    //     String customerId = json.Customer.Id;
    //     String QBTokn = json.Customer.SyncToken;
    //     System.debug(customerId);
    //     System.debug(QBTokn);
    //     QBCallout.updateAccounts(accId, customerId, QBTokn);
    // }

    // @future(callout=true)
    // public static void deleteCustomerCall(String body, String accId, String QbId) {
    //     System.debug(body);
    //     QBCallout qbCallout = new QBCallout();
    //     qbCallout.refresh(); // Refresh the tokens if needed

    //     // Initialize URL endpoint
    //     QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
    //     String url = QBData.base_url__c + '/v3/company/' + QBData.Company_Id__c + '/customer?minorversion=' + QBData.minorversion__c;

    //     // Start HTTP request
    //     Http h = new Http();
    //     HttpRequest req = new HttpRequest();
    //     HttpResponse res = new HttpResponse();
    //     req.setEndpoint(url);
    //     req.setMethod('POST'); // Use POST method
    //     req.setBody(body);
    //     req.setHeader('Authorization', 'Bearer ' + qbCallout.accessToken);
    //     req.setHeader('Accept', 'application/json');
    //     req.setHeader('Content-Type', 'application/json'); // Use application/json content type
    //     res = h.send(req);
    //     System.debug('response 2=>' + res.getBody());
    //     System.debug('response =>' + res);
    //     handleResponseError(res.getBody());
    //     QBCustomerResponseJSON json = QBCustomerResponseJSON.parse(res.getBody());
    //     String customerId = json.Customer.Id;
    //      String QBTokn = json.Customer.SyncToken;
    //      System.debug(customerId);
    //      System.debug(QBTokn);
    // }

    // private  static void handleResponseError(String body){
    //     QBOErrorJSON error = QBOErrorJSON.parse(body);
    //     if(error != null){
    //         System.debug('Error =>' +error);
    //         if(error.Fault != null && error.Fault.Error != null && error.Fault.Error.size() > 0)
    //         Throw new QBException(String.valueOf(error.Fault.Error[0]));
    //     }
    // }

    // @future(callout=true)
    // public static void CreateCustomerAPICall(String JSONBody){
    //     try{
    //         // Initialize URL endpoint
    //         QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
    //         String EndPoint = QBData.base_url__c + '/v3/company/' + QBData.Company_Id__c + '/customer?minorversion=' + QBData.minorversion__c;            
    //         HttpResponse Response = QBCallOutService.QBCallOutServiceWithoutNameCred(EndPoint, JSONBody);
    //         System.debug('ResponseBody without Name Credential : ' + Response);
    //     }
    //     catch(Exception e){
    //         System.debug('error in CreateCustomerAPICall>> '+ e.getMessage());
    //     }
    // }
    @future(callout=true)
    public static void CreateCustCall(String SIid){
        try{
            
            QBO_Metadata__mdt QBData = [SELECT ID, base_url__c, Company_Id__c, minorversion__c FROM QBO_Metadata__mdt];
            String EndPoint = '/v3/company/' + QBData.Company_Id__c + '/taxservice/taxcode?minorversion=' + QBData.minorversion__c; 
            List<buildertek__Billings__c> allInvoice = [SELECT Id, Name, buildertek__Customer_Account__c, buildertek__QB_Id__c,buildertek__Tax_Rate__c,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c];
            buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c, buildertek__QB_Id__c,buildertek__Tax_Rate__c,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =:SIId LIMIT 1];
            Boolean IsTaxRateExistInQB = false; // to break loop if once invoice flow going forward...
            String taxRateId;
            if(SI.buildertek__Tax_Rate__c != null && SI.buildertek__QBO_Tax_Rate_ID__c == null){
                for(buildertek__Billings__c inv : allInvoice){
                    if(IsTaxRateExistInQB == false){
                        if(SI.buildertek__Tax_Rate__c == inv.buildertek__Tax_Rate__c && SI.buildertek__Tax_Rate__c == inv.buildertek__QBO_Tax_Rate__c){
                            System.debug('No need to create tax in QB');
                            // assign inv.buildertek__QBO_Tax_Rate_ID__c to SI....
                            taxRateId =  inv.buildertek__QBO_Tax_Rate_ID__c;
                            IsTaxRateExistInQB = true;
                        }
                    }
                }
                if(IsTaxRateExistInQB == true){
                    System.debug('// Create Invoice with exsiting tax rate ID...');
                }
                else {
                    System.debug('// Create New Tax Rate In QB...');
                    String TaxRate_RequestBody = QBMap.mapTaxRateData(SI);           
                    HttpResponse TaxRate_ResponseBody = QBCallOutService.QBAPICallOut(EndPoint, TaxRate_RequestBody,false);
                    if(TaxRate_ResponseBody.getStatusCode() == 200){
                        System.debug('TaxRate_ResponseBody.getBody() :: '+ TaxRate_ResponseBody.getBody());
                        QBTaxCodeResponseJSON TaxRate_ResponseBody_Deser =  QBTaxCodeResponseJSON.parse(TaxRate_ResponseBody.getBody());
                        List<QBTaxCodeResponseJSON.TaxRateDetails> TaxRateDetai = new  List<QBTaxCodeResponseJSON.TaxRateDetails>();
                        TaxRateDetai = TaxRate_ResponseBody_Deser.TaxRateDetails;
                        taxRateId = TaxRateDetai[0].TaxRateId;
                        Double taxRateValue = TaxRateDetai[0].RateValue;
                        // UpdateInv(taxRateId, taxRateValue,SI.Id);
                    }
                    else{
                        QBException.QB_response( TaxRate_ResponseBody.getStatusCode(),  TaxRate_ResponseBody.getBody(), 'QBIntegrationQueue', 'Create_Customer_invoice_item_payment_in_QB');
                    }
                }

            }
            else{
                //Create Invoice without Tax Rate ID and Value
                taxRateId = null;
            }
        }
        catch(Exception e){
            System.debug('error in CreateCustomerAPICall>> '+ e.getMessage());
        }

    }
    public static void UpdateInv(String taxRateId, Double taxRateValue , String SIId){
        try {

            buildertek__Billings__c SI = new buildertek__Billings__c();
            SI.Id = SIId;
            SI.buildertek__QBO_Tax_Rate_ID__c = taxRateId;
            SI.buildertek__QBO_Tax_Rate__c = taxRateValue;
            update SI;
        } catch (Exception e) {
            System.debug('Error in UpdateSIline : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
}