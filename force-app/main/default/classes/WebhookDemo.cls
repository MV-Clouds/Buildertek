@RestResource(urlMapping='/api/Webhooks/pushDetailsdemo/*')

global class WebhookDemo {
   

   @HttpPost
   global static void doPost()
   {
        RestRequest req = RestContext.request;
        Blob body = req.requestBody;
        String bodyString = body.toString();    
        system.debug('====='+bodyString);           
   }      

}