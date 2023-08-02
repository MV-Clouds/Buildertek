public class MSAFormBoxController {
  public static void saveFileInBox(blob msafiledata,string accountId,string iscontractor,string resendMSA){
    system.debug('@@@');
      system.debug(resendMSA);
        string clientid = Box_Settings__c.getValues('BOX API').Client_Id__c;
        string client_secret = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Client_Secret__c;
        string ViewAPI_Key = buildertek__Box_Settings__c.getValues('BOX API').buildertek__API_Key__c;
        string AccessToken = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Access_Token__c;
        string RefreshToken = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Refresh_Token__c;
        string EnterpriceId = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Enterprise_ID__c;
        string Response='';
      String sObjName = Id.valueOf(accountId).getSObjectType().getDescribe().getName();
      if(sObjName == 'buildertek__Pre_Qual__c'){
          buildertek__Pre_Qual__c acc = [select id,name,buildertek__Box_Folder_Id__c,buildertek__Is_ResendMSA__c,buildertek__Is_Contract_Signed__c from buildertek__Pre_Qual__c where id=:accountId];
        HttpRequest req1 = new HttpRequest();
        //endPointURL='https://app.box.com/api/oauth2/token?code='+Authcode+'&client_id='+clientid+'&client_secret='+client_secret+'&grant_type=authorization_code';
        string endPointURL='https://app.box.com/api/oauth2/token?';
        System.debug('******endPointURL:'+endPointURL);
        req1.setEndpoint(endPointURL);
        req1.setMethod('POST');
        req1.setHeader('Content-Type','application/x-www-form-urlencoded');
        String bb='grant_type=authorization_code';

        req1.setbody('grant_type=client_credentials'+
                     '&box_subject_type=enterprise'+
                     '&box_subject_id='+EnterpriceId+
                     '&client_id='+clientid+
                     '&client_secret='+client_secret);
        req1.setHeader('Accept','application/json');
        Http http = new Http();
        HTTPResponse res1 = http.send(req1);
        Response=res1.getBody();
        Integer statusCode=res1.getStatusCode();
        System.debug(Response);
        // Parse JSON response to get refresh_token values.
        JSONParser parser = JSON.createParser(Response);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token') {
                    AccessToken= parser.getText();
                }if(fieldName == 'refresh_token') {
                    RefreshToken= parser.getText();
                }
            }
            }
       system.debug('AccessToken'+AccessToken);

          // if(base64String != ''){
          system.debug(iscontractor);
          blob base64EncodeFile;
          if(iscontractor == 'YES'){
              system.debug(acc.buildertek__Is_ResendMSA__c);
              if(acc.buildertek__Is_ResendMSA__c == true && acc.buildertek__Is_Contract_Signed__c == true){
                
                 system.debug('Contractor signature with Resend MSA');
                //base64EncodeFile=base64EncodeFileContent(msafiledata,'Fully Executed Resigned MSA'+system.now()+'.pdf');  
                base64EncodeFile=base64EncodeFileContent(msafiledata,'Fully Executed MSA.pdf'+system.now()+'.pdf');
              }else{
                  system.debug('Contractor signature ');
                  base64EncodeFile=base64EncodeFileContent(msafiledata,'Fully Executed MSA.pdf'+system.now()+'.pdf');
              }
           
          }else{
              if(resendMSA == 'YES'){
                  Datetime currentDate = system.now(); 
                //base64EncodeFile=base64EncodeFileContent(msafiledata,'Vendor Resigned MSA'+currentDate+'.pdf');
                  base64EncodeFile=base64EncodeFileContent(msafiledata,'Vendor Signed MSA.pdf'+currentDate+'.pdf');
              }else{
                  system.debug('NO NO');
                  Datetime currentDate = system.now(); 
                  base64EncodeFile=base64EncodeFileContent(msafiledata,'Vendor Signed MSA.pdf'+currentDate+'.pdf');
              }
          }
          
              
              /*//String csvBody = EncodingUtil.base64Encode(msafiledata);
              //blob fileContent=blob.valueof('test String');
              //blob base64EncodeFile=BoxUtility.base64EncodeFileContent(fileContent,'First file Upload');
              //string orginal=EncodingUtil.base64Decode(EncodingUtil.base64Encode(msafiledata)).toString();
             // blob orginal=EncodingUtil.base64Decode(msafiledata);
              //blob base64EncodeFile=base64EncodeFileContent(orginal,'MSA.form');*/
              system.debug(acc.buildertek__Box_Folder_Id__c);
              String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+acc.buildertek__Box_Folder_Id__c;
              String boundary = '----------------------------741e90d31eff';
              HttpRequest req = new HttpRequest();
              system.debug(EncodingUtil.Base64Encode(base64EncodeFile));
              req.setBodyAsblob(base64EncodeFile);
              req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
              req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
              req.setHeader('Authorization', 'Bearer ' + AccessToken);
              req.setMethod('POST');
              req.setEndpoint(uploadEndPointURL);
              req.setMethod('POST');
              req.setTimeout(120000);
              //Send request to Box
              HTTPResponse res=sendHttpRequest(req);
              Response=res.getBody();
              System.debug('**Files upload Response:'+Response);
              Integer uploadStatusCode=res.getStatusCode();
              if(uploadStatusCode==201){
                  system.debug('SUCCESS');
              }else{
                 //return 'error';
              }
        
      }else{
          Account acc = [select id,name,buildertek__Box_Folder_Id__c,buildertek__Is_ResendMSA__c,buildertek__Is_Contract_Signed__c from Account where id=:accountId];
        HttpRequest req1 = new HttpRequest();
        //endPointURL='https://app.box.com/api/oauth2/token?code='+Authcode+'&client_id='+clientid+'&client_secret='+client_secret+'&grant_type=authorization_code';
        string endPointURL='https://app.box.com/api/oauth2/token?';
        System.debug('******endPointURL:'+endPointURL);
        req1.setEndpoint(endPointURL);
        req1.setMethod('POST');
        req1.setHeader('Content-Type','application/x-www-form-urlencoded');
        String bb='grant_type=authorization_code';

        req1.setbody('grant_type=client_credentials'+
                     '&box_subject_type=enterprise'+
                     '&box_subject_id='+EnterpriceId+
                     '&client_id='+clientid+
                     '&client_secret='+client_secret);
        req1.setHeader('Accept','application/json');
        Http http = new Http();
        HTTPResponse res1 = http.send(req1);
        Response=res1.getBody();
        Integer statusCode=res1.getStatusCode();
        System.debug(Response);
        // Parse JSON response to get refresh_token values.
        JSONParser parser = JSON.createParser(Response);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                String fieldName = parser.getText();
                parser.nextToken();
                if(fieldName == 'access_token') {
                    AccessToken= parser.getText();
                }if(fieldName == 'refresh_token') {
                    RefreshToken= parser.getText();
                }
            }
            }
       system.debug('AccessToken'+AccessToken);

          // if(base64String != ''){
          system.debug(iscontractor);
          blob base64EncodeFile;
          if(iscontractor == 'YES'){
              system.debug(acc.buildertek__Is_ResendMSA__c);
              if(acc.buildertek__Is_ResendMSA__c == true && acc.buildertek__Is_Contract_Signed__c == true){
                
                 system.debug('Contractor signature with Resend MSA');
                base64EncodeFile=base64EncodeFileContent(msafiledata,'Fully Executed Resigned MSA'+system.now()+'.pdf');  
              }else{
                  system.debug('Contractor signature ');
                  base64EncodeFile=base64EncodeFileContent(msafiledata,'Fully Executed MSA.pdf');
              }
           
          }else{
              if(resendMSA == 'YES'){
                  Datetime currentDate = system.now(); 
                base64EncodeFile=base64EncodeFileContent(msafiledata,'Vendor Resigned MSA'+currentDate+'.pdf');
              }else if(resendMSA == 'NO'){
                  system.debug('NO NO');
                   Datetime currentDate = system.now();
                   base64EncodeFile=base64EncodeFileContent(msafiledata,'Vendor Signed MSA.pdf'+currentDate+'.pdf');
              }
          }
          
              
              /*//String csvBody = EncodingUtil.base64Encode(msafiledata);
              //blob fileContent=blob.valueof('test String');
              //blob base64EncodeFile=BoxUtility.base64EncodeFileContent(fileContent,'First file Upload');
              //string orginal=EncodingUtil.base64Decode(EncodingUtil.base64Encode(msafiledata)).toString();
             // blob orginal=EncodingUtil.base64Decode(msafiledata);
              //blob base64EncodeFile=base64EncodeFileContent(orginal,'MSA.form');*/
              system.debug(acc.buildertek__Box_Folder_Id__c);
              String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+acc.buildertek__Box_Folder_Id__c;
              String boundary = '----------------------------741e90d31eff';
              HttpRequest req = new HttpRequest();
              system.debug(EncodingUtil.Base64Encode(base64EncodeFile));
              req.setBodyAsblob(base64EncodeFile);
              req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
              req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
              req.setHeader('Authorization', 'Bearer ' + AccessToken);
              req.setMethod('POST');
              req.setEndpoint(uploadEndPointURL);
              req.setMethod('POST');
              req.setTimeout(120000);
              //Send request to Box
              HTTPResponse res=sendHttpRequest(req);
              Response=res.getBody();
              System.debug('**Files upload Response:'+Response);
              Integer uploadStatusCode=res.getStatusCode();
              if(uploadStatusCode==201){
                  system.debug('SUCCESS');
              }else{
                 //return 'error';
              }
        
      }
      
      
         // }

         
  }
  public static blob base64EncodeFileContent(Blob file_body, String file_name){
    String boundary = '----------------------------741e90d31eff';
    String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
    String footer = '--'+boundary+'--';             
    String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
    while(headerEncoded.endsWith('='))
    {
        header+=' ';
        headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
    }
    String bodyEncoded = EncodingUtil.base64Encode(file_body);
    Blob bodyBlob = null;
    String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
    
    if(last4Bytes.endsWith('==')) {
        last4Bytes = last4Bytes.substring(0,2) + '0K';
        bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
    } else if(last4Bytes.endsWith('=')) {
        last4Bytes = last4Bytes.substring(0,3) + 'N';
        bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
        footer = '\n' + footer;
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
    } else {
        footer = '\r\n' + footer;
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        system.debug('headerEncoded ****' + headerEncoded);
        system.debug('bodyEncoded ****' + bodyEncoded);
        system.debug('footerEncoded ****' + footerEncoded);
        bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
    }
    
    return bodyBlob;
}
public static HTTPResponse sendHttpRequest(HTTPRequest req){
  Http http = new Http();
  HTTPResponse res = http.send(req);
  System.debug('****response body:'+res.getBody());
  return res;
}

}