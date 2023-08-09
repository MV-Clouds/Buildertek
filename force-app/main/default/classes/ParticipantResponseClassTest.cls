@isTest
public class ParticipantResponseClassTest {
    @testSetup
    static void ParticipantsControllersetup() {
        Training_Settings__c tr=new Training_Settings__c();
        tr.Name='Training Settings';
        tr.Registration_Email_Template__c='Registration Email';
        tr.Registration_Completed_Email_Template__c ='Registration Completed';
        tr.Course_Completed_Email_Template__c='Course Completed';
        insert tr;
        
        buildertek__Checklist_Objects__c checkobj = new buildertek__Checklist_Objects__c ();
        checkobj.Name='Checklist Logo';
        insert checkobj ;
        
        Account acc = new Account(Name='Test Acc');
        insert acc;
             
        Contact con = new Contact(LastName='Test',AccountId=acc.Id,Email='test.test@gmail.com');
        insert con;
        
        Course__c Course = new Course__c(Name='Course');
        insert Course;
        
        Course_Session_Scheduling__c CSREC = new Course_Session_Scheduling__c(Name='Test Course',
                                                                              Course_Name__c=Course.Id,
                                                                              Session_Date__c=system.today());
        insert CSREC;
        
        Session_Participant__c SessionParticipantRec = new Session_Participant__c(Participant_Name__c=con.Id,
                                                                                  Participant_Company__c=acc.Id,
                                                                                  Course_Session_Scheduling__c=CSREC.Id,
                                                                                  Is_Participant_Attending__c='Yes');
        insert SessionParticipantRec;
       // ParticipantResponseClass.sendEmialToParticipants(SessionParticipantRec.id,'Registration Email');
    }
    static testMethod void test() {        
        List<Course_Session_Scheduling__c> CSSlist = [select id,Name,Course_Name__c,Course_Name__r.Name,Session_Date__c from Course_Session_Scheduling__c limit 1];
        List<Session_Participant__c> sp = [select id,Participant_Name__c,Is_Participant_Attending__c,Participant_Company__c,Course_Session_Scheduling__c from Session_Participant__c limit 1];
       
        test.startTest();
        ParticipantResponseClass.getCousreDetails(sp[0].Id);
        ParticipantResponseClass.getparticipant(sp[0].Id);
        ParticipantResponseClass.savesessionobj(sp[0].Id,'y','t','t','t','t','test.test@gmail.com','t','t','t','t','t','test');
        ParticipantResponseClass.savesessionobj(sp[0].Id,'n','t','t','t','t','test.test@gmail.com','t','t','t','t','t','test');
        ParticipantResponseClass.getTrainingSettings();
        //ParticipantResponseClass.getAttachmentData();
        ParticipantResponseClass.sendEmialToParticipants('sp','Registration Email');
        
        test.stopTest();
    }
}