public class OneTimeCheckoutController {
   /* public string getValue{get;set;}
    public OneTimeCheckoutController(){ 
        string soid=Apexpages.currentpage().getparameters().get('SOId');
        system.debug('soid-->'+soid);  
        
        //query SO line items and prepare JsonStr  
        integer amount=0;      
        integer qty=0;      
        String JsonStr1 ='';
        JunoMatic__Sales_Order__c SOrec = [Select Id, Name From JunoMatic__Sales_Order__c Where Id=:soid];
        List<JunoMatic__Sales_Order_Line__c> solList=[SELECT 
                                                      Id, 
                                                      Name,
                                                      JunoMatic__Sales_Order__c, 
                                                      JunoMatic__Product__c, 
                                                      JunoMatic__Product_Name__c,JunoMatic__Unit_Cost__c,
                                                      JunoMatic__Quantity__c FROM JunoMatic__Sales_Order_Line__c
                                                      where JunoMatic__Sales_Order__c=:soid ];  
        Set<Id> solListSet=new Set<Id>();
        for(JunoMatic__Sales_Order_Line__c jsolList:solList){
            solListSet.add(jsolList.JunoMatic__Product__c);
        }
        System.debug('Set---->'+solListSet);
        Map<id,String> productMap=new Map<id,String>();
        for(Product2 product:[SELECT 
                              Id, 
                              Name, 
                              ProductCode, 
                              Description, 
                              IsActive, 
                              JunoMatic__Product_Cost__c, 
                              JunoMatic__Product_Price__c, 
                              Price__c, Stripe_Id__c FROM Product2 where Id=: solListSet]){
                                  productMap.put(product.id,product.Stripe_Id__c);     
                              }
        System.debug('Map---->'+productMap);
        for(Integer i=0;i<solList.size();i++){            
            if(productMap.containsKey(solList[i].JunoMatic__Product__c)){    
                amount = amount+(integer.valueOf(solList[i].JunoMatic__Unit_Cost__c));
                qty = qty+(integer.valueOf(solList[i].JunoMatic__Quantity__c));
            } 
        } 
        System.debug(JsonStr1);       
        //End query SO line items and prepare JsonStr
        
        
        String authorizationHeader='';
        HttpResponse hs1;
        String APIkey ='sk_test_51HpJdvHL7aX0OSdcrgrU7zxjDVfUXY1yxoouUzehbaPjrruwAChEAy99pIZ361AJlFNxOcnahZAxvZbERlPvWCw3006JdBhrpR';
        String endPointValue = 'https://api.stripe.com/v1/checkout/sessions';
        HttpRequest http = new HttpRequest();
        http.setEndpoint(endPointValue);
        http.setMethod('POST');
        Blob headerValue = Blob.valueOf(APIkey + ':');
        authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        http.setHeader('Authorization', authorizationHeader);
        Http ht = new Http();    
        
        //String JsonStr = '&success_url='+'https://junorocketinc-developer-edition.na150.force.com/success?session_id={CHECKOUT_SESSION_ID}&SO=1234';
        String JsonStr = '&success_url='+'https://junorocketinc-developer-edition.na150.force.com/OneTimeSuccess?session_id={CHECKOUT_SESSION_ID}';
        JsonStr += '&cancel_url='+'https://junorocketinc-developer-edition.na150.force.com';
        JsonStr += '&payment_method_types[0]=card';
        JsonStr += '&line_items[][name]='+SOrec.Name;
        JsonStr += '&line_items[][amount]='+amount;
        JsonStr += '&line_items[][currency]=inr';
        JsonStr += '&line_items[][quantity]='+qty;
         
        system.debug('JsonStr--->'+JsonStr); 
        
        JsonStr += '&mode=payment';
        JsonStr += '&metadata[order_id]='+SOrec.Id;  
        http.setBody(JsonStr);
        hs1 = ht.send(http);
        system.debug('hs1--->'+hs1);
        system.debug('#### '+ hs1.getBody());
        string response =  hs1.getBody()+'';
        string sessionId = response.split(',')[0];
        system.debug('sessionId--->'+sessionId);
        sessionId = sessionId.split(':')[1];
        system.debug('sessionId--->'+sessionId);
        sessionId = sessionId.replaceAll('"', '');
        sessionId = sessionId.replaceAll(' ', '');
        system.debug('sessionId--->'+sessionId);    
        getValue = sessionId;
        
        Map<String,Object> m1;
        m1 = (Map<String,Object>) JSON.deserializeUntyped(response);
        system.debug('m1--->'+m1);
        
        for(string key: m1.keyset()){
system.debug('key--->'+key);
system.debug('value--->'+m1.get(key)); 
}
        
        //system.debug('payment intent--->'+m1.get('payment_intent'));         
        
        
    }*/
}