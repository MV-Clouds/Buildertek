public with sharing class ScheduleTriggerHandler{
    public static Boolean isFirstTime = true;
    public static Boolean isTask = true;
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipScheduleTrigger = false;
    public Boolean blnSkipTaskTrigger = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public ScheduleTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    @Future(CallOut = true)
    public static void FutureMethodCallOut_ForUpdatingProject(Set<Id> projectIdSet){
        List<buildertek__Schedule__c> scheduleList;
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        scheduleList = [SELECT Id, Name, buildertek__End_Date__c, buildertek__Primary_Schedule__c, buildertek__Start_Date__c, buildertek__Project__c
                        FROM buildertek__Schedule__c
                        WHERE buildertek__Project__c IN :projectIdSet
                        ORDER BY CreatedDate ASC];

        if (scheduleList.size() > 0){
            if (scheduleList.size() > 1){
                for (buildertek__Schedule__c schedule : scheduleList){
                    if (schedule.buildertek__Primary_Schedule__c == true){
                        if (schedule.buildertek__Project__c != null && String.isNotBlank(schedule.buildertek__Project__c)){
                            buildertek__Project__c proj = new buildertek__Project__c();
                            proj.Id = schedule.buildertek__Project__c;
                            proj.buildertek__Anticipated_Start_Date__c = schedule.buildertek__Start_Date__c;
                            proj.buildertek__Estimated_Completion_Date__c = schedule.buildertek__End_Date__c;
                            projectList.add(proj);
                        }
                    }
                }
            } else{
                for (buildertek__Schedule__c schedule : scheduleList){
                    if (schedule.buildertek__Project__c != null && String.isNotBlank(schedule.buildertek__Project__c)){
                        buildertek__Project__c proj = new buildertek__Project__c();
                        proj.Id = schedule.buildertek__Project__c;
                        proj.buildertek__Anticipated_Start_Date__c = schedule.buildertek__Start_Date__c;
                        proj.buildertek__Estimated_Completion_Date__c = schedule.buildertek__End_Date__c;
                        projectList.add(proj);
                    }
                    if(schedule.buildertek__Start_Date__c!=null && schedule.buildertek__End_Date__c!=null){
                    //futureContoller.updateScheduleRec(schedule.Id);
                    }
                }
            }
            update projectList;
        }
    }
    
    public void getScheduleItemCount(buildertek__Schedule__c[] schedules, Map<ID, buildertek__Schedule__c> schedulesMap){
       if(ScheduleTriggerHandler.isFirstTime){
            ScheduleTriggerHandler.isFirstTime = false;
            List<buildertek__Schedule__c> scheduleList = [select Id, (Select Id,buildertek__Milestone__c from buildertek__Schedule_Tasks__r) from buildertek__Schedule__c where Id IN:schedulesMap.keySet()];
            Map<String,Integer> scheduleAndTaskMap = new Map<String,Integer>();
            //[Select Id, buildertek__Schedule_Items_Count__c From buildertek__Schedule__c Where Id IN:schedulesMap.keySet()];
            List<buildertek__Schedule__c> updateScheduleList = new List<buildertek__Schedule__c>();
            //Integer TaskCount = [select count() from buildertek__Project_Task__c where buildertek__Schedule__c= 'a101K00000BQ8CuQAL'];
            for(buildertek__Schedule__c schItem: scheduleList){
                scheduleAndTaskMap.put(schItem.Id,schItem.buildertek__Schedule_Tasks__r.Size());
                buildertek__Schedule__c schRec = new buildertek__Schedule__c();
                schRec.Id = schItem.Id;
                schRec.buildertek__Schedule_Items_Count__c = schItem.buildertek__Schedule_Tasks__r.Size();
                if(schItem.buildertek__Start_Date__c!=null && schItem.buildertek__End_Date__c!=null){
           /*if(schItem.buildertek__Original_Start_Date__c==null && schItem.buildertek__Original_End_Date__c==null){
               schRec.buildertek__Original_Start_Date__c=schItem.buildertek__Start_Date__c;
                schRec.buildertek__Original_End_Date__c=schItem.buildertek__End_Date__c;
                }*/
           }
                for(buildertek__Project_Task__c task : schItem.buildertek__Schedule_Tasks__r){
                    system.debug(task);
                }
                system.debug(schItem.buildertek__Schedule_Tasks__r.size());
                updateScheduleList.add(schRec);
            }
            
            update updateScheduleList;
            
            /*buildertek__Schedule__c schRec = new buildertek__Schedule__c();
            schRec.Id = sch.Id;
            schRec.buildertek__Schedule_Items_Count__c = */
        }
    }
    
    //update original dates


    // @future
    // public static void afterUpdateHandler(String newTrigger, String oldmapTrigger, Boolean isExecuting, Integer triggerSize){
    //     try{
    //         UpdateProjecttOnScheduleUpdateHandler projectUpdateHandler = new UpdateProjecttOnScheduleUpdateHandler();
    //         List<buildertek__Schedule__c> schList = (List<buildertek__Schedule__c>)System.JSON.deserialize(newTrigger, List<buildertek__Schedule__c>.class);
    //         Map<Id,buildertek__Schedule__c> schmap = (Map<Id,buildertek__Schedule__c>)System.JSON.deserialize(oldmapTrigger, Map<Id,buildertek__Schedule__c>.class);
    //         SET<Id> projectIdSet = new SET<Id>();
    //         SET<Id> scheduleIds = new SET<Id>();
    //         Set<Id> scheduleShare = new Set<Id>();
            
    //         List<buildertek__Schedule__c> scheduleToUpdate = new List<buildertek__Schedule__c>();
    //         Map<Id, buildertek__Schedule__c> scheduleMap = new Map<Id, buildertek__Schedule__c>();
    //         List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
    //         for (buildertek__Schedule__c sch : schList){
    //             scheduleIds.add(sch.Id);
    //             projectIdSet.add(sch.buildertek__Project__c);
    //             if (schmap.get(sch.Id).buildertek__Vendor_Visible__c != sch.buildertek__Vendor_Visible__c && (sch.buildertek__Vendor_Visible__c)){
    //                 scheduleShare.add(sch.Project__r.buildertek__Account__r.Id);
    //             }
    //         }
            
    //         List<buildertek__Project__c> projectRecList = new List<buildertek__Project__c>();
    //         List<buildertek__Project__c> updateprojectRecList = new List<buildertek__Project__c>();
            
    //         if (scheduleShare.size() > 0){
    //             delete [Select Id
    //                     FROM buildertek__Schedule__Share
    //                     WHERE UserOrGroupId = :scheduleShare AND AccessLevel = :'Read' AND RowCause = :'Manual'];
    //         }
    
    //         if (projectIdSet.size() > 0){
    //             List<buildertek__Schedule__c> scheduleList;
    
    //             scheduleList = [SELECT Id, Name, buildertek__End_Date__c, buildertek__Primary_Schedule__c, buildertek__Start_Date__c, buildertek__Project__c
    //                             FROM buildertek__Schedule__c
    //                             WHERE buildertek__Project__c IN :projectIdSet
    //                             ORDER BY CreatedDate ASC];
    
    //             if (scheduleList.size() > 0){
    //                 if (scheduleList.size() > 1){
    //                     for (buildertek__Schedule__c schedule : scheduleList){
    //                         if (schedule.buildertek__Primary_Schedule__c == true){
    //                             if (schedule.buildertek__Project__c != null && String.isNotBlank(schedule.buildertek__Project__c)){
    //                                 buildertek__Project__c proj = new buildertek__Project__c();
    //                                 proj.Id = schedule.buildertek__Project__c;
    //                                 proj.buildertek__Anticipated_Start_Date__c = schedule.buildertek__Start_Date__c;
    //                                 proj.buildertek__Estimated_Completion_Date__c = schedule.buildertek__End_Date__c;
    //                                 projectList.add(proj);
    //                             }
    //                         }
    //                     }
    //                 } else{
    //                     for (buildertek__Schedule__c schedule : scheduleList){
    //                         if (schedule.buildertek__Project__c != null && String.isNotBlank(schedule.buildertek__Project__c)){
    //                             buildertek__Project__c proj = new buildertek__Project__c();
    //                             proj.Id = schedule.buildertek__Project__c;
    //                             proj.buildertek__Anticipated_Start_Date__c = schedule.buildertek__Start_Date__c;
    //                             proj.buildertek__Estimated_Completion_Date__c = schedule.buildertek__End_Date__c;
    //                             projectList.add(proj);
    //                         }
    //                     }
    //                 }
    //                 // ProjectTriggerHandler.blnSkipProjectTrigger = true;
    //                 projectUpdateHandler.updateProjectList_New(projectList);
    //                 // ProjectTriggerHandler.blnSkipProjectTrigger = false;
    //                // update projectList;
    //             }
    //         }
    //         projectList = new List<buildertek__Project__c>();
    //         for (AggregateResult ag : [SELECT buildertek__Project__c, AVG(buildertek__Complete__c)avg
    //                                    FROM buildertek__Schedule__c
    //                                    GROUP BY buildertek__Project__c]){
    //             if ((Id)ag.get('buildertek__Project__c') != null){
    //                 //projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg')));
    //                 if((Decimal)ag.get('avg') == 100){
    //                     projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'), buildertek__Actual_Completion_Date__c = system.today()));
    //                 }else if((Decimal)ag.get('avg') < 100){
    //                     //projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'), buildertek__Actual_Completion_Date__c = null));
    //                     projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg')));
    //                 }
    //             }
    //         }
    //         if (projectList.size() > 0){
    //             System.debug('Size of Trigger ------------------------> '+projectList.size());
    //             ProjectTriggerHandler.blnSkipProjectTrigger = true;
    //             projectUpdateHandler.updateProjectList_New(projectList);
    //             ProjectTriggerHandler.blnSkipProjectTrigger = false;
    //             //update projectList;
    //         }
    //         List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
    //        /* List<buildertek__Schedule__c> schedulesList = [Select Id, buildertek__Contractor__c, buildertek__External_Resource__c, buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c, (Select Id,buildertek__Start__c,buildertek__Finish__c, buildertek__Use_Project_Manager_from_Schedule__c, buildertek__Use_Internal_Resource_from_Schedule__c, buildertek__Use_External_Resource_from_Schedule__c
    //                                                                                                                                                                                                     FROM buildertek__Schedule_Tasks__r)
    //                                                        FROM buildertek__Schedule__c
    //                                                        WHERE Id In :scheduleIds];*/
    //         for( buildertek__Schedule__c  scheduleRec :   [Select Id, buildertek__Contractor__c, buildertek__External_Resource__c, buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c, (Select Id,buildertek__Start__c,buildertek__Finish__c, buildertek__Use_Project_Manager_from_Schedule__c, buildertek__Use_Internal_Resource_from_Schedule__c, buildertek__Use_External_Resource_from_Schedule__c FROM buildertek__Schedule_Tasks__r)
    //                                                        FROM buildertek__Schedule__c
    //                                                        WHERE Id In :scheduleIds]){
    //         //for (buildertek__Schedule__c scheduleRec : schedulesList){
    //             for (buildertek__Project_Task__c projectTaskRec : scheduleRec.buildertek__Schedule_Tasks__r){
    //                 buildertek__Project_Task__c taskRec = new buildertek__Project_Task__c();
    //                 taskRec.Id = projectTaskRec.Id;
    //                 if (projectTaskRec.buildertek__Use_External_Resource_from_Schedule__c){
    //                     taskRec.buildertek__Contractor_Resource__c = scheduleRec.buildertek__External_Resource__c;
    //                 }
    //                 if (projectTaskRec.buildertek__Use_Internal_Resource_from_Schedule__c){
    //                     taskRec.buildertek__Resource__c = scheduleRec.buildertek__Internal_Resource_1__c;
    //                 }
    //                 if (projectTaskRec.buildertek__Use_Project_Manager_from_Schedule__c){
    //                     taskRec.buildertek__Project_Manager__c = scheduleRec.buildertek__Project_Manager__c;
    //                 }
    //                 projectTasks.add(taskRec);
    //             }
    //         }
    //         System.debug('Last 1');
    //         if (projectTasks.size() > 0){
    //             System.debug('Start 000');
    //             ScheduleTriggerHandler handler = new ScheduleTriggerHandler(isExecuting, triggerSize);
    //             ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
    //             handler.blnSkipTaskTrigger = true;
    //             update projectTasks;
    //             handler.blnSkipTaskTrigger = false;
    //             ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
    //         }
    //         System.debug('Last 2');
    //         //handler.getScheduleItemCount(Trigger.new, Trigger.newMap);
    //     }catch(Exception e){
    //         System.debug('Exception-->'+e);
    //         System.debug('Exception ln-->'+e.getLineNumber());
    //         System.debug('Exception cause-->'+e.getCause());
    //         System.debug('Exception cause-->'+e.getStackTraceString());
    //     }
    // }
}