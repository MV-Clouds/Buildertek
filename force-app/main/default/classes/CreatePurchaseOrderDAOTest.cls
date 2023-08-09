@isTest
private class CreatePurchaseOrderDAOTest {

	private static testMethod void test() {
        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
        Account currAcc = new Account(Name = 'test');
        insert currAcc;
        contact con = new contact();
        con.lastname ='test';
        insert con;
        list<buildertek__Service_Request__c> buildertekServiceRequestRefLst = new List<buildertek__Service_Request__c>();
        buildertek__Service_Request__c buildertekServiceRequestRef = new buildertek__Service_Request__c();
        buildertekServiceRequestRef.buildertek__Project__c = buildertekProjectRef.id;
        buildertekServiceRequestRef.buildertek__Customer_Name__c = con.id;
        buildertekServiceRequestRef.buildertek__Subject__c ='test';
        buildertekServiceRequestRefLst.add(buildertekServiceRequestRef);
        insert buildertekServiceRequestRef;
        buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
        PO.buildertek__Project__c = buildertekServiceRequestRef.buildertek__Project__c;
        PO.buildertek__Status__c = 'New';
        PO.buildertek__Description__c = buildertekServiceRequestRef.buildertek__Subject__c;
        PO.buildertek__Vendor__c = currAcc.id;
        insert PO;
        CreatePurchaseOrderDAO.createPO(buildertekServiceRequestRef.Id);
        System.assertEquals('Test','Test');
	}

}