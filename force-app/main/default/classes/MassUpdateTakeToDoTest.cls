@isTest
public class MassUpdateTakeToDoTest{
	@testSetup
	static void setupMethod(){
		Account acc = new Account();
		acc.Name = 'Test 1';
		insert acc;

		buildertek__Project__c project = new buildertek__Project__c();
		project.buildertek__Account__c = acc.Id;
		insert project;
        
        buildertek__To_Do__c toDO = new buildertek__To_Do__c();
        toDO.buildertek__Project__c = project.Id;
        insert toDO;
        
        buildertek__To_Do_Items__c toDOItems = new buildertek__To_Do_Items__c();
        toDOItems.buildertek__To_Do__c = toDO.Id;
        insert toDOItems;
	}
 
	@isTest
	static void testMethod1(){
		List<buildertek__To_Do__c> toDO = [Select Id
		                                  FROM buildertek__To_Do__c
		                                  LIMIT 1];
        List<buildertek__To_Do_Items__c> toDOItems = [Select Id
		                                  FROM buildertek__To_Do_Items__c WHERE buildertek__To_Do__c =: toDo[0].Id];
		
        
        
        MassUpdateTakeToDo updaterecord = new MassUpdateTakeToDo();

        MassUpdateTakeToDo.getName(toDO[0].Id);
		MassUpdateTakeToDo.getFieldSet();
		MassUpdateTakeToDo.getRecords(toDo[0].Id,'[]');
		MassUpdateTakeToDo.updateToDoItems(toDo[0].Id,JSON.serialize(toDoItems), '[]');
        MassUpdateTakeToDo.getDropDown('buildertek__To_Do_Items__c','buildertek__Priority__c');
	}
    
    @isTest
	static void testMethod2(){
		MassUpdateTakeToDo.getName('');
		MassUpdateTakeToDo.getRecords('','[]');
		MassUpdateTakeToDo.updateToDoItems('','','[]');
        MassUpdateTakeToDo.getDropDown('buildertek__Quote_Item__c','buildertek__UOM__c');
	}
}