@isTest
public class ParticipantsCountTest {
    @testSetup
    static void ParticipantsCountsetup() {
        Contact con = new Contact(LastName='Test Con');
        insert con;
        
        Course__c CourseRec = new Course__c(Name='Test');
        insert CourseRec;
        
        Course_Session_Scheduling__c CSSRec = new Course_Session_Scheduling__c();
        CSSRec.buildertek__Course_Name__c = CourseRec.Id;
        insert CSSRec;
        
        Session_Participant__c SPRec = new Session_Participant__c();
        SPRec.buildertek__Participant_Name__c = con.id;
        SPRec.buildertek__Course_Session_Scheduling__c = CSSRec.Id;
        SPRec.buildertek__Participant_Attended__c='Yes';
        insert SPRec;
    }
    static testMethod void ParticipantsCountTest() {
        List<Session_Participant__c> SpRecList= [select id,buildertek__Participant_Name__c,Course_Session_Scheduling__c,Participant_Attended__c from Session_Participant__c];
        Set<Id> updateSessionIds = new Set<Id>();
        Set<Id> updateCourseIds = new Set<Id>();
        test.startTest();
        ParticipantsCount.calculateCourseParticipants(SpRecList,updateSessionIds,updateCourseIds);
        Map<Id,Session_Participant__c> oldTrigger = new Map<Id,Session_Participant__c>();
        ParticipantsCount.updateParticipants(SpRecList,oldTrigger);
        ParticipantsCount.deleteParticipants(SpRecList);
        test.stopTest();
    }
}