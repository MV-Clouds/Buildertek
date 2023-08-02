@isTest
private class importScheduleLineControllerTest {

    public static testMethod void testMethod1() {
        buildertek__Schedule__c schedule = new buildertek__Schedule__c();
        schedule.buildertek__Description__c='Test Description';
        schedule.buildertek__Type__c='Standard';
        insert schedule;
        String csv = '[{"Name":"Internal Design Concepts","Dependency":"","StartDate":"2024-05-04","Duration":"30","percentComplete":"0","Phase":"Plan Submission","Notes":"","Lag":"0","ID":"PT - 0"}]';
        
        Test.startTest();
        ImportScheduleLineController.insertData(schedule.Id, csv);
        Test.stopTest();
    }
}