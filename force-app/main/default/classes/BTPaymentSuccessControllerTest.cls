@isTest
public class BTPaymentSuccessControllerTest {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
     @testSetup
    static void setup() {
        Account acc = new Account(Name='Test Acc');
        insert acc;
        
        buildertek__Box_Settings__c boxsettings = new buildertek__Box_Settings__c(Name = 'BOX API',
                                                                                     buildertek__Client_Id__c = 'testclientid',
                                                                                     buildertek__Client_Secret__c = 'testclientsecret',
                                                                                     buildertek__API_Key__c = 'testapikey',
                                                                                     buildertek__Access_Token__c = 'testaccessToken',
                                                                                     buildertek__Refresh_Token__c = 'testrefreshtoken',
                                                                                     buildertek__Enterprise_ID__c = 'testenterpriseid');
            insert boxsettings;
        
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
        BT.buildertek__Is_Live_Environment__c = false;
        update BT;
        }
        static testMethod void testBTPaymentSuccessController() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
        test.startTest();
        List<buildertek__Stripe_Settings__c > salesOrderList = [SELECT Id,
                                                        Name,
                                                        buildertek__Is_Live_Environment__c ,
                                                        buildertek__Stripe_Publishable_Live_Key__c,
                                                        buildertek__Stripe_Publishable_Test_Key__c,
                                                        buildertek__Stripe_Secret_Live_Key__c,
                                                        buildertek__Stripe_Secret_Test_Key__c 
                                                        FROM buildertek__Stripe_Settings__c ];
       
        //Apexpages.currentpage().getparameters().put('session_id',salesOrderList[0].id);
        BTPaymentSuccessController Sucess = new BTPaymentSuccessController();
        Sucess.createPayment();
  
        test.stopTest();
    }

}