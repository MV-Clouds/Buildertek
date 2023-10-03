public with sharing class bryntumGanttController {

    @AuraEnabled
    public static DataTableDetails getScheduleWrapperAtLoading(string scheduleid){


        System.debug('getScheduleWrapperAtLoading called===');
        List<Id> filesIdList = new List<Id>();
        Set<Id> notesIdList = new Set<Id>();


        DataTableDetails dataTableDtls = new DataTableDetails();

        String strQuery = 'SELECT ';

        strQuery += 'Id,Name,buildertek__Type__c,buildertek__Indent_Task__c,buildertek__Completed__c, buildertek__Reference_for_Import__c,buildertek__Lag__c,buildertek__Schedule__c,buildertek__Budget__c,buildertek__ConstraintType__c,buildertek__ConstraintDate__c,buildertek__DependencyStatus__c,buildertek__Add_To_All_Active_Schedules__c,buildertek__Notes__c,buildertek__Schedule__r.Name,buildertek__Schedule__r.buildertek__Description__c,buildertek__Start__c,buildertek__Finish__c,buildertek__Duration__c,buildertek__Contractor__c,buildertek__Contractor__r.Name,buildertek__Phase__c,buildertek__Completion__c, buildertek__Dependency__c,buildertek__Dependency__r.Name,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Resource__c, buildertek__Resource__r.Name,buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_1__r.Name,buildertek__Contractor_Resource_2__c,buildertek__Contractor_Resource_2__r.Name,buildertek__Contractor_Resource_3__c,buildertek__Contractor_Resource_3__r.Name,buildertek__Internal_Resource_1__c,buildertek__Internal_Resource_1__r.Name,buildertek__Internal_Resource_3__c,buildertek__Internal_Resource_3__r.Name,buildertek__Internal_Resource_4__c,buildertek__Internal_Resource_4__r.Name,buildertek__Milestone__c,buildertek__Order__c,buildertek__Budget_Line__c,CreatedDate FROM buildertek__Project_Task__c where buildertek__Schedule__c = :  scheduleid Order By buildertek__Order__c NULLS LAST,CreatedDate';
        //CreatedDate//Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC
        system.debug('strQuery---' + strQuery);

        dataTableDtls.lstOfSObjs = Database.query(strQuery);

        System.debug('dataTableDtls**=='+JSON.serialize(dataTableDtls.lstOfSObjs));
        List<buildertek__Project_Task__c> projectTasksSorted = dataTableDtls.lstOfSObjs;

        String milestonequery = 'Select buildertek__Project__r.Name,buildertek__Schedule__r.Name,buildertek__Schedule__r.buildertek__Description__c, buildertek__Dependency__r.buildertek__Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + new_BT_Utils.getQueryStringForObjectWithAllFields('buildertek__Project_Task__c');
        milestonequery = milestonequery + ' From buildertek__Project_Task__c where buildertek__Schedule__c =:scheduleid AND buildertek__Milestone__c= true';
        List<buildertek__Project_Task__c> milestoneTaskList = DataBase.query(milestonequery);

        Map<String, List<buildertek__Project_Task__c>> TaskWithPhaseMap = new Map<String, List<buildertek__Project_Task__c>>();

        for (buildertek__Project_Task__c task : projectTasksSorted){
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
        buildertek__Schedule__c schedulerec = [Select Id, Name, buildertek__Description__c, buildertek__Gantt_Draw_Dependencies__c, buildertek__Gantt_Highlight_Non_Working_Time__c, buildertek__Gantt_Project_Lines__c, buildertek__Gantt_Task_Labels__c, buildertek__Hide_Gantt_Schedule__c,buildertek__Initial_Start_Date__c, buildertek__Project__c, buildertek__Project__r.Name
                                            from buildertek__Schedule__c
                                            Where Id = :scheduleid];
        dataTableDtls.scheduleObj = schedulerec;
        NotesAttachmet notesAttachFiles = new NotesAttachmet();
        Map<String, NotesAttachmet> getnotesFilesLengthMap = new Map<String, NotesAttachmet>();

        if (updatetaskList.size() > 0){
            Map<Id, list<ContentVersion>> filesList = new Map<Id, list<ContentVersion>>();
            if (filesIdList.size() > 0){
                filesList = new_filePreviewController.getRelatedFiles(filesIdList);
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

        List<object> fileLenListCustom = new list<Object>();

        dataTableDtls.lstOfSObjs = updatetaskList;
        System.debug('updatetaskList===='+JSON.serialize(updatetaskList));

        dataTableDtls.filesandattacmentList = getnotesFilesLengthMap;
        dataTableDtls.hideScheduleFromUser = curruser.buildertek__Hide_Schedule__c;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id = :profileId].Name;
        system.debug('ProfileName' + profileName);
        system.debug(userinfo.getusername());
        dataTableDtls.profileName = profileName;
        System.debug('dataTable :: ' + dataTableDtls);

        dataTableDtls.listOfContractorAndResources = [SELECT Id, Name, (SELECT Id, Name, LastName, FirstName FROM Contacts) FROM Account WHERE buildertek__BT_Account_Type__c = 'Vendor' ORDER BY Name ASC];
        dataTableDtls.listOfInternalResources = [SELECT Id, Name FROM User ORDER BY Name ASC LIMIT 10000];

        return dataTableDtls;
    }

    @AuraEnabled(Cacheable=true)
    public static List<buildertek__Project__c> searchProject(String searchProjectName){
        List<buildertek__Project__c> searchProjectList = [SELECT Name, Id FROM buildertek__Project__c WHERE Name LIKE :('%' + searchProjectName + '%')];
        System.debug('searchProjectList: ' + searchProjectList);
        return searchProjectList;
    }

    @AuraEnabled(Cacheable=true)
    public static List<User> searchUsers(String searchProjectManagerName){
        List<User> searchProjectManagerList = [SELECT Name, Id FROM User WHERE Name LIKE :('%' + searchProjectManagerName + '%')];
        System.debug('searchProjectManagerList: ' + searchProjectManagerList);
        return searchProjectManagerList;
    }

    @AuraEnabled
    public static list<buildertek__Schedule__c> fetchScheduleList(){

        return [select id, Name, buildertek__Type__c, buildertek__Total_Duration__c, buildertek__Description__c
        from buildertek__Schedule__c
        where buildertek__Type__c LIKE '%Master%'];
    }

    @AuraEnabled
    public static list<buildertek__Project_Task__c> getScheduleItemList(String masterId){
        string mId = masterId;
        System.debug('mId: ' + mId);
        return [select id, Name, buildertek__Start__c, buildertek__Phase__c, buildertek__Schedule__c, buildertek__Budget__c, buildertek__Budget_Line__c, buildertek__Completed__c, buildertek__Completion__c, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Cost_Code__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Last_Saved_End_Date__c, buildertek__Last_Saved_Start_Date__c, buildertek__Material_Ordered__c, buildertek__Material_Received__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Payable_Task__c, buildertek__Project__c
                from buildertek__Project_Task__c
                where buildertek__Schedule__c = :mId
                order by createdDate];
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
                Contact con = [SELECT Id, AccountId from Contact Where id = :resourceId];
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
                Account acc = [SELECT Id, Name from Account Where Id = :resourceId];
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
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = buildertek__Project_Task__c.buildertek__Phase__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static String upsertDataOnSaveChanges(String scheduleRecordStr, String taskRecordsStr, List<String> listOfRecordsToDelete, Map<String, String> childParentMap, Map<String, Object> projectTaskMap){
        String msg;
        buildertek__Schedule__c scheduleRecord = (buildertek__Schedule__c)System.JSON.deserialize(scheduleRecordStr, buildertek__Schedule__c.class);
        List<buildertek__Project_Task__c> taskRecords = (List<buildertek__Project_Task__c>)System.JSON.deserialize(taskRecordsStr, List<buildertek__Project_Task__c>.class);

        try {
            System.debug('childParentMap ==> '+childParentMap);
            System.debug('projectTaskMap ==> '+projectTaskMap);
            System.debug('listOfRecordsToDelete '+listOfRecordsToDelete);
            System.debug('listOfRecordsToDelete size '+listOfRecordsToDelete.size());
            if (listOfRecordsToDelete.size() > 0) {
                LIST<buildertek__Project_Task__c> taskListToDelete = [SELECT Id FROM buildertek__Project_Task__c WHERE Id IN :listOfRecordsToDelete];
                if (taskListToDelete.size() > 0) {
                    delete taskListToDelete;
                }
            }

            update scheduleRecord;
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
            if (projectTaskMap.size() > 0) {
                Map<String, buildertek__Project_Task__c> newProjectTaskMap = new Map<String, buildertek__Project_Task__c>();
                for (String key : projectTaskMap.keySet()) {
                    String jsonString = JSON.serialize(projectTaskMap.get(key));
                    buildertek__Project_Task__c task = (buildertek__Project_Task__c)JSON.deserialize(jsonString, buildertek__Project_Task__c.class);
                    newProjectTaskMap.put(key, task);
                }
                upsert newProjectTaskMap.values();

                if (childParentMap.size() > 0) {
                    List<buildertek__Project_Task__c> newTaskList = new List<buildertek__Project_Task__c>();
                    for (String taskId : childParentMap.keySet()) {
                        buildertek__Project_Task__c task = newProjectTaskMap.get(taskId);
                        task.buildertek__Dependency__c = newProjectTaskMap.get(childParentMap.get(taskId)).Id;
                        newTaskList.add(task);
                    }
                    if (newTaskList.size() > 0) {
                        update newTaskList;
                    }
                }
            }
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
            msg = 'Success';
        } catch (Exception e) {

            System.debug('Exception e '+e);
            System.debug('Exception e '+e.getMessage());
            System.debug('Exception e '+e.getLineNumber());
            msg = e.getMessage() + ' ' + e.getLineNumber();
        }
        return msg;
    }

    /* @Author        Karan Patel
     * Date           10-7-23
     * Description :  This method is used to create New Schedule.
     */

    @AuraEnabled
    public static String createNewSchedule(String description, String project ,Date initialStartDate, String type, String user, String masterId) {
        System.debug('description: ' + description);
        System.debug('project: ' + project);
        System.debug('initialStartDate: ' + initialStartDate);
        System.debug('type: ' + type);
        System.debug('user: ' + user);
        System.debug('masterId: ' + masterId);

        if(initialStartDate == null ){
            initialStartDate = Date.Today();
            System.debug('initialStartDate: ' + initialStartDate);
        }

        initialStartDate = getInitialStartDate(initialStartDate);

        System.debug('initialStartDate: outif' + initialStartDate);

        buildertek__Schedule__c schedule = new buildertek__Schedule__c(
            buildertek__Description__c = description,
            buildertek__Initial_Start_Date__c = date.parse(initialStartDate.format()),
            buildertek__Type__c = type,
            buildertek__Project_Managers__c = user,
            buildertek__Project__c = project
        );
        insert schedule;
        String pageUrl = schedule.Id;

        if(masterId != null && masterId != ''){
            createScheduleLineFromMasterSchedule(schedule.Id, masterId, initialStartDate);
        }

        return pageUrl;
    }

    /* @Author        Karan Patel
     * Date           10-7-23
     * Description :  This method is used to create New ScheduleLine from Master Schedule.
     */

    @AuraEnabled
    public static void createScheduleLineFromMasterSchedule (String recordId, String masterId, Date initialStartDate){

        buildertek__Schedule__c masterSchedule = [SELECT Id, Name, buildertek__Start_Date__c, buildertek__Initial_Start_Date__c FROM buildertek__Schedule__c WHERE Id =: masterId];
        String businessHourId = [SELECT Id, IsDefault, IsActive FROM BusinessHours WHERE IsDefault = true LIMIT 1].Id;

        date masterStartDate = masterSchedule.buildertek__Start_Date__c;
        if (masterStartDate == null) {
            masterStartDate = System.today();
        }
        initialStartDate = getInitialStartDate(initialStartDate);
        DateTime oldDate = DateTime.newInstance(masterStartDate.year(), masterStartDate.month(),masterStartDate.day());
        DateTime newDate = DateTime.newInstance(initialStartDate.year(), initialStartDate.month(),initialStartDate.day());

        // Integer diffDays = Integer.valueOf(System.BusinessHours.diff(businessHourId, oldDate, newDate)/(24 * 60 * 60 * 1000L));
        Long diffDays = System.BusinessHours.diff(businessHourId, oldDate, newDate);

        Map<Id, buildertek__Project_Task__c> projectInsertTaskMap = new Map<Id, buildertek__Project_Task__c>();

        List<buildertek__Project_Task__c> masterScheduleList = new List<buildertek__Project_Task__c>([select Id, Name, buildertek__Start__c,buildertek__Contractor__c,buildertek__Phase__c, buildertek__Schedule__c,buildertek__Dependency__r.Name, buildertek__Dependency__r.buildertek__Schedule__c, buildertek__Completed__c, buildertek__Completion__c, buildertek__Contractor_Resource__c, buildertek__Type__c,buildertek__Cost_Code__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Last_Saved_End_Date__c, buildertek__Last_Saved_Start_Date__c, buildertek__Material_Ordered__c, buildertek__Material_Received__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Payable_Task__c, buildertek__Project__c, buildertek__Purchase_Order__c, buildertek__Reason_for_Date_Change__c, buildertek__Reason_for_Date_Change_PL__c, buildertek__Required_Completion_Date__c  from buildertek__Project_Task__c where buildertek__Schedule__c = :masterId  ORDER BY buildertek__Order__c ASC NULLS LAST]);

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

                newSchItem.Name = Masterscheduleitem.Name;
                buildertek__Project_Task__c newSchItemClone = newSchItem.Clone(false, true);
                projectInsertTaskMap.put(Masterscheduleitem.Id, newSchItemClone);

            }
        }

        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        insert projectInsertTaskMap.values();
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

        for (String key : predecessorMap.keySet()) {
            projectInsertTaskMap.get(key).buildertek__Dependency__c = projectInsertTaskMap.get(predecessorMap.get(key)).Id;
        }

        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        update projectInsertTaskMap.values();
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

    }

    @AuraEnabled
    public static String getProjectName(String parentRecordId){
        try {
            String searchProjectName = [SELECT Name, Id FROM buildertek__Project__c WHERE Id =: parentRecordId].Name;
            System.debug('searchProjectName: ' + searchProjectName);
            return searchProjectName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* @Author        Nishit Suthar
     * Date           03-10-2023
     * Description :  This method is used for changing original start and end date with current start and end date.
     */
    @AuraEnabled
    public static String changeOriginalDates(String recordId){
        try{
            List<buildertek__Project_Task__c> scheduleTaskList = [SELECT Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c
                                                                  FROM buildertek__Project_Task__c
                                                                  WHERE buildertek__Schedule__c = :recordId
                                                                  FOR  UPDATE ];
            for (buildertek__Project_Task__c st : scheduleTaskList){
                st.buildertek__Original_Start_Date__c = st.buildertek__Start__c;
                st.buildertek__Original_End_Date__c = st.buildertek__Finish__c;
            }
            update scheduleTaskList;
            return 'Success';

        } catch (Exception e){
            String data = 'Error => ' + e.getMessage() + ' || Line No => ' + e.getLineNumber();
            System.debug(data);
            return data;
        }
    }


    /* @Author        Nishit Suthar
     * Date           24-08-2023
     * Description :  This method is used for checking sat & sun on InitialStartdate.
     */
    public static Date getInitialStartDate(Date startDate){
		DateTime currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
		String todayDay = currDate.format('EEEE');
		if (todayDay == 'Saturday'){
			startDate = startDate.addDays(2);
		} else if (todayDay == 'Sunday'){
			startDate = startDate.addDays(1);
		}
		return startDate;
	}

    /* Wrapper Class */
    //* moved all the wrapper classes to bottom by Nishit

    public class DataTableDetails{
        @AuraEnabled
        public List<buildertek__Project_Task__c> lstOfSObjs = new List<buildertek__Project_Task__c>();
        @AuraEnabled
        public buildertek__Schedule__c scheduleObj = new buildertek__Schedule__c();
        @AuraEnabled
        public Map<String, NotesAttachmet> filesandattacmentList = new Map<String, NotesAttachmet>();
        @AuraEnabled
        public List<User> listOfInternalResources = new List<User>();
        @AuraEnabled
        public List<Account> listOfContractorAndResources = new List<Account>();
        @AuraEnabled
        public string ganttJSON;
        @AuraEnabled
        public boolean hideScheduleFromUser;
        @AuraEnabled
        public string profileName;
    }

    public class NotesAttachmet{
        @AuraEnabled
        public Integer fileLength;
        @AuraEnabled
        public Integer notesLength;
    }

    public class RfqDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }

        @AuraEnabled
        public Integer pageNumber{ get; set; }

        @AuraEnabled
        public Integer totalRecords{ get; set; }

        @AuraEnabled
        public Integer recordStart{ get; set; }

        @AuraEnabled
        public Integer recordEnd{ get; set; }

        @AuraEnabled
        public List<Contact> recordList{ get; set; }

        @AuraEnabled
        public List<contactWrap> wrapperList ;

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean check;
        @AuraEnabled
        public String accId;
        @AuraEnabled
        public String accName;

        @AuraEnabled
        public List<RfqDataTableSubWrapper> accRecList {get;set;}
        // @AuraEnabled
        // public List<RfqDataTableSubWrapper> subwraplist {get;set;}

        // @AuraEnabled
        // public List<Account> accRecList{get;set;}
    }

    public class RfqDataTableSubWrapper{
        @AuraEnabled
        public String Id {get;set;}

        @AuraEnabled
        public String Name {get;set;}

        @AuraEnabled
        public Boolean check {get;set;}
    }

    public class contactWrap{

        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean check;
        @AuraEnabled
        public String accId;
        @AuraEnabled
        public String accName;
    }

}