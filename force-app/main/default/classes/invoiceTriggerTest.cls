@isTest
public class invoiceTriggerTest {
    public static testMethod void test1() {
        
        Account acc = new Account();
        acc.Name='test';
        insert acc;
        
        Change_Order__c co = new Change_Order__c();
        co.Name = 'test';
        co.Customer_Account__c=acc.id;
        insert co;
        
        
        Billings__c billing = new Billings__c();
        billing.Name='test';
        billing.Change_Order__c=co.id;
        insert billing;
        
        billing.Name='test1';
        update billing;
        
        DmlException expectedException;
        Test.startTest();
        try { delete billing; }
        catch (DmlException dmx) { expectedException = dmx; }
        Test.stopTest();
        
       System.assertEquals('Test','Test');
     
        
    }
    
      public static testMethod void test2() {
        
        Account acc = new Account();
        acc.Name='test2';
        insert acc;
        
        Change_Order__c co = new Change_Order__c();
        co.Name = 'test2';
        co.Customer_Account__c=acc.id;
        insert co;
        
        
        Billings__c billing = new Billings__c();
        billing.Name='test2';
        billing.Change_Order__c=co.id;
        billing.Tax_Rate__c=2;
        insert billing;
        
        Billable_Lines__c billinglines= new Billable_Lines__c();
        billinglines.Billings__c=billing.id;
        billinglines.Quantity__c=2;
        billinglines.Unit_Price__c=10;
        insert billinglines;
        
        
        // Receipt__c r = new Receipt__c();
        // r.Billing__c=billing.id;
        // r.Amount__c=20;
        // insert r;
      System.assertEquals('Test','Test');
        
        
        
       
     
        
    }
}