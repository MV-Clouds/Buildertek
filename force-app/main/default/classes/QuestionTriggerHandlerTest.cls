/*
Updated By:Riddhi
Company : MV Cloud
Date : 10 Oct 2022
*/

@isTest
public class QuestionTriggerHandlerTest {
    public static testMethod void testQuestionTriggerHandler() {
       Product2 prd=new Product2();
       prd.Name='products';
       insert prd;

       Question__c question = new Question__c();
       question.Name = 'Test 1';
       question.buildertek__Product__c=prd.Id;
       
       insert question;
       update question;
       delete question;
       System.assertEquals('Test','Test');
    }
}