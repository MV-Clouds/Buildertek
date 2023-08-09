@isTest
public  class MassUpdateWarrantyTest {
    @testSetup
	static void setupMethod(){
		Account acc = new Account();
		acc.Name = 'Test 1';
		insert acc;  

		buildertek__Project__c project = new buildertek__Project__c();
		project.buildertek__Account__c = acc.Id;
		insert project;
        
        buildertek__Warranty__c warranty = new buildertek__Warranty__c();
        warranty.buildertek__Project__c = project.Id;
        insert warranty;
        
        buildertek__Warranty_Item__c warrantyitems = new buildertek__Warranty_Item__c();
        warrantyitems.buildertek__Warranty__c = warranty.Id;
        warrantyitems.buildertek__Status__c = 'Open';
        insert warrantyitems;
	}
 
	@isTest
	static void testMethod1(){
		List<buildertek__Warranty__c> warranty = [Select Id
		                                  FROM buildertek__Warranty__c
		                                  LIMIT 1];
        List<buildertek__Warranty_Item__c> warrantyitems = [Select Id
		                                  FROM buildertek__Warranty_Item__c WHERE buildertek__Warranty__c =: warranty[0].Id];
		
   
        MassUpdateWarranty updaterecord = new MassUpdateWarranty();
        //MassUpdateWarranty.getCount(warranty[0].Id);
		//MassUpdateWarranty.getFieldSet();
        MassUpdateWarranty.getWarrantyItems(warranty[0].Id,1,1);
        //MassUpdateWarranty.getName(warranty[0].Id);
        //MassUpdateWarranty.getParentId(warranty[0].Id);
       	//MassUpdateWarranty.getRecords(warranty[0].Id,'[]',1,1);
        MassUpdateWarranty.updateRecords(warranty[0].Id,'[]',1,1);
        MassUpdateWarranty.deleteWarrantyRecord(warrantyitems[0].Id,warranty[0].Id,1,1);
    }
}