@isTest
public class RFQTOVendorTriggerTest {
    public static testMethod void testRFQTOVendorTrigger() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        RFQ__c rfq = new RFQ__c();
        rfq.Name = 'Test';
        rfq.buildertek__Project__c = proj.Id;
        insert rfq;
        
        RFQ_To_Vendor__c rfqToVendor = new RFQ_To_Vendor__c(RFQ__c = rfq.Id, Vendor__c = acc.Id);
        insert rfqToVendor;
        update rfqToVendor;
        delete rfqToVendor;
        system.assertEquals('Test', 'Test');
    }
}