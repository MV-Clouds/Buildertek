@isTest
public class PaymentApplicationTriggerHandlerTest {
    
    static testMethod void validatePaymentApplication() {
        
        buildertek__SOV_Payment_Application__c PaymentApp = new buildertek__SOV_Payment_Application__c();
        PaymentApp.Name='Test Application' ;
        PaymentApp.buildertek__Application__c='1';
         PaymentApp.buildertek__Retainage__c= 10;
        PaymentApp.buildertek__Change_Order_Additions__c=500;
        PaymentApp.buildertek__Change_Order_Decuctions__c=500;
         PaymentApp.buildertek__CO_Additions_Approved_This_Month__c=200;
        PaymentApp.buildertek__CO_Deductions_Approved_in_Previous_Month__c=200;
        paymentApp.buildertek__Period_To__c= system.today();
        insert PaymentApp;
        buildertek__SOV_Payment_Application__c PaymentApp1 = new buildertek__SOV_Payment_Application__c();
        PaymentApp1.Name='Test Application' ;
        PaymentApp1.buildertek__Application__c='1';
        PaymentApp1.buildertek__Retainage__c= 10;
        PaymentApp1.buildertek__Change_Order_Additions__c=500;
        PaymentApp1.buildertek__Change_Order_Decuctions__c=500;
        paymentApp1.buildertek__Period_To__c = system.today();
        PaymentApp1.buildertek__CO_Additions_Approved_This_Month__c=PaymentApp.buildertek__Change_Order_Additions__c;
        PaymentApp1.buildertek__CO_Deductions_Approved_in_Previous_Month__c=PaymentApp.buildertek__Change_Order_Decuctions__c;
        insert PaymentApp1;
    }
}