global class updateScheduleItemTaskBacthApex implements Database.Batchable<sObject>,Database.stateful {
    public set <Id> scheduleids;
    public set <Id> taskIds;
    public Id recordId;
    public set<Id> updateTaskKeySet =  new Set<Id>();
    public  List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
    public List<Project_Task__c> updateMilestoneListTwo = new List<Project_Task__c>();
    public  List<buildertek__Project_Task__c> projectTaskToUpdate = new  List<buildertek__Project_Task__c>();
    public Map<String, buildertek__Project_Task__c> milestoneList = new Map<String, buildertek__Project_Task__c>();
    public Map<Id, buildertek__Project_Task__c>  ProjectTaskMap = new Map<Id, buildertek__Project_Task__c>();
    public  Map<Id, buildertek__Project_Task__c>   mapAllTask = new Map<Id, buildertek__Project_Task__c>();
    public List<buildertek__Project_Task__c> previuosTasks = new List<buildertek__Project_Task__c>();
    public Map<String, buildertek__Project_Task__c> previousTaskmap;
    public List<buildertek__Project_Task__c> projectTask =  new List<buildertek__Project_Task__c>();
    global updateScheduleItemTaskBacthApex (set<Id> scheduleIdsList,Id scheduleId,Map<Id, buildertek__Project_Task__c>  ProjectTaskMapList){
        scheduleids = new set<Id>();
        
        for(Id  tskid : scheduleIdsList){
            scheduleids.add(tskid);   
        }
        recordId = scheduleId;
        ProjectTaskMap = ProjectTaskMapList;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String Query = 'Select Id, Name, buildertek__Schedule__c, buildertek__Milestone__c, buildertek__Duration__c, buildertek__Lag__c, buildertek__Start__c, buildertek__Dependency__c, buildertek__Phase__c, buildertek__Finish__c FROM buildertek__Project_Task__c  WHERE Id IN :scheduleids AND buildertek__Schedule__c=:recordId Order by buildertek__Order__c NULLS LAST , CreatedDate ASC';
        return DataBase.getQueryLocator(Query);  
        
    }
    global void execute(Database.BatchableContext BC,List<Project_Task__c> updatescheitemslst) {
        
        //List<buildertek__Project_Task__c> projectTask =  new List<buildertek__Project_Task__c>();
         for (buildertek__Project_Task__c scheduleitem : updatescheitemslst){
                buildertek__Project_Task__c schItem = new buildertek__Project_Task__c();
                system.debug('scheduleitem'+scheduleitem.buildertek__Phase__c);
                schItem.Id = scheduleitem.Id;
                if(scheduleitem.buildertek__Dependency__c != null && projectTaskMap.get(scheduleitem.buildertek__Dependency__c) != null){
                    if (String.isNotBlank(scheduleitem.buildertek__Dependency__c) && String.isNotBlank(projectTaskMap.get(scheduleitem.buildertek__Dependency__c).Id)){
                        schItem.buildertek__Dependency__c = projectTaskMap.get(scheduleitem.buildertek__Dependency__c).Id;
                    }
                }
                
                projectTask.add(schItem);
            }

            ProjectTaskTriggerHandler.isFromImport = true;
            
            if (projectTask.size() > 0){
               // update projectTask;
                //msg.Status = 'Success';
               // msg.Message = 'schedule Lines Imported Successfully';
                system.debug('Success---');
            }
        
            Map<String, buildertek__Project_Task__c> milestoneList = new Map<String, buildertek__Project_Task__c>();
            Map<String, buildertek__Project_Task__c> projectTaskList = new Map<String, buildertek__Project_Task__c>();
            List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();

            //If milestone not created for that Phase, Creates here.
           /* List<Project_Task__c> task = [Select Id, Name, buildertek__Phase__c, buildertek__Start__c, buildertek__Schedule__c, buildertek__Milestone__c
                                          FROM Project_Task__c
                                          WHERE buildertek__Schedule__c = :recordId];*/
            
            
            for (Project_Task__c tasks : [Select Id, Name, buildertek__Phase__c, buildertek__Start__c, buildertek__Schedule__c, buildertek__Milestone__c
                                          FROM Project_Task__c
                                          WHERE buildertek__Schedule__c = :recordId]){
                if (!tasks.buildertek__Milestone__c){
                    system.debug(tasks.buildertek__Start__c);
                    projectTaskList.put(tasks.buildertek__Phase__c, tasks);
                } else{
                    milestoneList.put(tasks.buildertek__Phase__c, tasks);
                }
            }
            system.debug('projectTaskList.values()'+projectTaskList.values());
            for (Project_Task__c tasks : projectTaskList.values()){
                system.debug('task'+tasks.buildertek__Start__c);
            }            
            for (Project_Task__c tasks : projectTaskList.values()){
                if (!milestoneList.containsKey(tasks.buildertek__Phase__c) && !tasks.buildertek__Milestone__c){
                    if(tasks.buildertek__Phase__c != null){
                        Project_Task__c project = new Project_Task__c();
                        project.Name = 'Milestone Complete';
                        project.buildertek__Phase__c = tasks.buildertek__Phase__c;
                        project.buildertek__Start__c = tasks.buildertek__Start__c;
                        project.buildertek__Schedule__c = recordId;
                        project.buildertek__Milestone__c = true;
                        projectTasks.add(project);
                    }
                    
                }
            }
            System.debug('Project Task::' + projectTasks);
        if(projectTasks.size()> 0){
             insert projectTasks;
        }
           
      
    }
    //finish method
    global void finish(Database.BatchableContext BC) {
        if(projectTask.size() > 0){
          system.debug(projectTask);
            set<Id> scheduleitemupdateids = new Set<Id>();
            for(Project_Task__c taskid: projectTask){
                scheduleitemupdateids.add(taskid.id);
            }
            if(scheduleitemupdateids .size() > 0){
                UpdateScheduleItemdatesbatchhelper.batchjobexcute(scheduleitemupdateids);
            }
        }
        
    }
    
}