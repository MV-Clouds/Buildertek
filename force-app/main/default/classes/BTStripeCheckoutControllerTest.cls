@isTest
public class BTStripeCheckoutControllerTest {
  
    
    @TestSetup
    static void setup() {
        Account acc = new Account(Name='Test Acc');
        insert acc;
        
        Contact con = new Contact(FirstName='Test',
                                  LastName='Contact',
                                  Email='test@email.com',
                                  AccountId=acc.id);
        insert con;
        
        
        buildertek__Stripe_Settings__c BT = new buildertek__Stripe_Settings__c();
        BT.name = 'Test';
        BT.buildertek__Is_Live_Environment__c = true;
        BT.buildertek__Stripe_Publishable_Live_Key__c = 'Test';
        BT.buildertek__Stripe_Publishable_Test_Key__c = 'TestKw';
        BT.buildertek__Stripe_Secret_Live_Key__c = 'te';
        BT.buildertek__Stripe_Secret_Test_Key__c = 'TestSecret';
        insert BT;
        
        buildertek__Billings__c billingrec = new buildertek__Billings__c();
        billingrec.buildertek__Customer_Account__c = acc.Id;
        insert billingrec;
        
        
        
        buildertek__MSA_Settings__c BMSRec = new buildertek__MSA_Settings__c(Name='Test custom',buildertek__Site_URL__c='test');
        insert BMSRec;
    }
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void testBTStripeCheckoutController() {
       /*  buildertek__Billings__c BTBill = new buildertek__Billings__c();
        insert BTBill;
        // Calling a Web Service here would throw an exception
        return null;*/
    	
        buildertek__MSA_Settings__c MSASiteUrl = [Select id,name,buildertek__Site_URL__c from buildertek__MSA_Settings__c ];
        
        
        buildertek__Billings__c BTBill = new buildertek__Billings__c();
        BTBill.Name = 'Test';
        insert BTBill;
        
        buildertek__Billable_Lines__c BTLines = new buildertek__Billable_Lines__c();
        //BTLines.Name = 'Test';
        BTLines.buildertek__Quantity__c = 1;
        BTLines.buildertek__Billings__c = BTBill.Id;
        insert BTLines;
        
        List<buildertek__Stripe_Settings__c > StripeList = [SELECT Id,
                                                            Name,
                                                            buildertek__Is_Live_Environment__c ,
                                                            buildertek__Stripe_Publishable_Live_Key__c,
                                                            buildertek__Stripe_Publishable_Test_Key__c,
                                                            buildertek__Stripe_Secret_Live_Key__c,
                                                            buildertek__Stripe_Secret_Test_Key__c 
                                                            FROM buildertek__Stripe_Settings__c ];
        
        Apexpages.currentpage().getparameters().put('Id',BTBill.id);
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
         test.stopTest();
        BTStripeCheckoutController Sucess = new BTStripeCheckoutController();
        
       
    }
    
}