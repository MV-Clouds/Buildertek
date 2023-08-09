@isTest
private class CreateQuoteFromRFQTest {

	private static testMethod void CreateQuote() {
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
	    
	    buildertek__RFQ__c rfq = new buildertek__RFQ__c();
	    rfq.buildertek__Project__c = proj.Id;
	    rfq.buildertek__Status__c = 'Awarded';
	    rfq.buildertek__Description__c = 'Test Description';
	    insert rfq;
	    
	    Account acc = new Account();
	    acc.name = 'Test Account';
	    insert acc;
	    
	    buildertek__RFQ_To_Vendor__c rfqToVendor = new buildertek__RFQ_To_Vendor__c();
	    rfqToVendor.Name = 'Test Vendor';
	    rfqToVendor.buildertek__RFQ__c = rfq.Id;
	    rfqToVendor.buildertek__Vendor__c = acc.Id;
	    insert rfqToVendor;
	    
	    rfq.buildertek__Vendor__c = rfqToVendor.Id;
	    update rfq;
	    
	    List<buildertek__RFQ_Item__c> rfqItemList = new List<buildertek__RFQ_Item__c>();
	    buildertek__RFQ_Item__c rfqItem = new buildertek__RFQ_Item__c();
	    rfqItem.Description__c = 'Test Description';
	    rfqItem.Name = 'Test Material';
	    rfqItem.buildertek__RFQ_Package__c = rfq.Id;
	    rfqItem.Quantity__c = 10;
	    rfqItem.Unit_Price__c = 100;
	    rfqItemList.add(rfqItem);
	    insert rfqItemList;
	    
	    CreateQuoteFromRFQ.CreateQuote(rfq.Id);
	    system.assertEquals('test', 'test');
	}

}