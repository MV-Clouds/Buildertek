@isTest
public class Test_MeetingTriggerHandler {
    @isTest 
    public static void testMeetingUpdateEndTime() {
        Time myTime = Time.newInstance(1, 30, 0, 0);
        Date myDate = System.today();
        buildertek__Meeting__c meetng = new buildertek__Meeting__c(buildertek__Subject__c = 'TestSubject123', buildertek__Meeting_Date__c = myDate, buildertek__Duration__c = '30', buildertek__Start_Time__c = myTime);
        insert meetng;

        meetng.buildertek__Duration__c = '90';
        meetng.buildertek__Start_Time__c = null;
        update meetng;
    }
}