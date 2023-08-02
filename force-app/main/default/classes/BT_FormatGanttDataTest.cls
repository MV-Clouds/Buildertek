@isTest
public  class BT_FormatGanttDataTest {
    
    @isTest static void testmethod1(){

        Account acc = new Account();
        acc.Name='test';
        insert acc;

        Contact con = new Contact();
        con.LastName='test';
        con.FirstName='testmthod';
        con.Email='test@test.com';
        con.AccountId=acc.Id;
        insert con;

        buildertek__Project__c project1=new buildertek__Project__c();
        project1.Name='project1 Test';
        insert project1;


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
        projectTask2.Name='test Task project 2 ';
        projectTask2.buildertek__Schedule__c=schedule1.Id;
        projectTask2.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask2.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        projectTask2.buildertek__Duration__c=20;
        projectTask2.buildertek__Phase__c='Candidate Selection';
        projectTask2.buildertek__Lag__c=0;
        projectTask2.buildertek__Milestone__c =false;
        projectTask2.buildertek__Contractor__c=acc.Id;
        projectTask2.buildertek__Resource__c =con.Id;
        projectTask2.buildertek__Contractor_Resource__c  =con.Id;
        projectTask2.buildertek__Dependency__c=projectTask1.Id;
        insert projectTask2;


        
        projectTaskList.add(projectTask1);
        projectTaskList.add(projectTask2);

        Test.startTest();
        BT_FormatGanttData.formatScheduleData(projectTaskList , schedule1 );
        // BT_FormatGanttData.cls_children child = new BT_FormatGanttData.cls_children();
        // child.id=con.Id;
        // child.name='test';
        // child.percentDone=50;
        // child.startDate='2019-01-14';
        // child.duration=1;
        // child.endDate='2019-01-14';
        // child.type='Task';
        // child.phase='test';
        // child.constraintType='test';
        // child.expanded=true;
        // child.predecessor='test';
        // child.internalresource='test';
        // child.internalresourcename='test';
        // child.contractorresource='test';
        // child.order=10;
        // child.lag=1;
        // child.contractoracc='test';
        // child.notes='test';
        // child.milestone=true;
        // child.contractorname='test';

        BT_FormatGanttData.cls_children child = new BT_FormatGanttData.cls_children();
        Test.stopTest();

    }

    @isTest static void testmethod2(){

        Account acc = new Account();
        acc.Name='test';
        insert acc;

        Contact con = new Contact();
        con.LastName='test';
        con.FirstName='testmthod';
        con.Email='test@test.com';
        con.AccountId=acc.Id;
        insert con;

        buildertek__Project__c project1=new buildertek__Project__c();
        project1.Name='project1 Test';
        insert project1;


        buildertek__Schedule__c schedule1 = new buildertek__Schedule__c();
        insert schedule1;


      List<buildertek__Project_Task__c> projectTaskList = new List<buildertek__Project_Task__c>();

        buildertek__Project_Task__c projectTask1 = new buildertek__Project_Task__c();
        projectTask1.Name='test Task';
        projectTask1.buildertek__Schedule__c=schedule1.Id;
        DateTime dt= System.now();
        // projectTask1.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask1.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        // projectTask1.buildertek__Duration__c=10;
        projectTask1.buildertek__Phase__c=null;
        // projectTask1.buildertek__Lag__c=0;
        // projectTask1.buildertek__Milestone__c =false;
        // projectTask1.buildertek__Contractor__c=acc.Id;
        // projectTask1.buildertek__Resource__c =con.Id;
        // projectTask1.buildertek__Contractor_Resource__c  =con.Id;
insert projectTask1;

        buildertek__Project_Task__c projectTask2 = new buildertek__Project_Task__c();
        projectTask2.Name='test Task project 2 ';
        projectTask2.buildertek__Schedule__c=schedule1.Id;
        // projectTask2.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
        projectTask2.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
        // projectTask2.buildertek__Duration__c=20;
        projectTask2.buildertek__Phase__c=null;
        // projectTask2.buildertek__Lag__c=0;
        // projectTask2.buildertek__Milestone__c =false;
        // projectTask2.buildertek__Contractor__c=acc.Id;
        // projectTask2.buildertek__Resource__c =con.Id;
        // projectTask2.buildertek__Contractor_Resource__c  =con.Id;
        // projectTask2.buildertek__Dependency__c=projectTask1.Id;
        insert projectTask2;


        
        projectTaskList.add(projectTask1);
        projectTaskList.add(projectTask2);

        Test.startTest();
        BT_FormatGanttData.cls_children child ;
        System.debug(child);
        BT_FormatGanttData.formatScheduleData(projectTaskList , schedule1 );
      
        Test.stopTest();

    }
}