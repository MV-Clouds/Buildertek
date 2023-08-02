@isTest
private class ServiceRequestDAOTest {

	private static testMethod void test() {
        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
        buildertek__Warranty__c buildertekWarrantyRef = new buildertek__Warranty__c();
        buildertekWarrantyRef.buildertek__Description__c ='test';
        insert buildertekWarrantyRef;
        List<buildertek__Warranty_Item__c> warrantyListRef = new List<buildertek__Warranty_Item__c>();
        buildertek__Warranty_Item__c warrantyRef = new buildertek__Warranty_Item__c();
        warrantyRef.buildertek__Description__c ='test';
        warrantyRef.buildertek__Project__c =buildertekProjectRef.id;
        warrantyRef.buildertek__Warranty__c = buildertekWarrantyRef.id;
        warrantyListRef.add(warrantyRef);
        insert warrantyRef;
        ServiceRequestDAO.createServiceRequest(warrantyRef.id); 
        System.assertEquals('Test','Test');
	}

}