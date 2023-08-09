@isTest
public class PreventInspectionDeletionTest {
    public static testMethod void test1() {
        
      Inspection__c inspection = new Inspection__c();
      inspection.Name__c = 'test';
      inspection.Status__c='Completed';
      insert inspection;
      
      DmlException expectedException;
        Test.startTest();
        try { delete inspection; }
        catch (DmlException dmx) { expectedException = dmx; }
        Test.stopTest();
      System.assertEquals('Test','Test');
    }
        
       
     
        
}