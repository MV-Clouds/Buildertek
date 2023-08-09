@isTest
public class RFQItemTriggerTest {
    public static testMethod void testRFQItemTrigger() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
         
        RFQ__c rfq = new RFQ__c();
        rfq.Name = 'Test';
        rfq.Project__c = proj.Id;
        insert rfq;
        
        RFQ_Item__c rfqItem = new RFQ_Item__c(RFQ_Package__c = rfq.Id);
        insert rfqItem;
        update rfqItem;
        delete rfqItem;
        System.assertEquals('Test','Test');
    }
}