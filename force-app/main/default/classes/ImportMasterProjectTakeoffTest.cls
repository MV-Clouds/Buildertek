@isTest
public class ImportMasterProjectTakeoffTest {
     public static testMethod void test1() {
        Contact c = new Contact();
        c.LastName='Test';
        c.email='test@gmail.com'; 
		insert c;        

        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        buildertek__Project_Takeoff__c tc = new buildertek__Project_Takeoff__c();
        tc.Type__c = 'Master';
        tc.Project__c = proj.Id;
        tc.buildertek__Name__c = 'Test line';
        insert tc; 
        
        list<string> tcIds = new list<string>();
        list<buildertek__Project_Takeoff_Lines__c> tcItemlist = new list<buildertek__Project_Takeoff_Lines__c>();
        buildertek__Project_Takeoff_Lines__c tcItem =new  buildertek__Project_Takeoff_Lines__c();
        tcItem.buildertek__Description__c  = 'test';
        tcItem.buildertek__Project_Takeoff__c = tc.Id;
        tcItemlist.add(tcItem);
        insert tcItemlist; 
        tcIds.add(tc.Id); 
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(tc);
        //ImportMasterSchedules impsch = new ImportMasterSchedules(sc);
        ImportMasterProjectTakeoff.MasterProjectTakeoffClass impmaster = new ImportMasterProjectTakeoff.MasterProjectTakeoffClass();
        ImportMasterProjectTakeoff.getMasterProjectTakeoff(tc.Id);
        ImportMasterProjectTakeoff.importMasterProjecttakeoffLines(tcIds, tc.Id);
        System.assertEquals('Test','Test');
        
        
        
        
    }
    


}