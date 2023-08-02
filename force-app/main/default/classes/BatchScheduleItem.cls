global class BatchScheduleItem implements Database.Batchable<sObject> {
    
    global List<buildertek__Project_Task__c> dataList {get;set;}
    global Map<Id, buildertek__Project_Task__c> projectTaskMap {get;set;}
    global Map<Id, buildertek__Project_Task__c> projectTaskMap_1 {get;set;}
    global String recordId{get;set;}
    global BatchScheduleItem(List<buildertek__Project_Task__c> getList,Map<Id, buildertek__Project_Task__c> getMap,String getId){
        dataList = new List<buildertek__Project_Task__c>();
        dataList = getList;
        projectTaskMap = new Map<Id,buildertek__Project_Task__c>();
        projectTaskMap = getMap;
        recordId = getId;
        projectTaskMap_1 = new Map<Id,buildertek__Project_Task__c>();
    }
    
    global List<buildertek__Project_Task__c> start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        List<buildertek__Project_Task__c> returnList = new List<buildertek__Project_Task__c>();
        return returnList;
        /*
String query = 'SELECT Id, Name FROM Account';
return Database.getQueryLocator(query);*/
    }
    
    global void execute(Database.BatchableContext BC, List<buildertek__Project_Task__c> accList) {
        
        try {
            // Update the Account Record
            insert accList;
            for(buildertek__Project_Task__c c: accList){
                projectTaskMap_1.put(c.Id,c);
            }
            
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
        try{
            
            
            
            // execute any post-processing operations like sending email
            List<buildertek__Project_Task__c> projectTask = new List<buildertek__Project_Task__c>();
            futureContoller.updateScheduleRec(recordId);
            
            System.debug('Check Project Manager 1');
            
            //system.debug([Select Id, Name, buildertek__Phase__c, buildertek__Start__c, buildertek__Schedule__c, buildertek__Milestone__c FROM Project_Task__c  WHERE buildertek__Schedule__c = :recordId]);
            for (buildertek__Project_Task__c scheduleitem : projectTaskMap_1.values()){
                buildertek__Project_Task__c schItem = new buildertek__Project_Task__c();
                system.debug('scheduleitem'+scheduleitem.buildertek__Phase__c);
                schItem.Id = scheduleitem.Id;
                if(scheduleitem.buildertek__Dependency__c != null && projectTaskMap_1.get(scheduleitem.buildertek__Dependency__c) != null){
                    if (String.isNotBlank(scheduleitem.buildertek__Dependency__c) && String.isNotBlank(projectTaskMap_1.get(scheduleitem.buildertek__Dependency__c).Id)){
                        schItem.buildertek__Dependency__c = projectTaskMap_1.get(scheduleitem.buildertek__Dependency__c).Id;
                    }
                }
                
                projectTask.add(schItem);
            }
            System.debug('Check Project Manager 2');
            ProjectTaskTriggerHandler.isFromImport = true;
            
            if (projectTask.size() > 0){
                update projectTask;
                //msg.Status = 'Success';
                //msg.Message = 'schedule Lines Imported Successfully';
                system.debug('Success---');
            }
            
            Map<String, buildertek__Project_Task__c> milestoneList = new Map<String, buildertek__Project_Task__c>();
            Map<String, buildertek__Project_Task__c> projectTaskList = new Map<String, buildertek__Project_Task__c>();
            List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();

            //If milestone not created for that Phase, Creates here.
            List<Project_Task__c> task = [Select Id, Name, buildertek__Phase__c, buildertek__Start__c, buildertek__Schedule__c, buildertek__Milestone__c
                                          FROM Project_Task__c
                                          WHERE buildertek__Schedule__c = :recordId];
            
            
            for (Project_Task__c tasks : task){
                if (!tasks.buildertek__Milestone__c){
                    system.debug(tasks.buildertek__Start__c);
                    projectTaskList.put(tasks.buildertek__Phase__c, tasks);
                } else{
                System.debug('Check Project Manager 4');
                    milestoneList.put(tasks.buildertek__Phase__c, tasks);
                }
            }
            system.debug('projectTaskList.values()'+projectTaskList.values());
            for (Project_Task__c tasks : projectTaskList.values()){
                system.debug('task'+tasks.buildertek__Start__c);
            }            
            for (Project_Task__c tasks : projectTaskList.values()){
                if (!milestoneList.containsKey(tasks.buildertek__Phase__c) && !tasks.buildertek__Milestone__c){
                System.debug('Check Project Manager 5');
                    if(tasks.buildertek__Phase__c != null){
                         system.debug('task214'+tasks.buildertek__Start__c);
                        Project_Task__c project = new Project_Task__c();
                        project.Name = 'Milestone Complete';
                        project.buildertek__Phase__c = tasks.buildertek__Phase__c;
                        project.buildertek__Start__c = tasks.buildertek__Start__c;
                        project.buildertek__Schedule__c = recordId;
                        project.buildertek__Use_Project_Manager_from_Schedule__c = true;
                        System.debug('Check Project Manager 6');
                        /*if(projectManagerId != null){
                            project.buildertek__Project_Manager__c = projectManagerId;
                            System.debug('Check Project Manager 7');
                        }*/
                    System.debug('Check Project Manager');
                        project.buildertek__Milestone__c = true;
                        projectTasks.add(project);
                    }
                    
                }
            }
            System.debug('Project Task::' + projectTasks);
            
            insert projectTasks;
            futureContoller.updateScheduleRec(recordId);
        }catch(Exception e){
            system.debug('e-->'+e);
        }
    }
}