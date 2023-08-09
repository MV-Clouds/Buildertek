@isTest
public class RegistrationEmailControllerTest {
    static testMethod void test(){
        Test.startTest();
        Account acc = new Account(Name='Test Acc');
        insert acc;
        
         Contact con = new Contact(LastName='Test',AccountId=acc.Id,Email='test.test@gmail.com');
        insert con;
        
        Course__c Course = new Course__c(Name='Course');
        insert Course;
        
        buildertek__Course_Session_Scheduling__c CSREC = new buildertek__Course_Session_Scheduling__c(Name='Test Course',
                                                                                                      buildertek__Course_Name__c=Course.Id,
                                                                                                      buildertek__Session_Date__c=system.today(),
                                                                                                      buildertek__Session_Duration__c = '2 weeks'
                                                                                                      );
        insert CSREC;
        
        buildertek__MSA_Settings__c MSA = new buildertek__MSA_Settings__c();
        MSA.Name = 'TestMSA';
        MSA.buildertek__Site_URL__c = 'test';
        insert MSA;
        
        buildertek__Session_Participant__c SessionParticipantRec = new buildertek__Session_Participant__c(buildertek__Participant_Name__c=con.Id,
                                                                                                          buildertek__Participant_Company__c=acc.Id,
                                                                                                          buildertek__Course_Session_Scheduling__c=CSREC.Id,
                                                                                                          buildertek__Is_Participant_Attending__c='Yes');
        insert SessionParticipantRec;
        system.debug('SessionParticipantRec--------'+SessionParticipantRec);
        
      
        RegistrationEmailController RC = new  RegistrationEmailController();
        MSA = RC.MsaUrl ; 
        RC.objectType = 'buildertek__Session_Participant__c';
        
        //RC.SesRec = SessionParticipantRec;  
        RC.RecId = SessionParticipantRec.Id;
        SessionParticipantRec = RC.SesRec ;
        test.stopTest();
    }
    
}