@isTest
public class ParticipantUpdatesControllerTest {
    static testMethod void test() {
        Account acc = new Account(Name='Test Acc');
        insert acc;
        
        buildertek__Training_Settings__c TrainSeetings = new buildertek__Training_Settings__c();
        TrainSeetings.Name = 'TestTrain';
        TrainSeetings.buildertek__Course_Completed_Email_Template__c = 'Registration Completed';
        TrainSeetings.buildertek__Registration_Email_Template__c = 'Course Completed';
        insert TrainSeetings;
        
        Contact con = new Contact(LastName='Test',AccountId=acc.Id,Email='test@gmail.com',Skill_Level__c ='Level 3 – Field Service Technician');
        insert con;
        Course__c course=new Course__c(Name='Test Course',Course_Length__c='8hr');
        insert course;
        Course_Session_Scheduling__c CourseSessionSchedulingRec = new Course_Session_Scheduling__c(Name='Test Course',Course_Name__c=course.Id,Session_Date__c=System.today(),Session_Duration__c='5');

        insert CourseSessionSchedulingRec;
        
        Session_Participant__c SessionParticipantRec = new Session_Participant__c(Participant_Name__c=con.Id,
                                                                                  Participant_Company__c=acc.Id,
                                                                                  Is_Participant_Attending__c='Yes',
                                                                                  Course_Completion_Date__c=system.today(),
                                                                                  Course_Session_Scheduling__c=CourseSessionSchedulingRec.Id
                                                                                  );
        insert SessionParticipantRec;
        List<Session_Participant__c> splist=new List<Session_Participant__c>();
      List<Id> ids=new List<Id>();
        ids.add(SessionParticipantRec.Id);
        splist.add(SessionParticipantRec);        
        test.startTest();
        ParticipantUpdatesController.getParticipants(CourseSessionSchedulingRec.Id);
        list<Object> records = new list<Object>();       
        map<Object,Object> mappingrec1 = new map<Object,Object>();
         mappingrec1.put('RowNumber', 1);
         mappingrec1.put('RecordId', SessionParticipantRec.Id);
        mappingrec1.put('ParticipantName', con.Id);
        mappingrec1.put('ParticipantEmail', 'test@gmail.com');
        mappingrec1.put('ParticipantCompanyId', acc.Id);
        mappingrec1.put('ParticipantScore', 20);
        mappingrec1.put('CourseCompleted', 'No');
        mappingrec1.put('CourseCompletionDate', system.today());
        mappingrec1.put('ParticipantAttended', 'Yes');
        mappingrec1.put('ParticipantAttended', 'Yes');
        records.add(mappingrec1);
        ParticipantUpdatesController.updateParticipants(records,ids);
        ParticipantUpdatesController.getCourseSession(CourseSessionSchedulingRec.id);
         ParticipantUpdatesController.getCourse(CourseSessionSchedulingRec.id);
        ParticipantUpdatesController.readFieldSet();
        ParticipantUpdatesController.getSkillLevel();
        ParticipantUpdatesController.sendEmialToParticipants(ids,'TestTemp');
        ParticipantUpdatesController.setAttachmentBody(CourseSessionSchedulingRec.Id,CourseSessionSchedulingRec.Id);
        //ParticipantUpdatesController.sendRegCompletionMail(SessionParticipantRec.Id);
        ParticipantUpdatesController.deleteparticipant(splist);        
        ParticipantUpdatesController.resendEmialToParticipants(SessionParticipantRec.Id,'TestTemp');
        ParticipantUpdatesController.getParticipantName(SessionParticipantRec.Id);
        String recids=string.valueOf(SessionParticipantRec.Id);
       // ParticipantUpdatesController.sendCourseCompletionEmail(recids);
        //ParticipantsCount.attendedParticipants(splist, oldTrigger);
        //ParticipantsCount.countOfParticipants(splist);
        
        test.stopTest();
        
    }
}