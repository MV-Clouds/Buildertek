@isTest
private class bryntumGanttControllerTest {

    @testSetup static void setup() {
        Account acc = new Account();
        acc.Name='test';
        insert acc;

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name='Project Name';
        project.buildertek__Customer__c=acc.Id;
        insert project;


        buildertek__Schedule__c schedule = new buildertek__Schedule__c();
        schedule.buildertek__Description__c='Test Description';
        schedule.buildertek__Type__c='Standard';
        insert schedule;

        ProjectTaskTriggerHandler.blnSkipTaskTrigger=true;

        buildertek__Project_Task__c scheduleItem = new buildertek__Project_Task__c();
        scheduleItem.buildertek__Schedule__c = schedule.Id;
        scheduleItem.Name='Test';
        scheduleItem.buildertek__Start__c = Date.today();
        scheduleItem.buildertek__Phase__c='Carpet/Cleaning';
        scheduleItem.buildertek__Duration__c=2;
        insert scheduleItem;



    }

    public static testMethod void testMethod1() {

        String userId = UserInfo.getUserId();
        buildertek__Project__c project= [Select Id , Name , buildertek__Customer__c   From buildertek__Project__c LIMIT 1];
        buildertek__Schedule__c schedule= [Select Id , Name , buildertek__Description__c , buildertek__Project__c From buildertek__Schedule__c LIMIT 1];
        List<buildertek__Project_Task__c> scheduleItemList= [Select Id , Name , buildertek__Schedule__c , buildertek__Start__c , buildertek__Project__c From buildertek__Project_Task__c];


        buildertek__Schedule__c scheduleRec = new buildertek__Schedule__c();
        scheduleRec.buildertek__Description__c='Test Description';
        scheduleRec.buildertek__Project__c=project.Id;
        insert scheduleRec;

            
        Test.startTest();
        bryntumGanttController.getScheduleWrapperAtLoading(schedule.Id);
        bryntumGanttController.getAccounts(1,2,'Test' , 'Test');
        bryntumGanttController.getContacts('Test' , 'Test' , 'Test');
        bryntumGanttController.searchProject('Test');
        bryntumGanttController.getFieldSet();
        bryntumGanttController.getDropDown('buildertek__Type__c');
        bryntumGanttController.fetchScheduleList();
        bryntumGanttController.searchUsers('Buildertek');
        bryntumGanttController.getScheduleItemList(scheduleRec.Id);
        bryntumGanttController.createNewSchedule('Test' , project.Id , date.today(),'Standard' , userId , scheduleRec.Id);
        bryntumGanttController.createScheduleLineFromMasterSchedule(scheduleRec.Id , schedule.Id , date.today());
        bryntumGanttController.addDaysSkippingWeekends('Test' , date.today() , 3);
        Test.stopTest();
    }
}