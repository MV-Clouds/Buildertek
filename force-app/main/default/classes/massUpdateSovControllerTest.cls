@isTest
public with sharing class massUpdateSovControllerTest {
    @TestSetup
    static void massUpdate() {

        buildertek__Schedule_of_Values__c schedule = new buildertek__Schedule_of_Values__c();
        schedule.Name = 'Test';
        schedule.buildertek__Status__c = 'Customer Approved';
        insert schedule;

        buildertek__Schedule_of_Value_Lines__c svLine = new buildertek__Schedule_of_Value_Lines__c();
        svLine.buildertek__Item__c = '10';
        svLine.buildertek__Status__c = 'Approved';
        svLine.buildertek__Schedule_of_Values__c = schedule.Id;
        svLine.buildertek__Item_New__c = 6;
        svLine.buildertek__Description_of_Work__c = 'test';
        insert svLine;
    }
    @isTest
    static void massUpdate1(){

        List<buildertek__Schedule_of_Values__c> schedule = [SELECT Id, Name FROM buildertek__Schedule_of_Values__c LIMIT 1];

        List<buildertek__Schedule_of_Value_Lines__c> svLine = [SELECT Id, Name FROM buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: schedule[0].Id];

        List<String> budgetIds = new List<String>{'a4KG10000000P4rMAE'};
        String fieldNameJson = '';

        massUpdateSovController.getFieldSet();
        massUpdateSovController.getRecords(schedule[0].Id,fieldNameJson,2,3);
        massUpdateSovController.getCount(schedule[0].Id);
        massUpdateSovController.getSOVName(budgetIds,schedule[0].Id);
        massUpdateSovController.getUser();
        massUpdateSovController.isSovSubmitted(schedule[0].Id);
        massUpdateSovController.massDeleteProjectTask(budgetIds,'abcd','test set',2,3);
        massUpdateSovController.updateRecords(schedule[0].Id,JSON.serialize(svLine),'[]',2,3);
    }
    @isTest
    static void massUpdate2(){
        massUpdateSovController.updateRecords('','','[]',2,3);
		massUpdateSovController.getRecords('','[]',2,3);
        massUpdateSovController.getCount('');
    }
}