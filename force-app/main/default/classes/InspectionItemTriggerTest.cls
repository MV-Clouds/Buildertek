@isTest
private class InspectionItemTriggerTest {

	private static testMethod void test() {
	    
	   buildertek__Project__c proj = new buildertek__Project__c();
       proj.Name = 'Test Project';
       insert proj;
        
	  Inspection__c inspection = new Inspection__c();
      inspection.Name__c = 'test';
      inspection.Status__c='Completed';
      inspection.buildertek__Project__c =proj.Id;
      insert inspection;
      
      buildertek__Inspection_Line__c inspectionline = new buildertek__Inspection_Line__c();
      inspectionline.buildertek__Inspection__c = inspection.Id;
      insert inspectionline;
      System.assertEquals(inspection.Status__c,'Completed');

	}

}