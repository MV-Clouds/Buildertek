public with sharing class UploadHelper {
    public string sessionId {get; set;}
    public string NewBody{get;set;}
    public UploadHelper(){      
        
        list<buildertek__Dynamic_Upload_File__mdt> displayFileUpload= 
            [select Id,DeveloperName,buildertek__Access_Token__c,buildertek__Client_Id__c,buildertek__Client_Secret__c,buildertek__Password__c,buildertek__User_Name__c from buildertek__Dynamic_Upload_File__mdt 
             Where DeveloperName='File_Upload_Record' limit 1];
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');

         req.setEndpoint(displayFileUpload[0].buildertek__Access_Token__c);
        req.setBody('grant_type=password' +
        '&client_id= '+displayFileUpload[0].buildertek__Client_Id__c+
        '&client_secret= '+displayFileUpload[0].buildertek__Client_Secret__c+   
        '&username=' + EncodingUtil.urlEncode(displayFileUpload[0].buildertek__User_Name__c, 'UTF-8') +
        '&password=' + EncodingUtil.urlEncode(displayFileUpload[0].buildertek__Password__c, 'UTF-8'));       
         Http h = new Http();
        Httpresponse res = h.send(req);
        string body = res.getBody();
        
        system.debug('***** Body -- '+ body);
        NewBody = body;
        
       uploadsession wObj = (uploadsession)Json.deserialize(body,uploadsession.class);
        sessionId = wObj.access_token;
        system.debug('***** accessToken -- '+ userinfo.getSessionId()); 
       system.debug('***** accessToken -- '+ sessionId); 
    }
    
    public class uploadsession{
        public String access_token; //SESSION_ID_REMOVED
        public String instance_url; //https://diligentforcelabs42-dev-ed.my.salesforce.com
        public String id;   //https://login.salesforce.com/id/00D5g000005Dc3eEAC/0055g000009cpFBAAY
        public String token_type;   //Bearer
        public String issued_at;    //1658148577683
        public String signature;    //Z97c4zWR1+LkTIRbv4V+0Ehh9Vd+1DSiVtrvLYp1oCs=
    }
    
    /*HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://btservice360-dev-ed.my.salesforce.com/services/oauth2/token');
        req.setBody('grant_type=password' +
        '&client_id= 3MVG9szVa2RxsqBbEqYDR3uOV8cLx8d1qQooZedvYBTs0KkpxPma5Jr5hpM6iPxpl7.5kUT2iOv6d9RTdel96'+
        '&client_secret= A97C82A54A0E1C09E204429C4A8CAE9F4E652B16AD5757BADAD4518A3159BDD5' +   
        '&username=' + EncodingUtil.urlEncode('bc@buildertek.com', 'UTF-8') +
        '&password=' + EncodingUtil.urlEncode('Today123#', 'UTF-8'));
        Http h = new Http();
        Httpresponse res = h.send(req);
        string body = res.getBody();
        
        system.debug('***** Body -- '+ body);
        NewBody = body; */
}