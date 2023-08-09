@isTest
private class TimecardTriggerTest {
    @isTest static void testMethod1() {
        Contact c= new Contact();
        c.lastName='test';
        c.Email='test@gmail.com';
        insert c; 
        
        buildertek__Time_Cards__c timecard =new buildertek__Time_Cards__c();
        timecard.buildertek__Start_Time__c = system.now();
        timecard.buildertek__End_Time__c = system.now()+1;
        timecard.buildertek__Resource__c=c.Id;
        insert timeCard;
        TimeCardTriggerHandler handler = new TimeCardTriggerHandler(true,1);
    }
    
    @isTest static void testMethod2() {
        Contact c= new Contact();
        c.lastName='test';
        c.Email='test@gmail.com';
        insert c; 
        buildertek__Time_Cards__c timecard =new buildertek__Time_Cards__c();
        timecard.buildertek__Start_Time__c = system.now();
        timecard.buildertek__Resource__c=c.Id;
        insert timeCard;
        TimeCardTriggerHandler handler = new TimeCardTriggerHandler(true,1);
    }
}