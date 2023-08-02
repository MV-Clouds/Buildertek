@isTest
public class MassUpdateMasterSelectionTest{
    @testSetup
    static void setupMethod(){
        
        
        buildertek__Project_Selection_Sheet_Takeoff__c selectsheettakeoff = new buildertek__Project_Selection_Sheet_Takeoff__c();
        insert selectsheettakeoff; 
        
        buildertek__Select_Sheet__c selectSheet = new buildertek__Select_Sheet__c();
        selectSheet.buildertek__Selection_Sheet_Takeoff__c = selectsheettakeoff.Id;
        insert selectSheet;
    }
    
    @isTest
    static void testMethod1(){
        List<buildertek__Select_Sheet__c> selectSheet = [Select Id
                                                         FROM buildertek__Select_Sheet__c
                                                         LIMIT 1];
        List<buildertek__Project_Selection_Sheet_Takeoff__c> selectsheettakeoff = [Select Id
                                                                                   FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                   LIMIT 1];
        MassUpdateMasterSelection updaterecord = new MassUpdateMasterSelection();
        MassUpdateMasterSelection.getCount(selectsheettakeoff[0].Id);
        MassUpdateMasterSelection.getName(selectsheettakeoff[0].Id);
        MassUpdateMasterSelection.getParentId(selectsheettakeoff[0].Id);
        MassUpdateMasterSelection.getFieldSet();
        MassUpdateMasterSelection.getRecords(selectsheettakeoff[0].Id,'[]',1,1,'d','c','u','u');
        MassUpdateMasterSelection.updateRecords(selectsheettakeoff[0].Id,'[]','[]',1,1,'d','c','u','u');
        MassUpdateMasterSelection.deleteProject(selectSheet[0].Id,selectsheettakeoff[0].Id,'[]',1,1,'d','c','u','u');
    }
}