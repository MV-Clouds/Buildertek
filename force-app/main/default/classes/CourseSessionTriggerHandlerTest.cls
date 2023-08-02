@isTest
public class CourseSessionTriggerHandlerTest {
    static testMethod void CourseSesionHandler(){
        Map<Id,Course_Session_Scheduling__c> oldmap = new Map<Id,Course_Session_Scheduling__c>();
        buildertek__Course__c CR = new buildertek__Course__c();
        CR.Name = 'CrTest';
        insert CR;
        List<Course_Session_Scheduling__c> CourseSesesion = new List<Course_Session_Scheduling__c>();
        Course_Session_Scheduling__c CS =  new Course_Session_Scheduling__c();
        CS.Name = 'Test';
        CS.Course_Name__c = CR.Id;
        CourseSesesion.add(CS);
        insert CourseSesesion;
        
        oldmap.put(CS.id,CS);
        CS.Name = 'Test01';
        
        Contact con=new Contact();
        con.LastName='Test';
        insert con;
         List<Session_Participant__c> Session = new List<Session_Participant__c>();
        Session_Participant__c SS =  new Session_Participant__c();        
        SS.Course_Session_Scheduling__c = CS.Id;
        SS.buildertek__Participant_Name__c=con.Id;
        Session.add(SS);
        insert Session;
        
        update CS;    
        Test.startTest();
        CourseSessionTriggerHandler.updateParticipantsCount(CourseSesesion,oldmap);
        CourseSessionTriggerHandler.deleteMethod(CourseSesesion);
        Test.stopTest();
        
    }

}