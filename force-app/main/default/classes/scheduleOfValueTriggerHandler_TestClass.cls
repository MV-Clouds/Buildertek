@isTest
public class scheduleOfValueTriggerHandler_TestClass {
    
    
    static testMethod void isAfterUpdate() {
        
     //   list<buildertek__Schedule_of_Values__c> SovList = new list<buildertek__Schedule_of_Values__c>();
        Test.startTest();
        
        buildertek__Schedule_of_Values__c testSOV = new buildertek__Schedule_of_Values__c();
        testSOV.Name = 'test SOV';
        testSOV.buildertek__Status__c = 'Pending';
        insert testSOV;
      //  SovList.add(testSOV);
        
        buildertek__Schedule_of_Value_Lines__c testSOVLine = new buildertek__Schedule_of_Value_Lines__c();
        testSOVLine.buildertek__Schedule_of_Values__c = testSOV.Id;
        testSOVLine.buildertek__Description_of_Work__c = 'Test Work';
        insert testSOVLine;
        
        testSOV.buildertek__Status__c = 'Company Approved';
        update testSOV;
        
       
        testSOVLine.buildertek__Status__c = 'Approved';
        
        update testSOVLine;
        
       
        Test.stopTest();
        
        
    }
}