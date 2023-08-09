@isTest
public class ProjectTaskBatchTest {
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        insert project;
        
        buildertek__Schedule__c sc = new buildertek__Schedule__c();
        sc.buildertek__Project__c = project.Id;
        insert sc;
        
        buildertek__Project_Task__c projectTask = new buildertek__Project_Task__c();
        projectTask.buildertek__Schedule__c = sc.Id;
        projectTask.buildertek__Start__c = System.Today();
        insert projectTask;
        
        buildertek__Project_Task__c projectTask1 = new buildertek__Project_Task__c();
        projectTask1.buildertek__Schedule__c = sc.Id;
        projectTask1.buildertek__Dependency__c = projectTask.Id;
        projectTask1.buildertek__Start__c = System.Today();
        insert projectTask1;
    }
    
    @isTest
    static void testMethod1(){
        List<buildertek__Schedule__c> sc = [Select Id FROM buildertek__Schedule__c LIMIT 1];
    	Set<Id> scheduleIds = new Set<Id>();
        scheduleIds.add(sc[0].Id);
        ProjectTaskBatch taskBatch = new ProjectTaskBatch(scheduleIds);
		Database.executeBatch(taskBatch, 100);
    }
}