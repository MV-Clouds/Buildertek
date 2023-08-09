public class ProjectTaskTriggerHandlerDuplicate {
    public static Boolean isFirstTime = true;
    public static Boolean isTask = true;
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipTaskTrigger = false;
    public static Boolean isFromImport = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public ProjectTaskTriggerHandlerDuplicate(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void updateChildDatesWithPredecessor(Project_Task__c[] ProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap){
        Set<Id>scheduleIds = new Set<Id>();
        Boolean dependencyPathExist = false;
        for (buildertek__Project_Task__c schItem : ProjectTasks){
            //system.debug(schItem.Name+ ' '+schItem.buildertek__Phase__c);
            scheduleIds.add(schItem.buildertek__Schedule__c);
        }
        //set dependency path
        //List<Project_Task__c> newProjectTaskList = [select Id,Name,buildertek__Dependency__c,buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c, buildertek__Schedule_Item_Dependency_Path__c,buildertek__Schedule__c from buildertek__Project_Task__c where buildertek__Schedule__c IN: scheduleIds];
        
        Map<Id,Project_Task__c> newProjectTaskMap = new Map<Id,Project_Task__c>([select Id,Name,buildertek__Start__c, buildertek__Finish__c,buildertek__Duration__c,
                                                                                 buildertek__Dependency__c,buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c,
                                                                                 buildertek__Schedule_Item_Dependency_Path__c,buildertek__Schedule__c,buildertek__Milestone__c,buildertek__Phase__c
                                                                                 from buildertek__Project_Task__c where buildertek__Schedule__c IN: scheduleIds]);
        
        List<Project_Task__c> newProjectTaskList = newProjectTaskMap.values();
        
        Map<Id,Project_Task__c> newUpdateProjectTaskMap = new  Map<Id,Project_Task__c> ();
        
        for(Project_Task__c task : newProjectTaskList){
           // system.debug('newClonetask-->'+task.buildertek__Dependency__c);
           // system.debug('buildertek__Schedule_Item_Dependency_Path__c-->'+task.buildertek__Schedule_Item_Dependency_Path__c);
            if(task.buildertek__Dependency__c != null){
                if(task.buildertek__Schedule_Item_Dependency_Path__c == '' || task.buildertek__Schedule_Item_Dependency_Path__c == null){
                    system.debug('null value');
                    task.buildertek__Schedule_Item_Dependency_Path__c = task.buildertek__Dependency__c;
                    if(task.buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c != null){
                        task.buildertek__Schedule_Item_Dependency_Path__c  += ',' + task.buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c;
                    }
                }
            }
            //system.debug('buildertek__Schedule_Item_Dependency_Path__c-->'+task.buildertek__Schedule_Item_Dependency_Path__c);
        }
        
        // get parent dates and update task
        set<string> taskIdSet = new set<string>();
        List<Project_Task__c> updateDatesTaskList = new List<Project_Task__c>();
        for(Project_Task__c taskItem: newProjectTaskList){
            system.debug('taskItem-->'+taskItem);
            Project_Task__c lastTask = new Project_Task__c();
            List<String> dependecyPathList = new List<String>();
            if(taskItem.buildertek__Schedule_Item_Dependency_Path__c != null){
                dependencyPathExist = true;
                system.debug('taskItem-->'+taskItem);
                dependecyPathList = taskItem.buildertek__Schedule_Item_Dependency_Path__c.split(',');
            }
            if(dependecyPathList.size()>0){
                system.debug('taskItem-->'+taskItem);
                Project_Task__c prevParent = new Project_Task__c();
                
                for(Integer i = dependecyPathList.size() - 1; i >= 0; i--){
                    String pathItem = dependecyPathList[i];
                    Date startDate;
                    Date endDate;
                    Project_Task__c currentTask = new Project_Task__c();
                    system.debug('pathItem-->'+pathItem);
                    system.debug('taskWithPathId-->'+newProjectTaskMap.get(Id.valueOf(pathItem)));
                    system.debug('prevParent-->'+prevParent);
                    if(newProjectTaskMap.get(Id.valueOf(pathItem)) != null){
                        if(prevParent.Id == null){
                            
                            prevParent = newProjectTaskMap.get(Id.valueOf(pathItem));
                            newUpdateProjectTaskMap.put(prevParent.Id,prevParent);
                            lastTask = prevParent;
                            system.debug('1prevParent start-->'+prevParent);
                        }
                        else{
                            currentTask = newProjectTaskMap.get(Id.valueOf(pathItem));
                            if(newUpdateProjectTaskMap.get(Id.valueOf(pathItem)) != null){
                                currentTask = newUpdateProjectTaskMap.get(Id.valueOf(pathItem));
                            }
                            
                            system.debug('currentTask start-->'+currentTask.Name+' '+currentTask.buildertek__Start__c);
                            system.debug('currentTask end-->'+currentTask.Name+' '+currentTask.buildertek__Finish__c);
                            currentTask.buildertek__Start__c = ProjectTaskTriggerHandler.getStartDate(prevParent.buildertek__finish__c.addDays(1));
                            if(Integer.valueOf(currentTask.buildertek__Duration__c) > 0){
                                endDate =  currentTask.buildertek__Start__c.addDays(Integer.valueOf(currentTask.buildertek__Duration__c) - 1);
                            }else{
                                endDate =  currentTask.buildertek__Start__c; //.addDays(1)
                            }
                            currentTask.buildertek__Finish__c = endDate;
                            prevParent = currentTask;
                            system.debug('2currentTask start-->'+currentTask.Name+' '+currentTask.buildertek__Start__c);
                            lastTask = currentTask;
                            system.debug('2lastTask start-->'+lastTask.Name+' '+lastTask.buildertek__Start__c);
                            system.debug('2prevParent start-->'+prevParent.Name+' '+prevParent.buildertek__Start__c);
                            newUpdateProjectTaskMap.put(currentTask.Id,currentTask);
                        }
                        taskIdSet.add(currentTask.Id);
                        system.debug('currentTask start-->'+currentTask.Name+' '+currentTask.buildertek__Start__c);
                        system.debug('currentTask end-->'+currentTask.Name+' '+currentTask.buildertek__Finish__c);  
                    }
                    
                }
            }
            system.debug('taskItem start-->'+taskItem.Name+' '+taskItem.buildertek__Start__c);
            system.debug('taskItem end-->'+taskItem.Name+' '+taskItem.buildertek__Finish__c);
            system.debug('lastTask-->'+lastTask);
            if(lastTask.Id != null){
                taskItem.buildertek__Start__c = ProjectTaskTriggerHandler.getStartDate(lastTask.buildertek__finish__c.addDays(1));
                Date taskEndDate;
                if(Integer.valueOf(lastTask.buildertek__Duration__c) > 0){
                    system.debug('1-->');
                    taskEndDate =  taskItem.buildertek__Start__c.addDays(Integer.valueOf(taskItem.buildertek__Duration__c) - 1);
                }else{
                    system.debug('2-->');
                    taskEndDate =  taskItem.buildertek__Start__c; //.addDays(1)
                }
                taskItem.buildertek__Finish__c = taskEndDate;
                newUpdateProjectTaskMap.put(taskItem.Id,taskItem);
                system.debug('taskItem start-->'+taskItem.Name+' '+taskItem.buildertek__Start__c);
                system.debug('taskItem end-->'+taskItem.Name+' '+taskItem.buildertek__Finish__c);
                
            }
        }
        
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        system.debug('ProjectTasks-->'+ProjectTasks);
        if(dependencyPathExist && newUpdateProjectTaskMap.values().size() > 0){
           // update newUpdateProjectTaskMap.values();
        }
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
        
        
    }
    
}