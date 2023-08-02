/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  02-Jan-2018
 */
global with sharing class BT_Task_Manager_Controller{
    public Project__c project{ get; set; }

    public Project_Task__c newTask{ get; set; }

    public Project_Task__c existingTask{ get; set; }

    public String existingTask1{ get; set; }

    public string ganttJSON{ get; set; }
    
    public string allGanttJSON {get; set;} 
    
    public static Map<String,List<Project_Task__c>> prevTaskMap {get; set;}
    
    public Integer totalProjectTasks {get; set;}
    
    public Integer pageLimitCheck {get; set;}
    
    public string projectId{ get; set; }

    public Integer nextStartDate{ get; set; }

    public string taskNameToSearch{ get; set; }

    public string projectIdToSearch{ get; set; }
    
    public Integer totalTasks {get; set;}

    public String scheduleIdToSearch{ get; set; }

    public string recordId{ get; set; }

    public string scheduleId{ get; set; }

    public Schedule__c schedule{ get; set; }

    public boolean istaskview{ get; set; }
    
    public static boolean isOnLoad {get; set;}
    
    public String updateGanttChartData {get; set;}

    public string viewas{ get; set; }

    public String selectedRadioItem{ get; set; }

    public Integer totalRecs = 0;
    public Integer OffsetSize = 0;
    public Integer LimitSize = 50;
    public Boolean isNextDisabled = true;
    public Boolean isPrevDisabled = true;
    public BT_Task_Manager_Controller(ApexPages.StandardController controller){
        LimitSize = 50;
        totalRecs = 0;
        OffsetSize = 0;
        isNextDisabled = true;
        isPrevDisabled = true;
        this.schedule = (Schedule__c)controller.getRecord();
        recordId = schedule.Id;
        System.debug(this.recordId);
        if (Schema.sObjectType.schedule__c.fields.id.isAccessible() && Schema.sObjectType.schedule__c.fields.Project__c.isAccessible() && Schema.sObjectType.Project__c.fields.Name.isAccessible()){
            projectId = [Select Id, Project__c, Project__r.Name
                         from schedule__c
                         where Id = :recordId].Project__c;
        }
    }

    public BT_Task_Manager_Controller(){
        LimitSize = 50;
        totalRecs = 0;
        OffsetSize = 0;
        isNextDisabled = true;
        isPrevDisabled = true;
        istaskview = false;
        isOnLoad = true;
        viewas = 'Ganntview';
        //projectId = ApexPages.currentPage().getParameters().get('pId');
        if (ApexPages.currentPage().getParameters().get('sId') != null)
            scheduleId = ApexPages.currentPage().getParameters().get('sId');
        if (ApexPages.currentPage().getParameters().get('Id') != null)
            recordId = ApexPages.currentPage().getParameters().get('Id');
        if (ApexPages.currentPage().getParameters().get('recordId') != null)
            recordId = ApexPages.currentPage().getParameters().get('recordId');
            scheduleId = ApexPages.currentPage().getParameters().get('recordId');
        if (String.isBlank(scheduleId) && ApexPages.currentPage().getParameters().get('Id') != null){
            scheduleId = ApexPages.currentPage().getParameters().get('Id');
        }

        if (scheduleId != null){
            totalRecs = [select count()
                         FROM buildertek__Project_Task__c
                         WHERE buildertek__Schedule__c = :scheduleId];
            try{
                projectId = [Select Id, Project__c, Project__r.Name
                             from schedule__c
                             where Id = :scheduleId].Project__c;
                system.debug([Select Id, Project__c, Project__r.Name
                             from schedule__c
                             where Id = :scheduleId]);
            } catch (exception e){
                System.debug('Error' + e.getMessage()+'::' + e.getLineNumber());
            }
        }
        newTask = new Project_Task__c();
        newTask.Project__c = projectId;
        if (projectId != null){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectId][0];
            totalProjectTasks = totalRecs;
            ganttJSON = BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
            allGanttJSON = BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, totalRecs, 0, totalRecs, isNextDisabled, isPrevDisabled);
            
        } else{
            totalProjectTasks = totalRecs;
            ganttJSON = BT_Task_Manager_Controller.getJSON(null, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
            allGanttJSON = BT_Task_Manager_Controller.getJSON(null, scheduleId, totalRecs, 0, totalRecs, isNextDisabled, isPrevDisabled);
        }
        system.debug('first'+isOnLoad);
    }

    public void getAllRecords(){
        if (scheduleId != null){
            totalProjectTasks = [select count()
                         FROM buildertek__Project_Task__c
                         WHERE buildertek__Schedule__c = :scheduleId];
            pageLimitCheck = OffsetSize;
            
            try{
                projectId = [Select Id, Project__c, Project__r.Name
                             from schedule__c
                             where Id = :scheduleId].Project__c;
            } catch (exception e){
                System.debug('Error' + e.getMessage()+'::' + e.getLineNumber());
            }
        }
        newTask = new Project_Task__c();
        newTask.Project__c = projectId;
        if (projectId != null){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectId][0];
            allGanttJSON = BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, totalProjectTasks, 0, totalRecs, true, true);
            ganttJSON = BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
            //return BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, totalRecs, 0, totalRecs, true, true);
        } else{
            ganttJSON = BT_Task_Manager_Controller.getJSON(null, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
            allGanttJSON = BT_Task_Manager_Controller.getJSON(null, scheduleId, totalProjectTasks, 0, totalRecs, true, true);
            //return BT_Task_Manager_Controller.getJSON(null, scheduleId, totalRecs, 0, totalRecs, true, true);
        }
    }
    
    public pageReference redirect(){
        pageReference pg = new pageReference('/lightning/r/' + projectId + '/related/buildertek__Schedules__r/view');
        return pg.setRedirect(true);
    }

    public void previous(){
        OffsetSize = OffsetSize - LimitSize;
        if (OffsetSize <= 0){
            OffsetSize = 0;
        }
        if (scheduleId != null){
            try{
                projectId = [Select Id, Project__c, Project__r.Name
                             from schedule__c
                             where Id = :scheduleId].Project__c;
            } catch (exception e){
                System.debug('Error' + e.getMessage()+'::' + e.getLineNumber());
            }
        }

        newTask = new Project_Task__c();
        newTask.Project__c = projectId;
        if (projectId != null){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectId][0];
            ganttJSON = BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
        } else{
            ganttJSON = BT_Task_Manager_Controller.getJSON(null, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
        }
    }

    public void next(){
        OffsetSize = OffsetSize + LimitSize;
        System.debug('OffsetSize: Next:' + OffsetSize);
        if (scheduleId != null){
            try{
                projectId = [Select Id, Project__c, Project__r.Name
                             from schedule__c
                             where Id = :scheduleId].Project__c;
            } catch (exception e){
                System.debug('Error' + e.getMessage()+'::' + e.getLineNumber());
            }
        }
        newTask = new Project_Task__c(); 
        newTask.Project__c = projectId;
        
        if (projectId != null){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectId][0];
            ganttJSON = BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
        } else{
            system.Debug('next');
            ganttJSON = BT_Task_Manager_Controller.getJSON(null, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
        }
    }
    
    public void saveData(){
        
        System.debug('OffsetSize: Next:' + OffsetSize);
        if (scheduleId != null){
            try{
                projectId = [Select Id, Project__c, Project__r.Name
                             from schedule__c
                             where Id = :scheduleId].Project__c;
            } catch (exception e){
                System.debug('Error' + e.getMessage()+'::' + e.getLineNumber());
            }
        }
        newTask = new Project_Task__c();
        newTask.Project__c = projectId;
        //system.debug(project.Id+','+ scheduleId+','+ LimitSize+','+ OffsetSize+','+ totalRecs+','+ isNextDisabled+','+ isPrevDisabled);
        if (projectId != null){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectId][0];
                    system.debug(projectId+','+project.Id+','+ scheduleId+','+ LimitSize+','+ OffsetSize+','+ totalRecs+','+ isNextDisabled+','+ isPrevDisabled);
            ganttJSON = BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
        } else{
            //system.debug(project.Id+','+ scheduleId+','+ LimitSize+','+ OffsetSize+','+ totalRecs+','+ isNextDisabled+','+ isPrevDisabled);
            ganttJSON = BT_Task_Manager_Controller.getJSON(null, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
            system.debug(ganttJSON);
            
        }
    }
    
   /* public void saveDataClone(){
       
        system.debug(updateGanttChartData);
        //system.debug((List<String>)System.JSON.deserialize(updateGanttChartData, List<String>.class));
       // system.debug(links);
        System.debug('OffsetSize: Next:' + OffsetSize);
        if (scheduleId != null){
            try{
                projectId = [Select Id, Project__c, Project__r.Name
                             from schedule__c
                             where Id = :scheduleId].Project__c;
            } catch (exception e){
                System.debug('Error' + e.getMessage()+'::' + e.getLineNumber());
            }
        }
        newTask = new Project_Task__c();
        newTask.Project__c = projectId;
        //system.debug(project.Id+','+ scheduleId+','+ LimitSize+','+ OffsetSize+','+ totalRecs+','+ isNextDisabled+','+ isPrevDisabled);
        if (projectId != null){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectId][0];
                    system.debug(projectId+','+project.Id+','+ scheduleId+','+ LimitSize+','+ OffsetSize+','+ totalRecs+','+ isNextDisabled+','+ isPrevDisabled);
            ganttJSON = BT_Task_Manager_Controller.getJSON(project.Id, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
        } else{
            //system.debug(project.Id+','+ scheduleId+','+ LimitSize+','+ OffsetSize+','+ totalRecs+','+ isNextDisabled+','+ isPrevDisabled);
            ganttJSON = BT_Task_Manager_Controller.getJSON(null, scheduleId, LimitSize, OffsetSize, totalRecs, isNextDisabled, isPrevDisabled);
            system.debug(ganttJSON);
            
        }
    }*/

    public void getDisablePrevious(){
    }

   
    
    public void getDisableNext(){
    }

    public Integer getTotalRecs(){
        return totalRecs;
    }

    /*publuc static string getAllTasks(){
        String query = 'Select Project__r.Name, buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
    }*/
    
    public static String getJSON(String projectId, String scheduleId, Integer LimitSize, Integer OffsetSize, Integer totalRecs, Boolean isNextDisabled, Boolean isPrevDisabled){
        if (OffsetSize >= totalRecs){
            isNextDisabled = true;
        } else{
            isNextDisabled = false;
        }
        if (OffsetSize == 0){
            isPrevDisabled = true;
        } else{
            isPrevDisabled = false;
        }
         List<buildertek__Project_Task__c> milestoneTaskList = new List<buildertek__Project_Task__c>();
        String query = 'Select Project__r.Name, buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
         String milestonequery = 'Select Project__r.Name, buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
        String query1 = 'Select Project__r.Name, buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
        if (scheduleId != null){
            //Order by  Order__c ASC NULLS LAST,buildertek__Phase__c ASC NULLS LAST, buildertek__Milestone__c ,buildertek__Start__c, Auto_Number__c ASC';
            //buildertek__Phase__c ASC NULLS LAST // Auto_Number__c ASC // Order__c ASC NULLS LAST buildertek__Milestone__c ,buildertek__Start__c,
            ////CreatedDate ASC,buildertek__Phase__c ASC NULLS LAST,buildertek__Milestone__c ,buildertek__Start__c
            //Order by buildertek__Milestone__c,CreatedDate ASC,buildertek__Phase__c ASC NULLS LAST,buildertek__Start__c';  Order by CreatedDate ASC,buildertek__Phase__c ASC NULLS LAST,buildertek__Milestone__c';//,buildertek__Start__c
            //CreatedDate ASC,buildertek__Phase__c ASC NULLS LAST,buildertek__Milestone__c,buildertek__Start__c
            query = query + ' From Project_Task__c where schedule__c =:scheduleId order by CreatedDate,buildertek__Phase__c,buildertek__Milestone__c';//CreatedDate,buildertek__Phase__c,buildertek__Milestone__c//CreatedDate,buildertek__Start__c,buildertek__Phase__c ASC,buildertek__Milestone__c
            query += ' LIMIT : LimitSize OFFSET : OffsetSize';
            query1 = query1 + ' From Project_Task__c where schedule__c =:scheduleId Order by buildertek__Order__c NULLS LAST,CreatedDate,LastModifiedDate ';//buildertek__Order__c NULLS LAST//,buildertek__Phase__c,buildertek__Milestone__c  CreatedDate,buildertek__Phase__c ASC,buildertek__Milestone__c
            //query1 += ' LIMIT : LimitSize OFFSET : OffsetSize';
            milestonequery = milestonequery + ' From Project_Task__c where schedule__c =:scheduleId AND buildertek__Milestone__c= true';
        } else{
            //Order by  Order__c ASC NULLS LAST,buildertek__Phase__c ASC NULLS LAST, buildertek__Milestone__c ,buildertek__Start__c, Auto_Number__c ASC';
            //buildertek__Phase__c ASC NULLS LAST //Auto_Number__c ASC, Order__c ASC NULLS LAST
            query = query + ' From Project_Task__c where Project__c =:projectId Order by CreatedDate,buildertek__Phase__c ASC,buildertek__Milestone__c';//,buildertek__Start__c
            query += ' LIMIT : LimitSize OFFSET : OffsetSize';
            query1 = query1 + ' From Project_Task__c where Project__c =:projectId Order by CreatedDate,buildertek__Order__c NULLS LAST,LastModifiedDate ';//,buildertek__Start__c
            //query1 += ' LIMIT : LimitSize OFFSET : OffsetSize';
             milestonequery = milestonequery + ' From Project_Task__c where Project__c =:projectId AND buildertek__Milestone__c= true';
        }
        
        Project__c project = new Project__c();
        system.debug(projectId);
        if (projectId != null && projectId != ''){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectId][0];
        }

       
        
       
        List<Schedule__c> schedules;
        if (scheduleId != null){
            schedules = [Select Id, Name, Start_Date__c, Total_Duration__c
                         from Schedule__c
                         where Id = :scheduleId];
            
        } else{
            schedules = [Select Id, Name, Start_Date__c, Total_Duration__c
                         from Schedule__c
                         where project__c = :projectId];
           
        }
        List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
        List<String> taskIds = new List<String>();
        projectTasks = DataBase.query(query);
        List<buildertek__Project_Task__c> projectTasksSorted = DataBase.query(query1); //projectTasks1
        milestoneTaskList = DataBase.query(milestonequery);
        
        
      /* for(buildertek__Project_Task__c task : projectTasks1){
            system.debug('Before '+task);
            taskIds.add(task.Id);
        }*/
        /*List<AggregateResult> groupByPhase = [select Id,buildertek__Phase__c,buildertek__Milestone__c From buildertek__Project_Task__c where buildertek__Schedule__c =:scheduleId group by Id,buildertek__Phase__c,buildertek__Milestone__c 
                                                  ]; */ //order by buildertek__Phase__c,buildertek__Milestone__c
                                                 
        /*List<String>dupTaskIds = new List<String>();
         for(AggregateResult task : groupByPhase){
            system.debug('Before '+task);
            dupTaskIds.add(task.Id);
        }*/
        
       /*List<buildertek__Project_Task__c> projectTasksSorted = [select Id, Name,buildertek__Milestone__c,buildertek__Notes__c,buildertek__Completion__c, buildertek__Start__c,buildertek__Finish__c,buildertek__Phase__c,buildertek__Dependency__c,buildertek__Lag__c,buildertek__Dependency__r.Name ,buildertek__Duration__c,buildertek__Schedule__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name
                                                          From buildertek__Project_Task__c where  Id IN:projectTasks1 order by CreatedDate,buildertek__Order__c NULLS LAST];*/ /* Limit: 50 OFFSET: OffsetSize*/
       
        system.debug(projectTasks.Size());
        /* for(buildertek__Project_Task__c task : projectTasksSorted){
            system.debug('after '+task);
            taskIds.add(task.Id);
        }*/
        
        List<buildertek__Project_Task__c> sendTaskList = new List<buildertek__Project_Task__c>();
        
       /* for(Integer i=OffsetSize; i<50+OffsetSize ; i++ ){
            if(projectTasksSorted != null){
                if(projectTasksSorted[i] != null){
                    sendTaskList.add(projectTasksSorted[i]);
                }
            }
        }*/
        
       // system.debug(sendTaskList.Size());
        /*List<buildertek__Project_Task__c> AllTasks = [select Id, Name,buildertek__Milestone__c,buildertek__Notes__c,buildertek__Completion__c, buildertek__Start__c,buildertek__Finish__c,buildertek__Phase__c,buildertek__Dependency__c,buildertek__Lag__c,buildertek__Dependency__r.Name ,buildertek__Duration__c,buildertek__Schedule__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name
                                                          From buildertek__Project_Task__c where buildertek__Schedule__c =:scheduleId order by buildertek__Phase__c,buildertek__Milestone__c];*/
        
         Map<Id,buildertek__Project_Task__c> allTaskMap = new Map<Id,buildertek__Project_Task__c>();
        
       
        /* Map<String,buildertek__Project_Task__c> milestoneMap = new Map<String,buildertek__Project_Task__c>();
        Map<String,List<buildertek__Project_Task__c>> TaskWithPhaseMap = new Map<String,List<buildertek__Project_Task__c>>();
        List<buildertek__Project_Task__c> taskWithNophases = new List<buildertek__Project_Task__c>();
        Map<String,buildertek__Project_Task__c> milestoneMapinPage = new Map<String,buildertek__Project_Task__c>();
        
        if(projectTasks.Size() > 0){
            for(buildertek__Project_Task__c task : projectTasks1){
                system.debug(task);
                
                if(!task.buildertek__Milestone__c){
                    if(task.buildertek__Phase__c !=null){
                        if(TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                            list<buildertek__Project_Task__c> newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                            newProjectTaskList.add(task);    
                            TaskWithPhaseMap.put(task.buildertek__Phase__c,newProjectTaskList);  
                            
                        }else{
                            List<buildertek__Project_Task__c> newTaskList = new List<buildertek__Project_Task__c>();
                            newTaskList.add(task);
                            TaskWithPhaseMap.put(task.buildertek__Phase__c,newTaskList);  
                        }
                    }else{
                        if(TaskWithPhaseMap.get('No Phase') != null){
                            list<buildertek__Project_Task__c> newListForTaskWithNoPhase = TaskWithPhaseMap.get('No Phase');
                            newListForTaskWithNoPhase.add(task);
                            TaskWithPhaseMap.put('No Phase',newListForTaskWithNoPhase);
                            //prevTaskMap.put('No Phase',newListForTaskWithNoPhase);  
                        }else{
                            List<buildertek__Project_Task__c> newTaskNoPhaseList = new List<buildertek__Project_Task__c>();
                            newTaskNoPhaseList.add(task);
                            TaskWithPhaseMap.put('No Phase',newTaskNoPhaseList); 
                        }
                        taskWithNophases.add(task);
                    }
                }else{
                    system.debug(task);
                    milestoneMapinPage.put(task.Id,task);
                    
                }
            }
        }
        
       //system.debug(prevTaskMap.size());
        
        if(milestoneTaskList.Size()>0){
            for(buildertek__Project_Task__c milestone : milestoneTaskList){
                if(milestone.buildertek__Phase__c != null){
                    milestoneMap.put(milestone.buildertek__Phase__c,milestone);
                }else{
                    milestoneMap.put(milestone.Id,milestone);
                    
               }
            }
        }
        
        List<buildertek__Project_Task__c> sortedTaskList = new List<buildertek__Project_Task__c>();
        
        
        Integer ListSize = 0;
        List<buildertek__Project_Task__c> checkLiseSize = new List<buildertek__Project_Task__c>();
        system.debug(OffsetSize);
        Map<String,list<buildertek__Project_Task__c>> newTaskWithPhaseMap = new Map<String,list<buildertek__Project_Task__c>>();
         List<buildertek__Project_Task__c> updatetaskList = new List<buildertek__Project_Task__c>();
       
           
            
        list<buildertek__Project_Task__c> newProjectTaskList = new List<buildertek__Project_Task__c>();
        for(buildertek__Project_Task__c  task : projectTasks){
            system.debug(task);
            if(milestoneMap.get(task.buildertek__Phase__c) != null && !task.buildertek__Milestone__c && task.buildertek__Phase__c != null){
                 system.debug(task);
                if(newTaskWithPhaseMap.get(task.buildertek__Phase__c) == null){
                     system.debug(task);
                    if(TaskWithPhaseMap.Size() > 0){
                        system.debug(task);
                        if(TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                            newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                            system.debug( TaskWithPhaseMap.get(task.buildertek__Phase__c));
                            system.debug(newProjectTaskList);
                            if(newProjectTaskList != null){
                                ListSize = ListSize+newProjectTaskList.Size();
                            }  
                            if(ListSize < 49){
                            system.debug(ListSize);
                                ListSize = ListSize+1;
                                system.debug(milestoneMap.get(task.buildertek__Phase__c));
                                newProjectTaskList.add(milestoneMap.get(task.buildertek__Phase__c));
                                system.debug(task.buildertek__Phase__c+milestoneMap.get(task.buildertek__Phase__c));
                            }
                            newTaskWithPhaseMap.put(task.buildertek__Phase__c,newProjectTaskList);
                                updatetaskList.addAll(newProjectTaskList);
                            
                            
                        }else{
                            system.debug(task);
                            //ListSize = ListSize+1;
                            updatetaskList.add(task);
                        }
                    }else{
                         //ListSize = ListSize+1;
                        updatetaskList.add(milestoneMap.get(task.buildertek__Phase__c));
                        
                    }
                }
            }else{
                system.debug(task);
                 
                if(task.buildertek__Phase__c == null){
                     if(task.buildertek__Milestone__c && totalRecs < OffsetSize+50){
                         ListSize = ListSize+1;
                        updatetaskList.add(task);
                    }else if(!task.buildertek__Milestone__c){
                        ListSize = ListSize+1;
                        updatetaskList.add(task);
                    }
                }
               
                
            }
        }*/
        
        Map<String,List<buildertek__Project_Task__c>> TaskWithPhaseMap = new Map<String,List<buildertek__Project_Task__c>>();
        String taskIdWithNoPhase = '';
        for(buildertek__Project_Task__c task:projectTasksSorted){ //projectTasks1
            if(!task.buildertek__Milestone__c){
                if(task.buildertek__Phase__c !=null){
                   system.debug(task.Name);
                    if(TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                        list<buildertek__Project_Task__c> newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                        newProjectTaskList.add(task);    
                        TaskWithPhaseMap.put(task.buildertek__Phase__c,newProjectTaskList);  
                    }else{
                        List<buildertek__Project_Task__c> newTaskList = new List<buildertek__Project_Task__c>();
                        newTaskList.add(task);
                        TaskWithPhaseMap.put(task.buildertek__Phase__c,newTaskList);  
                    }
                }
                if(task.buildertek__Phase__c == null){
                    taskIdWithNoPhase = task.Id;
                }
            }
            
        }
        
         Map<String,buildertek__Project_Task__c> milestoneMap = new Map<String,buildertek__Project_Task__c>();
         if(milestoneTaskList.Size()>0){
            for(buildertek__Project_Task__c milestone : milestoneTaskList){
                if(milestone.buildertek__Phase__c != null){
                    list<buildertek__Project_Task__c> newProjectTaskList = TaskWithPhaseMap.get(milestone.buildertek__Phase__c);
                    newProjectTaskList.add(milestone);    
                    TaskWithPhaseMap.put(milestone.buildertek__Phase__c,newProjectTaskList);  
                }else{
                   // milestoneMap.put(milestone.Id,milestone);
                   if(taskIdWithNoPhase != ''){
                       milestoneMap.put(taskIdWithNoPhase,milestone);
                   }
                   
                    system.debug(milestone);
               }
            }
         }
        Integer i=0;
        Map<String,Integer> newTaskWithPhaseMap = new Map<String,Integer>();
        List<buildertek__Project_Task__c> updatetaskList = new List<buildertek__Project_Task__c>();
        List<buildertek__Project_Task__c> newProjectTaskList = new List<buildertek__Project_Task__c>();
       // Map<String,Integer> addedMilestoneWithNoPhase = new Map<String,Integer>();
        
        Integer ListSize = 0;
        system.debug(OffsetSize);
        for(Integer j=0; j<projectTasksSorted.Size(); j++){
            buildertek__Project_Task__c task = projectTasksSorted[j];
            system.debug(task);
            if(!string.isBlank(task.buildertek__Phase__c)){
                if(TaskWithPhaseMap.Size() > 0){
                    if(newTaskWithPhaseMap.get(task.buildertek__Phase__c) == null){
                        if(TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                            newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                            if(newProjectTaskList != null){
                                ListSize = ListSize+newProjectTaskList.Size();
                            }  
                            newTaskWithPhaseMap.put(task.buildertek__Phase__c,newProjectTaskList.Size());
                            updatetaskList.addAll(newProjectTaskList);
                            i = i+ListSize;
                        }
                    }
                }
            }else{
                if(!task.buildertek__Milestone__c){
                    updatetaskList.add(task);
                    system.debug(task);
                    system.debug(milestoneMap.get(task.Id));
                    if(milestoneMap.get(task.Id) != null){
                        updatetaskList.add(milestoneMap.get(task.Id));
                    }
                    i++;
                }
                
            }
        }
        
        system.debug(OffsetSize);
        
    List<buildertek__Project_Task__c> FinalTaskList = new List<buildertek__Project_Task__c>();
        Integer taskListSize = 0;
        for(Integer k = OffsetSize ; k<OffsetSize+50 ;k++){
            system.debug(k+ ' '+totalRecs+ ' '+updatetaskList.Size());
            system.debug(k+ ' '+totalRecs+ ' '+updatetaskList.Size());
            if(k <updatetaskList.Size()){
                system.debug(updatetaskList[k]);
                updatetaskList[k].buildertek__Order__c = k+1;
                //system.debug(updatetaskList[k]);
                FinalTaskList.add(updatetaskList[k]);
            }else{
                break;
            }
        } 
        /*system.debug(FinalTaskList.Size());
        system.debug(BT_Task_Manager_Controller.isOnLoad); 
        BT_Task_Manager_Controller.isOnLoad = false;
        system.debug(BT_Task_Manager_Controller.isOnLoad);*/
        
       //GanttChart GanttChart = new GanttChart(schedules, projectTasks, project);
      // GanttChart GanttChart = new GanttChart(schedules, projectTasksSorted, project);
        // GanttChart GanttChart = new GanttChart(schedules, updatetaskList, project);
        GanttChart GanttChart = new GanttChart(schedules, FinalTaskList, project);
        //system.debug((Project_Task__c)System.JSON.deserialize(GanttChart.getJSON(), Project_Task__c.class));
        return GanttChart.getJSON();
    }

    public void searchTasks(){
        taskNameToSearch = ApexPages.currentPage().getParameters().get('taskNameToSearch');
        scheduleIdToSearch = ApexPages.currentPage().getParameters().get('scheduleIdToSearch');
        projectIdToSearch = ApexPages.currentPage().getParameters().get('projectIdToSearch');
        String query = 'Select Project__r.Name, buildertek__Contractor__r.Name,buildertek__Resource__r.Name,buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
        if (scheduleIdToSearch != null){
            taskNameToSearch = '%' + taskNameToSearch + '%';
            taskNameToSearch = taskNameToSearch.replace(' ', '%');
            query = query + ' From Project_Task__c where schedule__c =:scheduleIdToSearch AND buildertek__Phase__c LIKE : taskNameToSearch Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC';
        } else{
            taskNameToSearch = '%' + taskNameToSearch + '%';
            query = query + ' From Project_Task__c where Project__c =:projectIdToSearch AND buildertek__Phase__c LIKE : taskNameToSearch Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC';
        }
        Project__c project = new Project__c();
        if (projectIdToSearch != null && String.isNotBlank(projectIdToSearch)){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectIdToSearch][0];
        }
        List<Schedule__c> schedules;
        if (scheduleIdToSearch != null && String.isNotBlank(scheduleIdToSearch)){
            schedules = [Select Id, Name, Start_Date__c, Total_Duration__c
                         from Schedule__c
                         where Id = :scheduleIdToSearch];
        } else{
            schedules = [Select Id, Name, Start_Date__c, Total_Duration__c
                         from Schedule__c
                         where project__c = :projectIdToSearch];
        }
        List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
        projectTasks = DataBase.query(query);
        GanttChart GanttChart = new GanttChart(schedules, projectTasks, project);
        ganttJSON = GanttChart.getJSON();
        allGanttJSON = GanttChart.getJSON();
    }

    public void callTimeFrameTask(){
        nextStartDate = Integer.valueOf(ApexPages.currentPage().getParameters().get('nextStartDate'));
        scheduleIdToSearch = ApexPages.currentPage().getParameters().get('scheduleIdToSearch');
        projectIdToSearch = ApexPages.currentPage().getParameters().get('projectIdToSearch');
        Date nextDate;
        Date endDate;
        if (nextStartDate == 7){
            date myDate = date.today();
            date weekStart = myDate.toStartofWeek();
            nextDate = weekStart.addDays(7);
            endDate = weekStart.addDays(14);
        } else if (nextStartDate == 14){
            date myDate = date.today();
            date weekStart = myDate.toStartofWeek();
            nextDate = weekStart.addDays(14);
            endDate = weekStart.addDays(21);
        } else if (nextStartDate == 28){
            date myDate = date.today();
            myDate = myDate.addMonths(1);
            Integer month = myDate.month();
            Integer year = myDate.year();
            nextDate = Date.newInstance(year, month, 01);
            myDate = myDate.addMonths(1);
            month = myDate.month();
            year = myDate.year();
            endDate = Date.newInstance(year, month, 01);
        } else if (nextStartDate == 4){
            nextDate = [Select StartDate
                        From Period
                        Where type = 'Quarter' and StartDate = NEXT_FISCAL_QUARTER].StartDate;
            endDate = nextDate.addMonths(3);
        }
        String query = 'Select Project__r.Name, buildertek__Contractor__r.Name,buildertek__Resource__r.Name,buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
        if (scheduleIdToSearch != null){
            query = query + ' From Project_Task__c where schedule__c =:scheduleIdToSearch';
            if (nextStartDate != 0){
                query = query + ' AND buildertek__Start__c >: nextDate AND buildertek__Start__c <: endDate';
            }
            query = query + ' Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC';
        } else{
            taskNameToSearch = '%' + taskNameToSearch + '%';
            query = query + ' From Project_Task__c where Project__c =:projectIdToSearch';
            if (nextStartDate != 0){
                query = query + ' AND buildertek__Start__c >: nextDate AND buildertek__Start__c <: endDate';
            }
            query = query + ' Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC';
        }

        Project__c project = new Project__c();
        if (projectIdToSearch != null && String.isNotBlank(projectIdToSearch)){
            project = [Select Id, Name
                       from Project__c
                       where id = :projectIdToSearch][0];
        }

        List<Schedule__c> schedules;
        if (scheduleIdToSearch != null && String.isNotBlank(scheduleIdToSearch)){
            schedules = [Select Id, Name, Start_Date__c, Total_Duration__c
                         from Schedule__c
                         where Id = :scheduleIdToSearch];
        } else{
            schedules = [Select Id, Name, Start_Date__c, Total_Duration__c
                         from Schedule__c
                         where project__c = :projectIdToSearch];
        }

        List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
        projectTasks = DataBase.query(query);
        GanttChart GanttChart = new GanttChart(schedules, projectTasks, project);
        ganttJSON = GanttChart.getJSON();
        allGanttJSON = GanttChart.getJSON();
    }

    public void cancelTask(){
        newTask = new Project_Task__c();
        newTask.buildertek__Start__c = Date.today();
        system.debug(existingTask1);
        existingTask1 = '';
    }

    public void initNewTask(){
        existingTask1 = '';
        String parentId = ApexPages.currentPage().getParameters().get('parentId').escapeHtml4();
        String taskIdToEdit = ApexPages.currentPage().getParameters().get('taskIdToEdit').escapeHtml4();
        newTask = new Project_Task__c();
        newTask.Project__c = projectId;
        try{
            if (scheduleId != null){
                newTask.Schedule__c = scheduleId;
            }

            if (!String.isBlank(taskIdToEdit)){
                newTask.id = taskIdToEdit;
                //newTask = projecttask;
            } else if (!String.isBlank(parentId) && parentId.length() > 1){
                if (BT_Utils.getSObjectPrefix(BT_Constants.OBJECT_TYPE_PROJECT_TASK).equals(parentId.substring(0, 3))){
                    List<Project_Task__c> parentTask;

                    parentTask = [Select Id, Phase__c, Type__c, buildertek__Milestone__c, Finish__c
                                  from Project_Task__c
                                  where id = :parentId];

                    newTask.Dependency__c = parentId;
                    newTask.Dependency__c = parentId;
                    newTask.phase__c = parentTask[0].Phase__c;
                    newTask.Type__c = parentTask[0].Type__c;
                    if (parentTask[0].Finish__c != null){
                        newTask.Start__c = ProjectTaskTriggerHandler.addBussinessDays(parentTask[0].Finish__c, 1);
                    }
                    newTask.Finish__c = newTask.Start__c;
                    newTask.duration__c = 1;
                    newTask.lag__c = 0;
                } else if (BT_Utils.getSObjectPrefix(BT_Constants.OBJECT_TYPE_PROJECT).equals(parentId.substring(0, 3))){
                    newTask.phase__c = '';
                    newTask.Start__c = Date.today();
                    newTask.Finish__c = Date.today();
                    newTask.duration__c = 1;
                    newTask.lag__c = 0;
                } else if (BT_Utils.getSObjectPrefix(BT_Constants.OBJECT_TYPE_SCHEDULE).equals(parentId.substring(0, 3))){
                    newTask.Schedule__c = parentId;
                    newTask.Start__c = Date.today();
                    newTask.Finish__c = Date.today();
                    newTask.duration__c = 1;
                    newTask.lag__c = 0;
                } else{
                    newTask.phase__c = parentId;
                    newTask.Start__c = Date.today();
                    newTask.Finish__c = Date.today();
                    newTask.duration__c = 1;
                    newTask.lag__c = 0;
                }
            } else{
                newTask.Start__c = Date.today();
                newTask.Finish__c = Date.today();
                newTask.duration__c = 1;
                newTask.lag__c = 0;
            }
        } catch (Exception exp){
            System.debug('Error Message::' + exp.getMessage());
            throw new AuraHandledException('Error Occurs:: ');
        }
    }

    public void initNewTask1(){
        existingTask1 = '';
        String parentPhase = ApexPages.currentPage().getParameters().get('parentPhase').escapeHtml4();
        String parentId = ApexPages.currentPage().getParameters().get('parentId').escapeHtml4();
        newTask = new Project_Task__c();
        newTask.Project__c = projectId;
        try{
            if (scheduleId != null){
                newTask.Schedule__c = scheduleId;
            }

            if (!String.isBlank(parentPhase) && parentPhase.length() > 1){
                newTask.Phase__c = parentPhase.UnescapeHTML4();
                newTask.Start__c = Date.today();
                newTask.Finish__c = Date.today();
                newTask.duration__c = 1;
            }
        } catch (Exception exp){
            System.debug('Error Message::' + exp.getMessage());
            throw new AuraHandledException('Error Occurs:: ');
        }
    }

    @RemoteAction
    global static String insertBTTask(String taskJson, String scheduleId){
        Project_Task__c newtask = (Project_Task__c)System.JSON.deserialize(taskJson, Project_Task__c.class);
            if (newtask.buildertek__Start__c != null){
                Date sDate = newtask.buildertek__Start__c;
                if (newTask.buildertek__Duration__c != null && newTask.buildertek__Duration__c > 0){
                    Date eDate = sDate.addDays(Integer.valueOf(newTask.Duration__c)-1);
                    newTask.Finish__c = getEndDate(sDate, eDate);
                } else{
                    newTask.Finish__c = getEndDate(sDate, sDate);
                }
                
                ProjectTaskTriggerHandler.isFromImport = false;
                try{
                    if (newtask.Id != null){
                        update newtask;
                    } else{
                        newtask.buildertek__Schedule__c = scheduleId;
                        newtask.buildertek__Original_Start_Date__c = newtask.buildertek__Start__c;
                        newtask.buildertek__Original_End_Date__c = newtask.buildertek__Finish__c;
                        insert newtask;
                    }
                }catch(Exception e){
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
                    ApexPages.addMessage(msg);
                    //throw new AuraHandledException(e.getMessage());
                   return e.getMessage();
                }
               
                Project_Task__c projTask = [Select Id, Project__c, buildertek__Schedule__c
                                            from Project_Task__c
                                            where id = :newTask.Id];
                Integer totalRecs = [select count()
                                     FROM buildertek__Project_Task__c
                                     WHERE buildertek__Schedule__c = :scheduleId];
                
                system.debug(getJSON(projTask.Project__c, scheduleId, 50, 0, totalRecs, true, true));
                //BT_Task_Manager_Controller.allGanttJSON = getJSON(projTask.Project__c, scheduleId, totalRecs, 0, totalRecs, true, true);
                //getAllRecords() ;
                return getJSON(projTask.Project__c, scheduleId, 50, 0, totalRecs, true, true);
            }
            return null;
    }

    @RemoteAction
    global static String updateBTTask(String taskJson, String scheduleId){
        Project_Task__c newtask = (Project_Task__c)System.JSON.deserialize(taskJson, Project_Task__c.class);
        system.debug('newtask ------> ' + newtask);
        Date sDate = newtask.buildertek__Start__c;
        Integer workingDays = 0;
        system.debug('buildertek__Finish__c'+newtask.buildertek__Finish__c);
        //Add finish date
        if (newTask.buildertek__Duration__c != null && newTask.buildertek__Duration__c > 0){
            Date eDate = sDate.addDays(Integer.valueOf(newTask.Duration__c)-1);
            newTask.Finish__c = getEndDate(sDate, eDate);//Calculate and add weekends.
        } else{
            newTask.Finish__c = getEndDate(sDate, sDate);//Calculate and add weekends.
        }

        //When first time Task is created assign start and end date.
        if (newtask.Id == null){
            newtask.buildertek__Original_Start_Date__c = newtask.buildertek__Start__c;
            newtask.buildertek__Original_End_Date__c = newtask.buildertek__Finish__c;
        }
        ProjectTaskTriggerHandler.isFromImport = false;
        upsert newtask;

        //Retrive updated Task
        Project_Task__c projTask = [Select Id, Name, Project__c, Start__c, Finish__c, buildertek__Milestone__c, Duration__c, Completion__c, schedule__c, Phase__c, Resource__r.Name, buildertek__Contractor_Resource__r.Name, buildertek__Dependency__c, buildertek__Lag__c, buildertek__Notes__c, buildertek__Contractor__c, buildertek__Resource__c
                                    from Project_Task__c
                                    where id = :newTask.Id];
        return getUpdatedJSON(projTask);
    }

    public static String getUpdatedJSON(Project_Task__c projectTask){
        Data d = new Data();
        d.id = projectTask.Id;
        d.text = projectTask.Name;
        d.contractorResource = '-';
        if (projectTask.buildertek__Contractor_Resource__r.Name != null){
            d.contractorResource = projectTask.buildertek__Contractor_Resource__r.Name;
        }
        if (projectTask.Start__c != null){
            d.start_date = projectTask.Start__c.month()+'-' + projectTask.Start__c.day()+'-' + projectTask.Start__c.year();
        }
        if (projectTask.Finish__c != null){
            Date eDate = projectTask.Finish__c;
            eDate = eDate.addDays(1);
            d.end_date = eDate.month()+'-' + eDate.day()+'-' + eDate.year();
        }
        d.duration = string.valueOf(projectTask.Duration__c);
        d.progress = string.valueOf(projectTask.Completion__c != null ? projectTask.Completion__c / 100 : 0);
        d.progress1 = string.valueOf((projectTask.Completion__c != null ? projectTask.Completion__c : 0).round())+'%';
        d.open = true;
        if (projectTask.buildertek__Milestone__c){
            d.type = 'milestone';
        } else{
            d.type = 'task';
        }
        if (projectTask.Resource__c != null)
            d.resource = projectTask.Resource__r.Name;
        else
            d.resource = '-';
        if (!String.isBlank(projectTask.Phase__c))
            d.parent = projectTask.Phase__c;
        else
            d.parent = projectTask.schedule__c;
        d.contractorResource = projectTask.buildertek__Contractor_Resource__r.Name;
        if (String.isNotBlank(projectTask.buildertek__Dependency__c)){
            d.dependency = projectTask.buildertek__Dependency__c;
        } else{
            d.dependency = '';
        }
        projectTask.Completion__c = projectTask.Completion__c == null ? 0 : projectTask.Completion__c;
        if (projectTask.Completion__c == 100){
            d.color = 'rgb(93, 219, 70)';// Task is completed Green color
        } else if (projectTask.Finish__c != null && projectTask.Finish__c < Date.today() && projectTask.Completion__c < 100){
            d.color = 'rgb(224, 25, 25)';
        } else{
            d.color = 'rgb(61,185,211)';
        }
        if (projectTask.buildertek__Lag__c != null){
            d.lag = projectTask.buildertek__Lag__c;
        }
        if (projectTask.buildertek__Notes__c != null)
            d.notes = projectTask.buildertek__Notes__c;
        else
            d.notes = '';
        if (projectTask.buildertek__Contractor__c != null){
            d.contractor = projectTask.buildertek__Contractor__c;
        }
        if (projectTask.buildertek__Resource__c != null){
            d.internalResource = projectTask.buildertek__Resource__c;
        }
        return JSON.serialize(d);
    }

    @RemoteAction
    global static String insertNewTaskLinks(String taskJson){
        return null;
    }

    @RemoteAction
    global static String getNewTaskFieldsetInfo(String taskJson){
        return null;
    }

    @RemoteAction
    global static String changeTaskSchedulingMode(String taskJson){
        return null;
    }

    @RemoteAction
    global static String getAllProjectJSON(String taskJson){
        return null;
    }

    //Calculate and add weekends.
    public static Date getEndDate(Date sDate, Date eDate){
        try{
            for (integer j = 0; j <= sDate.daysBetween(eDate); j++){
                Date dt = sDate + j;
                DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                String todayDay = currDate.format('EEEE');
                if (todayDay == 'Saturday' || todayDay == 'Sunday'){
                    eDate = eDate.addDays(1);
                }
            }
            return eDate;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @RemoteAction
    global static String saveGanttData(String taskJson, String taskLinkJson){
        List<GanttChart.Data> tasks = (List<GanttChart.Data>)JSON.deserializeStrict(taskJson, List<GanttChart.Data>.class);
        List<GanttChart.Links> links = (List<GanttChart.Links>)JSON.deserializeStrict(taskLinkJson, List<GanttChart.Links>.class);

        Map<Id, GanttChart.Links> ganttTargetLinks = new Map<Id, GanttChart.Links>();
        for (GanttChart.Links link : links){
            ganttTargetLinks.put(link.target, link);
        }

        List<Project_Task__c> taskToUpdate = new List<Project_Task__c>();
        List<string> ListRec = new List<string>();
        Integer i = 0;
        Map<String, GanttChart.Data> MapGanttChart = new Map<String, GanttChart.Data>();
        
        Integer o = 1;
       
       
        //Integer o = BT_Task_Manager_Controller.offsetSizeDup+1;
        for (GanttChart.Data data : tasks){
            Project_Task__c projectTask = new Project_Task__c();
            ListRec.add(data.Id);
            data.order = o;
            
            MapGanttChart.put(data.Id, data);
            system.debug(data);
            system.debug(data.order);
            o++;
        }

        taskToUpdate = [select id, Name, Duration__c, Start__c, Finish__c, Completion__c, lag__c, Dependency__c, Order__c, Schedule__c
                        from Project_Task__c
                        where id IN :ListRec];

        List<String> updatedTaskIds = new List<String>();
        for (Project_Task__c projectTask : taskToUpdate){
            if (MapGanttChart.get(projectTask.Id) != null){
                updatedTaskIds.add(projectTask.Id);
                projectTask.Name = MapGanttChart.get(projectTask.Id).text;
                projectTask.Duration__c = double.valueof(MapGanttChart.get(projectTask.Id).duration);
                projectTask.Start__c = Date.valueOf(MapGanttChart.get(projectTask.Id).start_date);
                Date sDate = Date.valueOf(MapGanttChart.get(projectTask.Id).start_date);
                if (projectTask.Duration__c != null && Integer.valueOf(projectTask.Duration__c) > 0){
                    Date eDate = sDate.addDays(Integer.valueOf(projectTask.Duration__c)-1);
                    projectTask.Finish__c = getEndDate(sDate, eDate);
                } else{
                    projectTask.Finish__c = sDate;
                }

                if (MapGanttChart.get(projectTask.Id).type == 'milestone'){
                    projectTask.Finish__c = sDate;
                }
                projectTask.Completion__c = MapGanttChart.get(projectTask.Id).progress != '' && MapGanttChart.get(projectTask.Id).progress != null ? Double.valueOf(MapGanttChart.get(projectTask.Id).progress) * 100:0;
                if (ganttTargetLinks.containsKey(projectTask.Id)){
                    projectTask.lag__c = ganttTargetLinks.get(projectTask.Id).lag;
                    projectTask.Dependency__c = ganttTargetLinks.get(projectTask.Id).source;
                } else{
                    projectTask.lag__c = 0;
                    projectTask.Dependency__c = null;
                }
                projectTask.Order__c = double.valueof(MapGanttChart.get(projectTask.Id).order);
                system.debug(projectTask.Name+' '+projectTask.buildertek__Order__c);
                i++;
            }
        }
        ProjectTaskTriggerHandler.isFromImport = false;
        update taskToUpdate;
        String updatedTaskIdString;
        /*if(updatedTaskIds.Size() > 0){
            updatedTaskIdString = JSON.serialize(updatedTaskIds);
            return updatedTaskIdString;
        }*/
        
        //getJSON(projectId, scheduleId, 50, 0, totalRecs, true, true);
        return null;
    }
    
   /* @RemoteAction
    global static String saveGanttData(String taskJson, String taskLinkJson){
        List<GanttChart.Data> tasks = (List<GanttChart.Data>)JSON.deserializeStrict(taskJson, List<GanttChart.Data>.class);
        List<GanttChart.Links> links = (List<GanttChart.Links>)JSON.deserializeStrict(taskLinkJson, List<GanttChart.Links>.class);

        Map<Id, GanttChart.Links> ganttTargetLinks = new Map<Id, GanttChart.Links>();
        for (GanttChart.Links link : links){
            ganttTargetLinks.put(link.target, link);
        }

        List<Project_Task__c> taskToUpdate = new List<Project_Task__c>();
        List<string> ListRec = new List<string>();
        Integer i = 0;
        Map<String, GanttChart.Data> MapGanttChart = new Map<String, GanttChart.Data>();
        
        Integer o = 0;
       
       
        //Integer o = BT_Task_Manager_Controller.offsetSizeDup+1;
        for (GanttChart.Data data : tasks){
            Project_Task__c projectTask = new Project_Task__c();
            ListRec.add(data.Id);
            data.order = o;
            
            MapGanttChart.put(data.Id, data);
            system.debug(data);
            system.debug(data.order);
            o++;
        }

        taskToUpdate = [select id, Name, Duration__c, Start__c, Finish__c, Completion__c, lag__c, Dependency__c, Order__c, Schedule__c
                        from Project_Task__c
                        where id IN :ListRec];

        for (Project_Task__c projectTask : taskToUpdate){
            if (MapGanttChart.get(projectTask.Id) != null){
                projectTask.Name = MapGanttChart.get(projectTask.Id).text;
                projectTask.Duration__c = double.valueof(MapGanttChart.get(projectTask.Id).duration);
                projectTask.Start__c = Date.valueOf(MapGanttChart.get(projectTask.Id).start_date);
                Date sDate = Date.valueOf(MapGanttChart.get(projectTask.Id).start_date);
                if (projectTask.Duration__c != null && Integer.valueOf(projectTask.Duration__c) > 0){
                    Date eDate = sDate.addDays(Integer.valueOf(projectTask.Duration__c)-1);
                    projectTask.Finish__c = getEndDate(sDate, eDate);
                } else{
                    projectTask.Finish__c = sDate;
                }

                if (MapGanttChart.get(projectTask.Id).type == 'milestone'){
                    projectTask.Finish__c = sDate;
                }
                projectTask.Completion__c = MapGanttChart.get(projectTask.Id).progress != '' && MapGanttChart.get(projectTask.Id).progress != null ? Double.valueOf(MapGanttChart.get(projectTask.Id).progress) * 100:0;
                if (ganttTargetLinks.containsKey(projectTask.Id)){
                    projectTask.lag__c = ganttTargetLinks.get(projectTask.Id).lag;
                    projectTask.Dependency__c = ganttTargetLinks.get(projectTask.Id).source;
                } else{
                    projectTask.lag__c = 0;
                    projectTask.Dependency__c = null;
                }
                projectTask.Order__c = double.valueof(MapGanttChart.get(projectTask.Id).order);
                system.debug(projectTask.Name+' '+projectTask.buildertek__Order__c);
                i++;
            }
        }
        ProjectTaskTriggerHandler.isFromImport = false;
        update taskToUpdate;
        return null;
    }*/

    @RemoteAction
    global static String deleteTaskLinkById(String taskJson){
        return null;
    }

    @RemoteAction
    global static String deleteTaskById(String taskId, String projectId, String scheduleId){
        List<Schedule__c> sc = [Select Id, name
                                from Schedule__c
                                WHERE ID = :taskId];
        if (sc.size() > 0){
            sc[0].Id = taskId;
            if (Schedule__c.sObjectType.getDescribe().isDeletable()){
                delete sc;
            }
        }

        List<Project_Task__c> projectTask = [Select Id, name, Phase__c
                                             from Project_Task__c
                                             WHERE (Phase__c = :taskId AND Schedule__c = :scheduleId) OR (Id = :taskId AND Schedule__c = :scheduleId)];
        if (projectTask.size() > 0){
            if (Project_Task__c.sObjectType.getDescribe().isDeletable()){
                delete projectTask;
            }
        }
        Integer totalRecs = [select count()
                             FROM buildertek__Project_Task__c
                             WHERE buildertek__Schedule__c = :scheduleId];
        system.debug('totalRecs '+totalRecs);
        //BT_Task_Manager_Controller.allGanttJSON = getJSON(projectId, scheduleId, totalRecs, 0, totalRecs, true, true);
        return getJSON(projectId, scheduleId, 50, 0, totalRecs, true, true);
    }

    public class Json2ApexConverter{
        public Attributes attributes{ get; set; }

        public String buildertekProjectzz{ get; set; }

        public String buildertekSchedulezz{ get; set; }

        public String Name{ get; set; }

        public String buildertekPhasezz{ get; set; }

        public Integer buildertekDurationzz{ get; set; }

        public String buildertekStartzz{ get; set; }
    }

    public class Attributes{
        public String type_Z{ get; set; }

        // in json: type
    }

    public class Data{
        public String id{ get; set; }

        public String text{ get; set; }

        public String start_date{ get; set; }

        public String end_date{ get; set; }

        public String duration{ get; set; }

        public String progress{ get; set; }

        public string progress1{ get; set; }

        public string contractorResource{ get; set; }

        public Boolean open{ get; set; }

        public String type{ get; set; }

        public String dependency{ get; set; }

        public String contractor{ get; set; }

        public String notes{ get; set; }

        public String internalResource{ get; set; }

        public Decimal lag{ get; set; }

        public String parent{ get; set; }

        public String resource{ get; set; }

        public String color{ get; set; }

        public Integer order{ get; set; }

        public String templates{ get; set; }
    }
}