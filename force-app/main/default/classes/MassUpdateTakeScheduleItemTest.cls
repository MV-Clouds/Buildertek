@isTest
public class MassUpdateTakeScheduleItemTest{
	@testSetup
	static void setupMethod(){
		Account acc = new Account();
        acc.Name = 'Test 1 ';
        insert acc;
        
        contact con = new contact();
        con.Lastname = 'Test 1';
        con.AccountId = acc.Id;
        con.Email='test@gmail.com'; 
        insert con; 
        
        buildertek__Project__c  project = new buildertek__Project__c();
        project.Name = 'test';
        insert project;
        
        buildertek__Schedule__c schedule = new buildertek__Schedule__c();
        schedule.buildertek__Description__c = 'test';
        schedule.buildertek__Vendor_Visible__c = true;
        schedule.buildertek__Project__c = project.Id;
        schedule.buildertek__Primary_Schedule__c = true;
        insert schedule;
        
        List<buildertek__Project_Task__c> projectTaskList = new List<buildertek__Project_Task__c>();
        buildertek__Project_Task__c projectTask = new buildertek__Project_Task__c();
        projectTask.buildertek__Schedule__c = schedule.Id;
        projectTask.Name = 'Test';
        projectTask.buildertek__Start__c = Date.Today();
        projectTask.buildertek__Milestone__c = false;
        projectTaskList.add(projectTask);
        
        insert projectTaskList;
	}
 
	@isTest
	static void testMethod1(){
		List<buildertek__Schedule__c> schedule = [Select Id
		                                  FROM buildertek__Schedule__c
		                                  LIMIT 1];
        List<buildertek__Project_Task__c> task = [Select Id
		                                  FROM buildertek__Project_Task__c LIMIT 1];
		List<String> fieldName = new List<String>();
        fieldName.add('Id');
        List<String> recordsToDelete = new List<String>();
        recordsToDelete.add(task[0].Id);
        MassUpdateTakeScheduleItem updaterecord = new MassUpdateTakeScheduleItem();
        MassUpdateTakeScheduleItem.getCount(schedule[0].Id);
		MassUpdateTakeScheduleItem.getFieldSet();
        MassUpdateTakeScheduleItem.getRecords(schedule[0].Id,JSON.serialize(fieldName),1,1,'d','c','b','a');
        MassUpdateTakeScheduleItem.updateRecords(schedule[0].Id,'[]',JSON.serialize(fieldName),1,1,'d','c','b','a');
        MassUpdateTakeScheduleItem.deleteProject(schedule[0].Id,task[0].Id,JSON.serialize(fieldName),1,1,'d','c','b','a');
        MassUpdateTakeScheduleItem.massDeleteProjectTask(recordsToDelete,task[0].Id,JSON.serialize(fieldName),1,1,'d','c','b','a');
    }
}