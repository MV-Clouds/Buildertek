public class BTPaymentSuccessController {
    public string sid{get;set;}
    public buildertek__Billings__c InvoiceData{get;set;}
    public string amount{get;set;}

    public BTPaymentSuccessController(){
        try{
            string session_id=Apexpages.currentpage().getparameters().get('session_id');
            sid = session_id.split('~')[1];
            system.debug('session_id-->'+session_id); 
            //sid = session_id;     
            string invid = session_id.split('~')[0];
            InvoiceData = [Select id,name,Total_Amount_Tax__c from buildertek__Billings__c where id =:invid];
            amount = string.valueOf(InvoiceData.Total_Amount_Tax__c); 
        }catch(Exception e){
            system.debug('exception e--->'+e.getMessage()+'---line no--->'+e.getLineNumber());             
        } 
                
    }
    
    public PageReference createPayment(){
          String StripeSecertKeyVal = '';
           buildertek__Stripe_Settings__c StripeSerectKey = [Select id,name,buildertek__Is_Live_Environment__c,buildertek__Stripe_Secret_Live_Key__c,buildertek__Stripe_Secret_Test_Key__c from buildertek__Stripe_Settings__c];
           system.debug('StripeSerectKey-------'+StripeSerectKey); 
           if(StripeSerectKey.buildertek__Is_Live_Environment__c == true){
                 StripeSecertKeyVal = StripeSerectKey.buildertek__Stripe_Secret_Live_Key__c;
              }else{
                    StripeSecertKeyVal = StripeSerectKey.buildertek__Stripe_Secret_Test_Key__c;
                 }
        try{
            system.debug('sid--->'+sid);
            String authorizationHeader='';
            HttpResponse hs1;
            String APIkey = StripeSecertKeyVal ;
            String endPointValue = 'https://api.stripe.com/v1/checkout/sessions/'+sid;
            HttpRequest http = new HttpRequest();
            http.setEndpoint(endPointValue);
            http.setMethod('GET'); 
            Blob headerValue = Blob.valueOf(APIkey + ':');
            authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
            http.setHeader('Authorization', authorizationHeader);
            http.setHeader('content-type', 'application/json');
            //Use get Method as we are retrieving data from shopify
            http.setMethod('GET');
            Http ht = new Http();
            
            HttpResponse res = ht.send(http);
            //ResponseBody = res.getBody();         
            
            system.debug('res body--->'+res.getBody());
            
            Map<String,Object> m2;
            m2 = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            system.debug('m2--->'+m2);       
            system.debug('metadata--->'+m2.get('metadata'));        
            //system.debug('payment_intent--->'+m2.get('payment_intent'));
            
            Map<string,Object> m3;
            m3 = (Map<string,Object>)(m2.get('metadata')); 
                       
            
           
            
            //put payment update code
            
             String authorizationHeader1='';
             HttpResponse hs2;  
             String APIkey1 = StripeSecertKeyVal;
             String endPointValue1 = 'https://api.stripe.com/v1/payment_intents/'+m2.get('payment_intent');         
             HttpRequest http1 = new HttpRequest();
             http1.setEndpoint(endPointValue1);
             http1.setMethod('POST');
             Blob headerValue1 = Blob.valueOf(APIkey + ':');
             authorizationHeader1 = 'BASIC ' +EncodingUtil.base64Encode(headerValue1);
             http1.setHeader('Authorization', authorizationHeader1);
             Http ht1 = new Http();
             string JsonStr1 = '&metadata[order_id]='+m3.get('order_id');
             http1.setBody(JsonStr1); 
             hs2 = ht1.send(http1);
             system.debug('hs2--->'+hs2);
             system.debug('#### '+ hs2.getBody());                           
           //End put payment update code

            Map<String,Object> paymentmap;
            paymentmap = (Map<String,Object>) JSON.deserializeUntyped(hs2.getBody());
            system.debug('paymentmap--->'+paymentmap);       
            system.debug('metadata--->'+paymentmap.get('metadata'));        
            

            Map<string,Object> paymentMetadataMap;
            paymentMetadataMap = (Map<string,Object>)(paymentmap.get('metadata')); 
            system.debug('orderid--->'+paymentMetadataMap.get('order_id')); 
            string InvoiceId = string.valueOf(paymentMetadataMap.get('order_id'));  

            double amount = double.valueOf(paymentmap.get('amount'));
            system.debug('amount ----------'+amount );
            String PaymentID = string.valueOf(paymentmap.get('id'));
            system.debug('PaymentID ----------'+PaymentID );
            
            if(InvoiceId!=null){            
                InvoiceData = [Select id,name,buildertek__Total_Amount_Tax__c from buildertek__Billings__c where id =: InvoiceId];
                //buildertek__Billings__c  Invoice = [Select id,name from buildertek__Billings__c Where Id=:InvoiceId];             
                buildertek__Receipt__c CashReceipt = new buildertek__Receipt__c();
                CashReceipt.buildertek__Amount__c = amount ; 
                CashReceipt.buildertek__Receipt_Date__c = system.today();
                CashReceipt.buildertek__Billing__c = InvoiceId;
                CashReceipt.buildertek__Type__c = 'Customer Receipt';
                CashReceipt.buildertek__Stripe_Payment_ID__c = PaymentID;
                insert CashReceipt;
            }
                            
            
            
            
     
        }catch(Exception e){
            system.debug('exception --->'+e.getMessage()+'---line no--->'+e.getLineNumber());
        }
        
        return null;
    }
    
     public PageReference doCancel() {
        return Page.ForceWindowClose;
       
    }
    
    
}