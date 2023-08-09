@isTest
public class MassUpdateTakeOffLinesTest{
	@testSetup
	static void setupMethod(){
		Account acc = new Account();
		acc.Name = 'Test 1';
		insert acc; 

		buildertek__Project__c project = new buildertek__Project__c();
		project.buildertek__Account__c = acc.Id;
		insert project;
        
        buildertek__Category__c category = new buildertek__Category__c();
        insert category;
        
        buildertek__Trade_Type__c tradeType = new buildertek__Trade_Type__c();
        insert tradeType;
        
        buildertek__Product_Type__c productType = new buildertek__Product_Type__c();
        insert productType;
        
        buildertek__Plans__c plantype = new buildertek__Plans__c();
        insert plantype;
                
        buildertek__Project_Takeoff__c takeOff = new buildertek__Project_Takeoff__c();
        takeOff.buildertek__Project__c = project.Id;
        takeOff.buildertek__Name__c = 'Test Takeoff';
        insert takeOff;
        
        buildertek__Project_Takeoff_Lines__c takeOffLines = new buildertek__Project_Takeoff_Lines__c();
        takeOffLines.buildertek__Project_Takeoff__c = takeOff.Id;
        insert takeOffLines;
	}
 
	@isTest
	static void testMethod1(){
		List<buildertek__Project_Takeoff__c> takeOff = [Select Id
		                                  FROM buildertek__Project_Takeoff__c
		                                  LIMIT 1];
        List<buildertek__Project_Takeoff_Lines__c> takeOffLines = [Select Id
		                                  FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =: takeOff[0].Id];
		
        buildertek__Category__c category = [Select Id FROm buildertek__Category__c LIMIT 1];
        buildertek__Trade_Type__c tradeType = [Select Id FROm buildertek__Trade_Type__c LIMIT 1];
        buildertek__Product_Type__c productType = [Select Id FROm buildertek__Product_Type__c LIMIT 1];
        buildertek__Plans__c plantype = [Select Id FROm buildertek__Plans__c LIMIT 1];
        
        MassUpdateTakeOffLines updaterecord = new MassUpdateTakeOffLines();
        MassUpdateTakeOffLines.getCount(takeOff[0].Id);
		MassUpdateTakeOffLines.getFieldSet();
        MassUpdateTakeOffLines.getName(takeOff[0].Id);
        MassUpdateTakeOffLines.getParentId(takeOff[0].Id);
        MassUpdateTakeOffLines.getRecords(takeOff[0].Id,'[]',1,1,'d','c','b','a');
        MassUpdateTakeOffLines.updateRecords(takeOff[0].Id,'[]','[]',1,1,'d','c','b','a');
        MassUpdateTakeOffLines.deleteProject(takeOff[0].Id,takeOffLines[0].Id,'[]',1,1,'d','c','b','a');
    }
}