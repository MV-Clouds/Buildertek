@isTest
public class ParticipantsControllerTest {
    @testSetup
    static void ParticipantsControllersetup() {
        Account acc = new Account(Name='Test Acc');
        insert acc;
        
        Contact con = new Contact(LastName='Test',AccountId=acc.Id,Email='sowndarya.nittala@diligentforcelabs.com');
        insert con;
        
        Course__c CourseRec = new Course__c(Name='Test Course');
        insert CourseRec;
        
        Course_Session_Scheduling__c CourseSessionSchedulingRec = new Course_Session_Scheduling__c(Name='Test Course',
                                                                                                   Course_Name__c=CourseRec.Id);
        insert CourseSessionSchedulingRec;
        
        Session_Participant__c SessionParticipantRec = new Session_Participant__c(Participant_Name__c=con.Id,
                                                                                  Participant_Company__c=acc.Id,
                                                                                  Course_Session_Scheduling__c=CourseSessionSchedulingRec.Id);
        insert SessionParticipantRec;
         Session_Participant__c SessionParticipantRec1 = new Session_Participant__c(Participant_Name__c=con.Id,
                                                                                  Participant_Company__c=acc.Id,
                                                                                  Course_Session_Scheduling__c=CourseSessionSchedulingRec.Id);
        insert SessionParticipantRec1;
    }
    static testMethod void ParticipantsControllerTest() {
        Contact con = [select id,name,Email,AccountId,Account.Name from Contact];
        Course_Session_Scheduling__c CSSRec = [select id,Name,Course_Name__c from Course_Session_Scheduling__c];
        List<Session_Participant__c> SPRec = [select id,Participant_Name__c,Participant_Name__r.Email,Participant_Company__c,Course_Session_Scheduling__c from Session_Participant__c];
        test.startTest();
        ParticipantsController.getParticipantAccount(con.Id);
        ParticipantsController.checkDuplicateSessions(con.Id,CSSRec.Id);
        ParticipantsController.getParticipants(CSSRec.Id);
        list<Object> records = new list<Object>();       
        map<Object,Object> mappingrec1 = new map<Object,Object>();
        mappingrec1.put('RowNumber', '1');
        mappingrec1.put('ParticipantName', SPRec[0].Participant_Name__c);
        mappingrec1.put('ParticipantCompany', SPRec[0].Participant_Company__c);
        mappingrec1.put('ParticipantAttended', 'No');
        mappingrec1.put('ParticipantScore', '');
        mappingrec1.put('CourseCompleted', 'No');
        mappingrec1.put('Notes', '');
        mappingrec1.put('ContactSelectedValue', '');
        mappingrec1.put('AccountSelectedValue', '');
        mappingrec1.put('showContactLookup', true);
        mappingrec1.put('showAccountLookup', true);
        records.add(mappingrec1);
        ParticipantsController.saveParticipants(records,CSSRec.Id);
        test.stopTest();
    }
}