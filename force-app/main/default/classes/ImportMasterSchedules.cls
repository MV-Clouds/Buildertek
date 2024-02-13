public with sharing class ImportMasterSchedules{
   
@AuraEnabled
public static object getMasterSchedule(String recordId, String searchKeyword){
    List<buildertek__Schedule__c> schedulesList;
    String searchString = '%' + searchKeyword + '%';

    // Retrieve all records of buildertek__Schedule__c
    schedulesList = [SELECT Id, Name, buildertek__Description__c, buildertek__Type__c, buildertek__Community__c
                     FROM buildertek__Schedule__c
                     WHERE buildertek__Type__c = 'Master' AND Id != :recordId
                     ORDER BY Name ASC];

    // Filter the records based on searchKeyword
    List<MasterScheduleClass> MasterScheduleClassList = new List<MasterScheduleClass>();
    for (buildertek__Schedule__c sch : schedulesList){
        // Check if Name or Description contains the searchKeyword
        if ((sch.Name != null && sch.Name.containsIgnoreCase(searchKeyword)) ||
            (sch.buildertek__Description__c != null && sch.buildertek__Description__c.containsIgnoreCase(searchKeyword))) {
            MasterScheduleClass MasterScheduleClassRecord = new MasterScheduleClass();
            MasterScheduleClassRecord.masterscheduleRecord = sch;
            MasterScheduleClassRecord.scheduleCheck = false;
            MasterScheduleClassList.add(MasterScheduleClassRecord);
        }
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
            }

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
                        if (projectManagerId != null){
                            schItem.buildertek__Project_Manager__c = projectManagerId;
                        }

                        schItem.buildertek__Finish__c = scheduleitem.buildertek__Finish__c;
                        schItem.buildertek__Resource__c = scheduleitem.buildertek__Resource__c;
                        schItem.buildertek__Lag__c = scheduleitem.buildertek__Lag__c;
                        schItem.buildertek__Milestone__c = scheduleitem.buildertek__Milestone__c;
                        schItem.buildertek__Notes__c = scheduleitem.buildertek__Notes__c;
                        schItem.buildertek__Order__c = scheduleitem.buildertek__Order__c;
                        schItem.buildertek__Original_Start_Date__c = Date.today();
                        schItem.buildertek__Original_End_Date__c = Date.today().adddays(Integer.valueOf(scheduleitem.buildertek__Duration__c));
                        schItem.buildertek__Phase__c = scheduleitem.buildertek__Phase__c;
                        schItem.buildertek__Type__c = scheduleitem.buildertek__Type__c;
                        schItem.buildertek__Purchase_Order__c = scheduleitem.buildertek__Purchase_Order__c;
                        schItem.buildertek__Reason_for_Date_Change__c = scheduleitem.buildertek__Reason_for_Date_Change__c;
                        schItem.buildertek__Reason_for_Date_Change_PL__c = scheduleitem.buildertek__Reason_for_Date_Change_PL__c;
                        schItem.buildertek__Required_Completion_Date__c = scheduleitem.buildertek__Required_Completion_Date__c;
                        schItem.buildertek__Schedule__c = recordId;
                        schItem.buildertek__Order__c = count;
                        schItem.buildertek__Reference_for_Import__c = scheduleitem.Id;
                        if (initialDate != null){
                            schItem.buildertek__Start__c = initialDate;
                        } else{
                            Date today = system.today();
                            schItem.buildertek__Start__c = today;
                        }
                        schItem.Name = scheduleitem.Name;
                        buildertek__Project_Task__c schItemClone = schItem.Clone(false, true);
                        system.debug(schItemClone.buildertek__Phase__c);
                        projectTaskMap.put(scheduleitem.Id, schItemClone);
                        listOfPhase.add(schItem.buildertek__Phase__c);
                        if (scheduleitem.buildertek__Dependency__r.Name != NULL){
                            if (!newmap.containsKey(schItem.Name)){
                                newmap.put(schItem.Name, scheduleitem.buildertek__Dependency__r.Name);
                            }
                        }
                        count++;
                    }
                }

                Database.SaveResult[] saveResultList = Database.insert (projectTaskMap.values(), false);

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
                            taskEndDate = projectTask1.buildertek__Start__c.addDays(Integer.valueOf(projectTask1.buildertek__Duration__c) - 1);
                        } else{
                            taskEndDate = projectTask1.buildertek__Start__c; //.addDays(1)
                        }
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
                    Id Dependency = projectTask2.buildertek__Dependency__c;

                    if (projectTask2.buildertek__Dependency__c != null){
                        buildertek__Project_Task__c parentTask = mapAllTask.get(projectTask2.buildertek__Dependency__c);
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
                            projectTask2.buildertek__Start__c = ProjectTaskTriggerHandler.getStartDate(startDate);//startDate;

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
                futureContoller.updateScheduleRec(recordId);

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

                for (Project_Task__c tasks : projectTaskList.values()){
                    if (!milestoneList.containsKey(tasks.buildertek__Phase__c) && !tasks.buildertek__Milestone__c){
                        if (tasks.buildertek__Phase__c != null){
                            Project_Task__c project = new Project_Task__c();
                            project.Name = 'Milestone Complete';
                            project.buildertek__Phase__c = tasks.buildertek__Phase__c;
                            project.buildertek__Start__c = tasks.buildertek__Start__c;
                            project.buildertek__Schedule__c = recordId;
                            project.buildertek__Use_Project_Manager_from_Schedule__c = true;
                            if (projectManagerId != null){
                                project.buildertek__Project_Manager__c = projectManagerId;
                            }
                            project.buildertek__Milestone__c = true;
                            projectTasksLs.add(project);
                        }

                    }
                }
                Database.SaveResult[] saveResultList2 = Database.insert (projectTasksLs, false);

                futureContoller.updateScheduleRec(recordId);

            } else{
                system.debug('Error---');
                msg.Status = 'Failed';
                msg.Message = 'There are no schedule lines for the selected schedule.';
            }
            return msg;
        } catch (Exception e){
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            msg.Status = 'Failed';
            msg.Message = e.getMessage();
            System.debug('Error::' + e.getMessage() + ':Line:' + e.getLineNumber());
            return msg;
        }
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

    @AuraEnabled
    public static MessageClass createScheduleLineFromMasterSchedule (String recordId, String masterId){
        MessageClass msg = new MessageClass();
        Date initialStartDate = [SELECT Id, buildertek__Initial_Start_Date__c FROM buildertek__Schedule__c WHERE Id =: recordId].buildertek__Initial_Start_Date__c;
        System.debug('initialStartDate: ' + initialStartDate);
        buildertek__Schedule__c masterSchedule = [SELECT Id, Name, buildertek__Start_Date__c, buildertek__Initial_Start_Date__c FROM buildertek__Schedule__c WHERE Id =: masterId];
        String businessHourId = [SELECT Id, IsDefault, IsActive FROM BusinessHours WHERE IsDefault = true LIMIT 1].Id;
        System.debug('recordId: ' + recordId);
        System.debug('masterId: ' + masterId);
        date masterStartDate = masterSchedule.buildertek__Start_Date__c;
        if (masterStartDate == null) {
            masterStartDate = System.today();
        }
        initialStartDate = bryntumGanttController.getInitialStartDate(initialStartDate);
        DateTime oldDate = DateTime.newInstance(masterStartDate.year(), masterStartDate.month(),masterStartDate.day());
        DateTime newDate = DateTime.newInstance(initialStartDate.year(), initialStartDate.month(),initialStartDate.day());

        // Integer diffDays = Integer.valueOf(System.BusinessHours.diff(businessHourId, oldDate, newDate)/(24 * 60 * 60 * 1000L));
        Long diffDays = System.BusinessHours.diff(businessHourId, oldDate, newDate);

        Map<Id, buildertek__Project_Task__c> projectInsertTaskMap = new Map<Id, buildertek__Project_Task__c>();

        List<buildertek__Project_Task__c> masterScheduleList = new List<buildertek__Project_Task__c>([Select Id, Name, buildertek__Start__c,buildertek__Contractor__c,buildertek__Phase__c, buildertek__Schedule__c,buildertek__Dependency__r.Name, buildertek__Dependency__r.buildertek__Schedule__c, buildertek__Completed__c, buildertek__Completion__c, buildertek__Contractor_Resource__c, buildertek__Type__c,buildertek__Cost_Code__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Last_Saved_End_Date__c, buildertek__Last_Saved_Start_Date__c, buildertek__Material_Ordered__c, buildertek__Material_Received__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Payable_Task__c, buildertek__Project__c, buildertek__Purchase_Order__c, buildertek__Reason_for_Date_Change__c, buildertek__Reason_for_Date_Change_PL__c, buildertek__Required_Completion_Date__c, buildertek__Trade_Type__c, buildertek__BT_Grouping__c from buildertek__Project_Task__c where buildertek__Schedule__c = :masterId  ORDER BY buildertek__Order__c ASC NULLS LAST]);

        System.debug('masterScheduleList: ' + masterScheduleList);

        Map<String, String> predecessorMap = new Map<String, String>();

        for (buildertek__Project_Task__c Masterscheduleitem : masterScheduleList){
            if (!Masterscheduleitem.buildertek__Milestone__c){

                if (Masterscheduleitem.buildertek__Dependency__c != null) {
                    predecessorMap.put(Masterscheduleitem.Id, Masterscheduleitem.buildertek__Dependency__c);
                }

                buildertek__Project_Task__c newSchItem = new buildertek__Project_Task__c();
                newSchItem.buildertek__Completion__c = Masterscheduleitem.buildertek__Completion__c;
                newSchItem.buildertek__Contractor__c = Masterscheduleitem.buildertek__Contractor__c;
                newSchItem.buildertek__Contractor_Resource__c = Masterscheduleitem.buildertek__Contractor_Resource__c;

                if (Masterscheduleitem.buildertek__Duration__c != 0 && Masterscheduleitem.buildertek__Duration__c != null){
                    newSchItem.buildertek__Duration__c = Masterscheduleitem.buildertek__Duration__c;
                } else{
                    newSchItem.buildertek__Duration__c = 1;
                }

                DateTime sDate = DateTime.newInstance(Masterscheduleitem.buildertek__Start__c.year(), Masterscheduleitem.buildertek__Start__c.month(),Masterscheduleitem.buildertek__Start__c.day());
                DateTime eDate = DateTime.newInstance(Masterscheduleitem.buildertek__Finish__c.year(), Masterscheduleitem.buildertek__Finish__c.month(),Masterscheduleitem.buildertek__Finish__c.day());

                newSchItem.buildertek__Start__c = System.BusinessHours.add(businessHourId, sDate, diffDays).date();
                newSchItem.buildertek__Finish__c = System.BusinessHours.add(businessHourId, eDate, diffDays).date();

                newSchItem.buildertek__Resource__c = Masterscheduleitem.buildertek__Resource__c;
                newSchItem.buildertek__Lag__c = Masterscheduleitem.buildertek__Lag__c;
                newSchItem.buildertek__Milestone__c = Masterscheduleitem.buildertek__Milestone__c;
                newSchItem.buildertek__Notes__c = Masterscheduleitem.buildertek__Notes__c;
                newSchItem.buildertek__Order__c = Masterscheduleitem.buildertek__Order__c;
                newSchItem.buildertek__Original_Start_Date__c = Date.today();
                newSchItem.buildertek__Original_End_Date__c = Date.today().adddays(Integer.valueOf(Masterscheduleitem.buildertek__Duration__c));
                newSchItem.buildertek__Phase__c = Masterscheduleitem.buildertek__Phase__c;
                newSchItem.buildertek__Type__c = Masterscheduleitem.buildertek__Type__c;
                newSchItem.buildertek__Purchase_Order__c = Masterscheduleitem.buildertek__Purchase_Order__c;
                newSchItem.buildertek__Reason_for_Date_Change__c = Masterscheduleitem.buildertek__Reason_for_Date_Change__c;
                newSchItem.buildertek__Reason_for_Date_Change_PL__c = Masterscheduleitem.buildertek__Reason_for_Date_Change_PL__c;
                newSchItem.buildertek__Required_Completion_Date__c = Masterscheduleitem.buildertek__Required_Completion_Date__c;
                newSchItem.buildertek__Schedule__c = recordId;
                newSchItem.buildertek__Reference_for_Import__c = Masterscheduleitem.Id;
                newSchItem.buildertek__Cost_Code__c = Masterscheduleitem.buildertek__Cost_Code__c;
                newSchItem.buildertek__Trade_Type__c = Masterscheduleitem.buildertek__Trade_Type__c;
                newSchItem.buildertek__BT_Grouping__c = Masterscheduleitem.buildertek__BT_Grouping__c;

                newSchItem.Name = Masterscheduleitem.Name;
                buildertek__Project_Task__c newSchItemClone = newSchItem.Clone(false, true);
                projectInsertTaskMap.put(Masterscheduleitem.Id, newSchItemClone);

            }
        }
        System.debug('projectInsertTaskMap: ' + projectInsertTaskMap);
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        if(projectInsertTaskMap.size() > 0){
            insert projectInsertTaskMap.values();
            msg.Status = 'Success';
            msg.Message = 'Schedule Lines Imported Successfully';
        } else{
            msg.Status = 'Failed';
            msg.Message = 'There are no schedule lines for the selected schedule.';
        }
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

        for (String key : predecessorMap.keySet()) {
            projectInsertTaskMap.get(key).buildertek__Dependency__c = projectInsertTaskMap.get(predecessorMap.get(key)).Id;
        }

        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        update projectInsertTaskMap.values();
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

        futureContoller.updateScheduleRec(recordId);
        futureContoller.updateProjectOnSchedule(recordId);
        return msg;
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

}