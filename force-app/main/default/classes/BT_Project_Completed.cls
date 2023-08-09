public class BT_Project_Completed {
  @AuraEnabled
    public static buildertek__Project__c UpdateProjects(String projectId) {
        buildertek__Project__c proj = [SELECT Id,buildertek__Stage__c, buildertek__Actual_Completion_Date__c,buildertek__Project_Completion__c FROM buildertek__Project__c WHERE id=:projectId];
        //buildertek__Project__c pro = new buildertek__Project__c();
        proj.buildertek__Stage__c = 'Completed';
        proj.buildertek__Actual_Completion_Date__c = system.today();
        proj.buildertek__Project_Completion__c = 100;
         
         update proj;
         
         
         
        List<buildertek__Project_Task__c> scheduleLineListToProject = [select Id,Name, buildertek__Milestone__c,buildertek__Completion__c ,buildertek__Schedule__c,buildertek__Schedule__r.Name,buildertek__Schedule__r.buildertek__Project__c
                                                                       from buildertek__Project_Task__c where buildertek__Schedule__r.buildertek__Project__c =: projectId];
            
        List<buildertek__Project_Task__c> updateLineList =  new  List<buildertek__Project_Task__c>();
        if(scheduleLineListToProject.size() > 0){
            for(buildertek__Project_Task__c Task: scheduleLineListToProject){
                if(!Task.buildertek__Milestone__c){
                 system.debug(Task);
                    Task.buildertek__Completion__c = 100;
                    system.debug('task percent '+Task.buildertek__Completion__c);
                    updateLineList.add(Task);
                }
            }
        }
        system.debug(updateLineList);
        
        if(updateLineList.size() > 0){
            update updateLineList;
        }
        
        return proj;
    }
 @AuraEnabled
    public static buildertek__Project__c insertProjects(String projectId) {
        buildertek__Project__c pro = [SELECT Id,buildertek__Stage__c, buildertek__Actual_Completion_Date__c,buildertek__Project_Completion__c FROM buildertek__Project__c WHERE id=:projectId];
        //buildertek__Project__c pro = new buildertek__Project__c();
        //proj.buildertek__Stage__c = 'Completed';
        //proj.buildertek__Actual_Completion_Date__c = system.today();
       // proj.buildertek__Project_Completion__c = 100;
         
        // update proj;
        
        return pro;
    }
}