@isTest
public class BTStripePaymentControllerTest {
    static testMethod void test(){
    Test.startTest();
        
        buildertek__MSA_Settings__c MSA = new buildertek__MSA_Settings__c();
        MSA.Name = 'TestMSA';
        MSA.buildertek__Site_URL__c = 'test';
        insert MSA;
        
        buildertek__Billings__c BTBill = new buildertek__Billings__c();
        BTBill.Name = 'Test';
        insert BTBill;
        
        BTStripePaymentController BTpay = new  BTStripePaymentController();
        BTpay.RecId = BTBill.Id;
        MSA = BTpay.MsaUrl; 
        BTBill= BTpay.BTBillings;
        
        
        
    test.stopTest();
    }

}