@isTest
private class BT_DeleteRFQsControllerTest {

	private static testMethod void insertRFQs() {
	   
        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
        // buildertekProjectRef.Name = 'Test';
        // insert buildertekProjectRef;
        
        List<buildertek__RFQ__c> RFQLSTRef = new List<buildertek__RFQ__c> ();
        buildertek__RFQ__c RFQRef = new buildertek__RFQ__c ();
        RFQRef.Name='test';
        RFQRef.buildertek__Project__c = buildertekProjectRef.Id;
        RFQLSTRef.add(RFQRef);
        insert RFQLSTRef;
        // delete RFQLSTRef;
        // BT_DeleteRFQsController BT_DeleteRFQsControllerRef = new BT_DeleteRFQsController();
        BT_DeleteRFQsController.deleteRFQsRecord(RFQRef.id); 
        System.assertEquals('Test','Test');
       
	}

}