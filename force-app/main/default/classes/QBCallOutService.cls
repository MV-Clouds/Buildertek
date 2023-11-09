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
}