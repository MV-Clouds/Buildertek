trigger ScheduleRecTrigger on buildertek__Schedule__c (after insert, after update, before delete, before update) {
    System.debug('*** ** ScheduleRecTrigger ** ***');
    ScheduleTriggerHandler handler = new ScheduleTriggerHandler(Trigger.isExecuting, Trigger.size);
    UpdateProjecttOnScheduleUpdateHandler projectUpdateHandler = new UpdateProjecttOnScheduleUpdateHandler();
    if (Trigger.isInsert && Trigger.isAfter && !handler.blnSkipTaskTrigger){

        SET<Id> projectIdSet = new SET<Id>();
        List<buildertek__Schedule__c> scheduleToUpdate = new List<buildertek__Schedule__c>();
        //Set<Id> scheduleIds = new Set<Id>();
        for (buildertek__Schedule__c sch : Trigger.new){
            projectIdSet.add(sch.buildertek__Project__c);
            //scheduleIds.add(sch.Id);
        }

        //handler.getScheduleItemCount(Trigger.new, Trigger.newMap);

        List<buildertek__Schedule__c> scheduleList;
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        List<buildertek__Project__c> projectRecList = new List<buildertek__Project__c>();
        List<buildertek__Project__c> updateprojectRecList = new List<buildertek__Project__c>();

        if (projectIdSet.size() > 0){

            projectRecList = [select Id,Name,buildertek__Actual_Start__c ,buildertek__Actual_Completion_Date__c, buildertek__Stage__c, buildertek__Original_Start_Date__c,buildertek__Original_End_Date__c ,
                                (select id,Name,buildertek__Start_Date__c,buildertek__End_Date__c,buildertek__Original_Start_Date__c,buildertek__Original_End_Date__c from buildertek__Schedules__r ORDER BY CreatedDate ASC)  from buildertek__Project__c where Id IN:projectIdSet];
            if(projectRecList.size()>0){
                for(buildertek__Project__c proj : projectRecList){
                    if(proj.buildertek__Schedules__r.size() > 0){
                        buildertek__Schedule__c sch = proj.buildertek__Schedules__r[0];
                        buildertek__Project__c newProj = new buildertek__Project__c();
                        newProj.Id = proj.Id;
                        system.debug('Ater Insert in Trigger ScheduleRecTrigger     ---> '+sch.buildertek__End_Date__c);
                        if (proj.buildertek__Stage__c != 'Completed') {
                            newProj.buildertek__Actual_Start__c = sch.buildertek__Start_Date__c;
                            newProj.buildertek__Actual_Completion_Date__c= sch.buildertek__End_Date__c;
                        }

                        newProj.buildertek__Original_Start_Date__c = sch.buildertek__Original_Start_Date__c;
                        newProj.buildertek__Original_End_Date__c = sch.buildertek__Original_End_Date__c;
                        System.debug('schedule debug'+sch.buildertek__Original_End_Date__c);
                        updateprojectRecList.add(newProj);
                    }
                }
            }
        }

        if(updateprojectRecList.size()>0){
            projectUpdateHandler.updateProjectList_New(updateprojectRecList);
            system.debug('updateprojectRecList'+updateprojectRecList);
        }

        scheduleList = [SELECT Id, Name, buildertek__End_Date__c, buildertek__Start_Date__c, buildertek__Primary_Schedule__c, buildertek__Project__c, buildertek__Project__r.buildertek__Project_Manager__c
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
                    /*else{
                        buildertek__Project__c proj = new  buildertek__Project__c();
                        proj.Id = schedule.buildertek__Project__c;
                        proj.buildertek__Estimated_Completion_Date__c = schedule.buildertek__End_Date__c;
                        projectList.add(proj);
                        }*/
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
                }
            }
            if (Schema.sObjectType.buildertek__Project__c.isUpdateable() && Schema.sObjectType.buildertek__Project__c.fields.Id.isUpdateable() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Anticipated_Start_Date__c.isUpdateable() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Estimated_Completion_Date__c.isUpdateable()){
                //update project on chedule update
                projectUpdateHandler.updateProjectList_New(projectList);
                //update projectList;
            }

            /* projectList = new List<buildertek__Project__c>();
            for (AggregateResult ag : [SELECT buildertek__Project__c, AVG(buildertek__Complete__c)avg
                                        FROM buildertek__Schedule__c
                                        WHERE buildertek__Project__c IN :projectIdSet
                                        GROUP BY buildertek__Project__c]){

                if ((Id)ag.get('buildertek__Project__c') != null){
                    projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg')));
                }
            }
            if (projectList.size() > 0){
                //update project on chedule update
                    projectUpdateHandler.updateProjectList_New(projectList);
                // update projectList;
            } */


            projectList = new List<buildertek__Project__c>();
            for (AggregateResult ag : [SELECT buildertek__Project__c, AVG(buildertek__Complete__c)avg
                                        FROM buildertek__Schedule__c
                                        WHERE buildertek__Project__c IN :projectIdSet
                                        GROUP BY buildertek__Project__c]){
                if ((Id)ag.get('buildertek__Project__c') != null){
                    if((Decimal)ag.get('avg') == 100){
                        projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'), buildertek__Actual_Completion_Date__c = system.today()));
                    }else if((Decimal)ag.get('avg') < 100){
                        //projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'),buildertek__Actual_Completion_Date__c = null));
                        projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg')));
                    }
                    //projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg')));
                }
            }
            if (projectList.size() > 0){
                //update project on schedule update
                    projectUpdateHandler.updateProjectList_New(projectList);
                // update projectList;
            }
        }
    }

    if (Trigger.isUpdate && Trigger.isAfter && !handler.blnSkipTaskTrigger){
        try{
            SET<Id> projectIdSet = new SET<Id>();
            SET<Id> scheduleIds = new SET<Id>();
            Set<Id> scheduleShare = new Set<Id>();

            List<buildertek__Schedule__c> scheduleToUpdate = new List<buildertek__Schedule__c>();
            Map<Id, buildertek__Schedule__c> scheduleMap = new Map<Id, buildertek__Schedule__c>();
            List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
            for (buildertek__Schedule__c sch : Trigger.new){
                scheduleIds.add(sch.Id);
                projectIdSet.add(sch.buildertek__Project__c);
                if (trigger.oldMap.get(sch.Id).buildertek__Vendor_Visible__c != sch.buildertek__Vendor_Visible__c && (sch.buildertek__Vendor_Visible__c)){
                    scheduleShare.add(sch.Project__r.buildertek__Account__r.Id);
                }
            }

            List<buildertek__Project__c> projectRecList = new List<buildertek__Project__c>();
            List<buildertek__Project__c> updateprojectRecList = new List<buildertek__Project__c>();

            if (scheduleShare.size() > 0){
                delete [Select Id
                        FROM buildertek__Schedule__Share
                        WHERE UserOrGroupId = :scheduleShare AND AccessLevel = :'Read' AND RowCause = :'Manual'];
            }

            if (projectIdSet.size() > 0){
                List<buildertek__Schedule__c> scheduleList;

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
                        }
                    }
                    ProjectTriggerHandler.blnSkipProjectTrigger = true;
                    projectUpdateHandler.updateProjectList_New(projectList);
                    ProjectTriggerHandler.blnSkipProjectTrigger = false;
                }
            }
            projectList = new List<buildertek__Project__c>();
            for (AggregateResult ag : [SELECT buildertek__Project__c, AVG(buildertek__Complete__c)avg
                                       FROM buildertek__Schedule__c
                                       WHERE buildertek__Project__c IN :projectIdSet
                                       GROUP BY buildertek__Project__c]){
                if ((Id)ag.get('buildertek__Project__c') != null){
                    if((Decimal)ag.get('avg') == 100){
                        projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'), buildertek__Actual_Completion_Date__c = system.today()));
                    }else if((Decimal)ag.get('avg') < 100){
                        projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg')));
                    }
                }
            }
            if (projectList.size() > 0){
                System.debug('Size of Trigger ------------------------> '+projectList.size());
                ProjectTriggerHandler.blnSkipProjectTrigger = true;
                projectUpdateHandler.updateProjectList_New(projectList);
                ProjectTriggerHandler.blnSkipProjectTrigger = false;
            }
            List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();

            for( buildertek__Schedule__c  scheduleRec :   [Select Id, buildertek__Contractor__c, buildertek__External_Resource__c, buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c, (Select Id,buildertek__Start__c,buildertek__Finish__c, buildertek__Use_Project_Manager_from_Schedule__c, buildertek__Use_Internal_Resource_from_Schedule__c, buildertek__Use_External_Resource_from_Schedule__c FROM buildertek__Schedule_Tasks__r)
                                                           FROM buildertek__Schedule__c
                                                           WHERE Id In :scheduleIds]){

                for (buildertek__Project_Task__c projectTaskRec : scheduleRec.buildertek__Schedule_Tasks__r){
                    Boolean flag = false;
                    buildertek__Project_Task__c taskRec = new buildertek__Project_Task__c();
                    taskRec.Id = projectTaskRec.Id;
                    if (projectTaskRec.buildertek__Use_External_Resource_from_Schedule__c){
                        taskRec.buildertek__Contractor_Resource__c = scheduleRec.buildertek__External_Resource__c;
                        flag = true;
                    }
                    if (projectTaskRec.buildertek__Use_Internal_Resource_from_Schedule__c){
                        taskRec.buildertek__Resource__c = scheduleRec.buildertek__Internal_Resource_1__c;
                        flag = true;
                    }
                    if (projectTaskRec.buildertek__Use_Project_Manager_from_Schedule__c){
                        taskRec.buildertek__Project_Manager__c = scheduleRec.buildertek__Project_Manager__c;
                        flag = true;
                    }

                    if(flag){
                        projectTasks.add(taskRec);
                    }
                }
            }
            if (projectTasks.size() > 0){
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
                handler.blnSkipTaskTrigger = true;
                update projectTasks;
                handler.blnSkipTaskTrigger = false;
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
            }
            System.debug('Last 2');
        }catch(Exception e){
            System.debug('Exception-->'+e);
            System.debug('Exception ln-->'+e.getLineNumber());
            System.debug('Exception cause-->'+e.getCause());
            System.debug('Exception cause-->'+e.getStackTraceString());
        }
    }

    if (trigger.isDelete && trigger.isBefore){


         SET<Id> projectIdSet = new SET<Id>();
        List<buildertek__Schedule__c> scheduleToUpdate = new List<buildertek__Schedule__c>();
        //Set<Id> scheduleIds = new Set<Id>();

        if(Trigger.new != null){
            for (buildertek__Schedule__c sch : Trigger.new){
                projectIdSet.add(sch.buildertek__Project__c);
                //scheduleIds.add(sch.Id);
            }
        }else if(Trigger.old != null){
            for (buildertek__Schedule__c sch : Trigger.old){
                projectIdSet.add(sch.buildertek__Project__c);
                //scheduleIds.add(sch.Id);
            }
        }



        List<buildertek__Schedule__c> scheduleList;
        List<buildertek__Project__c> projectList = new List<buildertek__Project__c>();
        if (projectIdSet.size() > 0){

            scheduleList = [SELECT Id, Name, buildertek__End_Date__c, buildertek__Start_Date__c, buildertek__Primary_Schedule__c, buildertek__Project__c, buildertek__Project__r.buildertek__Project_Manager__c
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
                        /*else{
                         buildertek__Project__c proj = new  buildertek__Project__c();
                         proj.Id = schedule.buildertek__Project__c;
                         proj.buildertek__Estimated_Completion_Date__c = schedule.buildertek__End_Date__c;
                         projectList.add(proj);
                         }*/
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
                    }
                }
                if (Schema.sObjectType.buildertek__Project__c.isUpdateable() && Schema.sObjectType.buildertek__Project__c.fields.Id.isUpdateable() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Anticipated_Start_Date__c.isUpdateable() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Estimated_Completion_Date__c.isUpdateable()){
                    //update project on chedule update
                     ProjectTriggerHandler.blnSkipProjectTrigger = true;
                    projectUpdateHandler.updateProjectList_New(projectList);
                     ProjectTriggerHandler.blnSkipProjectTrigger = false;
                   // update projectList;
                }

                /* projectList = new List<buildertek__Project__c>();
                for (AggregateResult ag : [SELECT buildertek__Project__c, AVG(buildertek__Complete__c)avg
                                           FROM buildertek__Schedule__c
                                           WHERE buildertek__Project__c IN :projectIdSet
                                           GROUP BY buildertek__Project__c]){
                    if ((Id)ag.get('buildertek__Project__c') != null){
                       // projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg')));
                        if((Decimal)ag.get('avg') == 100){
                             projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'),buildertek__Actual_Completion_Date__c = system.today()));
                        }else if((Decimal)ag.get('avg') < 100){
                            projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'), buildertek__Actual_Completion_Date__c = null));
                        }
                    }
                }
                if (projectList.size() > 0){
                    //update project on chedule update
                     ProjectTriggerHandler.blnSkipProjectTrigger = true;
                    projectUpdateHandler.updateProjectList_New(projectList);
                     ProjectTriggerHandler.blnSkipProjectTrigger = false;
                    //update projectList;
                } */


                projectList = new List<buildertek__Project__c>();
                for (AggregateResult ag : [SELECT buildertek__Project__c, AVG(buildertek__Complete__c)avg
                                           FROM buildertek__Schedule__c
                                           WHERE buildertek__Project__c IN :projectIdSet
                                           GROUP BY buildertek__Project__c]){
                    if ((Id)ag.get('buildertek__Project__c') != null){
                        //projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg')));
                        if((Decimal)ag.get('avg') == 100){
                             projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'),buildertek__Actual_Completion_Date__c = system.today()));
                        }else if((Decimal)ag.get('avg') < 100){
                            projectList.add(new buildertek__Project__c(Id = (Id)ag.get('buildertek__Project__c'), buildertek__Project_Completion__c = (Decimal)ag.get('avg'), buildertek__Actual_Completion_Date__c = null));
                        }
                    }
                }
                if (projectList.size() > 0){
                    //update project on chedule update
                     ProjectTriggerHandler.blnSkipProjectTrigger = true;
                    projectUpdateHandler.updateProjectList_New(projectList);
                     ProjectTriggerHandler.blnSkipProjectTrigger = false;
                    //update projectList;
                }
            }
        }
    }

    if (trigger.isUpdate && trigger.isBefore){
        for (buildertek__Schedule__c sch : Trigger.new){
            if(sch.buildertek__Complete1__c >0 && sch.buildertek__Actual_Start_Date_2__c == null){
                sch.buildertek__Actual_Start_Date_2__c = system.today();
            }
        }
    }
}