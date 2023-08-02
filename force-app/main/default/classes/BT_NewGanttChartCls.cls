public class BT_NewGanttChartCls{

    @AuraEnabled
    public static buildertek__Schedule__c getProject(String recordId){
        buildertek__Schedule__c proj = [SELECT Id, Name, buildertek__Description__c, buildertek__Project__c, buildertek__Project__r.Name
                                        from buildertek__Schedule__c
                                        where Id = :recordId];
        return proj;
    }

    @AuraEnabled
    public static Boolean chekIsOldGantt(){
        Boolean oldGanttRenderer;
        List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Old_Gantt_Chart__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Schedule Configuration'];
        if (adminInterfaceNodeConfigurations.size() > 0) {
            oldGanttRenderer = adminInterfaceNodeConfigurations[0].buildertek__Old_Gantt_Chart__c;
        }
        return oldGanttRenderer;
    }

    @AuraEnabled
    public static String getObjectTypeName(Id recorId){
        String objectName = String.valueOf(recorId.getSObjectType());
        return objectName;
    }

    @AuraEnabled
    public static List<Holiday> getholidays(){
        List<Holiday> holidays = [Select StartTimeInMinutes,Name, ActivityDate
				            From Holiday
				            Limit 50000];
        return holidays;
    }

    @AuraEnabled
    public static List<AggregateResult> getPhaseDates(string scheduleId){
        List<AggregateResult> taskList = new List<AggregateResult>();
        taskList = [SELECT COUNT(Id), MIN(buildertek__Start__c), MAX(buildertek__Finish__c), buildertek__Phase__c
                    FROM buildertek__Project_Task__c
                    WHERE buildertek__Schedule__c = :scheduleId
                    GROUP BY buildertek__Phase__c];
        return taskList;
    }

    @AuraEnabled
    public static DataTableDetails getScheduleItemRecords(String objApi, string scheduleid){


        System.debug('getScheduleItemRecords called===');
        List<Id> filesIdList = new List<Id>();
        Set<Id> notesIdList = new Set<Id>();


        DataTableDetails dataTableDtls = new DataTableDetails();

        String strQuery = 'SELECT ';

        //strQuery = strQuery + 'Id ,buildertek__Milestone__c FROM ' + objApi + ' where buildertek__Schedule__c = :  scheduleid Order By CreatedDate,buildertek__Phase__c ASC,buildertek__Milestone__c' ;//CreatedDate//Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC
        strQuery += 'Id,Name,buildertek__Type__c,buildertek__Indent_Task__c,buildertek__Reference_for_Import__c,buildertek__Lag__c,buildertek__Schedule__c,buildertek__Budget__c,buildertek__Add_To_All_Active_Schedules__c,buildertek__Notes__c,buildertek__Schedule__r.Name,buildertek__Start__c,buildertek__Finish__c,buildertek__Duration__c,buildertek__Contractor__c,buildertek__Contractor__r.Name,buildertek__Phase__c,buildertek__Completion__c, buildertek__Dependency__c,buildertek__Dependency__r.Name,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Resource__c, buildertek__Resource__r.Name,buildertek__Milestone__c,buildertek__Order__c,buildertek__Budget_Line__c,CreatedDate FROM ' + objApi + ' where buildertek__Schedule__c = :  scheduleid Order By buildertek__Order__c NULLS LAST,CreatedDate';//CreatedDate//Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC
        system.debug('strQuery---' + strQuery);

        dataTableDtls.lstOfSObjs = Database.query(strQuery);

        System.debug('dataTableDtls**=='+JSON.serialize(dataTableDtls.lstOfSObjs));
        List<buildertek__Project_Task__c> projectTasksSorted = dataTableDtls.lstOfSObjs;

        String milestonequery = 'Select buildertek__Project__r.Name,buildertek__Schedule__r.Name, buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
        milestonequery = milestonequery + ' From buildertek__Project_Task__c where buildertek__Schedule__c =:scheduleid AND buildertek__Milestone__c= true';
        System.debug('BT_Utils.PMAM@# '+BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c'));
        System.debug('milestonequery '+milestonequery);
        List<buildertek__Project_Task__c> milestoneTaskList = DataBase.query(milestonequery);

        Map<String, List<buildertek__Project_Task__c>> TaskWithPhaseMap = new Map<String, List<buildertek__Project_Task__c>>();

        for (buildertek__Project_Task__c task : projectTasksSorted){
             //projectTasks1
            if (!filesIdList.contains(task.Id)){
                filesIdList.add(task.Id);
            }
            if (task.buildertek__Reference_for_Import__c != null){
                if (!filesIdList.contains(task.buildertek__Reference_for_Import__c)){
                    filesIdList.add(task.buildertek__Reference_for_Import__c);
                }
            }
            if (!notesIdList.contains(task.Id)){
                notesIdList.add(task.Id);
            }
            if (!task.buildertek__Milestone__c){
                if (task.buildertek__Phase__c != null){
                    // system.debug(task.Name);
                    if (TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                        list<buildertek__Project_Task__c> newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                        newProjectTaskList.add(task) ;
                        TaskWithPhaseMap.put(task.buildertek__Phase__c, newProjectTaskList);
                    } else{
                        List<buildertek__Project_Task__c> newTaskList = new List<buildertek__Project_Task__c>();
                        newTaskList.add(task) ;
                        TaskWithPhaseMap.put(task.buildertek__Phase__c, newTaskList);
                    }
                }
            }
        }

        Map<String, buildertek__Project_Task__c> milestoneMap = new Map<String, buildertek__Project_Task__c>();
        if (milestoneTaskList.Size() > 0){
            for (buildertek__Project_Task__c milestone : milestoneTaskList){
                if (milestone.buildertek__Phase__c != null){
                    System.debug(milestone.buildertek__Phase__c);
                    list<buildertek__Project_Task__c> newProjectTaskList = TaskWithPhaseMap.get(milestone.buildertek__Phase__c);
                    System.debug(newProjectTaskList);
                    if (newProjectTaskList != null){
                        if (newProjectTaskList.Size() > 0){
                            newProjectTaskList.add(milestone);
                            TaskWithPhaseMap.put(milestone.buildertek__Phase__c, newProjectTaskList);
                        }
                    }

                } else{
                    milestoneMap.put(milestone.Id, milestone);
                }
            }
        }

        Integer i = 0;
        Map<String, Integer> newTaskWithPhaseMap = new Map<String, Integer>();
        List<buildertek__Project_Task__c> updatetaskList = new List<buildertek__Project_Task__c>();
        List<buildertek__Project_Task__c> newProjectTaskList = new List<buildertek__Project_Task__c>();
        Integer ListSize = 0;
        for (Integer j = 0; j < projectTasksSorted.Size(); j++){
            buildertek__Project_Task__c task = projectTasksSorted[j];
            if (!string.isBlank(task.buildertek__Phase__c)){
                if (TaskWithPhaseMap.Size() > 0){
                    if (newTaskWithPhaseMap.get(task.buildertek__Phase__c) == null){
                        if (TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                            newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                            if (newProjectTaskList != null){
                                ListSize = ListSize + newProjectTaskList.Size();
                            }
                            newTaskWithPhaseMap.put(task.buildertek__Phase__c, newProjectTaskList.Size());
                            updatetaskList.addAll(newProjectTaskList);
                            i = i + ListSize;
                        }
                    }
                }
            } else{
                updatetaskList.add(task) ;
                i++;
            }
        }

        system.debug('Schedule Items ::' + dataTableDtls.lstOfSObjs);
        system.debug('Schedule Item ::' + dataTableDtls);
        buildertek__Schedule__c schedulerec = [Select Id, Name, buildertek__Gantt_Draw_Dependencies__c, buildertek__Gantt_Highlight_Non_Working_Time__c, buildertek__Gantt_Project_Lines__c, buildertek__Gantt_Task_Labels__c, buildertek__Hide_Gantt_Schedule__c, buildertek__Project__c, buildertek__Project__r.Name
                                               from buildertek__Schedule__c
                                               Where Id = :scheduleid];
        dataTableDtls.scheduleObj = schedulerec;
        NotesAttachmet notesAttachFiles = new NotesAttachmet();
        Map<String, NotesAttachmet> getnotesFilesLengthMap = new Map<String, NotesAttachmet>();

        if (updatetaskList.size() > 0){
            //for files
            Map<Id, list<ContentVersion>> filesList = new Map<Id, list<ContentVersion>>();
            if (filesIdList.size() > 0){
                //filePreviewController filePreviewcls = new filePreviewController();
                filesList = filePreviewController.getRelatedFiles(filesIdList);
                System.debug(filesList.size());
                System.debug(filesList);
            }

            // for notes
            List<ContentNote> notesList = new List<ContentNote>();
            map<Id, list<ContentNote>> parentandNoteMap = new map<Id, list<ContentNote>>();
            Map<Id, Id> docAndParentMap = new Map<Id, Id>();
            if (notesIdList.size() > 0){
                Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink conDoc : [SELECT ContentDocumentId, LinkedEntityId
                                                   FROM ContentDocumentLink
                                                   WHERE LinkedEntityId IN:notesIdList]){
                    contentDocumentIds.add(conDoc.ContentDocumentId);
                    docAndParentMap.put(conDoc.ContentDocumentId, conDoc.LinkedEntityId);
                }
                System.debug(docAndParentMap);
                //get all the content notes using contentDocumentIds
                List<ContentNote> contentNotes = [SELECT Id, Content, Title, TextPreview, CreatedDate
                                                  from ContentNote
                                                  where Id In:contentDocumentIds
                                                  order by CreatedDate ASC];
                System.debug(contentNotes);
                for (ContentNote noteRec : contentNotes){
                    system.debug(noteRec.Id);
                    if (!parentandNoteMap.containsKey(docAndParentMap.get(noteRec.Id))){
                        parentandNoteMap.put(docAndParentMap.get(noteRec.Id), new list<ContentNote>());
                    }
                    parentandNoteMap.get(docAndParentMap.get(noteRec.Id)).add(noteRec);
                }
                System.debug(parentandNoteMap);
            }

            NotesAttachmet getnotesFilesLength = new NotesAttachmet();
            //Map<String,NotesAttachmet> getnotesFilesLengthMap = new Map<String,NotesAttachmet>();
            if (updatetaskList.size() > 0){
                for (buildertek__Project_Task__c taskItem : updatetaskList){
                    NotesAttachmet getnotesFilesObj = new NotesAttachmet();

                    if (filesList.get(taskItem.Id) != null || filesList.get(taskItem.buildertek__Reference_for_Import__c) != null){
                        getnotesFilesObj.fileLength = 0;
                        if (filesList.get(taskItem.Id) != null){
                            getnotesFilesObj.fileLength = filesList.get(taskItem.Id).size();
                        }
                        if (filesList.get(taskItem.buildertek__Reference_for_Import__c) != null){
                            getnotesFilesObj.fileLength += filesList.get(taskItem.buildertek__Reference_for_Import__c).size();
                        }
                    } else{
                        getnotesFilesObj.fileLength = 0;
                    }

                    if (parentandNoteMap.get(taskItem.Id) != null){
                        getnotesFilesObj.notesLength = parentandNoteMap.get(taskItem.Id).size();
                    } else{
                        getnotesFilesObj.notesLength = 0;
                    }

                    if (!getnotesFilesLengthMap.containsKey(taskItem.Id)){
                        getnotesFilesLengthMap.put(taskItem.Id, getnotesFilesObj);
                    }
                }
            }
            system.debug(getnotesFilesLengthMap);

        }

        User curruser = [select id, Name, buildertek__Hide_Schedule__c
                         from User
                         where id = :userInfo.getUserId()];
        //buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Enable_Schedule_Items_Import__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Schedule Configuration'];
        List<object> fileLenListCustom = new list<Object>();
        //fileLenListCustom.add(getnotesFilesLengthMap);

        dataTableDtls.lstOfSObjs = updatetaskList;
        System.debug('updatetaskList===='+JSON.serialize(updatetaskList));

        dataTableDtls.filesandattacmentList = getnotesFilesLengthMap;
        dataTableDtls.hideScheduleFromUser = curruser.buildertek__Hide_Schedule__c;
        //dataTableDtls.importEnabled = adminInterfaceNodeConfigurations.buildertek__Enable_Schedule_Items_Import__c;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name
                              from Profile
                              where Id = :profileId].Name;
        system.debug('ProfileName' + profileName);
        system.debug(userinfo.getusername());
        dataTableDtls.profileName = profileName;
        //BT_FormatGanttData formatsch = new BT_FormatGanttData();
        //dataTableDtls.ganttJSON = BT_FormatGanttData.formatScheduleData(dataTableDtls.lstOfSObjs,dataTableDtls.scheduleObj);
        System.debug('dataTable :: ' + dataTableDtls);
        return dataTableDtls;
    }

    @AuraEnabled
    public static notesLenClass getattachmentLength(String objApi, string scheduleid){
        List<buildertek__Project_Task__c> updatetaskList = [Select Id, Name, buildertek__Reference_for_Import__c, buildertek__Schedule__c
                                                            From buildertek__Project_Task__c
                                                            Where buildertek__Schedule__c = :scheduleid];
        List<Id> filesIdList = new List<Id>();
        Set<Id> notesIdList = new Set<Id>();
        notesLenClass notewrapClass = new notesLenClass();
        //Map<String,NotesAttachmet> getnotesFilesLengthMap = new Map<String,NotesAttachmet>();
        if (updatetaskList.size() > 0){
            for (buildertek__Project_Task__c task : updatetaskList){
                if (!filesIdList.contains(task.Id)){
                    filesIdList.add(task.Id);
                }
                if (task.buildertek__Reference_for_Import__c != null){
                    if (!filesIdList.contains(task.buildertek__Reference_for_Import__c)){
                        filesIdList.add(task.buildertek__Reference_for_Import__c);
                    }
                }
                if (!notesIdList.contains(task.Id)){
                    notesIdList.add(task.Id);
                }
            }

            //for files
            Map<Id, list<ContentVersion>> filesList = new Map<Id, list<ContentVersion>>();
            if (filesIdList.size() > 0){
                //filePreviewController filePreviewcls = new filePreviewController();
                filesList = filePreviewController.getRelatedFiles(filesIdList);
                System.debug(filesList.size());
                System.debug(filesList);
            }

            // for notes
            List<ContentNote> notesList = new List<ContentNote>();
            map<Id, list<ContentNote>> parentandNoteMap = new map<Id, list<ContentNote>>();
            Map<Id, Id> docAndParentMap = new Map<Id, Id>();
            if (notesIdList.size() > 0){
                Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink conDoc : [SELECT ContentDocumentId, LinkedEntityId
                                                   FROM ContentDocumentLink
                                                   WHERE LinkedEntityId IN:notesIdList]){
                    contentDocumentIds.add(conDoc.ContentDocumentId);
                    docAndParentMap.put(conDoc.ContentDocumentId, conDoc.LinkedEntityId);
                }
                System.debug(docAndParentMap);
                //get all the content notes using contentDocumentIds
                List<ContentNote> contentNotes = [SELECT Id, Content, Title, TextPreview, CreatedDate
                                                  from ContentNote
                                                  where Id In:contentDocumentIds
                                                  order by CreatedDate ASC];
                System.debug(contentNotes);
                for (ContentNote noteRec : contentNotes){
                    system.debug(noteRec.Id);
                    if (!parentandNoteMap.containsKey(docAndParentMap.get(noteRec.Id))){
                        parentandNoteMap.put(docAndParentMap.get(noteRec.Id), new list<ContentNote>());
                    }
                    parentandNoteMap.get(docAndParentMap.get(noteRec.Id)).add(noteRec);
                }
                System.debug(parentandNoteMap);
            }

            NotesAttachmet getnotesFilesLength = new NotesAttachmet();
            Map<String, NotesAttachmet> getnotesFilesLengthMap = new Map<String, NotesAttachmet>();
            if (updatetaskList.size() > 0){
                for (buildertek__Project_Task__c taskItem : updatetaskList){
                    NotesAttachmet getnotesFilesObj = new NotesAttachmet();
                    if (filesList.get(taskItem.Id) != null){
                        getnotesFilesObj.fileLength = filesList.get(taskItem.Id).size();
                    } else{
                        getnotesFilesObj.fileLength = 0;
                    }

                    if (parentandNoteMap.get(taskItem.Id) != null){
                        getnotesFilesObj.notesLength = parentandNoteMap.get(taskItem.Id).size();
                    } else{
                        getnotesFilesObj.notesLength = 0;
                    }

                    if (!getnotesFilesLengthMap.containsKey(taskItem.Id)){
                        getnotesFilesLengthMap.put(taskItem.Id, getnotesFilesObj);
                    }
                }
            }
            system.debug(getnotesFilesLengthMap);
            notewrapClass.filesandattacmentList = getnotesFilesLengthMap;
        }
        return notewrapClass;
    }

    @AuraEnabled
    public static buildertek__Project_Task__c insertUpdateTask(String taskFields, Boolean isUpdate, Id scheduleId){
        ProjectTaskTriggerHandler.updateFromGanttChart = true;

        List<buildertek__Project_Task__c> returntaskList = new List<buildertek__Project_Task__c>();
        buildertek__Project_Task__c updatedprojecttask = (buildertek__Project_Task__c)System.JSON.deserialize(taskFields, buildertek__Project_Task__c.class);
        system.debug(updatedprojecttask);
        if (isUpdate){
            //updatedprojecttask
            System.debug('in if condition lets see lag here' + updatedprojecttask.buildertek__Lag__c);
            List<buildertek__Project_Task__c> checkForMilestone = new List<buildertek__Project_Task__c>();
            if (updatedprojecttask != null){
                if (updatedprojecttask.buildertek__Phase__c != null && updatedprojecttask.buildertek__Phase__c != ''){
                    checkForMilestone = [select Id, buildertek__Indent_Task__c, Name, buildertek__Type__c, buildertek__Milestone__c, buildertek__Schedule__c, buildertek__Phase__c
                                         From buildertek__Project_Task__c
                                         where buildertek__Schedule__c = :scheduleId AND buildertek__Phase__c = :updatedprojecttask.buildertek__Phase__c AND buildertek__Milestone__c = :true];
                }
                if (checkForMilestone.size() == 0 && updatedprojecttask.buildertek__Phase__c != null && updatedprojecttask.buildertek__Phase__c != ''){
                    buildertek__Project_Task__c insertMilestoneForUpdatedTaskWithPhase = new buildertek__Project_Task__c();
                    insertMilestoneForUpdatedTaskWithPhase.Name = 'Milestone Complete';
                    insertMilestoneForUpdatedTaskWithPhase.buildertek__Start__c = updatedprojecttask.buildertek__Finish__c;
                    insertMilestoneForUpdatedTaskWithPhase.buildertek__Finish__c = updatedprojecttask.buildertek__Finish__c;
                    insertMilestoneForUpdatedTaskWithPhase.buildertek__Duration__c = 1;
                    insertMilestoneForUpdatedTaskWithPhase.buildertek__Milestone__c = true;
                    insertMilestoneForUpdatedTaskWithPhase.buildertek__Phase__c = updatedprojecttask.buildertek__Phase__c;
                    insertMilestoneForUpdatedTaskWithPhase.buildertek__Schedule__c = scheduleId;
                    system.debug(insertMilestoneForUpdatedTaskWithPhase);
                    insert insertMilestoneForUpdatedTaskWithPhase;
                    //returntaskList.add(insertMilestoneForUpdatedTaskWithPhase);
                    system.debug(insertMilestoneForUpdatedTaskWithPhase);
                }
            }
            System.debug('start date for updated Project Task ==> ' + updatedprojecttask.buildertek__Start__c);
            System.debug('end date for updated Project Task ==> ' + updatedprojecttask.buildertek__Finish__c);
            updatedprojecttask.Name = updatedprojecttask.Name;
            update updatedprojecttask;
            return updatedprojecttask;
        } else{
            List<buildertek__Project_Task__c> checkForMilestone = new List<buildertek__Project_Task__c>();
            buildertek__Project_Task__c newTask = new buildertek__Project_Task__c();
            System.debug('in else condition lets see lag here' + updatedprojecttask.buildertek__Lag__c);
            //get parent
            List<buildertek__Project_Task__c> parentTask = new List<buildertek__Project_Task__c>();
            if (!String.isBlank(updatedprojecttask.buildertek__Dependency__c)){
                parentTask = [Select Id, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c
                              FROM buildertek__Project_Task__c
                              where Id = :updatedprojecttask.buildertek__Dependency__c];
            }


            if (parentTask.size() > 0){
                updatedprojecttask.buildertek__Start__c = ProjectTaskTriggerHandler.getStartDate(parentTask[0].buildertek__Finish__c.addDays(1));
            }

            if (updatedprojecttask.buildertek__Finish__c != null && updatedprojecttask.buildertek__Duration__c != null){
                updatedprojecttask.buildertek__Finish__c = updatedprojecttask.buildertek__Start__c.addDays(Integer.valueOf(updatedprojecttask.buildertek__Duration__c) - 1);
            } else if (updatedprojecttask.buildertek__Finish__c == null){
                if (updatedprojecttask.buildertek__Duration__c != null){
                    updatedprojecttask.buildertek__Finish__c = updatedprojecttask.buildertek__Start__c.addDays(Integer.valueOf(updatedprojecttask.buildertek__Duration__c) - 1);
                }
            } else if (updatedprojecttask.buildertek__Finish__c != null){
                if (updatedprojecttask.buildertek__Duration__c == null){
                    Date d1 = updatedprojecttask.buildertek__finish__c;
                    Date d2 = updatedprojecttask.buildertek__Start__c;
                    Integer daysDiff = d2.daysbetween(d1);

                    updatedprojecttask.buildertek__Duration__c = Decimal.valueOf(daysDiff + 1);
                }
            }

            system.debug('start date in else condition ==> ' + updatedprojecttask.buildertek__Start__c);
            system.debug('end date in else condition ==> ' + updatedprojecttask.buildertek__Finish__c);
            system.debug('lag in else condition ==> ' + updatedprojecttask.buildertek__Lag__c);
            newTask.Name = updatedprojecttask.Name;
            newTask.buildertek__Dependency__c = updatedprojecttask.buildertek__Dependency__c;
            newTask.buildertek__Start__c = updatedprojecttask.buildertek__Start__c;
            newTask.buildertek__Finish__c = updatedprojecttask.buildertek__Finish__c;
            newTask.buildertek__Schedule__c = scheduleId;
            newTask.buildertek__Duration__c = updatedprojecttask.buildertek__Duration__c;
            newTask.buildertek__Phase__c = updatedprojecttask.buildertek__Phase__c;
            newTask.buildertek__Lag__c = updatedprojecttask.buildertek__Lag__c;
            newTask.buildertek__Type__c = updatedprojecttask.buildertek__Type__c;
            newTask.buildertek__Indent_Task__c = updatedprojecttask.buildertek__Indent_Task__c;
            if (updatedprojecttask.buildertek__Order__c != null){
                if (Integer.valueOf(updatedprojecttask.buildertek__Order__c) > 0){
                    newTask.buildertek__Order__c = updatedprojecttask.buildertek__Order__c;
                }
            }

            newTask.buildertek__Resource__c = updatedprojecttask.buildertek__Resource__c;
            newTask.buildertek__Contractor__c = updatedprojecttask.buildertek__Contractor__c;
            newTask.buildertek__Contractor_Resource__c = updatedprojecttask.buildertek__Contractor_Resource__c;
            newTask.buildertek__Budget__c = updatedprojecttask.buildertek__Budget__c;
            newTask.buildertek__Notes__c = updatedprojecttask.buildertek__Notes__c;
            newTask.buildertek__Completion__c = updatedprojecttask.buildertek__Completion__c;
            newTask.buildertek__Add_To_All_Active_Schedules__c = updatedprojecttask.buildertek__Add_To_All_Active_Schedules__c;

            /* before insert code */
            if (newTask.buildertek__Completion__c > 0 && newTask.buildertek__Completion_updated__c == false){
                newTask.buildertek__Actual_Start_Date__c = system.today();
                newTask.buildertek__Completion_updated__c = true;
            }
            //Get 'Trade Type' from selected Contractor[Account] and update 'Trade Type' field in Schedule Item
            if (!String.isBlank(newTask.buildertek__Contractor__c)){
                Map<id, account> newMapAccounts = new Map<id, account>([select id, buildertek__Trade_Type_Lookup__c
                                                                        from Account
                                                                        where Id = :newTask.buildertek__Contractor__c]);
                if (newMapAccounts.get(newTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c != null){
                    newTask.buildertek__Trade_Type__c = newMapAccounts.get(newTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c;
                }
            }

            /* after insert code */
            Map<Id, buildertek__Schedule__c> scheduleMap = new Map<Id, buildertek__Schedule__c>([Select Id, buildertek__Initial_Start_Date__c, Name, buildertek__Contractor__c, buildertek__External_Resource__c, buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c
                                                                                                 FROM buildertek__Schedule__c
                                                                                                 WHERE Id = :newTask.buildertek__Schedule__c]);
            newTask.buildertek__Original_Start_Date__c = ProjectTaskTriggerHandler.getStartDate(newTask.buildertek__Start__c);
            if (newTask.buildertek__Duration__c != null && newTask.buildertek__Duration__c > 0){
                newTask.buildertek__Original_End_Date__c = newTask.buildertek__Start__c.addDays(Integer.valueOf(newTask.buildertek__Duration__c) - 1);
                //newTask.buildertek__Original_End_Date__c = ProjectTaskTriggerHandler.getEndDate(newTask.buildertek__Start__c, newTask.buildertek__Original_End_Date__c);
            }
            if (newTask.buildertek__Use_External_Resource_from_Schedule__c && scheduleMap.get(newTask.buildertek__Schedule__c).buildertek__External_Resource__c != null){
                newTask.buildertek__Contractor_Resource__c = scheduleMap.get(newTask.buildertek__Schedule__c).buildertek__External_Resource__c;
            }
            if (newTask.buildertek__Use_Internal_Resource_from_Schedule__c && scheduleMap.get(newTask.buildertek__Schedule__c).buildertek__Internal_Resource_1__c != null){
                newTask.buildertek__Resource__c = scheduleMap.get(newTask.buildertek__Schedule__c).buildertek__Internal_Resource_1__c;
            }
            if (newTask.buildertek__Use_Project_Manager_from_Schedule__c && scheduleMap.get(newTask.buildertek__Schedule__c).buildertek__Project_Manager__c != null){
                newTask.buildertek__Project_Manager__c = scheduleMap.get(newTask.buildertek__Schedule__c).buildertek__Project_Manager__c;
            }

            ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
            insert newTask;
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

            newTask.buildertek__Lag__c = updatedprojecttask.buildertek__Lag__c;
            update newTask;

            //returntaskList.add(newTask);
            if (newTask.buildertek__Phase__c != null && newTask.buildertek__Phase__c != ''){
                checkForMilestone = [select Id, Name, buildertek__Milestone__c, buildertek__Schedule__c, buildertek__Phase__c
                                     From buildertek__Project_Task__c
                                     where buildertek__Schedule__c = :scheduleId AND buildertek__Phase__c = :newTask.buildertek__Phase__c AND buildertek__Milestone__c = :true];
            }
            if (checkForMilestone.size() == 0 && newTask.buildertek__Phase__c != null && newTask.buildertek__Phase__c != ''){
                buildertek__Project_Task__c insertMilestoneForUpdatedTaskWithPhase = new buildertek__Project_Task__c();
                insertMilestoneForUpdatedTaskWithPhase.Name = 'Milestone Complete';
                insertMilestoneForUpdatedTaskWithPhase.buildertek__Start__c = newTask.buildertek__Finish__c;
                insertMilestoneForUpdatedTaskWithPhase.buildertek__Finish__c = newTask.buildertek__Finish__c;
                insertMilestoneForUpdatedTaskWithPhase.buildertek__Duration__c = 1;
                insertMilestoneForUpdatedTaskWithPhase.buildertek__Milestone__c = true;
                insertMilestoneForUpdatedTaskWithPhase.buildertek__Phase__c = newTask.buildertek__Phase__c;
                insertMilestoneForUpdatedTaskWithPhase.buildertek__Schedule__c = scheduleId;
                system.debug(insertMilestoneForUpdatedTaskWithPhase);
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
                insert insertMilestoneForUpdatedTaskWithPhase;
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
                //returntaskList.add(insertMilestoneForUpdatedTaskWithPhase);
                system.debug(insertMilestoneForUpdatedTaskWithPhase);
            } else if (checkForMilestone.size() > 0){
                if (checkForMilestone[0].buildertek__Phase__c != '' && checkForMilestone[0].buildertek__Phase__c != null){
                    checkForMilestone[0].buildertek__Start__c = newTask.buildertek__Finish__c;
                    checkForMilestone[0].buildertek__Finish__c = newTask.buildertek__Finish__c;
                    ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
                    update checkForMilestone;
                    ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
                    //returntaskList.add(checkForMilestone[0]);
                }
            }

            system.debug(newTask.buildertek__Order__c);
            //DataTableDetails taskListTable = new DataTableDetails();
            // taskListTable = getScheduleItemRecords('buildertek__Project_Task__c',scheduleId);
            //System.debug(taskListTable);
            return newTask;
            /*  List<buildertek__Project_Task__c> updateorderOfTaskList = new List<buildertek__Project_Task__c>();
             if(taskListTable != null){
             if(taskListTable.lstOfSObjs.size() >0){
             for(Integer i=0;i<taskListTable.lstOfSObjs.Size();i++){
             taskListTable.lstOfSObjs[i].buildertek__Order__c = i+1;
             system.debug(taskListTable.lstOfSObjs[i]);
             updateorderOfTaskList.add(taskListTable.lstOfSObjs[i]);
             }
             if(updateorderOfTaskList.size()>0){
             update updateorderOfTaskList;
             }
             }
             } */
        }

        //System.debug(taskFields);
        //return returntaskList;
    }

    @AuraEnabled
    public static List<Contact> getAllContacts(){
        List<Contact> getConList = [Select Id, Name
                                    From Contact];
        return getConList;
    }

    @AuraEnabled
    public static string deleteTasks(String taskId, String type, String ScheduleId){
        system.debug(taskId);
        system.debug(type) ;
        String returnValue;
        if (taskId != null && type == 'Task'){
            buildertek__Project_Task__c deleteItem = [Select Id, Name
                                                      from buildertek__Project_Task__c
                                                      where Id = :taskId];
            System.debug(deleteItem);
            delete deleteItem;
            returnValue = 'deletedTask';
        } else if (type == 'Phase'){
            List<buildertek__Project_Task__c> deleteItem = [Select Id, Name, buildertek__Phase__c
                                                            from buildertek__Project_Task__c
                                                            where buildertek__Phase__c = :taskId AND buildertek__Schedule__c = :ScheduleId];
            System.debug(deleteItem);
            delete deleteItem;
            returnValue = 'deletedPhase';
        } else if (type == 'Project'){
            if (Schema.sObjectType.buildertek__Schedule__c.fields.id.isAccessible() && buildertek__Schedule__c.sObjectType.getDescribe().isDeletable()){
                buildertek__Schedule__c Schedule = [select Id
                                                    from buildertek__Schedule__c
                                                    where Id = :taskId];
                delete Schedule;
                returnValue = 'deletedSchedule';
            }
        }
        return returnValue;
    }

    @AuraEnabled
    public static buildertek__Project_Task__c getTask(Id taskId){
        buildertek__Project_Task__c task = [select Id, buildertek__Type__c, buildertek__Indent_Task__c, Name, buildertek__Order__c, buildertek__Phase__c, buildertek__Dependency__c, buildertek__Completion__c, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c, buildertek__Lag__c, buildertek__Resource__c, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Budget__c, buildertek__Add_To_All_Active_Schedules__c, buildertek__Notes__c, buildertek__Schedule__c
                                            From buildertek__Project_Task__c
                                            Where Id = :taskId];
        System.debug('Task String checking ==> ' + task);
        return task;
    }

    @AuraEnabled
    public static User updateHideGanttOnSch(Boolean hideGantt){
         //Id schId,
        /*  buildertek__Schedule__c schedulerec = [Select Id,Name,buildertek__Gantt_Draw_Dependencies__c,buildertek__Gantt_Highlight_Non_Working_Time__c,buildertek__Gantt_Project_Lines__c,buildertek__Gantt_Task_Labels__c,
         buildertek__Hide_Gantt_Schedule__c,buildertek__Project__c from buildertek__Schedule__c Where Id=:schId ];

         schedulerec.buildertek__Hide_Gantt_Schedule__c = hideGantt;
         update schedulerec; */
        User curruser = [select id, Name, buildertek__Hide_Schedule__c
                         from User
                         where id = :userInfo.getUserId()];
        curruser.buildertek__Hide_Schedule__c = hideGantt;
        update curruser;
        return curruser;
    }

    @AuraEnabled
    public static void insertUpdateTaskList(String taskJSON, Boolean isUpdate){

        List<buildertek__Project_Task__c> updatedprojecttaskList = (List<buildertek__Project_Task__c>)System.JSON.deserialize(taskJSON, List<buildertek__Project_Task__c>.class);
        List<buildertek__Project_Task__c> newUpdateList = new List<buildertek__Project_Task__c>();
        Map<Id, buildertek__Project_Task__c> projectTaskMap = new Map<Id, buildertek__Project_Task__c>();
        for (buildertek__Project_Task__c pt : updatedprojecttaskList) {
            System.debug('Old check project task in save changes + '+pt);
            projectTaskMap.put(pt.Id, pt);
        }

        for (buildertek__Project_Task__c pt : updatedprojecttaskList) {
            if (pt.buildertek__Dependency__c != null) {
                pt.buildertek__Lag__c = ProjectTaskTriggerHandler.calculateDuration(projectTaskMap.get(pt.buildertek__Dependency__c).buildertek__Finish__c, pt.buildertek__Start__c)-1;
            }
        }

        for (buildertek__Project_Task__c pt : updatedprojecttaskList) {
            System.debug('New check project task in save changes + '+pt);
        }

        if (isUpdate){
            upsert updatedprojecttaskList;
        }
        System.debug(taskJSON);
    }

    @AuraEnabled
    public static Date getEndDate(String sDate, String eDate, Integer duration){

        Date startDate = Date.valueOf(sDate);
        Date endDate;
        String todayDay;
        DateTime currDate;
        if (Integer.valueOf(duration) > 0){
            endDate = startDate.addDays(Integer.valueOf(duration) - 1);
            currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
            todayDay = currDate.format('EEEE');
            if (todayDay == 'Saturday'){
                startDate = startDate.addDays(2);
            } else if (todayDay == 'Sunday'){
                startDate = startDate.addDays(1);
            }
            endDate = startDate.addDays(Integer.valueOf(duration) - 1);
            for (integer j = 0; j <= startDate.daysBetween(endDate); j++){
                Date dt = startDate + j;
                DateTime currentDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                todayDay = currentDate.format('EEEE');
                if (todayDay == 'Saturday' || todayDay == 'Sunday'){
                    endDate = endDate.addDays(1);
                }
            }
            //recordObject.put('buildertek__Finish__c',endDate);
        } else{
            endDate = startDate;
            currDate = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());
            todayDay = currDate.format('EEEE');
            if (todayDay == 'Saturday'){
                endDate = endDate.addDays(2);
            } else if (todayDay == 'Sunday'){
                endDate = endDate.addDays(1);
            }
            //recordObject.put('buildertek__Finish__c', endDate);
        }
        dateValues dtValues = new dateValues();
        dtValues.sDate = startDate;
        dtValues.eDate = endDate;
        dtValues.duration = Integer.valueOf(duration);
        //return dtValues;
        return endDate;
    }

    @AuraEnabled
    public static Date getEndDateBeforeCellEdit(String sDate, String duration){
        system.debug(sDate);
        system.debug(sDate.split('-'));
        // System.debug(Date.newInstance(sDate.split('-')[0],sDate.split('-')[1],sDate.split('-')[2]));
        String str = sDate;
        List<String> res = str.split('-');
        System.debug(Date.newInstance(Integer.valueOf(res[0]), Integer.valueOf(res[1]), Integer.valueOf(res[2])));
        Date startDate = Date.newInstance(Integer.valueOf(res[0]), Integer.valueOf(res[1]), Integer.valueOf(res[2]));
        Date endDate;
        String todayDay;
        DateTime currDate;
        system.debug(sDate);
        system.debug(duration);
        if (Integer.valueOf(duration) > 0){
            endDate = startDate.addDays(Integer.valueOf(duration) - 1);
            currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
            todayDay = currDate.format('EEEE');
            if (todayDay == 'Saturday'){
                startDate = startDate.addDays(2);
            } else if (todayDay == 'Sunday'){
                startDate = startDate.addDays(1);
            }
            endDate = startDate.addDays(Integer.valueOf(duration) - 1);
            for (integer j = 0; j <= startDate.daysBetween(endDate); j++){
                Date dt = startDate + j;
                DateTime currentDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                todayDay = currentDate.format('EEEE');
                if (todayDay == 'Saturday' || todayDay == 'Sunday'){
                    endDate = endDate.addDays(1);
                }
            }
            System.debug(endDate);
            //recordObject.put('buildertek__Finish__c',endDate);
        } else{
            endDate = startDate;
            currDate = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());
            todayDay = currDate.format('EEEE');
            if (todayDay == 'Saturday'){
                endDate = endDate.addDays(2);
            } else if (todayDay == 'Sunday'){
                endDate = endDate.addDays(1);
            }
            //recordObject.put('buildertek__Finish__c', endDate);
        }
        dateValues dtValues = new dateValues();
        dtValues.sDate = startDate;
        dtValues.eDate = endDate;
        dtValues.duration = Integer.valueOf(duration);
        System.debug(endDate);
        //return dtValues;
        return endDate;
    }

    @AuraEnabled
    public static Integer getDurationAfterCellEdit(String sDate, String eDate){
        String str = sDate;
        List<String> res = str.split('-');
        System.debug(Date.newInstance(Integer.valueOf(res[0]), Integer.valueOf(res[1]), Integer.valueOf(res[2])));
        String str1 = eDate;
        List<String> res1 = str1.split('-');
        Date startDate = Date.newInstance(Integer.valueOf(res[0]), Integer.valueOf(res[1]), Integer.valueOf(res[2]));
        Date endDate = Date.newInstance(Integer.valueOf(res1[0]), Integer.valueOf(res1[1]), Integer.valueOf(res1[2]));
        Integer duration = 0;
        String todayDay;
        for (Integer j = 0; j <= startDate.daysBetween(endDate); j++){
            Date dt = startDate;
            DateTime currentDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
            todayDay = currentDate.format('EEEE');
            if (todayDay != 'Saturday' || todayDay != 'Sunday'){
                duration = duration + 1;
            }
        }
        return duration;
    }

    //fetch picklist values from custom object in lwc
    @AuraEnabled(cacheable = true)
    public static List<customValueWrapper> pickListValueDynamically(sObject customObjInfo, string selectPicklistApi){
        Schema.DescribeSObjectResult objDescribe = customObjInfo.getSObjectType().getDescribe();
        map<String, Schema.SObjectField> customFieldMap = objDescribe.fields.getMap();
        list<Schema.PicklistEntry> custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
        list<customValueWrapper> customObjWrapper = new list<customValueWrapper>();
        Integer i = 0;
        customValueWrapper optionValueWrapper = new customValueWrapper();
        optionValueWrapper.label = '--None--';
        optionValueWrapper.value = '';
        customObjWrapper.add(optionValueWrapper);

        for (Schema.PicklistEntry myCustPick : custPickValues){

            customValueWrapper selectOptionValueWrapper = new customValueWrapper();

            selectOptionValueWrapper.label = myCustPick.getLabel();
            selectOptionValueWrapper.value = myCustPick.getValue();
            customObjWrapper.add(selectOptionValueWrapper);
        }

        return customObjWrapper;
    }

    @AuraEnabled
    public static string addCommentToRecord(String schItem){
        buildertek__Project_Task__c taskItem = (buildertek__Project_Task__c)System.JSON.deserialize(SchItem, buildertek__Project_Task__c.class);
        system.debug(taskItem);
        if (taskItem != null){
            update taskItem;
            return 'Success';
        }
        return '';
    }

    @AuraEnabled
    public static string addNotesCommentToRecord(String schItem, List<ContentNote> notes){
        //List<ContentNote> notesList= (List<ContentNote>)System.JSON.deserialize(notes, List<ContentNote>.class);
        List<ContentNote> notesList = new List<ContentNote>();
        system.debug(notesList);
        if (notes.Size() != null){
            for (ContentNote noteRec : notes){
                ContentNote noteRecord = new ContentNote();
                noteRecord.Title = noteRec.Title;
                String body = noteRec.TextPreview;
                noteRecord.Content = Blob.valueOf(body.escapeHTML4());
                notesList.add(noteRecord);
                //insert noteRecord;

            }
            insert notesList;

            Set<Id> noteIds = new Set<Id>();
            List<ContentDocumentLink> docLinkList = new List<ContentDocumentLink>();
            for (ContentNote item : notesList){
                system.debug(notesList);
                ContentDocumentLink link = new ContentDocumentLink();
                link.ContentDocumentId = item.Id;
                link.LinkedEntityId = schItem;
                link.ShareType = 'V';
                link.Visibility = 'InternalUsers';
                docLinkList.add(link);

                noteIds.add(item.Id);
            }
            if (docLinkList.size() > 0){
                insert docLinkList;
            }
            /* List<ContentDocumentLink> docList = new List<ContentDocumentLink>();
             List<ContentDocumentLink> conDocList = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE  ContentDocumentId IN :noteIds];
             for(ContentDocumentLink conDoc : conDocList){
             ContentDocumentLink docLink = new ContentDocumentLink();
             docLink.Id = conDoc.Id;
             //  docLink.ContentDocumentId = conDoc.ContentDocumentId;
             docLink.LinkedEntityId = schItem;
             docList.add(docLink);
             //contentDocumentIds.add(conDoc.ContentDocumentId);
             }
             if(docList.size() > 0){
             update docList;
             } */
            return 'Success';
        }
        return '';
    }

    @AuraEnabled
    public static buildertek__Project_Task__c getNotesofRecord(Id schId){
        system.debug(schId);
        buildertek__Project_Task__c task = [Select Id, Name, buildertek__Notes__c
                                            From buildertek__Project_Task__c
                                            Where Id = :schId];

        return task;
    }

    @AuraEnabled
    public static List<notesWrapper> getAllNotes(Id schId){
         //List<ContentNote>
        Set<Id> taskIds = new Set<Id>();
        taskIds.add(schId); //include all the contact ids for which you need to retrieve content note
        Set<Id> contentDocumentIds = new Set<Id>();
        //get all contentdocumentids so that you can query on contentnote
        for (ContentDocumentLink conDoc : [SELECT ContentDocumentId
                                           FROM ContentDocumentLink
                                           WHERE LinkedEntityId IN:taskIds]){
            contentDocumentIds.add(conDoc.ContentDocumentId);
        }
        //get all the content notes using contentDocumentIds
        List<ContentNote> contentNotes = [SELECT Id, Content, Title, TextPreview, LastModifiedDate, CreatedDate, CreatedById, CreatedBy.Name
                                          from ContentNote
                                          where Id In:contentDocumentIds
                                          order by CreatedDate ASC];
        List<notesWrapper> wrapperNote = new List<notesWrapper>();
        if (contentNotes.size() > 0){
            for (ContentNote note : contentNotes){
                notesWrapper noteWrap = new notesWrapper();
                noteWrap.Id = note.Id;
                noteWrap.TextPreview = note.Content.toString();
                noteWrap.timeStamp = note.CreatedDate.format('MM/dd/yyyy HH:mm:ss');//String.valueOf(note.LastModifiedDate);
                noteWrap.createdUsername = note.CreatedBy.Name;
                wrapperNote.add(noteWrap);
            }
        }
        //return contentNotes;
        return wrapperNote;
    }

    public class notesWrapper{
        @AuraEnabled
        public String TextPreview;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String timeStamp;
        @AuraEnabled
        public String createdUsername;
    }

    @AuraEnabled
    public static buildertek__Project_Task__c saveResourceForRecord(Id taskId, String resourceId, String resourceApiName){
        System.debug('check param here');
        System.debug('taskID '+taskId);
        System.debug('resourceID '+resourceId);
        System.debug('resourceAPIName '+resourceApiName);
        string rel = resourceApiName.split('__c')[0] + '__r.Name';
        String queryStr = 'Select Id,Name,' + resourceApiName + ',' + rel + ' From buildertek__Project_Task__c Where Id=:taskId';
        String apiName = resourceApiName;
        System.debug('apiName>>>' + apiName);
        buildertek__Project_Task__c updateTask = Database.query(queryStr);
        List<buildertek__Project_Task__c> updateTaskResourceList = new List<buildertek__Project_Task__c>();
        if (resourceApiName == 'buildertek__Resource__c'){
            if (resourceId != null){
                system.debug(updateTask.buildertek__Resource__c);
                system.debug(resourceId);
                buildertek__Project_Task__c projTask = new buildertek__Project_Task__c();
                projTask.Id = updateTask.Id;
                projTask.buildertek__Resource__c = resourceId;
                updateTaskResourceList.add(projTask);
                update updateTaskResourceList;
                system.debug(updateTaskResourceList[0].buildertek__Resource__c);
            }
        } else if (apiName == 'buildertek__Contractor_Resource__c'){
            if (resourceId != null){
                Contact con = [SELECT Id, AccountId
                               from Contact
                               Where id = :resourceId];
                buildertek__Project_Task__c projTask = new buildertek__Project_Task__c();
                projTask.Id = updateTask.Id;
                projTask.buildertek__Contractor_Resource__c = resourceId;
                projTask.buildertek__Contractor__c = con.AccountId;
                updateTaskResourceList.add(projTask);
                update updateTaskResourceList;
            }
        }


        //added for contractor
        else if (apiName == 'buildertek__Contractor__c'){

            System.debug('In contractor>>>>');
            System.debug('resourceId>>>' + resourceId);
            System.debug('resourceApiName>>>' + resourceApiName);
            if (resourceId != null){
                Account acc = [SELECT Id, Name
                               from Account
                               Where Id = :resourceId];
                buildertek__Project_Task__c projTask = new buildertek__Project_Task__c();
                projTask.Id = updateTask.Id;
                // projTask.buildertek__Contractor_Resource__c = resourceId;
                projTask.buildertek__Contractor__c = acc.Id;
                updateTaskResourceList.add(projTask);
                update updateTaskResourceList;
            }
        }


        return updateTask;
    }

    @AuraEnabled
    public static String changeOriginalDates(String recordId){
        try{
            System.debug('changeOriginalDates');
            List<buildertek__Project_Task__c> scheduleTaskList = [SELECT Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c
                                                                  FROM buildertek__Project_Task__c
                                                                  WHERE buildertek__Schedule__c = :recordId
                                                                  FOR  UPDATE ];
            System.debug('scheduleTaskList => ' + scheduleTaskList);
            for (buildertek__Project_Task__c st : scheduleTaskList){
                st.buildertek__Original_Start_Date__c = st.buildertek__Start__c;
                st.buildertek__Original_End_Date__c = st.buildertek__Finish__c;
            }
            update scheduleTaskList;
            System.debug('Success');
            return 'Success';

        } catch (Exception e){
            String data = 'Error => ' + e.getMessage() + ' || Line No => ' + e.getLineNumber();
            System.debug(data);
            return data;
        }
    }

    @AuraEnabled(cacheable = true)
    public static String getRecordType(){
        List<SelectOption> recordTypes = new List<SelectOption>();
        for (RecordTypeInfo info : buildertek__Project_Task__c.SObjectType.getDescribe().getRecordTypeInfos()){
            if (info.isAvailable()){
                recordTypes.add(new SelectOption(info.getRecordTypeId(), info.getName()));
            }
        }
        return recordTypes[0].getValue();
    }

    // public static string updateTaskRecord(List<Map<String, String>> taskData){
    @AuraEnabled
    public static string updateTaskRecord(List<List<String>> taskData){
        try{
            System.debug('========updateTaskRecord==============');
            system.debug(taskData);


            Set<Id> taskIds = new Set<Id>();
            for (List<String> taskMap : taskData){
                System.debug('taskMap ==> ' + taskMap);
                if (taskMap[0] != null && taskMap[1] != null){
                    taskIds.add(taskMap[0]);
                }
            }

            Map<Id, buildertek__Project_Task__c> oldTaskMap = new Map<Id, buildertek__Project_Task__c>([SELECT Id, Name, buildertek__Dependency__c, buildertek__Finish__c
                                                                                                        FROM buildertek__Project_Task__c
                                                                                                        WHERE Id IN:taskIds]);


            List<buildertek__Project_Task__c> taskList = new List<buildertek__Project_Task__c>();
            Map<Id, buildertek__Project_Task__c> newTaskMap = new Map<Id, buildertek__Project_Task__c>();


            for (List<String> taskMap : taskData){

                String pId = oldTaskMap.get(taskMap[0]).buildertek__Dependency__c;
                if (pId != '' && pId != null){
                    buildertek__Project_Task__c task = new buildertek__Project_Task__c();
                    task.Id = pId;

                    task.buildertek__Finish__c = Datetime.valueOf(taskMap[1].replace('T', ' ')).date();

                    System.debug('task ==> ' + task);
                    newTaskMap.put(task.Id, task);

                    taskList.add(task) ;
                }
            }


            // update newTaskMap.values();
            // update taskList[0];
            return 'Success';
        } catch (Exception e){
            String data = 'Error Message => ' + e.getMessage() + 'Error Line no => ' + e.getLineNumber();
            return data;
        }
    }


    //* store wbs value
    @AuraEnabled
    public static void setWBSValue(String scheduleItemMap){
        try {
            System.debug('setWBSValue Called');

            List<buildertek__Project_Task__c> scheduleItemList = new List<buildertek__Project_Task__c>();
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(scheduleItemMap);
            Set<String> ScheduleItemIds= new Set<String>();

            for (String key : dataMap.keySet()) {
                Object value = dataMap.get(key);
                // Process the key-value pair as needed
                String jsonString = JSON.serialize(value);
                jsonString = jsonString.replace('"','');
                ScheduleItemIds.add(jsonString);
            }

            scheduleItemList = [Select Id , buildertek__WBS__c, Name From buildertek__Project_Task__c WHERE Id IN:ScheduleItemIds];

            if (scheduleItemList.size() > 0) {
                for(buildertek__Project_Task__c scheduleItem:scheduleItemList){
                    for (String key : dataMap.keySet()) {
                        Object value = dataMap.get(key);
                        // Process the key-value pair as needed
                        System.debug('Key: ' + key + ', Value: ' + value);
                        if(value == scheduleItem.Id && key!= '1'){
                            scheduleItem.buildertek__WBS__c=key;
                        }
                    }
                }
                ProjectTriggerHandler.blnSkipProjectTrigger = true;
                update scheduleItemList;
                ProjectTriggerHandler.blnSkipProjectTrigger = false;
            }

        } catch (Exception e) {
            System.debug(e);
            System.debug('line number for WBS ==>' + e.getLineNumber() + ' - error ==>' + e.getMessage());
        }
    }



    // wrapper class
    public with sharing class customValueWrapper{
        @auraEnabled
        public string label{ get; set; }

        @auraEnabled
        public string value{ get; set; }

    }

    public class DataTableDetails{
        @AuraEnabled
        public List<buildertek__Project_Task__c> lstOfSObjs = new List<buildertek__Project_Task__c>();
        @AuraEnabled
        public buildertek__Schedule__c scheduleObj = new buildertek__Schedule__c();
        @AuraEnabled
        //public List<Object> fileLengthForRecord = new List<Object>();
        public Map<String, NotesAttachmet> filesandattacmentList = new Map<String, NotesAttachmet>();
        @AuraEnabled
        public string ganttJSON;
        @AuraEnabled
        public boolean hideScheduleFromUser;
        @AuraEnabled
        public string profileName;
        /* @AuraEnabled
         public boolean importEnabled; */
    }

    public class notesLenClass{
        @AuraEnabled
        public Map<String, NotesAttachmet> filesandattacmentList = new Map<String, NotesAttachmet>();
    }

    public class Innerclass{
        @AuraEnabled
        public Map<string, List<buildertek__Project_Task__c>> ResultMap;
        @AuraEnabled
        public List<sObject> lstOfSObj = new List<sObject>();
    }

    public class NotesAttachmet{
        @AuraEnabled
        public Integer fileLength;
        @AuraEnabled
        public Integer notesLength;
    }

    public class dateValues{
        @AuraEnabled
        public Date sDate;
        @AuraEnabled
        public Date eDate;
        @AuraEnabled
        public Integer duration;

    }

}