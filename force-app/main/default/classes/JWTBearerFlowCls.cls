public class JWTBearerFlowCls {
 public static String getAccessToken(String tokenEndpoint, JWT jwt) {
        
     String grantType = 'urn:ietf:params:oauth:grant-type:jwt-bearer';
     String access_token = null;
     system.debug('jwt.assertion()-->'+jwt.assertion());
     String body = 'grant_type='+EncodingUtil.urlEncode(grantType, 'UTF-8')+'&assertion=' + jwt.assertion();
     HttpRequest req = new HttpRequest();                            
     req.setMethod('POST');
     req.setEndpoint('https://account-d.docusign.com/oauth/token'); //tokenEndpoint
     req.setHeader('Content-type', 'application/x-www-form-urlencoded');
     req.setHeader('Authorization', 'Bearer '+jwt.assertion());
     System.debug('Authorization Bearer' + jwt.assertion());
     req.setBody(body);
     Http http = new Http();               
     try{
         HTTPResponse res = http.send(req);
            if ( res.getStatusCode() == 200 ) {
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                access_token = (String)responseMap.get('access_token');
            }else{
                System.debug('JWTBearerFlow Error Occurred '+res.getBody());
                System.debug( res.getStatusCode());
            }
        }catch(Exception ex){
            if(String.valueOf(ex).startsWith('Unauthorized endpoint')){
                System.debug('JWTBearerFlow Please check Setup->Security->Remote site settings and add '+tokenEndpoint);
            }else{
                System.debug('JWTBearerFlow  '+ex.getStackTraceString());
                System.debug('JWTBearerFlow '+ex);
            }
        }
      System.debug('access_token '+access_token);
        return access_token;
    }
}