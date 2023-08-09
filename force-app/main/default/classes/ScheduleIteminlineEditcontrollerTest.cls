@isTest
public  class ScheduleIteminlineEditcontrollerTest {

    @isTest static void testMethod1 (){
        Account acc = new Account();
        acc.Name='test';
        insert acc;

        Contact con = new Contact();
        con.LastName='test';
        con.FirstName='testmthod';
        con.Email='test@test.com';
        con.AccountId=acc.Id;
        insert con;



        buildertek__Schedule__c schedule1 = new buildertek__Schedule__c();
        insert schedule1;

        List<buildertek__Project_Task__c> projectTaskList = new List<buildertek__Project_Task__c>();
        buildertek__Project_Task__c projectTask1 = new buildertek__Project_Task__c();
        projectTask1.Name='test Task';
        projectTask1.buildertek__Schedule__c=schedule1.Id;
        DateTime dt= System.now();
        projectTask1.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask1.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        projectTask1.buildertek__Duration__c=10;
        projectTask1.buildertek__Phase__c='Candidate Selection';
        projectTask1.buildertek__Lag__c=0;
        projectTask1.buildertek__Milestone__c =false;
        projectTask1.buildertek__Contractor__c=acc.Id;
        projectTask1.buildertek__Resource__c =con.Id;
        projectTask1.buildertek__Contractor_Resource__c  =con.Id;
        insert projectTask1;

        buildertek__Project_Task__c projectTask2 = new buildertek__Project_Task__c();
        projectTask2.Name='test Task';
        projectTask2.buildertek__Schedule__c=schedule1.Id;
        projectTask2.buildertek__Duration__c=10;
        projectTask2.buildertek__Phase__c='Candidate Selection';
        projectTask2.buildertek__Lag__c=0;
        projectTask2.buildertek__Milestone__c =false;
        projectTask2.buildertek__Contractor__c=acc.Id;
        projectTask2.buildertek__Resource__c =con.Id;
        projectTask2.buildertek__Contractor_Resource__c  =con.Id;
        projectTask2.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask2.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        insert projectTask2;
        projectTaskList.add(projectTask1);
        projectTaskList.add(projectTask2);


        Map<String,buildertek__Project_Task__c []> oppMap = new Map<String, buildertek__Project_Task__c[]>();
        oppMap.put('test',projectTaskList);
        string expected='[ { Name} , {buildertek__Schedule__c} , {buildertek__Finish__c} ,{ buildertek__Start__c} ,buildertek__Duration__c , buildertek__Phase__c, buildertek__Milestone__c } ]';
        String jsondata='[{"Id":"'+projectTask2.Id+'", "Name":"Test" , "buildertek__Phase__c":"Candidate Selection"}]';

        Map<Id,buildertek__Project_Task__c > projectMap = new Map<Id, buildertek__Project_Task__c>();
        projectMap.put(projectTask2.Id,projectTask2);

        //    ScheduleTriggerHandler triggerHandler = new ScheduleTriggerHandler(true , 1);
        //    triggerHandler.blnSkipTaskTrigger=true;
        Test.startTest();
        ProjectTaskTriggerHandler.blnSkipTaskTrigger=true;
        ScheduleIteminlineEditcontroller.fetchAccts();
        ScheduleIteminlineEditcontroller.fetchprojecttasks(schedule1.Id);
        ScheduleIteminlineEditcontroller.updateprojeccttasks(projectTaskList);
        ScheduleIteminlineEditcontroller.deletescheduleitemrec(projectTask1.Id);
        ScheduleIteminlineEditcontroller.getFieldSet('buildertek__Project_Task__c' , 'buildertek__Schedule_Item_field_set',schedule1.Id);
        ScheduleIteminlineEditcontroller.getRecords('buildertek__Project_Task__c' , 'Name' , schedule1.Id , jsondata  );
        ScheduleIteminlineEditcontroller.updateprojeccttasksDuplicate(jsondata , schedule1.Id , 1 );
        ScheduleIteminlineEditcontroller.updateTaskOrder(jsondata , 1 );
        ScheduleIteminlineEditcontroller.getScheduleRecord(schedule1.Id);

        Test.stopTest();


    }

    @isTest static void testMethod2 (){
        Account acc = new Account();
        acc.Name='test';
        insert acc;

        Contact con = new Contact();
        con.LastName='test';
        con.FirstName='testmthod';
        con.Email='test@test.com';
        con.AccountId=acc.Id;
        insert con;



        buildertek__Schedule__c schedule1 = new buildertek__Schedule__c();
        insert schedule1;

        List<buildertek__Project_Task__c> projectTaskList = new List<buildertek__Project_Task__c>();
        buildertek__Project_Task__c projectTask1 = new buildertek__Project_Task__c();
        projectTask1.Name='test Task';
        projectTask1.buildertek__Schedule__c=schedule1.Id;
        DateTime dt= System.now();
        projectTask1.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask1.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        projectTask1.buildertek__Duration__c=10;
        projectTask1.buildertek__Phase__c='Candidate Selection';
        projectTask1.buildertek__Lag__c=0;
        projectTask1.buildertek__Milestone__c =false;
        projectTask1.buildertek__Contractor__c=acc.Id;
        projectTask1.buildertek__Resource__c =con.Id;
        projectTask1.buildertek__Contractor_Resource__c  =con.Id;
        insert projectTask1;

        buildertek__Project_Task__c projectTask2 = new buildertek__Project_Task__c();
        projectTask2.Name='test Task';
        projectTask2.buildertek__Schedule__c=schedule1.Id;
        projectTask2.buildertek__Duration__c=10;
        projectTask2.buildertek__Phase__c='Candidate Selection';
        projectTask2.buildertek__Lag__c=0;
        projectTask2.buildertek__Milestone__c =false;
        projectTask2.buildertek__Contractor__c=acc.Id;
        projectTask2.buildertek__Resource__c =con.Id;
        projectTask2.buildertek__Contractor_Resource__c  =con.Id;
        projectTask2.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask2.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        projectTask2.buildertek__Dependency__c=projectTask1.Id;


        insert projectTask2;
        projectTaskList.add(projectTask1);
        projectTaskList.add(projectTask2);


        Map<String,buildertek__Project_Task__c []> oppMap = new Map<String, buildertek__Project_Task__c[]>();
        oppMap.put('test',projectTaskList);
        string expected='[ { Name} , {buildertek__Schedule__c} , {buildertek__Finish__c} ,{ buildertek__Start__c} ,buildertek__Duration__c , buildertek__Phase__c, buildertek__Milestone__c } ]';
        String jsondata='[{"Name":"Test" , "buildertek__Phase__c":"Candidate Selection"}]';

        Map<Id,buildertek__Project_Task__c > projectMap = new Map<Id, buildertek__Project_Task__c>();
        projectMap.put(projectTask2.Id,projectTask2);

     Test.startTest();
        ProjectTaskTriggerHandler.blnSkipTaskTrigger=true;
        // FieldsetUtilityClass.getFieldFromFieldSet('buildertek__Project_Task__c' ,jsondata );
        // FieldsetUtilityClass.FieldSetProperties fieldWrapper = new .FieldSetProperties();
        // fieldWrapper.label='Name';
        // fieldWrapper.fieldName='test';
        // fieldWrapper.type='test';

        ScheduleIteminlineEditcontroller.getRecords('buildertek__Project_Task__c' , 'Name' , schedule1.Id , expected  );
        ScheduleIteminlineEditcontroller.updateprojeccttasksDuplicate(expected , schedule1.Id , 1 );
        ScheduleIteminlineEditcontroller.getDataTableDetails('buildertek__Project_Task__c' , 'buildertek__Schedule_Item_field_set' ,  schedule1.Id);
        ScheduleIteminlineEditcontroller.updateTaskOrder(expected , 1 );
        ScheduleIteminlineEditcontroller.UPandINTaskOrder(jsondata , schedule1.Id , 1 );
        ScheduleIteminlineEditcontroller.updateprojeccttasks(projectTaskList );
        ScheduleIteminlineEditcontroller.getFieldSet('buildertek__Projectrr_Task__c' , 'TEST',schedule1.Id);



     Test.stopTest();


    }

    @isTest static void testMethod3 (){
        Account acc = new Account();
        acc.Name='test';
        insert acc;

        Contact con = new Contact();
        con.LastName='test';
        con.FirstName='testmthod';
        con.Email='test@test.com';
        con.AccountId=acc.Id;
        insert con;



        buildertek__Schedule__c schedule1 = new buildertek__Schedule__c();
        insert schedule1;

        List<buildertek__Project_Task__c> projectTaskList = new List<buildertek__Project_Task__c>();
        buildertek__Project_Task__c projectTask1 = new buildertek__Project_Task__c();
        projectTask1.Name='test Task';
        projectTask1.buildertek__Schedule__c=schedule1.Id;
        DateTime dt= System.now();
        projectTask1.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask1.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        projectTask1.buildertek__Duration__c=10;
        projectTask1.buildertek__Phase__c=null;
        projectTask1.buildertek__Lag__c=0;
        projectTask1.buildertek__Milestone__c =false;
        projectTask1.buildertek__Contractor__c=acc.Id;
        projectTask1.buildertek__Resource__c =con.Id;
        projectTask1.buildertek__Contractor_Resource__c  =con.Id;
        insert projectTask1;

        buildertek__Project_Task__c projectTask2 = new buildertek__Project_Task__c();
        projectTask2.Name='test Task';
        projectTask2.buildertek__Schedule__c=schedule1.Id;
        projectTask2.buildertek__Duration__c=10;
        projectTask2.buildertek__Phase__c=null;
        projectTask2.buildertek__Lag__c=0;
        projectTask2.buildertek__Milestone__c =false;
        projectTask2.buildertek__Contractor__c=acc.Id;
        projectTask2.buildertek__Resource__c =con.Id;
        projectTask2.buildertek__Contractor_Resource__c  =con.Id;
        projectTask2.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask2.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        projectTask2.buildertek__Dependency__c=projectTask1.Id;


        insert projectTask2;
        projectTaskList.add(projectTask1);
        projectTaskList.add(projectTask2);


        Map<String,buildertek__Project_Task__c []> oppMap = new Map<String, buildertek__Project_Task__c[]>();
        oppMap.put('test',projectTaskList);
        string expected='[ { Name} , {buildertek__Schedule__c} , {buildertek__Finish__c} ,{ buildertek__Start__c} ,buildertek__Duration__c , buildertek__Phase__c, buildertek__Milestone__c } ]';
        String jsondata='[{"Name":"Test" , "buildertek__Phase__c":"Candidate Selection"}]';

        Map<Id,buildertek__Project_Task__c > projectMap = new Map<Id, buildertek__Project_Task__c>();
        projectMap.put(projectTask2.Id,projectTask2);

     Test.startTest();
        ProjectTaskTriggerHandler.blnSkipTaskTrigger=true;
        ScheduleIteminlineEditcontroller.getDataTableDetails('buildertek__Project_Task__c' , 'buildertek__Schedule_Item_field_set' ,  schedule1.Id);


     Test.stopTest();


    }

    
}