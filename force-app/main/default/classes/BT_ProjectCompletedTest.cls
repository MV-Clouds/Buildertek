@isTest
public class BT_ProjectCompletedTest {
     public static testMethod void test1() {
         buildertek__Project__c proj = new buildertek__Project__c();
          proj.buildertek__Stage__c = 'Completed';
        proj.buildertek__Actual_Completion_Date__c = system.today();
        proj.buildertek__Project_Completion__c = 100;
         insert proj;
         
         BT_Project_Completed.UpdateProjects(proj.Id);
         BT_Project_Completed.insertProjects(proj.Id);
         
    
     }
}