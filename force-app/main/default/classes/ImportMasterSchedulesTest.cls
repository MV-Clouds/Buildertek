@isTest
private class ImportMasterSchedulesTest {
    
    public static testMethod void test1() {
        Contact c = new Contact();
        c.LastName='Test';
        c.email='test@gmail.com'; 
        insert c;        

        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;

        List<schedule__c> scheduleList = new List<schedule__c>();

        schedule__c sd = new schedule__c();
        sd.Description__c = 'test';
        sd.Type__c = 'Master';
        sd.Project__c = proj.Id;
        scheduleList.add(sd);

        schedule__c sd1 = new schedule__c();
        sd1.Description__c = 'new record1';
        sd1.Project__c = proj.Id;
        sd1.buildertek__Project_Manager__c = c.Id;
        sd1.buildertek__Initial_Start_Date__c = System.today();
        scheduleList.add(sd1);
        insert scheduleList;
        
        Date iniStartDate = sd1.buildertek__Initial_Start_Date__c;
        String recordId = sd1.Id;
        String projectManagerId = sd1.buildertek__Project_Manager__c;
        list<string> schIds = new list<string>();
        list<buildertek__Project_Task__c> schItemlist = new list<buildertek__Project_Task__c>();

        buildertek__Project_Task__c schItem1 =new  buildertek__Project_Task__c();
        schItem1.Name = 'testing 1';
        schItem1.buildertek__Schedule__c = sd.Id;
        schItem1.buildertek__Start__c = system.today();
        schItem1.buildertek__Duration__c = 20;
        schItem1.buildertek__Phase__c = 'Demolition';
        insert schItem1;
        
        /*buildertek__Trigger_Deactivation_Configuration__c te = new buildertek__Trigger_Deactivation_Configuration__c();
        te.Name = 'Project_Task__c';
        te.buildertek__Disabled__c = true;
        insert te;*/
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;

        buildertek__Project_Task__c schItem2 =new  buildertek__Project_Task__c();
        schItem2.Name = 'testing 2';
        schItem2.buildertek__Dependency__c = schItem1.Id;
        schItem2.buildertek__Schedule__c = sd.Id;
        schItem2.buildertek__Start__c = system.today();
        schItem2.buildertek__Duration__c = 20;
        schItem2.buildertek__Phase__c = 'Demolition';
        Test.startTest();
        insert schItem2;

        buildertek__Project_Task__c schItem =new  buildertek__Project_Task__c();
        schItem.Name = 'test';
        schItem.buildertek__Dependency__c = schItem2.Id;
        schItem.buildertek__Schedule__c = sd.Id;
        schItem.buildertek__Start__c = system.today();
        schItem.buildertek__Duration__c = 20;
        schItem.buildertek__Phase__c = 'Ground Work';
        schItemlist.add(schItem);
        insert schItemlist; 
        schIds.add(sd.Id); 
        

        ImportMasterSchedules.getMasterSchedule(recordId);
        ImportMasterSchedules.importMasterScheduleLines(schIds, sd.Id, null, projectManagerId);
        ImportMasterSchedules.getStartDate(system.today());
        Test.stopTest();

        // ApexPages.StandardController sc = new ApexPages.StandardController(sd);
        // ImportMasterSchedules impsch = new ImportMasterSchedules(sc);
        // // impsch.MasterScheduleClass impmaster = new ImportMasterSchedules.MasterScheduleClass();
        // impsch.getMasterSchedule(sd.Id);
        // impsch.importMasterScheduleLines(schIds, sd.Id, system.today());
        // System.assertEquals('Test','Test');
        
    }
    
}