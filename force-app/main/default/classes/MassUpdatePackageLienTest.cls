@isTest
public class MassUpdatePackageLienTest {
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;  
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        insert project;
        
        buildertek__Package__c packageRec = new buildertek__Package__c();
        insert packageRec;
        
        buildertek__Package_Line__c packageItems = new buildertek__Package_Line__c();
        packageItems.buildertek__Package_Name__c  = packageRec.Id;
        insert packageItems;
    }
    
    @isTest
    static void testMethod1(){
        List<buildertek__Package__c> packageRec = [Select Id
                                                  FROM buildertek__Package__c
                                                  LIMIT 1];
        List<buildertek__Package_Line__c> packageItems = [Select Id
                                                            FROM buildertek__Package_Line__c WHERE buildertek__Package_Name__c  =: packageRec[0].Id];
        
        
        MassUpdatePackageLien updaterecord = new MassUpdatePackageLien();
        MassUpdatePackageLien.getRecords(packageRec[0].Id,1,1);
        MassUpdatePackageLien.updateRecords(packageRec[0].Id,'[]',1,1);
        MassUpdatePackageLien.deleteRecords(packageItems[0].Id,packageRec[0].Id,1,1);
    }
}