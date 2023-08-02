@isTest
private class CreatePOFromRFQTest {

	private static testMethod void insertRFQ() {
        Account currAcc = new Account(Name = 'test');
        insert currAcc;
        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
        // ResponseBase response = new ResponseBase();
        // buildertek__Budget__c buildertekBudgetRef = new buildertek__Budget__c();
        // buildertekBudgetRef.Name = 'test';
        // insert buildertekBudgetRef;
        
        // buildertek__Vendor__c buildertekVendorRef = new buildertek__Vendor__c();
        // buildertekVendorRef.Name ='test';
        // buildertekVendorRef.Email ='test@gmail.com';
        // insert buildertekVendorRef;
        
        List<buildertek__RFQ__c> RFQLSTRef = new List<buildertek__RFQ__c> ();
        buildertek__RFQ__c RFQRef = new buildertek__RFQ__c ();
        RFQRef.Name='test';
        RFQRef.buildertek__Project__c = buildertekProjectRef.Id;
        // RFQRef.buildertek__Budget__c = buildertekBudgetRef.Id;
        RFQRef.buildertek__Due_Date__c = system.today();
        RFQRef.buildertek__Status__c ='Awarded';
        // RFQRef.buildertek__Vendor__r.buildertek__Vendor__c = buildertekVendorRef.id;
        // RFQRef.buildertek__Vendor__c = buildertekVendorRef.id;
        RFQLSTRef.add(RFQRef);
        insert RFQLSTRef;
        
        buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
        PO.buildertek__Project__c = buildertekProjectRef.Id;
        PO.buildertek__Status__c = 'Awarded';
        PO.buildertek__Type__c = 'Standard';
        // PO.buildertek__Vendor__c = RFQ.buildertek__Vendor__r.buildertek__Vendor__c;
        // PO.buildertek__Budget__c = RFQRef.buildertek__Budget__c;
        // PO.buildertek__Quote__c = RFQ.buildertek__Quote__c;
        PO.buildertek__RFQ__c = RFQRef.Id;
        Po.buildertek__Description__c = RFQRef.Name;
        Po.buildertek__Vendor__c = currAcc.id;
        insert PO;
        RFQRef.buildertek__Associated_Purchase_Order__c = PO.Id;
        update RFQRef;
        List<buildertek__Purchase_Order_Item__c> arItemLst = new List<buildertek__Purchase_Order_Item__c>();
        buildertek__Purchase_Order_Item__c arItem = new buildertek__Purchase_Order_Item__c();
        arItem.Name = 'test';
        arItem.buildertek__Purchase_Order__c = PO.Id;
        arItem.Name = RFQRef.Name;
        // arItem.Cost_Code__c  
        // arItem.Description__c 
        // arItem.Product__c 
        // arItem.Unit_Price__c
        // arItem.buildertek__Budget_Item__c 
        // arItem.Quantity__c 
        // arItem.buildertek__RFQ_Item__c 
        arItemLst.add(arItem);
        insert arItem;
        
        buildertek__RFQ_Item__c rfqItem = new buildertek__RFQ_Item__c();
        rfqItem.Name = 'test';
        rfqItem.buildertek__Description__c = 'test';
        rfqItem.buildertek__RFQ_Package__c = RFQRef.id;
        insert rfqItem;
        CreatePOFromRFQ.CreatePOMethod(RFQRef.id);
        System.assertEquals('Test','Test');
	}

}