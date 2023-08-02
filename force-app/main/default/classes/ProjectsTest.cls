@isTest
public class ProjectsTest {
     private static testMethod void getproject() {
        
         List<buildertek__Project__c> projList = new List<buildertek__Project__c>();
       buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        proj.buildertek__Project_Id__c=proj.id;
        projList.add(proj); 
        insert projList;
        
       // List<String> selectedIds = new List<String>();
        //selectedIds.add(purList[0].Id);
         Projects.getAllProjects();

}
}