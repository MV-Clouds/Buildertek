@isTest
public class QuestionsTriggerHandlerTest {
    public static testMethod void testQuestionTriggerHandler() {
        buildertek__Questions__c qt = new buildertek__Questions__c();
        qt.buildertek__Customize__c = 'test Question?';
        qt.buildertek__Question_Type__c = 'Text Response';
        insert qt;
        
        buildertek__Checklist_Questions__c cqt = new buildertek__Checklist_Questions__c();
        cqt.buildertek__Questions__c = qt.id;
        insert cqt;
        
        qt.buildertek__Customize__c = 'test';
        update qt;
    }
}