public with sharing class ImportMasterSchedules{
    /**/
    @AuraEnabled
    public static object getMasterSchedule(String recordId){
        List<buildertek__Schedule__c> schedulesList;
        /* if (Schema.sObjectType.buildertek__Schedule__c.fields.Id.isAccessible() &&
         Schema.sObjectType.buildertek__Schedule__c.fields.Name.isAccessible() &&
         Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Description__c.isAccessible() &&
         Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Type__c.isAccessible() ){  */
        schedulesList = [SELECT Id, Name, buildertek__Description__c, buildertek__Type__c, buildertek__Community__c
                         FROM buildertek__Schedule__c
                         WHERE buildertek__Type__c = 'Master' AND Id != :recordId];
        //}
        List<MasterScheduleClass> MasterScheduleClassList = new List<MasterScheduleClass>();
        for (buildertek__Schedule__c sch : schedulesList){
            MasterScheduleClass MasterScheduleClassRecord = new MasterScheduleClass();
            MasterScheduleClassRecord.masterscheduleRecord = sch;
            MasterScheduleClassRecord.scheduleCheck = false;
            MasterScheduleClassList.add(MasterScheduleClassRecord);
        }
        return MasterScheduleClassList;
    }

    @AuraEnabled
    public static MessageClass importMasterScheduleLines(List<String> scheduleRecIds, String recordId, Date initialDate, String projectManagerId){
        MessageClass msg = new MessageClass();
        Map<Id, buildertek__Project_Task__c> projectTaskMap = new Map<Id, buildertek__Project_Task__c>();
        List<buildertek__Project_Task__c> projectTask = new List<buildertek__Project_Task__c>();
        Set<String> listOfPhase = new Set<String>();
        system.debug(recordId + '--------------' + scheduleRecIds);
        try{
            list<buildertek__Project_Task__c> scheduleitems = new list<buildertek__Project_Task__c>();
            list<buildertek__Project_Task__c> existedScheduleitems = new list<buildertek__Project_Task__c>();
            /*if (Schema.sObjectType.buildertek__Project_Task__c.fields.Id.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Completion__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Contractor__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Contractor_Resource__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Duration__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Finish__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Resource__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Lag__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Dependency__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Milestone__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Notes__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Order__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Original_End_Date__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Original_Start_Date__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Phase__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Type__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Dependency__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Project__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Purchase_Order__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Reason_for_Date_Change__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Reason_for_Date_Change_PL__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Required_Completion_Date__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isAccessible() &&
             Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isAccessible()){ */

            //    List<buildertek__Schedule__c> schRecords =  [SELECT Id,buildertek__Project_Manager__c From buildertek__Schedule__c WHERE Id=:recordId];
            //   System.debug('Schedule Record -------------> '+schRecords);
            scheduleitems = [select id, buildertek__Completion__c, buildertek__Contractor__c, buildertek__Dependency__r.Name, buildertek__Dependency__r.buildertek__Schedule__c, buildertek__Contractor_Resource__c, buildertek__Project_Manager__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Phase__c, buildertek__Type__c, buildertek__Dependency__c, buildertek__Project__c, buildertek__Purchase_Order__c, buildertek__Reason_for_Date_Change__c, buildertek__Reason_for_Date_Change_PL__c, buildertek__Required_Completion_Date__c, buildertek__Schedule__c, buildertek__Start__c, Name
                             from buildertek__Project_Task__c
                             where buildertek__Schedule__c IN:scheduleRecIds
                             order by CreatedDate, buildertek__Order__c
                             NULLS LAST];

            if (initialDate == null){
                initialDate = [SELECT Id, buildertek__Initial_Start_Date__c
                               FROM buildertek__Schedule__c
                               WHERE Id = :recordId].buildertek__Initial_Start_Date__c;
            }

            existedScheduleitems = [select id, buildertek__Completion__c, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Phase__c, buildertek__Type__c, buildertek__Dependency__c, buildertek__Project__c, buildertek__Purchase_Order__c, buildertek__Reason_for_Date_Change__c, buildertek__Reason_for_Date_Change_PL__c, buildertek__Required_Completion_Date__c, buildertek__Schedule__c, buildertek__Start__c, Name
                                    from buildertek__Project_Task__c
                                    where buildertek__Schedule__c = :recordId AND buildertek__Milestone__c = :false
                                    order by CreatedDate, buildertek__Order__c
                                    NULLS LAST];

            Integer lastIndex = -1;
            if (existedScheduleitems.Size() > 0){
                lastIndex = existedScheduleitems.Size() - 1;
                if (lastIndex >= 0){
                    system.debug(existedScheduleitems[lastIndex]);
                }
            }

            // }
            Integer count = 1;
            if (lastIndex >= 0){
                if (Integer.valueOf(existedScheduleitems[lastIndex].buildertek__Order__c) == null){
                    existedScheduleitems[lastIndex].buildertek__Order__c = 0;
                }
                count = Integer.valueOf(existedScheduleitems[lastIndex].buildertek__Order__c) + 1;
                system.debug(existedScheduleitems[lastIndex]);
            }
            if (scheduleitems.size() > 0){
                Map<String, String> newmap = new Map<String, String>();
                for (buildertek__Project_Task__c scheduleitem : scheduleitems){
                    if (!scheduleitem.buildertek__Milestone__c){
                        buildertek__Project_Task__c schItem = new buildertek__Project_Task__c();
                        schItem.buildertek__Completion__c = scheduleitem.buildertek__Completion__c;
                        schItem.buildertek__Contractor__c = scheduleitem.buildertek__Contractor__c;
                        schItem.buildertek__Contractor_Resource__c = scheduleitem.buildertek__Contractor_Resource__c;
                        if (scheduleitem.buildertek__Duration__c != 0 && scheduleitem.buildertek__Duration__c != null){
                            schItem.buildertek__Duration__c = scheduleitem.buildertek__Duration__c;
                        } else{
                            schItem.buildertek__Duration__c = 1;
                        }
                        System.debug('check one');
                        if (projectManagerId != null){
                            schItem.buildertek__Project_Manager__c = projectManagerId;

                        }
                        /*    if(schRecords.size() > 0){
                         System.debug('Check Two');
                         if(schRecords[0].buildertek__Project_Manager__c != null){
                         System.debug('Check Three');
                         schItem.buildertek__Project_Manager__c = schRecords[0].buildertek__Project_Manager__c;
                         }
                         }  */
                        // if (scheduleitem.buildertek__Dependency__r.buildertek__Schedule__c == recordId && scheduleitem.buildertek__Dependency__r.buildertek__Schedule__c != null){
                        // }
                        // schItem.buildertek__Dependency__c = scheduleitem.buildertek__Dependency__c;
                        schItem.buildertek__Finish__c = scheduleitem.buildertek__Finish__c;
                        System.debug('finish date in import master before insertion ==> ' + schItem.buildertek__Finish__c + ' and master item id ' + scheduleitem.id);
                        schItem.buildertek__Resource__c = scheduleitem.buildertek__Resource__c;
                        schItem.buildertek__Lag__c = scheduleitem.buildertek__Lag__c;
                        schItem.buildertek__Milestone__c = scheduleitem.buildertek__Milestone__c;
                        schItem.buildertek__Notes__c = scheduleitem.buildertek__Notes__c;
                        schItem.buildertek__Order__c = scheduleitem.buildertek__Order__c;
                        schItem.buildertek__Original_Start_Date__c = Date.today();
                        schItem.buildertek__Original_End_Date__c = Date.today().adddays(Integer.valueOf(scheduleitem.buildertek__Duration__c));
                        schItem.buildertek__Phase__c = scheduleitem.buildertek__Phase__c;
                        schItem.buildertek__Type__c = scheduleitem.buildertek__Type__c;
                        // schItem.buildertek__Project__c = scheduleitem.buildertek__Project__c;
                        schItem.buildertek__Purchase_Order__c = scheduleitem.buildertek__Purchase_Order__c;
                        schItem.buildertek__Reason_for_Date_Change__c = scheduleitem.buildertek__Reason_for_Date_Change__c;
                        schItem.buildertek__Reason_for_Date_Change_PL__c = scheduleitem.buildertek__Reason_for_Date_Change_PL__c;
                        schItem.buildertek__Required_Completion_Date__c = scheduleitem.buildertek__Required_Completion_Date__c;
                        schItem.buildertek__Schedule__c = recordId;
                        schItem.buildertek__Order__c = count;
                        schItem.buildertek__Reference_for_Import__c = scheduleitem.Id;
                        if (initialDate != null){
                            schItem.buildertek__Start__c = initialDate;
                            System.debug('start date in import master before insertion ==> ' + schItem.buildertek__Start__c);
                        } else{
                            //fromNewSchedule != null && fromNewSchedule &&
                            Date today = system.today();
                            schItem.buildertek__Start__c = today;
                            System.debug('start date in else condition import master before insertion ==> ' + schItem.buildertek__Start__c);
                        }
                        //else{
                        //schItem.buildertek__Start__c = scheduleitem.buildertek__Start__c;
                        //}

                        // schItem.buildertek__Start__c = scheduleitem.buildertek__Start__c;
                        schItem.Name = scheduleitem.Name;
                        buildertek__Project_Task__c schItemClone = schItem.Clone(false, true);
                        system.debug(schItemClone.buildertek__Phase__c);
                        projectTaskMap.put(scheduleitem.Id, schItemClone);
                        listOfPhase.add(schItem.buildertek__Phase__c);
                        system.debug('schItem-->' + schItem);
                        if (scheduleitem.buildertek__Dependency__r.Name != NULL){
                            if (!newmap.containsKey(schItem.Name)){
                                newmap.put(schItem.Name, scheduleitem.buildertek__Dependency__r.Name);
                            }
                        }
                        count++;
                    }
                }

                System.debug('projectTaskMap values ==> ' + projectTaskMap.values());
                // insert projectTaskMap.values();
                // adding database.insert here
                Database.SaveResult[] saveResultList = Database.insert (projectTaskMap.values(), false);
                // Set<Id> schIds = new Set<Id>();
                // for (Database.SaveResult sr : saveResultList){
                //     if (sr.isSuccess()){
                //         // Operation was successful, so get the ID of the record that was processed
                //         System.debug('Successfully inserted schedule Lines ID: ' + sr.getId());
                //         schIds.add(sr.getId());
                //     }
                // }
                msg.Status = 'Success';
                msg.Message = 'schedule Lines Imported Successfully';
                system.debug('Success---');

                Map<String, Id> predmap = new Map<String, Id>();
                Map<String, Date> preddatemap = new Map<String, Date>();
                for (buildertek__Project_Task__c pt : projectTaskMap.values()){
                    predmap.put(pt.Name, pt.Id);
                    preddatemap.put(pt.Name, pt.buildertek__Finish__c);
                }
                List<buildertek__Project_Task__c> dependList = new List<buildertek__Project_Task__c>();
                for (buildertek__Project_Task__c sci : projectTaskMap.values()){
                    if (newmap.containsKey(sci.Name)){
                        sci.buildertek__Dependency__c = predmap.get(newmap.get(sci.Name));
                        if (sci.buildertek__Start__c > sci.buildertek__Finish__c){
                            System.debug('sci.name' + sci.Name);
                            System.debug('sci.name' + sci.Id);
                            System.debug('sci.buildertek__Start__c-->' + sci.buildertek__Start__c);
                            System.debug('sci.buildertek__Finish__c-->' + sci.buildertek__Finish__c);
                            System.debug('newmap.get(sci.Name)-->' + newmap.get(sci.Name));
                            if (sci.buildertek__Duration__c != null){
                                System.debug('preddatemap.get(newmap.get(sci.Name))-->' + preddatemap.get(newmap.get(sci.Name)));
                                sci.buildertek__Start__c = sci.buildertek__Start__c.addDays(1);
                                sci.buildertek__Finish__c = sci.buildertek__Start__c.addDays(Integer.valueOf(sci.buildertek__Duration__c));
                            }
                            System.debug('sci.buildertek__Start__c-->' + sci.buildertek__Start__c);
                            System.debug('sci.buildertek__Finish__c-->' + sci.buildertek__Finish__c);
                        }
                        dependList.add(sci);
                    }
                }
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
                Database.SaveResult[] saveResultListt = Database.update (dependList, false);
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

                //adding trigger logic after update here below
                // logic started

                // for (Project_Task__c task : dependList){
                //     if (task.Id != null && task.buildertek__finish__c != null){
                //         task.buildertek__Start__c = getStartDate(task.buildertek__finish__c.addDays(1));
                //         Date taskEndDate;
                //         if (Integer.valueOf(task.buildertek__Duration__c) > 0){
                //             system.debug('1-->');
                //             taskEndDate = task.buildertek__Start__c.addDays(Integer.valueOf(task.buildertek__Duration__c) - 1);
                //         } else{
                //             system.debug('2-->');
                //             taskEndDate = task.buildertek__Start__c; //.addDays(1)
                //         }
                //         // system.debug('taskEndDate -->' + taskEndDate);
                //         task.buildertek__Finish__c = taskEndDate;
                //         System.debug('start date ==> ' + task.buildertek__Start__c);
                //         System.debug('end date ==> ' + task.buildertek__Finish__c);
                //     }
                // }

                // update dependList;
                // System.debug('after update ==> ' + dependList);
                // logic ended here

                // added second logic here for start date
                //logic starts from here below
                Date startDate;
                Date endDate;
                DateTime currDate;
                Integer numberDaysDue;
                Map<Id, buildertek__Project_Task__c> mapAllTask = new Map<Id, buildertek__Project_Task__c>();
                List<buildertek__Project_Task__c> projectTaskToUpdate = new List<buildertek__Project_Task__c>();
                Map<Id, List<Project_Task__c>> projectTaskMaps = new Map<Id, List<Project_Task__c>>();
                List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();

                for (Project_Task__c projectTask1 : dependList){
                    if (projectTask1.Id != null && projectTask1.buildertek__finish__c != null){
                        projectTask1.buildertek__Start__c = getStartDate(projectTask1.buildertek__finish__c.addDays(1));
                        Date taskEndDate;
                        if (Integer.valueOf(projectTask1.buildertek__Duration__c) > 0){
                            system.debug('1-->');
                            taskEndDate = projectTask1.buildertek__Start__c.addDays(Integer.valueOf(projectTask1.buildertek__Duration__c) - 1);
                        } else{
                            system.debug('2-->');
                            taskEndDate = projectTask1.buildertek__Start__c; //.addDays(1)
                        }
                        // system.debug('taskEndDate -->' + taskEndDate);
                        projectTask1.buildertek__Finish__c = taskEndDate;
                        System.debug('start date ==> ' + projectTask1.buildertek__Start__c);
                        System.debug('end date ==> ' + projectTask1.buildertek__Finish__c);
                    }

                    mapAllTask.put(projectTask1.Id, projectTask1);
                    if (!projectTaskMaps.containsKey(projectTask1.buildertek__Schedule__c)){
                        projectTaskMaps.put(projectTask1.buildertek__Schedule__c, new List<Project_Task__c>());
                    }
                    projectTaskMaps.get(projectTask1.buildertek__Schedule__c).add(projectTask1);
                }

                for (Id taskId : mapAllTask.keySet()){
                    buildertek__Project_Task__c projectTask2 = mapAllTask.get(taskId);
                    //system.debug(projectTask.buildertek__Milestone__c);
                    Id Dependency = projectTask2.buildertek__Dependency__c;
                    // if (previuosTasks.Size() > 0 && !previousTaskmap.containsKey(projectTask.Id) && !projectTask.buildertek__Milestone__c && isFromImport){
                    //     Integer lastIdx = previuosTasks.Size() - 1;
                    //     if (lastIdx >= 0){
                    //         projectTask.buildertek__Start__c = previuosTasks[lastIdx].buildertek__finish__c.addDays(1);
                    //         projectTask.buildertek__Original_Start_Date__c = ProjectTaskTriggerHandler.getStartDate(projectTask.buildertek__Start__c);
                    //         if (projectTask.buildertek__Duration__c != null && projectTask.buildertek__Duration__c > 0){
                    //             projectTask.buildertek__Original_End_Date__c = projectTask.buildertek__Start__c.addDays(Integer.valueOf(projectTask.buildertek__Duration__c) - 1);
                    //             projectTask.buildertek__Original_End_Date__c = ProjectTaskTriggerHandler.getEndDate(projectTask.buildertek__Start__c, projectTask.buildertek__Original_End_Date__c);
                    //         }
                    //     }
                    // }
                    if (projectTask2.buildertek__Dependency__c != null){
                        buildertek__Project_Task__c parentTask = mapAllTask.get(projectTask2.buildertek__Dependency__c);
                        // system.debug(parentTask);
                        if (parentTask != null){
                            Integer lag = projectTask2.buildertek__Lag__c != null ? Integer.valueOf(projectTask2.buildertek__Lag__c) : 0;
                            if (parentTask.buildertek__finish__c != null){
                                startDate = parentTask.buildertek__finish__c.addDays(1);
                                if (mapAllTask.get(taskId).buildertek__Duration__c != null){
                                    endDate = getStartDate(parentTask.buildertek__finish__c).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
                                } else{
                                    // calculate duration from (mapAllTask.get(taskId)buildertek__finish__c).daysbetween.mapAllTask.get(taskId).buildertek__Start__c if needed
                                    Date d1 = mapAllTask.get(taskId).buildertek__finish__c;
                                    Date d2 = mapAllTask.get(taskId).buildertek__Start__c;
                                    Integer daysDiff = d2.daysbetween(d1);
                                    endDate = getStartDate(parentTask.buildertek__finish__c).addDays(daysDiff + 1);
                                    mapAllTask.get(taskId).buildertek__Duration__c = daysDiff + 1;
                                }
                            } else{
                                Integer Duration = Integer.valueOf(parentTask.buildertek__Duration__c);
                                startDate = parentTask.buildertek__Start__c.addDays(Duration);
                                if (mapAllTask.get(taskId).buildertek__Duration__c == null){
                                    mapAllTask.get(taskId).buildertek__Duration__c = 1;
                                }
                                endDate = ProjectTaskTriggerHandler.getStartDate(parentTask.buildertek__Start__c.addDays(Duration)).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
                            }
                            numberDaysDue = startDate.daysBetween(endDate);
                            System.debug('3rd method before changing start Date ==> ' + projectTask2.buildertek__Start__c + ' Id ' + projectTask2.Id);
                            projectTask2.buildertek__Start__c = ProjectTaskTriggerHandler.getStartDate(startDate);//startDate;
                            System.debug('3rd method after changing start Date ==> ' + projectTask2.buildertek__Start__c + ' Id ' + projectTask2.Id);

                            if (numberDaysDue <= 0){
                                projectTask2.buildertek__finish__c = projectTask2.buildertek__Start__c;
                                projectTask2.buildertek__Duration__c = 1;
                            } else{
                                projectTask2.buildertek__finish__c = ProjectTaskTriggerHandler.getEndDate(startDate, endDate);
                            }
                            projectTaskToUpdate.add(projectTask2);
                        }
                    }
                }
                update projectTaskToUpdate;
                //logic ends here


                // handler.blnSkipTaskTrigger = false;
                // handler.updateChildDatesWithPredecessor(dependList,updatepredmap);
                // for (Database.SaveResult sr : saveResultListt){
                //     if (sr.isSuccess()){
                //         System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                //     } else{
                //         for (Database.Error err : sr.getErrors()){
                //             System.debug('The following error has occurred.');
                //             System.debug(err.getStatusCode() + ': ' + err.getMessage());
                //             System.debug('Account fields that affected this error: ' + err.getFields());
                //         }
                //     }
                // }
                futureContoller.updateScheduleRec(recordId);

                System.debug('Check Project Manager 1');

                //system.debug([Select Id, Name, buildertek__Phase__c, buildertek__Start__c, buildertek__Schedule__c, buildertek__Milestone__c FROM Project_Task__c  WHERE buildertek__Schedule__c = :recordId]);
                // for (buildertek__Project_Task__c scheduleitem : projectTaskMap.values()){
                //     buildertek__Project_Task__c schItem = new buildertek__Project_Task__c();
                //     system.debug('scheduleitem' + scheduleitem.buildertek__Phase__c);
                //     schItem.Id = scheduleitem.Id;
                //     if (scheduleitem.buildertek__Dependency__c != null && projectTaskMap.get(scheduleitem.buildertek__Dependency__c) != null){
                //         if (String.isNotBlank(scheduleitem.buildertek__Dependency__c) && String.isNotBlank(projectTaskMap.get(scheduleitem.buildertek__Dependency__c).Id)){
                //             schItem.buildertek__Dependency__c = projectTaskMap.get(scheduleitem.buildertek__Dependency__c).Id;
                //         }
                //     }

                //     projectTask.add(schItem);
                // }
                // System.debug('Check Project Manager 2');
                // ProjectTaskTriggerHandler.isFromImport = true;
                // System.debug('<--projectTask.size()-->'+projectTask.size());
                // if (projectTask.size() > 0){
                //     // update projectTask;
                //     // adding database.update here
                //     Database.SaveResult[] saveResultList3 = Database.update (projectTask, false);
                //     for (Database.SaveResult sr : saveResultList3){
                //         if (sr.isSuccess()){
                //             // Operation was successful, so get the ID of the record that was processed
                //             System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                //         } else{
                //             // Operation failed, so get all errors
                //             for (Database.Error err : sr.getErrors()){
                //                 System.debug('The following error has occurred.');
                //                 System.debug(err.getStatusCode() + ': ' + err.getMessage());
                //                 System.debug('Account fields that affected this error: ' + err.getFields());
                //             }
                //         }
                //     }
                //     msg.Status = 'Success';
                //     msg.Message = 'schedule Lines Imported Successfully';
                //     system.debug('Success---');
                // }
                System.debug('Check Project Manager 3');
                /*updateScheduleItemTaskBacthApex updatedependency = new updateScheduleItemTaskBacthApex(projectTaskMap.keyset(),recordId,projectTaskMap);
                 database.executeBatch(updatedependency, 200);*/

                /* updateScheduleItemTaskBacthApex updatedependency = new updateScheduleItemTaskBacthApex(projectTaskMap.keyset(),recordId,projectTaskMap);
                 database.executeBatch(updatedependency, 200);*/


                Map<String, buildertek__Project_Task__c> milestoneList = new Map<String, buildertek__Project_Task__c>();
                Map<String, buildertek__Project_Task__c> projectTaskList = new Map<String, buildertek__Project_Task__c>();
                List<buildertek__Project_Task__c> projectTasksLs = new List<buildertek__Project_Task__c>();

                //If milestone not created for that Phase, Creates here.
                List<Project_Task__c> task = [Select Id, Name, buildertek__Phase__c, buildertek__Start__c, buildertek__Schedule__c, buildertek__Milestone__c
                                              FROM Project_Task__c
                                              WHERE buildertek__Schedule__c = :recordId];


                for (Project_Task__c tasks : task){
                    if (!tasks.buildertek__Milestone__c){
                        projectTaskList.put(tasks.buildertek__Phase__c, tasks);
                    } else{
                        milestoneList.put(tasks.buildertek__Phase__c, tasks);
                    }
                }
                // for (Project_Task__c tasks : projectTaskList.values()){
                //     system.debug('task' + tasks.buildertek__Start__c);
                // }
                for (Project_Task__c tasks : projectTaskList.values()){
                    if (!milestoneList.containsKey(tasks.buildertek__Phase__c) && !tasks.buildertek__Milestone__c){
                        System.debug('Check Project Manager 5');
                        if (tasks.buildertek__Phase__c != null){
                            system.debug('task214' + tasks.buildertek__Start__c);
                            Project_Task__c project = new Project_Task__c();
                            project.Name = 'Milestone Complete';
                            project.buildertek__Phase__c = tasks.buildertek__Phase__c;
                            project.buildertek__Start__c = tasks.buildertek__Start__c;
                            project.buildertek__Schedule__c = recordId;
                            project.buildertek__Use_Project_Manager_from_Schedule__c = true;
                            System.debug('Check Project Manager 6');
                            if (projectManagerId != null){
                                project.buildertek__Project_Manager__c = projectManagerId;
                                System.debug('Check Project Manager 7');
                            }
                            // project.buildertek__Use_Project_Manager_from_Schedule__c = True;
                            /*  if(schRecords.size() > 0){
                             if(schRecords[0].buildertek__Project_Manager__c != null){
                             project.buildertek__Project_Manager__c = schRecords[0].buildertek__Project_Manager__c;
                             }
                             }  */
                            System.debug('Check Project Manager');
                            project.buildertek__Milestone__c = true;
                            projectTasksLs.add(project);
                        }

                    }
                }
                System.debug('Project Task::' + projectTasksLs);

                // insert projectTasks;
                //  adding database.insert here
                Database.SaveResult[] saveResultList2 = Database.insert (projectTasksLs, false);

                futureContoller.updateScheduleRec(recordId);
                /*   List<buildertek__Project_Task__c> scheduleLinesListToUpdate = new  List<buildertek__Project_Task__c>();
                 for(buildertek__Project_Task__c schedulesLines : projectTasks){
                 if(schedulesLines.Name ==  'Milestone Complete'){
                 if(schRecords.size() > 0){
                 if(schRecords[0].buildertek__Project_Manager__c != null){
                 schedulesLines.buildertek__Project_Manager__c = schRecords[0].buildertek__Project_Manager__c;
                 scheduleLinesListToUpdate.add(schedulesLines);
                 }
                 }
                 }

                 }
                 if(!scheduleLinesListToUpdate.isEmpty()){
                 update scheduleLinesListToUpdate;
                 } */

            } else{
                system.debug('Error---');
                msg.Status = 'Failed';
                msg.Message = 'There are no schedule lines for the selected schedule.';
            }
            return msg;
        } catch (Exception e){
            msg.Status = 'Failed';
            msg.Message = e.getMessage();
            System.debug('Error::' + e.getMessage() + ':Line:' + e.getLineNumber());
            return msg;
        }
    }

    public class MasterScheduleClass{
        @AuraEnabled
        public buildertek__Schedule__c masterscheduleRecord{ get; set; }

        @AuraEnabled
        public boolean scheduleCheck{ get; set; }

    }

    public class MessageClass{
        @AuraEnabled
        public String Status{ get; set; }

        @AuraEnabled
        public string Message{ get; set; }

    }

    public static Date getStartDate(Date startDate){
        DateTime currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
        String todayDay = currDate.format('EEEE');
        if (todayDay == 'Saturday'){
            startDate = startDate.addDays(2);
        } else if (todayDay == 'Sunday'){
            startDate = startDate.addDays(1);
        }
        return startDate;
    }

}