public without sharing class BTStripeCheckoutController {
    public string getValue{get;set;}
    public String StripeData{get;set;}
    public String getGetwayURL{get;set;}
    public Boolean ErrorHandler{get;set;}
    public string ErrorMsg{get;set;}
    public Boolean CheckOutHandler{get;set;}
    public BTStripeCheckoutController(){
        ErrorHandler = false;
        CheckOutHandler = true;
        this.ErrorMsg='';
        string recordid=Apexpages.currentpage().getparameters().get('Id');
        system.debug('recordid-->'+recordid);
        String SecertKeyVal = '';
        buildertek__Billings__c BillValues = new buildertek__Billings__c();
        if(Test.isRunningTest()){
             BillValues = [Select id,name,buildertek__Total_Amount_Tax__c,(Select id,name,buildertek__Quantity__c,buildertek__Billings__c from buildertek__Billable_Lines__r)from buildertek__Billings__c LIMIT 1];
        }else{
             BillValues = [Select id,name,buildertek__Total_Amount_Tax__c,(Select id,name,buildertek__Quantity__c,buildertek__Billings__c from buildertek__Billable_Lines__r)from buildertek__Billings__c where id =: recordid ];
        }
        system.debug('');
        String name = BillValues.name;
        Decimal TotalAmt = integer.valueOf(BillValues.buildertek__Total_Amount_Tax__c);
        decimal Qt = 0;
        for(buildertek__Billable_Lines__c br : BillValues.buildertek__Billable_Lines__r ){
            Qt = Qt+(integer.valueOf(br.buildertek__Quantity__c));
        }
        system.debug('Qt---------'+Qt);
        buildertek__Stripe_Settings__c StripeDataVal = [Select id,name,buildertek__Is_Live_Environment__c,buildertek__Stripe_Publishable_Live_Key__c,buildertek__Stripe_Publishable_Test_Key__c from buildertek__Stripe_Settings__c];
        if(StripeDataVal.buildertek__Is_Live_Environment__c == true){
            SecertKeyVal = StripeDataVal.buildertek__Stripe_Publishable_Live_Key__c;
        }else{
            SecertKeyVal = StripeDataVal.buildertek__Stripe_Publishable_Test_Key__c;
        }
        StripeData = SecertKeyVal;

        //query SO line items and prepare JsonStr
        integer amount=100;
        integer qty=1;
        String JsonStr1 ='';
        String StripeSecertKeyVal = '';
        String status = '';
        //End query SO line items and prepare JsonStr

        buildertek__MSA_Settings__c MSASiteUrl = [Select id,name,buildertek__Site_URL__c from buildertek__MSA_Settings__c ];

        buildertek__Stripe_Settings__c StripeSerectKey = [Select id,name,buildertek__Is_Live_Environment__c,buildertek__Stripe_Secret_Live_Key__c,buildertek__Stripe_Secret_Test_Key__c from buildertek__Stripe_Settings__c];
        if(StripeSerectKey.buildertek__Is_Live_Environment__c == true ){
            StripeSecertKeyVal = StripeSerectKey.buildertek__Stripe_Secret_Live_Key__c;
        }else{
            StripeSecertKeyVal = StripeSerectKey.buildertek__Stripe_Secret_Test_Key__c;
        }

        String authorizationHeader='';
        HttpResponse hs1;
        String APIkey = StripeSecertKeyVal ;
        system.debug('APIkey---------'+APIkey);
        String endPointValue = 'https://api.stripe.com/v1/checkout/sessions';
        HttpRequest http = new HttpRequest();
        http.setEndpoint(endPointValue);
        http.setMethod('POST');
        Blob headerValue = Blob.valueOf(APIkey + ':');
        authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        http.setHeader('Authorization', authorizationHeader);
        Http ht = new Http();

        String JsonStr = '&success_url='+MSASiteUrl.buildertek__Site_URL__c+'buildertek__BTPaymentSuccessVFPage?session_id='+recordid+'~{CHECKOUT_SESSION_ID}';
        system.debug('JsonStr------'+JsonStr);
        JsonStr += '&cancel_url='+MSASiteUrl.buildertek__Site_URL__c;    // 'https://junorocketinc-developer-edition.na150.force.com';
        JsonStr += '&payment_method_types[0]=card';
        JsonStr += '&line_items[0][name]='+Name;
        JsonStr += '&line_items[0][amount]='+(TotalAmt*100);
        JsonStr += '&line_items[0][currency]=usd';
        JsonStr += '&line_items[0][quantity]='+qty;

        system.debug('JsonStr--->'+JsonStr);

        JsonStr += '&mode=payment';
        system.debug('JsonStr------'+JsonStr);
        JsonStr += '&metadata[order_id]='+recordid;
        system.debug('JsonStr------'+JsonStr);
        http.setBody(JsonStr);
       // if(!Test.isRunningTest()){
        	hs1 = ht.send(http);
            //system.debug('hs1--->'+hs1);
            //system.debug('#### '+ hs1.getBody());
            status = hs1.getBody();
            system.debug('status -----------'+status);
            if(status.contains('Invalid API Key provided: tetst')){
                ErrorHandler = true;
                CheckOutHandler = false;
                this.ErrorMsg = 'Please check stripe connection in stripe settings.';
            }else if(status.contains('only registered Indian businesses')){
                ErrorHandler = true;
                CheckOutHandler = false;
                this.ErrorMsg = 'As per Indian regulations, only registered Indian businesses (i.e. sole proprietorships, limited liability partnerships and companies, but not individuals) can accept international payments. Please contact your admin for stripe connection.';
            }else if(status.contains('total amount due must add up to at least ₹0.50 inr')){
                ErrorHandler = true;
                CheckOutHandler = false;
                this.ErrorMsg = 'The Checkout Sessions total amount due must add up to at least ₹0.50 inr';
            }
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
            getGetwayURL = String.valueOf(m1.get('url'));
            System.debug('get url '+getGetwayURL);
        //}
    }

    public pageReference redirectToGetway(){

        pageReference pg = new pageReference(getGetwayURL);
        return pg;
    }

}