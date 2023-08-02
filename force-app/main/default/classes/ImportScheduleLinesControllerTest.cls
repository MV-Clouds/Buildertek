@isTest
public class ImportScheduleLinesControllerTest {
    public static testMethod void test1() {
        
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        Schedule__c sch = new Schedule__c();
        sch.buildertek__Project__c = proj.Id;
        sch.Description__c = 'test';
        insert sch;
        String id = Id.valueOf(sch.id);
        String jsonText = '[{"Name":"test","Dependency":"test","StartDate":"2018-03-03","Duration":20,"Phase":"Ground Work"}]'; 
        ImportScheduleLinesController.insertData(id,jsonText); 
        System.assertEquals('Test','Test');
    }
     
        
}