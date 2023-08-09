@isTest
public class SendPaymentEmailControllerTest {
    @testSetup
    static void setup() {
        Account acc = new Account(Name='Test acc',buildertek__Email_Address__c='Test@test.com');
        insert acc;
        
        Contact con = new Contact(FirstName='Test',
                                  LastName='Contact',
                                  Email='test@email.com',
                                  AccountId=acc.id);
        insert con;
        
        buildertek__Stripe_Settings__c stripeSeetings = new buildertek__Stripe_Settings__c();
        stripeSeetings.Name = 'Tset';
        stripeSeetings.buildertek__Email_Template_Name__c = 'Invoice';
        insert stripeSeetings;
        
        buildertek__Billings__c BBRec = new buildertek__Billings__c(Name='Test',
                                                                    buildertek__Customer_Account__c=acc.id);
        insert BBRec;
        buildertek__MSA_Settings__c BMSRec = new buildertek__MSA_Settings__c(Name='Test custom',buildertek__Site_URL__c='test');
        insert BMSRec;
    }
    static testMethod void test() {
        Contact con = [select id from Contact];
        buildertek__MSA_Settings__c MSASiteUrl = [Select id,name,buildertek__Site_URL__c from buildertek__MSA_Settings__c ];
        buildertek__Billings__c salesOrder = [SELECT Id, Name,buildertek__Customer_Account__r.buildertek__Email_Address__c,buildertek__Customer_Account__r.Name FROM buildertek__Billings__c LIMIT 1];
        test.startTest();
        SendPaymentEmailController.getSalesOrderDetails(salesOrder.id,'');
        SendPaymentEmailController.setAttachmentBody(salesOrder.Id,salesOrder.Id);
        SendPaymentEmailController.sendEmail(salesOrder.id,'Only for testing','Test Email');
        test.stopTest();
    }
}