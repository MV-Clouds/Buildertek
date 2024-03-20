public with sharing class SingleProjResourceScheduleDashnoardCls {
    @AuraEnabled
    public static String getProjectId(string scheduleId){
        List<buildertek__Schedule__c> schdelelist = [select id,buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Customer__r.name from buildertek__Schedule__c  where id=:scheduleId];
        projectWrapper prj = new projectWrapper();

        if (schdelelist.size() > 0){
            prj.Id = schdelelist[0].buildertek__Project__c;
            prj.Name = schdelelist[0].buildertek__Project__r.Name;
            prj.AccountName = schdelelist[0].buildertek__Project__r.buildertek__Customer__r.name;
        }

        String result = JSON.serialize(prj);
        System.debug('result : '+result);
        return result;
    }

    @AuraEnabled
    public static  combinedProjectCalendarWrapperClone getScheduleItemsByProject(String fromDate, String toDate, string slectedTradetypeId, string slectedprojectId, string slectedcontactId, String projectSearch,String resourceSearch, String alltypeSearch){

        System.debug('fromdate : '+fromDate);
        System.debug('toDate : '+toDate);
        System.debug('slectedTradetypeId : '+slectedTradetypeId);
        System.debug('slectedprojectId : '+slectedprojectId);
        System.debug('slectedcontactId : '+slectedcontactId);
        System.debug('projectSearch : '+projectSearch);
        System.debug('resourceSearch : '+resourceSearch);
        System.debug('alltypeSearch : '+alltypeSearch);

        string userName = userInfo.getUserId();

        list<Network> netRec = [SELECT Id FROM Network];

        if(netRec.size() > 0){
            string strQry = 'Select Id,Name, isPortalEnabled From User Where id=: userName';
            list<User> userRec = Database.query(strQry);

            if(userRec[0].get('isPortalEnabled').toString() == 'true'){
                resourceSearch = userRec[0].Name;
                alltypeSearch  = '';
            }
        }

        Map<Id, list<buildertek__Project_Task__c>> scheduleitemmap = new Map<Id, list<buildertek__Project_Task__c>>();
        Map<Id, string> contactnamemap = new Map<Id, string>();
        list<buildertek__Project_Task__c> schudleitemList = new list<buildertek__Project_Task__c>();
        list<buildertek__Project_Task__c> scitemList = new list<buildertek__Project_Task__c>();
        list<buildertek__Schedule__c> SchedulerList = new list<buildertek__Schedule__c>();
        list<contact> conresource = new list<contact>();
        list<user> internalResource = new list<user>();
        List<buildertek__Project__c> projectRecordList = new List<buildertek__Project__c>();


        String str = fromDate;
        List<String> res = str.split('-');

        String str2 = toDate;
        List<String> res2 = str2.split('-');

        date startDate  = Date.newInstance(Integer.valueOf(res[0]),Integer.valueOf(res[1]),Integer.valueOf(res[2]));
        date endDate = Date.newInstance(Integer.valueOf(res2[0]),Integer.valueOf(res2[1]),Integer.valueOf(res2[2]));

        String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';

        list<contact> resources = new list<contact>();
        list<buildertek__Project_Task__c> schduleitems = new List<buildertek__Project_Task__c>();

        String projectSearchVal = '%'+''+'%';
        if(projectSearch != '' && projectSearch != null){
            projectSearch = projectSearch.toLowerCase();
            projectSearchVal = '%'+projectSearch+'%';
        }

        String resourceSearchVal = '%'+''+'%';
        if(resourceSearch != null && resourceSearch!= ''){
            resourceSearchVal = '%'+resourceSearch+'%';
        }

        String alltypeSearchVal = '%'+''+'%';
        if(alltypeSearch != null && alltypeSearch!= ''){
            alltypeSearchVal = '%'+alltypeSearch+'%';
        }

        System.debug('projectSearchVal : '+projectSearchVal);
        System.debug('resourceSearchVal : '+resourceSearchVal);
        System.debug('alltypeSearchVal : '+alltypeSearchVal);


        String taskQuery = 'Select id,buildertek__Start__c, buildertek__Contractor_Resource_1__c, buildertek__Contractor_Resource_1__r.Name, buildertek__Contractor_Resource_1__r.AccountId, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_1__r.Account.Name, buildertek__Contractor_Resource_1__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_2__r.AccountId, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_2__r.Account.Name, buildertek__Contractor_Resource_2__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_3__c, buildertek__Contractor_Resource_3__r.Name, buildertek__Contractor_Resource_3__r.AccountId, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_3__r.Account.Name, buildertek__Contractor_Resource_3__r.buildertek__Simultaneous_Tasks__c, buildertek__Finish__c, Name, buildertek__Duration__c,buildertek__Schedule__c,buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Resource__c,buildertek__Resource__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, ';
        taskQuery += ' buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,';
        taskQuery += 'buildertek__Internal_Resource_1__c, buildertek__Internal_Resource_1__r.Name, buildertek__Internal_Resource_1__r.AccountId, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_1__r.Account.Name, buildertek__Internal_Resource_4__c, buildertek__Internal_Resource_4__r.Name, buildertek__Internal_Resource_4__r.AccountId, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_4__r.Account.Name, buildertek__Internal_Resource_3__c, buildertek__Internal_Resource_3__r.Name, buildertek__Internal_Resource_3__r.AccountId, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_3__r.Account.Name, buildertek__Internal_User__c, buildertek__Internal_User__r.Name, buildertek__Internal_User__r.AccountId, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_User__r.Account.Name';
        taskQuery += ' From buildertek__Project_Task__c where ';
        taskQuery += ' buildertek__Start__c <=:endDate AND buildertek__Finish__c >=: startDate ';

        if(projectSearch !='' || projectSearch != null || resourceSearch != null || resourceSearch != '' ){
            system.debug('test3');
            if(slectedprojectId != '' && slectedprojectId != null){
                if(projectSearch != '' && projectSearch != null){
                    system.debug(projectSearch + '---projId---' + slectedprojectId);
                    taskQuery += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: projectSearchVal) ';
                }else{
                    taskQuery += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId) ';

                }
            }else if(projectSearch != '' && projectSearch != null){
                taskQuery += ' AND (buildertek__Schedule__r.buildertek__Project__c != null AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: projectSearchVal) ';
            }
            if(resourceSearch != null && resourceSearch != ''){
                taskQuery += ' AND (buildertek__Contractor_Resource__r.Name LIKE: resourceSearchVal OR buildertek__Resource__r.Name LIKE: resourceSearchVal OR buildertek__Contractor_Resource_1__r.Name LIKE: resourceSearchVal OR buildertek__Contractor_Resource_2__r.Name LIKE: resourceSearchVal OR buildertek__Contractor_Resource_3__r.Name LIKE: resourceSearchVal) ';
            }else{
                taskQuery += ' AND (buildertek__Contractor_Resource__c != null OR buildertek__Resource__c != null OR buildertek__Contractor_Resource_1__c != null OR buildertek__Contractor_Resource_2__c != null OR buildertek__Contractor_Resource_3__c != null OR buildertek__Internal_User__c != null OR buildertek__Internal_Resource_1__c != null OR buildertek__Internal_Resource_3__c != null OR buildertek__Internal_Resource_4__c != null) ';
            }
        }else{
            if(slectedprojectId != '' && slectedprojectId != null){
                taskQuery += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId) AND (buildertek__Contractor_Resource__c != null OR buildertek__Resource__c != null OR buildertek__Contractor_Resource_1__c != null OR buildertek__Contractor_Resource_2__c != null OR buildertek__Contractor_Resource_3__c != null OR buildertek__Internal_User__c != null OR buildertek__Internal_Resource_1__c != null OR buildertek__Internal_Resource_3__c != null OR buildertek__Internal_Resource_4__c != null) ';
            }else{
                taskQuery += '(buildertek__Schedule__r.buildertek__Project__c != null) AND (buildertek__Contractor_Resource__c != null OR buildertek__Resource__c != null OR buildertek__Contractor_Resource_1__c != null OR buildertek__Contractor_Resource_2__c != null OR buildertek__Contractor_Resource_3__c != null OR buildertek__Internal_User__c != null OR buildertek__Internal_Resource_1__c != null OR buildertek__Internal_Resource_3__c != null OR buildertek__Internal_Resource_4__c != null) ';
            }
        }

        schduleitems = Database.query(taskQuery);

        List<String> scheduleitemIdList = new List<String>();
        for(buildertek__Project_Task__c item:schduleitems){
            if(!scheduleitemIdList.contains(item.id)){

                scheduleitemIdList.add(item.id);
            }
        }


        List<buildertek__Project_Task__c> tasksforalltypesearch = new List<buildertek__Project_Task__c>();
        String taskQuery2;
        if(alltypeSearch != '' && alltypeSearch !=null){

            taskQuery2 = 'Select id, buildertek__Contractor_Resource_1__c, buildertek__Contractor_Resource_1__r.Name, buildertek__Contractor_Resource_1__r.AccountId, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_1__r.Account.Name, buildertek__Contractor_Resource_1__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_2__r.AccountId, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_2__r.Account.Name, buildertek__Contractor_Resource_2__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_3__c, buildertek__Contractor_Resource_3__r.Name, buildertek__Contractor_Resource_3__r.AccountId, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_3__r.Account.Name, buildertek__Contractor_Resource_3__r.buildertek__Simultaneous_Tasks__c, buildertek__Start__c,buildertek__Finish__c,buildertek__Duration__c, Name, buildertek__Schedule__c,buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Resource__c,buildertek__Resource__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, ';
            taskQuery2 += ' buildertek__Contractor_Resource__r.Account.Name,buildertek__Resource__r.Account.Name,buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name, ';
            taskQuery2 += 'buildertek__Internal_Resource_1__c, buildertek__Internal_Resource_1__r.Name, buildertek__Internal_Resource_1__r.AccountId, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_1__r.Account.Name, buildertek__Internal_Resource_4__c, buildertek__Internal_Resource_4__r.Name, buildertek__Internal_Resource_4__r.AccountId, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_4__r.Account.Name, buildertek__Internal_Resource_3__c, buildertek__Internal_Resource_3__r.Name, buildertek__Internal_Resource_3__r.AccountId, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_3__r.Account.Name, buildertek__Internal_User__c, buildertek__Internal_User__r.Name, buildertek__Internal_User__r.AccountId, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_User__r.Account.Name';
            taskQuery2 += ' From buildertek__Project_Task__c where id IN: scheduleitemIdList AND (buildertek__Contractor_Resource__c != null OR buildertek__Resource__c != null OR buildertek__Contractor_Resource_1__c != null OR buildertek__Contractor_Resource_2__c != null OR buildertek__Contractor_Resource_3__c != null OR buildertek__Internal_User__c != null OR buildertek__Internal_Resource_1__c != null OR buildertek__Internal_Resource_3__c != null OR buildertek__Internal_Resource_4__c != null) AND ';
            taskQuery2 += ' (buildertek__Start__c <=:endDate AND buildertek__Finish__c >=: startDate) ';
            if(slectedprojectId != '' && slectedprojectId != null){
                if(alltypeSearch != '' && alltypeSearch != null){
                    taskQuery2 += ' AND ((buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: alltypeSearchVal) ';
                }
            }else {
                taskQuery2 += ' AND ((buildertek__Schedule__r.buildertek__Project__c != null AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: alltypeSearchVal) ';
            }

            taskQuery2 += ' OR ((buildertek__Contractor_Resource__r.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_1__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_2__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_3__r.Name LIKE: alltypeSearchVal)) ';
            taskQuery2 += ' OR (buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal) ';
            taskQuery2 += ' OR (buildertek__Contractor_Resource__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_1__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_2__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_3__r.Account.Name LIKE: alltypeSearchVal)) ';

            tasksforalltypesearch =  Database.query(taskQuery2);
        }


            List<String> filteredTasksIds = new List<String>();
        for(buildertek__Project_Task__c allTypeSearchTask : tasksforalltypesearch){

            if(!filteredTasksIds.contains(allTypeSearchTask.Id)){
                filteredTasksIds.add(allTypeSearchTask.Id);
            }
        }

        List<String> filteredTasks = new  List<String>();

        if(filteredTasksIds.size()>0 && (projectSearch !='' || projectSearch != null || resourceSearch != null || resourceSearch != '')) {
            for(buildertek__Project_Task__c filterTask : schduleitems){
                if(filteredTasksIds.contains(filterTask.Id)){
                    filteredTasks.add(filterTask.Id);
                }
            }
        }else{
            filteredTasks = filteredTasksIds;
        }


        set<Id> userId = new set<Id>();
        set<Id> conid = new set<Id>();
        set<Id> scheduleids = new set<Id>();
        set<Id> accountRecIds = new Set<Id>();
        if(filteredTasks.Size() > 0){
            List<buildertek__Project_Task__c> filteredTaskList = [Select id,buildertek__Start__c, buildertek__Internal_User__c, buildertek__Internal_Resource_1__c, buildertek__Internal_Resource_3__c, buildertek__Internal_Resource_4__c, buildertek__Finish__c,buildertek__Duration__c, Name, buildertek__Schedule__c,buildertek__Schedule__r.buildertek__Project__c, buildertek__Contractor_Resource_1__c, buildertek__Contractor_Resource_1__r.Name, buildertek__Contractor_Resource_1__r.AccountId, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_1__r.Account.Name, buildertek__Contractor_Resource_1__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_2__r.AccountId, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_2__r.Account.Name, buildertek__Contractor_Resource_2__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_3__c, buildertek__Contractor_Resource_3__r.Name, buildertek__Contractor_Resource_3__r.AccountId, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_3__r.Account.Name, buildertek__Contractor_Resource_3__r.buildertek__Simultaneous_Tasks__c, buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Resource__c,buildertek__Resource__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name,buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, buildertek__Resource__r.Account.Name,buildertek__Contractor_Resource__r.Account.Name,buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name  From buildertek__Project_Task__c where id IN: filteredTasks];

            for (buildertek__Project_Task__c scitem : filteredTaskList){

                if(!conid.contains(scitem.buildertek__Contractor_Resource_1__c) && scitem.buildertek__Contractor_Resource_1__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    conid.add(scitem.buildertek__Contractor_Resource_1__c);
                }

                if(!conid.contains(scitem.buildertek__Contractor_Resource_2__c) && scitem.buildertek__Contractor_Resource_2__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    conid.add(scitem.buildertek__Contractor_Resource_2__c);
                }

                if(!conid.contains(scitem.buildertek__Contractor_Resource_3__c) && scitem.buildertek__Contractor_Resource_3__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    conid.add(scitem.buildertek__Contractor_Resource_3__c);
                }

                if(!userId.contains(scitem.buildertek__Internal_Resource_1__c) && scitem.buildertek__Internal_Resource_1__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    userId.add(scitem.buildertek__Internal_Resource_1__c);
                }

                if(!userId.contains(scitem.buildertek__Internal_Resource_3__c) && scitem.buildertek__Internal_Resource_3__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    userId.add(scitem.buildertek__Internal_Resource_3__c);
                }

                if(!userId.contains(scitem.buildertek__Internal_Resource_4__c) && scitem.buildertek__Internal_Resource_4__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    userId.add(scitem.buildertek__Internal_Resource_4__c);
                }

                scheduleids.add(scitem.buildertek__Schedule__c);

            }
        }else{
            for (buildertek__Project_Task__c scitem : schduleitems){

                if(!conid.contains(scitem.buildertek__Contractor_Resource_1__c) && scitem.buildertek__Contractor_Resource_1__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    conid.add(scitem.buildertek__Contractor_Resource_1__c);
                }

                if(!conid.contains(scitem.buildertek__Contractor_Resource_2__c) && scitem.buildertek__Contractor_Resource_2__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    conid.add(scitem.buildertek__Contractor_Resource_2__c);
                }

                if(!conid.contains(scitem.buildertek__Contractor_Resource_3__c) && scitem.buildertek__Contractor_Resource_3__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    conid.add(scitem.buildertek__Contractor_Resource_3__c);
                }

                if(!userId.contains(scitem.buildertek__Internal_Resource_1__c) && scitem.buildertek__Internal_Resource_1__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    userId.add(scitem.buildertek__Internal_Resource_1__c);
                }

                if(!userId.contains(scitem.buildertek__Internal_Resource_3__c) && scitem.buildertek__Internal_Resource_3__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    userId.add(scitem.buildertek__Internal_Resource_3__c);
                }

                if(!userId.contains(scitem.buildertek__Internal_Resource_4__c) && scitem.buildertek__Internal_Resource_4__c != null){ // && (scitem.buildertek__Resource__r.Name.toLowerCase()).contains(alltypeSearch.toLowerCase())
                    userId.add(scitem.buildertek__Internal_Resource_4__c);
                }

                scheduleids.add(scitem.buildertek__Schedule__c);

            }
        }

        SchedulerList = [select Id, Name, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Project__c, buildertek__Project__r.Name
                            from buildertek__Schedule__c
                            where Id IN :scheduleids];
        resources = [select id, Name,AccountId,Account.Name
                        from Contact
                        where Id IN :conid];

        for(Contact con : resources){
            if(!accountRecIds.contains(con.AccountId)){
                accountRecIds.add(con.AccountId);
            }
        }


        string Query = 'select id,Name, buildertek__Contractor_Resource_1__c, buildertek__Contractor_Resource_1__r.Name, buildertek__Contractor_Resource_1__r.AccountId, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_1__r.Account.Name, buildertek__Contractor_Resource_1__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_2__r.AccountId, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_2__r.Account.Name, buildertek__Contractor_Resource_2__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_3__c, buildertek__Contractor_Resource_3__r.Name, buildertek__Contractor_Resource_3__r.AccountId, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_3__r.Account.Name, buildertek__Contractor_Resource_3__r.buildertek__Simultaneous_Tasks__c, buildertek__Duration__c,buildertek__Completion__c,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor_Resource__r.buildertek__Simultaneous_Tasks__c,';
        Query += 'buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Contractor__c,buildertek__Schedule__r.buildertek__Contractor__r.Name,buildertek__Schedule__r.buildertek__Contractor__r.buildertek__Simultaneous_Tasks__c,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,';
        Query += ' buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name, ';
        // Changes for BUIL-3932
        Query += 'buildertek__Internal_Resource_1__c, buildertek__Internal_Resource_1__r.Name, buildertek__Internal_Resource_1__r.AccountId, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_1__r.Account.Name, buildertek__Internal_Resource_4__c, buildertek__Internal_Resource_4__r.Name, buildertek__Internal_Resource_4__r.AccountId, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_4__r.Account.Name, buildertek__Internal_Resource_3__c, buildertek__Internal_Resource_3__r.Name, buildertek__Internal_Resource_3__r.AccountId, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_3__r.Account.Name, buildertek__Internal_User__c, buildertek__Internal_User__r.Name, buildertek__Internal_User__r.AccountId, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_User__r.Account.Name,';
        // Changes for BUIL-3932 -- END ---
        Query += 'buildertek__Resource__r.Name,buildertek__Resource__r.Account.Name,buildertek__Contractor_Resource__r.Account.Name,buildertek__Resource__c,buildertek__Start__c,buildertek__Finish__c from ';
        Query += 'buildertek__Project_Task__c where ';
        Query += 'buildertek__Schedule__c != null and buildertek__Schedule__r.buildertek__Project__c != null and (buildertek__Start__c <=:endDate AND buildertek__Finish__c >=: startDate)'; //buildertek__Start__c >=:startDate OR buildertek__Finish__c <=: endDate
        //Query += ' and buildertek__Schedule__r.buildertek__Type__c !=: scheduletype';
        if(projectSearch !='' || projectSearch != null || resourceSearch != null || resourceSearch != ''){

            if(slectedprojectId != '' && slectedprojectId != null){
                if(projectSearch != '' && projectSearch != null){
                    Query += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: projectSearchVal) ';
                }else{
                    Query += ' AND (buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId) ';
                }
            }else if(projectSearch != '' && projectSearch != null){
                Query += ' AND (buildertek__Schedule__r.buildertek__Project__c != null AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: projectSearchVal) ';
            }
            if(resourceSearch != null && resourceSearch != ''){
                Query += ' AND (buildertek__Contractor_Resource__r.Name LIKE: resourceSearchVal OR buildertek__Resource__r.Name LIKE: resourceSearchVal OR buildertek__Contractor_Resource_1__r.Name LIKE: resourceSearchVal OR buildertek__Contractor_Resource_2__r.Name LIKE: resourceSearchVal OR buildertek__Contractor_Resource_3__r.Name LIKE: resourceSearchVal) ';
                Query += ' and (buildertek__Contractor_Resource__c IN:conid OR buildertek__Resource__c IN:conid OR buildertek__Contractor_Resource_1__c IN:conid OR buildertek__Contractor_Resource_2__c IN:conid OR buildertek__Contractor_Resource_3__c IN:conid)';
            }else{
                Query += ' and (buildertek__Contractor_Resource__c IN:conid OR buildertek__Resource__c IN:conid OR buildertek__Contractor_Resource_1__c IN:conid OR buildertek__Contractor_Resource_2__c IN:conid OR buildertek__Contractor_Resource_3__c IN:conid OR buildertek__Internal_User__c IN: userId OR buildertek__Internal_Resource_1__c IN: userId OR buildertek__Internal_Resource_3__c IN: userId OR buildertek__Internal_Resource_4__c IN: userId)';
            }

        }else{
            if (slectedprojectId != null && slectedprojectId != ''){
                Query += ' and buildertek__Schedule__r.buildertek__Project__c=:slectedprojectId';
            }

            Query += ' and (buildertek__Contractor_Resource__c IN:conid OR buildertek__Resource__c IN:conid OR buildertek__Contractor_Resource_1__c IN:conid OR buildertek__Contractor_Resource_2__c IN:conid OR buildertek__Contractor_Resource_3__c IN:conid OR buildertek__Internal_User__c IN: userId OR buildertek__Internal_Resource_1__c IN: userId OR buildertek__Internal_Resource_3__c IN: userId OR buildertek__Internal_Resource_4__c IN: userId)';
        }


        schudleitemList = Database.query(Query);
        System.debug('Query : ' + Query);
        System.debug('************** schudleitemList size ************************* ' + schudleitemList.size());
        System.debug('************** schudleitemList ************************* ' + schudleitemList);

        List<buildertek__Project_Task__c> tasksforalltypesearch2 = new List<buildertek__Project_Task__c>();
        String taskQuery3;
        if(alltypeSearch != '' && alltypeSearch !=null){

            taskQuery3 = 'select id,Name, buildertek__Contractor_Resource_1__c, buildertek__Contractor_Resource_1__r.Name, buildertek__Contractor_Resource_1__r.AccountId, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_1__r.Account.Name, buildertek__Contractor_Resource_1__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_2__r.AccountId, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_2__r.Account.Name, buildertek__Contractor_Resource_2__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_3__c, buildertek__Contractor_Resource_3__r.Name, buildertek__Contractor_Resource_3__r.AccountId, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_3__r.Account.Name, buildertek__Contractor_Resource_3__r.buildertek__Simultaneous_Tasks__c, buildertek__Duration__c,buildertek__Completion__c,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor_Resource__r.buildertek__Simultaneous_Tasks__c,';
            taskQuery3 += 'buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Contractor__c,buildertek__Schedule__r.buildertek__Contractor__r.Name,buildertek__Schedule__r.buildertek__Contractor__r.buildertek__Simultaneous_Tasks__c,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,';
            taskQuery3 += ' buildertek__Contractor_Resource__r.AccountId,buildertek__Contractor_Resource__r.Account.Name,buildertek__Resource__r.Account.Name,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name, ';
            // Changes for BUIL-3932
            taskQuery3 += 'buildertek__Internal_Resource_1__c, buildertek__Internal_Resource_1__r.Name, buildertek__Internal_Resource_1__r.AccountId, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_1__r.Account.Name, buildertek__Internal_Resource_4__c, buildertek__Internal_Resource_4__r.Name, buildertek__Internal_Resource_4__r.AccountId, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_4__r.Account.Name, buildertek__Internal_Resource_3__c, buildertek__Internal_Resource_3__r.Name, buildertek__Internal_Resource_3__r.AccountId, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_3__r.Account.Name, buildertek__Internal_User__c, buildertek__Internal_User__r.Name, buildertek__Internal_User__r.AccountId, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_User__r.Account.Name,';
            // Changes for BUIL-3932 -- END ---
            taskQuery3 += 'buildertek__Resource__r.Name,buildertek__Resource__c,buildertek__Start__c,buildertek__Finish__c from ';
            taskQuery3 += 'buildertek__Project_Task__c where id IN:schudleitemList AND ';
            taskQuery3 += '(buildertek__Contractor_Resource__c IN:conid OR buildertek__Resource__c IN:conid OR buildertek__Contractor_Resource_1__c IN:conid OR buildertek__Contractor_Resource_2__c IN:conid OR buildertek__Contractor_Resource_3__c IN:conid OR buildertek__Internal_User__c IN: userId OR buildertek__Internal_Resource_1__c IN: userId OR buildertek__Internal_Resource_3__c IN: userId OR buildertek__Internal_Resource_4__c IN: userId) AND buildertek__Schedule__c != null and buildertek__Schedule__r.buildertek__Project__c != null and (buildertek__Start__c <=:endDate AND buildertek__Finish__c >=: startDate)'; //buildertek__Start__c >=:startDate OR buildertek__Finish__c <=: endDate
            if(slectedprojectId != '' && slectedprojectId != null){
                if(alltypeSearch != '' && alltypeSearch != null){
                    taskQuery3 += ' AND ((buildertek__Schedule__r.buildertek__Project__c =:slectedprojectId AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: alltypeSearchVal) ';
                }
            }else {
                taskQuery3 += ' AND ((buildertek__Schedule__r.buildertek__Project__c != null AND buildertek__Schedule__r.buildertek__Project__r.Name LIKE: alltypeSearchVal) ';
            }

            taskQuery3 += ' OR ((buildertek__Contractor_Resource__r.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_1__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_2__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_3__r.Name LIKE: alltypeSearchVal)) ';
            taskQuery3 += ' OR (buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name LIKE: alltypeSearchVal) ';
            taskQuery3 += ' OR (buildertek__Contractor_Resource__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Resource__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_1__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_2__r.Account.Name LIKE: alltypeSearchVal OR buildertek__Contractor_Resource_3__r.Account.Name LIKE: alltypeSearchVal)) ';

            tasksforalltypesearch2 =  Database.query(taskQuery3);
        }


        List<String> filteredTasksIds2 = new List<String>();
        for(buildertek__Project_Task__c allTypeSearchTask : tasksforalltypesearch2){

            if(!filteredTasksIds2.contains(allTypeSearchTask.Id)){
                filteredTasksIds2.add(allTypeSearchTask.Id);
            }
        }


        List<String> filteredTasks2 = new  List<String>();

        if(filteredTasksIds2.size()>0 && (projectSearch !='' || projectSearch != null || resourceSearch != null || resourceSearch != '')) {
            for(buildertek__Project_Task__c filterTask : schudleitemList){
                if(filteredTasksIds2.contains(filterTask.Id)){
                    filteredTasks2.add(filterTask.Id);
                }
            }
        }else{
            filteredTasks2 = filteredTasksIds2;
        }


        if(filteredTasks2.Size() > 0){
            List<buildertek__Project_Task__c> filteredTaskList2 = [select id,Name, buildertek__Contractor_Resource_1__c, buildertek__Contractor_Resource_1__r.Name, buildertek__Contractor_Resource_1__r.AccountId, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_1__r.Account.Name, buildertek__Contractor_Resource_1__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_2__r.AccountId, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_2__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_2__r.Account.Name, buildertek__Contractor_Resource_2__r.buildertek__Simultaneous_Tasks__c, buildertek__Contractor_Resource_3__c, buildertek__Contractor_Resource_3__r.Name, buildertek__Contractor_Resource_3__r.AccountId, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Contractor_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Contractor_Resource_3__r.Account.Name, buildertek__Contractor_Resource_3__r.buildertek__Simultaneous_Tasks__c, buildertek__Duration__c,buildertek__Completion__c,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor_Resource__r.buildertek__Simultaneous_Tasks__c,
                                                                    buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Contractor__c,buildertek__Schedule__r.buildertek__Contractor__r.Name,buildertek__Schedule__r.buildertek__Contractor__r.buildertek__Simultaneous_Tasks__c,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,
                                                                    buildertek__Contractor_Resource__r.AccountId,buildertek__Resource__r.AccountId,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__c,buildertek__Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,buildertek__Contractor_Resource__r.Account.buildertek__Trade_Type_Lookup__r.Name,
                                                                    buildertek__Resource__r.Name,buildertek__Resource__r.Account.Name,buildertek__Contractor_Resource__r.Account.Name,buildertek__Resource__c,buildertek__Start__c,buildertek__Finish__c,
                                                                    buildertek__Internal_Resource_1__c, buildertek__Internal_Resource_1__r.Name, buildertek__Internal_Resource_1__r.AccountId, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_1__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_1__r.Account.Name, buildertek__Internal_Resource_4__c, buildertek__Internal_Resource_4__r.Name, buildertek__Internal_Resource_4__r.AccountId, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_4__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_4__r.Account.Name, buildertek__Internal_Resource_3__c, buildertek__Internal_Resource_3__r.Name, buildertek__Internal_Resource_3__r.AccountId, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_Resource_3__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_Resource_3__r.Account.Name, buildertek__Internal_User__c, buildertek__Internal_User__r.Name, buildertek__Internal_User__r.AccountId, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__c, buildertek__Internal_User__r.Account.buildertek__Trade_Type_Lookup__r.Name, buildertek__Internal_User__r.Account.Name,
                                                                    buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c
                                                                    From buildertek__Project_Task__c where id IN: filteredTasks2];
            schudleitemList = filteredTaskList2;
        }

        Map<String,List<buildertek__Project_Task__c>> ProjScheduleTaskMap = new Map<String,List<buildertek__Project_Task__c>>();
        List<String> projectIdList = new List<String>();
        System.debug('schudleitemList size : ' + schudleitemList.size());
        System.debug('schudleitemList : ' + schudleitemList);
        for(buildertek__Project_Task__c schItemTask : schudleitemList){

            if(schItemTask.buildertek__Schedule__r.buildertek__Project__c != null){

                projectIdList.add(schItemTask.buildertek__Schedule__r.buildertek__Project__c);
                if(ProjScheduleTaskMap.get(schItemTask.buildertek__Schedule__r.buildertek__Project__c) != null){
                    List<buildertek__Project_Task__c> projTask = ProjScheduleTaskMap.get(schItemTask.buildertek__Schedule__r.buildertek__Project__c);
                    projTask.add(schItemTask);
                    ProjScheduleTaskMap.put(schItemTask.buildertek__Schedule__r.buildertek__Project__c,projTask);
                }else{
                    List<buildertek__Project_Task__c> projTask = new List<buildertek__Project_Task__c>();
                    projTask.add(schItemTask);
                    ProjScheduleTaskMap.put(schItemTask.buildertek__Schedule__r.buildertek__Project__c,projTask);
                }
            }
        }

        //will get only schedule items of schedule that is linked to project
        projectRecordList = [Select Id,Name, buildertek__Customer__c,buildertek__Customer__r.Name From buildertek__Project__c WHERE ID IN: projectIdList];
        System.debug('size of projectRecordList : ' + projectRecordList.size());
        System.debug(' projectRecordList : ' + projectRecordList);
        System.debug(' projectIdList : ' + projectIdList);


        Map<Id, string> tradeTypenamemap = new Map<Id, string>();
        Map<Id, string> contactAccountMap = new Map<Id, string>();
        Map<Id, Decimal> contactSimulateMap = new Map<Id, Decimal>();
        for (contact conrec : [Select id, Name, AccountId, buildertek__Simultaneous_Tasks__c
                                from Contact
                                where id in :conid]){ // AND Name LIKE : resourceSearchVal
                                    if(resourceSearch != '' && resourceSearch != null){
                                        if(conrec.Name.containsIgnoreCase(resourceSearch)){
                                            if (conrec.AccountId != null){
                                                contactAccountMap.put(conrec.id, conrec.AccountId);
                                                if (conrec.buildertek__Simultaneous_Tasks__c != null){
                                                    contactSimulateMap.put(conrec.id, conrec.buildertek__Simultaneous_Tasks__c);
                                                }
                                            }
                                        }
                                    }else{
                                        if (conrec.AccountId != null){
                                            contactAccountMap.put(conrec.id, conrec.AccountId);
                                            if (conrec.buildertek__Simultaneous_Tasks__c != null){
                                                contactSimulateMap.put(conrec.id, conrec.buildertek__Simultaneous_Tasks__c);
                                            }
                                        }
                                    }

                                }

        // Chnages for BUIL-3932 --------- START --------------------
        for (user conrec : [Select id, Name, AccountId
                            from user
                            where id in :userId]){ // AND Name LIKE : resourceSearchVal
                                if(resourceSearch != '' && resourceSearch != null){
                                    if(conrec.Name.containsIgnoreCase(resourceSearch)){
                                        if (conrec.AccountId != null){
                                            contactAccountMap.put(conrec.id, conrec.AccountId);
                                        }
                                    }
                                }else{
                                    if (conrec.AccountId != null){
                                        contactAccountMap.put(conrec.id, conrec.AccountId);
                                    }
                                }
                            }
        // Chnages for BUIL-3932  ---- END ------

        for (Account accrec : [Select id, Name, buildertek__Trade_Type_Lookup__c, buildertek__Simultaneous_Tasks__c, buildertek__Trade_Type_Lookup__r.Name
                                from account
                                where id in :contactAccountMap.values() ]){ //AND buildertek__Trade_Type_Lookup__r.Name LIKE :alltypeSearchVal
                                    if (accrec.buildertek__Trade_Type_Lookup__c != null){
                                        tradeTypenamemap.put(accrec.id, accrec.buildertek__Trade_Type_Lookup__r.Name);
                                    }
                                }


        string contactQuery = 'Select id,Name,Account.Name,AccountId,buildertek__Simultaneous_Tasks__c From Contact Where ';
        contactQuery += ' id != null ';
        if (slectedTradetypeId != null && slectedTradetypeId != ''){
            contactQuery += ' AND Account.buildertek__Trade_Type_Lookup__c=: slectedTradetypeId';
        }
        if(resourceSearch != null && resourceSearch != ''){
            contactQuery += ' AND (Name LIKE: resourceSearchVal) ';
            contactQuery += ' and (id IN: conid)';
        }else{
            contactQuery += ' AND id IN: conid';
        }

        contactQuery += ' order by Name asc';

        conresource = Database.query(contactQuery);

        // Changes for BUIL-3932 ------ START --------
        string internalResourcelistQuery = 'SELECT Id, Name , Account.Name, AccountId FROM User WHERE ';
        internalResourcelistQuery += ' id != null';
        if (slectedTradetypeId != null && slectedTradetypeId != ''){
            internalResourcelistQuery += ' AND Account.buildertek__Trade_Type_Lookup__c=: slectedTradetypeId';
        }
        if(resourceSearch != null && resourceSearch != ''){
            internalResourcelistQuery += ' AND (Name LIKE: resourceSearchVal) ';
            internalResourcelistQuery += ' and (id IN: userId)';
        }else{
            internalResourcelistQuery += ' AND id IN: userId';
        }

        internalResource = Database.query(internalResourcelistQuery);
        // Changes for BUIL-3932 ------ END --------


        for (buildertek__Project_Task__c scitem : schudleitemList){
            system.debug(fromDate+','+ toDate+','+scitem.buildertek__Start__c+','+scitem.buildertek__Finish__c);
            if (!scheduleitemmap.containsKey(scitem.buildertek__Contractor_Resource__c)){
                scheduleitemmap.put(scitem.buildertek__Contractor_Resource__c, new List<buildertek__Project_Task__c>());
            }
            scheduleitemmap.get(scitem.buildertek__Contractor_Resource__c).add(scitem);

            // if(scitem.buildertek__Resource__c != scitem.buildertek__Contractor_Resource__c && scitem.buildertek__Resource__c!= null){
            //     if(!scheduleitemmap.containsKey(scitem.buildertek__Resource__c)){
            //         scheduleitemmap.put(scitem.buildertek__Resource__c, new List<buildertek__Project_Task__c>());
            //     }
            //     scheduleitemmap.get(scitem.buildertek__Resource__c).add(scitem);
            // }
            if (scitem.buildertek__Contractor_Resource_1__c!= null) {
                if(!scheduleitemmap.containsKey(scitem.buildertek__Contractor_Resource_1__c)){
                    scheduleitemmap.put(scitem.buildertek__Contractor_Resource_1__c, new List<buildertek__Project_Task__c>());
                }
                scheduleitemmap.get(scitem.buildertek__Contractor_Resource_1__c).add(scitem);
            }
            if (scitem.buildertek__Contractor_Resource_2__c!= null) {
                if(!scheduleitemmap.containsKey(scitem.buildertek__Contractor_Resource_2__c)){
                    scheduleitemmap.put(scitem.buildertek__Contractor_Resource_2__c, new List<buildertek__Project_Task__c>());
                }
                scheduleitemmap.get(scitem.buildertek__Contractor_Resource_2__c).add(scitem);
            }

            if (scitem.buildertek__Contractor_Resource_3__c!= null) {
                if(!scheduleitemmap.containsKey(scitem.buildertek__Contractor_Resource_3__c)){
                    scheduleitemmap.put(scitem.buildertek__Contractor_Resource_3__c, new List<buildertek__Project_Task__c>());
                }
                scheduleitemmap.get(scitem.buildertek__Contractor_Resource_3__c).add(scitem);
            }


            // Changes for BUIL-3932 ------ START --------
            if (!scheduleitemmap.containsKey(scitem.buildertek__Internal_User__c)){
                scheduleitemmap.put(scitem.buildertek__Internal_User__c, new List<buildertek__Project_Task__c>());
            }
            scheduleitemmap.get(scitem.buildertek__Internal_User__c).add(scitem);

            if(scitem.buildertek__Internal_Resource_1__c != scitem.buildertek__Internal_User__c && scitem.buildertek__Internal_Resource_1__c!= null){
                if(!scheduleitemmap.containsKey(scitem.buildertek__Internal_Resource_1__c)){
                    scheduleitemmap.put(scitem.buildertek__Internal_Resource_1__c, new List<buildertek__Project_Task__c>());
                }
                scheduleitemmap.get(scitem.buildertek__Internal_Resource_1__c).add(scitem);
            }
            if (scitem.buildertek__Internal_Resource_3__c!= null) {
                if(!scheduleitemmap.containsKey(scitem.buildertek__Internal_Resource_3__c)){
                    scheduleitemmap.put(scitem.buildertek__Internal_Resource_3__c, new List<buildertek__Project_Task__c>());
                }
                scheduleitemmap.get(scitem.buildertek__Internal_Resource_3__c).add(scitem);
            }
            if (scitem.buildertek__Internal_Resource_4__c!= null) {
                if(!scheduleitemmap.containsKey(scitem.buildertek__Internal_Resource_4__c)){
                    scheduleitemmap.put(scitem.buildertek__Internal_Resource_4__c, new List<buildertek__Project_Task__c>());
                }
                scheduleitemmap.get(scitem.buildertek__Internal_Resource_4__c).add(scitem);
            }
            // Changes for BUIL-3932 ---- END ---------


            if (scitem.buildertek__Contractor_Resource__c != null){
                contactnamemap.put(scitem.buildertek__Contractor_Resource__c, scitem.buildertek__Contractor_Resource__r.Name);
            }
            // if(scitem.buildertek__Resource__c != scitem.buildertek__Contractor_Resource__c && scitem.buildertek__Resource__c != null){
            //     contactnamemap.put(scitem.buildertek__Resource__c, scitem.buildertek__Resource__r.Name);
            // }
            if(scitem.buildertek__Contractor_Resource_1__c != scitem.buildertek__Contractor_Resource__c && scitem.buildertek__Contractor_Resource_1__c != scitem.buildertek__Resource__c && scitem.buildertek__Contractor_Resource_1__c != null){
                contactnamemap.put(scitem.buildertek__Contractor_Resource_1__c, scitem.buildertek__Contractor_Resource_1__r.Name);
            }
            if(scitem.buildertek__Contractor_Resource_2__c != scitem.buildertek__Contractor_Resource__c && scitem.buildertek__Contractor_Resource_2__c != scitem.buildertek__Resource__c && scitem.buildertek__Contractor_Resource_2__c != scitem.buildertek__Contractor_Resource_1__c && scitem.buildertek__Contractor_Resource_2__c != null){
                contactnamemap.put(scitem.buildertek__Contractor_Resource_2__c, scitem.buildertek__Contractor_Resource_2__r.Name);
            }
            if(scitem.buildertek__Contractor_Resource_3__c != scitem.buildertek__Contractor_Resource__c && scitem.buildertek__Contractor_Resource_3__c != scitem.buildertek__Resource__c && scitem.buildertek__Contractor_Resource_3__c != scitem.buildertek__Contractor_Resource_1__c && scitem.buildertek__Contractor_Resource_3__c != scitem.buildertek__Contractor_Resource_2__c && scitem.buildertek__Contractor_Resource_3__c != null){
                contactnamemap.put(scitem.buildertek__Contractor_Resource_3__c, scitem.buildertek__Contractor_Resource_3__r.Name);
            }

            // Changes for BUIL-3932 ------ START --------
            if (scitem.buildertek__Internal_User__c != null){
                contactnamemap.put(scitem.buildertek__Internal_User__c, scitem.buildertek__Internal_User__r.Name);
            }
            if(scitem.buildertek__Internal_Resource_1__c != scitem.buildertek__Internal_User__c && scitem.buildertek__Internal_Resource_1__c != scitem.buildertek__Resource__c && scitem.buildertek__Internal_Resource_1__c != null){
                contactnamemap.put(scitem.buildertek__Internal_Resource_1__c, scitem.buildertek__Internal_Resource_1__r.Name);
            }
            if(scitem.buildertek__Internal_Resource_3__c != scitem.buildertek__Internal_User__c && scitem.buildertek__Internal_Resource_3__c != scitem.buildertek__Resource__c && scitem.buildertek__Internal_Resource_3__c != scitem.buildertek__Internal_Resource_1__c && scitem.buildertek__Internal_Resource_3__c != null){
                contactnamemap.put(scitem.buildertek__Internal_Resource_3__c, scitem.buildertek__Internal_Resource_3__r.Name);
            }
            if(scitem.buildertek__Internal_Resource_4__c != scitem.buildertek__Internal_User__c && scitem.buildertek__Internal_Resource_4__c != scitem.buildertek__Resource__c && scitem.buildertek__Internal_Resource_4__c != scitem.buildertek__Internal_Resource_1__c && scitem.buildertek__Internal_Resource_4__c != scitem.buildertek__Internal_Resource_3__c && scitem.buildertek__Internal_Resource_4__c != null){
                contactnamemap.put(scitem.buildertek__Internal_Resource_4__c, scitem.buildertek__Internal_Resource_4__r.Name);
            }
            // Changes for BUIL-3932 ---- END ---------
        }


        Map<String,List<ResourceCalendarWrap>> accountResourceLinkList = new Map<String,List<ResourceCalendarWrap>>();
        Map<String,List<ResourceCalendarWrap.ProjectTaskRecords>> projectTaskLinkMap = new Map<String,List<ResourceCalendarWrap.ProjectTaskRecords>>();
        Map<Id,List<ResourceCalendarWrap.ProjectTaskRecords>> contactTaskMap = new Map<Id,List<ResourceCalendarWrap.ProjectTaskRecords>>();
        list<ResourceCalendarWrap> RecordList = new list<ResourceCalendarWrap>();
        Map<Id,List<String>> contactTaskIdMap = new Map<Id,List<String>>();
        Map<Id,ResourceCalendarWrap.ProjectTaskRecords> taskMap = new Map<Id,ResourceCalendarWrap.ProjectTaskRecords>();
        if(schudleitemList.Size() > 0){
            list<ResourceCalendarWrap.ProjectTaskRecords> EquipmentRecordList = new list<ResourceCalendarWrap.ProjectTaskRecords>();

            for (buildertek__Project_Task__c pse : schudleitemList){
                ResourceCalendarWrap.ProjectTaskRecords EquipmentRec = new ResourceCalendarWrap.ProjectTaskRecords();
                Datetime dt = (DateTime)pse.buildertek__Start__c;
                String dayOfWeek = dt.format('yyyy-MM-dd');

                EquipmentRec.title = pse.Name;
                EquipmentRec.startString = '';
                EquipmentRec.endString = '';
                string s = string.valueOfGmt(pse.buildertek__Start__c);
                String strDate = s.split(' ')[0];
                String sMonth = String.valueof(pse.buildertek__Start__c.month());

                String sDay = String.valueof(pse.buildertek__Start__c.day());

                if (sMonth.length() == 1){
                    sMonth = '0' + sMonth;
                }
                if (sDay.length() == 1){
                    sDay = '0' + sDay;
                }
                string ndate = sMonth + '/' + sDay + '/' + String.valueof(pse.buildertek__Start__c.year());
                if (pse.buildertek__Finish__c != null){
                    string FinishDate = string.valueOfGmt(pse.buildertek__Finish__c);
                    String FinishDatestrDate = FinishDate.split(' ')[0];
                    String FinishDatesMonth = String.valueof(pse.buildertek__Finish__c.month());
                    String FinishDatesDay = String.valueof(pse.buildertek__Finish__c.day());
                    if (FinishDatesMonth.length() == 1){
                        FinishDatesMonth = '0' + FinishDatesMonth;
                    }
                    if (FinishDatesDay.length() == 1){
                        FinishDatesDay = '0' + FinishDatesDay;
                    }
                    string FinishDatendate = FinishDatesMonth + '/' + FinishDatesDay + '/' + String.valueof(pse.buildertek__Finish__c.year());
                    string ndate1 = String.valueof(pse.buildertek__Start__c.year())+'-' + sMonth + '-' + sDay;
                    Datetime dt1 = DateTime.newInstance(date.valueOf(ndate1), Time.newInstance(0, 0, 0, 0));
                    String dateStr = dt1.format('EEEE');
                    EquipmentRec.weekName = dateStr;

                    EquipmentRec.day = ndate;
                    EquipmentRec.endday = FinishDatendate;
                    EquipmentRec.projectId = pse.buildertek__Schedule__r.buildertek__Project__r.Name;
                    if(pse.buildertek__Contractor_Resource_1__c != null){
                        EquipmentRec.contractresourceId = pse.buildertek__Contractor_Resource_1__r.Name;
                    }else if(pse.buildertek__Contractor_Resource_2__c != null){
                        EquipmentRec.contractresourceId = pse.buildertek__Contractor_Resource_2__r.Name;
                    }else if(pse.buildertek__Contractor_Resource_3__c != null){
                        EquipmentRec.contractresourceId = pse.buildertek__Contractor_Resource_3__r.Name;
                    }else if(pse.buildertek__Internal_Resource_1__c != null){
                        EquipmentRec.contractresourceId = pse.buildertek__Internal_Resource_1__r.Name;
                    }else if(pse.buildertek__Internal_Resource_3__c != null){
                        EquipmentRec.contractresourceId = pse.buildertek__Internal_Resource_3__r.Name;
                    }else{
                        EquipmentRec.contractresourceId = pse.buildertek__Internal_Resource_4__r.Name;
                    }

                    EquipmentRec.Id = pse.id;
                    EquipmentRec.taskdescription = pse.Name;
                    EquipmentRec.taskdays = integer.valueof(pse.buildertek__Duration__c);
                    EquipmentRec.Completion = integer.valueof(pse.buildertek__Completion__c);
                    EquipmentRec.startdate = pse.buildertek__Start__c;
                    EquipmentRec.enddate = pse.buildertek__Finish__c;
                    EquipmentRec.Eid = pse.buildertek__Schedule__c;
                    EquipmentRec.Model = pse.buildertek__Schedule__r.Name;
                    EquipmentRecordList.add(EquipmentRec);
                    taskMap.put(pse.id,EquipmentRec);

                    if(projectTaskLinkMap.get(pse.buildertek__Schedule__r.buildertek__Project__c) != null){
                        System.debug('if condition 1');
                        list<ResourceCalendarWrap.ProjectTaskRecords> calendarList = projectTaskLinkMap.get(pse.buildertek__Schedule__r.buildertek__Project__c);
                        calendarList.add(EquipmentRec);
                        projectTaskLinkMap.put(pse.buildertek__Schedule__r.buildertek__Project__c,calendarList);

                    }else{
                        System.debug('if condition 2');
                        list<ResourceCalendarWrap.ProjectTaskRecords> calendarList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        calendarList.add(EquipmentRec);
                        projectTaskLinkMap.put(pse.buildertek__Schedule__r.buildertek__Project__c,calendarList);
                    }

                    if(contactTaskMap.get(pse.buildertek__Contractor_Resource_1__c) != null && pse.buildertek__Contractor_Resource_1__c != null){
                        System.debug('if condition 5');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = contactTaskMap.get(pse.buildertek__Contractor_Resource_1__c);
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Contractor_Resource_1__r.Name));
                        contactTaskMap.put(pse.buildertek__Contractor_Resource_1__c,tasksList);
                        List<String> idsList = contactTaskIdMap.get(pse.buildertek__Contractor_Resource_1__c);
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Contractor_Resource_1__c, idsList);
                    }else if(pse.buildertek__Contractor_Resource_1__c != null){
                        System.debug('if condition 6');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Contractor_Resource_1__r.Name));
                        contactTaskMap.put(pse.buildertek__Contractor_Resource_1__c,tasksList);
                        List<String> idsList = new List<String>();
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Contractor_Resource_1__c, idsList);
                    }

                    if(contactTaskMap.get(pse.buildertek__Contractor_Resource_2__c) != null && pse.buildertek__Contractor_Resource_2__c != null){
                        System.debug('if condition 7');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = contactTaskMap.get(pse.buildertek__Contractor_Resource_2__c);
                        System.debug('tasksList size --> '+tasksList.size()+' tasksList --> '+tasksList);
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Contractor_Resource_2__r.Name));
                        System.debug('tasksList size after --> '+tasksList.size()+' tasksList after --> '+tasksList);
                        contactTaskMap.put(pse.buildertek__Contractor_Resource_2__c,tasksList);
                        List<String> idsList = contactTaskIdMap.get(pse.buildertek__Contractor_Resource_2__c);
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Contractor_Resource_2__c, idsList);
                    }else if(pse.buildertek__Contractor_Resource_2__c != null){
                        System.debug('if condition 8');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Contractor_Resource_2__r.Name));
                        contactTaskMap.put(pse.buildertek__Contractor_Resource_2__c,tasksList);
                        List<String> idsList = new List<String>();
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Contractor_Resource_2__c, idsList);
                    }
                    if(contactTaskMap.get(pse.buildertek__Contractor_Resource_3__c) != null && pse.buildertek__Contractor_Resource_3__c != null){
                        System.debug('if condition 9');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = contactTaskMap.get(pse.buildertek__Contractor_Resource_3__c);
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Contractor_Resource_3__r.Name));
                        contactTaskMap.put(pse.buildertek__Contractor_Resource_3__c,tasksList);
                        List<String> idsList = contactTaskIdMap.get(pse.buildertek__Contractor_Resource_3__c);
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Contractor_Resource_3__c, idsList);
                    }else if(pse.buildertek__Contractor_Resource_3__c != null){
                        System.debug('if condition 10');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Contractor_Resource_3__r.Name));
                        contactTaskMap.put(pse.buildertek__Contractor_Resource_3__c,tasksList);
                        List<String> idsList = new List<String>();
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Contractor_Resource_3__c, idsList);
                    }

                    if(contactTaskMap.get(pse.buildertek__Internal_Resource_1__c) != null && pse.buildertek__Internal_Resource_1__c != null){
                        System.debug('if condition 15');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = contactTaskMap.get(pse.buildertek__Internal_Resource_1__c);
                        System.debug('tasksList size --> '+tasksList.size()+' tasksList --> '+tasksList);
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Internal_Resource_1__r.Name));
                        System.debug('tasksList size after --> '+tasksList.size()+' tasksList after --> '+tasksList);
                        contactTaskMap.put(pse.buildertek__Internal_Resource_1__c,tasksList);
                        List<String> idsList = contactTaskIdMap.get(pse.buildertek__Internal_Resource_1__c);
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Internal_Resource_1__c, idsList);
                    }else if(pse.buildertek__Internal_Resource_1__c != null){
                        System.debug('if condition 16');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Internal_Resource_1__r.Name));
                        contactTaskMap.put(pse.buildertek__Internal_Resource_1__c,tasksList);
                        List<String> idsList = new List<String>();
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Internal_Resource_1__c, idsList);
                    }
                    if(contactTaskMap.get(pse.buildertek__Internal_Resource_3__c) != null && pse.buildertek__Internal_Resource_3__c != null){
                        System.debug('if condition 17');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = contactTaskMap.get(pse.buildertek__Internal_Resource_3__c);
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Internal_Resource_3__r.Name));
                        contactTaskMap.put(pse.buildertek__Internal_Resource_3__c,tasksList);
                        List<String> idsList = contactTaskIdMap.get(pse.buildertek__Internal_Resource_3__c);
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Internal_Resource_3__c, idsList);
                    }else if(pse.buildertek__Internal_Resource_3__c != null){
                        System.debug('if condition 18');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Internal_Resource_3__r.Name));
                        contactTaskMap.put(pse.buildertek__Internal_Resource_3__c,tasksList);
                        List<String> idsList = new List<String>();
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Internal_Resource_3__c, idsList);
                    }
                    if(contactTaskMap.get(pse.buildertek__Internal_Resource_4__c) != null && pse.buildertek__Internal_Resource_4__c != null){
                        System.debug('if condition 19');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = contactTaskMap.get(pse.buildertek__Internal_Resource_4__c);
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Internal_Resource_4__r.Name));
                        contactTaskMap.put(pse.buildertek__Internal_Resource_4__c,tasksList);
                        List<String> idsList = contactTaskIdMap.get(pse.buildertek__Internal_Resource_4__c);
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Internal_Resource_4__c, idsList);
                    }else if(pse.buildertek__Internal_Resource_4__c != null){
                        System.debug('if condition 20');
                        list<ResourceCalendarWrap.ProjectTaskRecords> tasksList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        tasksList.add(assignResource(EquipmentRec, pse.buildertek__Internal_Resource_4__r.Name));
                        contactTaskMap.put(pse.buildertek__Internal_Resource_4__c,tasksList);
                        List<String> idsList = new List<String>();
                        idsList.add(EquipmentRec.Id);
                        contactTaskIdMap.put(pse.buildertek__Internal_Resource_4__c, idsList);
                    }
                    // Chnages for BUIL-3938 ------------------- END --------------------------------

                }
            }

        }

        List<String> resourceTaskList = new List<String>();
        combinedProjectCalendarWrapperClone combinedWrapper = new combinedProjectCalendarWrapperClone();


        if(conresource.size() > 0){
            for (contact con : conresource){

                if (contactnamemap.get(con.id) != null){
                    ResourceCalendarWrap projectRec = new ResourceCalendarWrap();
                    // list<ResourceCalendarWrap.ProjectTaskRecordsList> SchedulertaskRecordList = new list<ResourceCalendarWrap.ProjectTaskRecordsList>();

                    projectRec.ContractresourceId = con.id;
                    projectRec.resourceType = 'external';

                    projectRec.ContractresourceName = contactnamemap.get(con.Id);
                    if(contactnamemap.get(con.Id) !=null && contactnamemap.get(con.Id) !=''){
                        projectRec.FirstLetterofContractresourceName = contactnamemap.get(con.Id).toUpperCase().substring(0,1);
                    }
                    //projectRec.simultaneousTasksContractor = cona;
                    if (contactSimulateMap.containsKey(con.Id)){
                        projectRec.simultaneousTasksContractorResources = contactSimulateMap.get(con.Id);
                    }
                    if (scheduleitemmap.get(con.id) != null){
                        projectRec.tasks = string.valueof(scheduleitemmap.get(con.id).size());
                    }
                    if (contactAccountMap.get(con.id) != null){
                        projectRec.TradeType = tradeTypenamemap.get(contactAccountMap.get(con.id));

                    }
                    projectRec.Companyname = con.Account.Name;

                    //get selected resources tasks
                    if(slectedcontactId != '' && slectedcontactId != null){
                        if(con.Id == slectedcontactId){
                            projectRec.ProjectTaskRecordsList = contactTaskMap.get(con.Id);
                        }
                    }else{
                        projectRec.ProjectTaskRecordsList = contactTaskMap.get(con.Id);
                    }

                    if(alltypeSearch != '' && alltypeSearch != null){

                        if((projectRec.ContractresourceName.toLowerCase()).contains(alltypeSearch.toLowerCase()) || (projectRec.Companyname != null  && (projectRec.Companyname.toLowerCase()).contains(alltypeSearch.toLowerCase()))
                            || (projectRec.TradeType != null && (projectRec.TradeType.toLowerCase()).contains(alltypeSearch.toLowerCase()))){
                                for (Id key : contactTaskIdMap.keySet()) {
                                    System.debug('key --> '+key);
                                    System.debug('value --> '+contactTaskIdMap.get(key));
                                }
                                System.debug('before error');
                                System.debug('check cont Id '+con.Id);
                                System.debug('getting contactTaskIdMap value --> '+contactTaskIdMap.get(con.Id));
                            resourceTaskList.addAll(contactTaskIdMap.get(con.Id));
                            RecordList.add(projectRec);
                        }
                    }else{
                        RecordList.add(projectRec);
                    }
                    combinedWrapper.areExternalResource = true;

                }
            }
        }
        else{
            combinedWrapper.areExternalResource = false;
        }

        //  BUIL-3932 --------------- START ---------------------
        if(internalResource.size() > 0){
            for (User con : internalResource){
                if (contactnamemap.get(con.id) != null){
                    ResourceCalendarWrap projectRec = new ResourceCalendarWrap();

                    projectRec.ContractresourceId = con.id;

                    projectRec.resourceType = 'internal';

                    projectRec.ContractresourceName = contactnamemap.get(con.Id);
                    if(contactnamemap.get(con.Id) !=null && contactnamemap.get(con.Id) !=''){
                        projectRec.FirstLetterofContractresourceName = contactnamemap.get(con.Id).toUpperCase().substring(0,1);
                    }

                    if (scheduleitemmap.get(con.id) != null){
                        projectRec.tasks = string.valueof(scheduleitemmap.get(con.id).size());
                    }
                    if (contactAccountMap.get(con.id) != null){
                        system.debug(tradeTypenamemap.get(contactAccountMap.get(con.id)));
                        projectRec.TradeType = tradeTypenamemap.get(contactAccountMap.get(con.id));
                        if(tradeTypenamemap.get(contactAccountMap.get(con.id))!=null){
                            system.debug((projectRec.TradeType.toLowerCase()).contains(alltypeSearch.toLowerCase()));
                        }

                    }
                    projectRec.Companyname = con.Account.Name;

                    //get selected resources tasks
                    if(slectedcontactId != '' && slectedcontactId != null){
                        if(con.Id == slectedcontactId){
                            projectRec.ProjectTaskRecordsList = contactTaskMap.get(con.Id);
                        }
                    }else{
                        projectRec.ProjectTaskRecordsList = contactTaskMap.get(con.Id);
                    }

                    if(alltypeSearch != '' && alltypeSearch != null){

                        if((projectRec.ContractresourceName.toLowerCase()).contains(alltypeSearch.toLowerCase()) || (projectRec.Companyname != null  && (projectRec.Companyname.toLowerCase()).contains(alltypeSearch.toLowerCase()))
                            || (projectRec.TradeType != null && (projectRec.TradeType.toLowerCase()).contains(alltypeSearch.toLowerCase()))){

                            resourceTaskList.addAll(contactTaskIdMap.get(con.Id));
                            RecordList.add(projectRec);
                        }
                    }else{

                        RecordList.add(projectRec);
                    }
                    combinedWrapper.areInternalResource = true;
                }
            }
        }
        else{
            combinedWrapper.areInternalResource = false;
        }
        //  BUIL-3932 --------------- END ---------------------

        Map<String,List<ResourceCalendarWrap.ProjectTaskRecords>> projectAlltypeFilterTask = new Map<String,List<ResourceCalendarWrap.ProjectTaskRecords>>();
        if(resourceTaskList.size() > 0){
            for(buildertek__Project_Task__c task : schudleitemList){
                if(resourceTaskList.indexOf(task.id) > -1){
                    if(projectAlltypeFilterTask.get(task.buildertek__Schedule__r.buildertek__Project__c) != null){
                        list<ResourceCalendarWrap.ProjectTaskRecords> calendarList = projectAlltypeFilterTask.get(task.buildertek__Schedule__r.buildertek__Project__c);
                        calendarList.add(taskMap.get(task.id));
                        projectAlltypeFilterTask.put(task.buildertek__Schedule__r.buildertek__Project__c,calendarList);

                    }else{
                        list<ResourceCalendarWrap.ProjectTaskRecords> calendarList = new list<ResourceCalendarWrap.ProjectTaskRecords>();
                        calendarList.add(taskMap.get(task.id));
                        projectAlltypeFilterTask.put(task.buildertek__Schedule__r.buildertek__Project__c,calendarList);
                    }
                }

            }
        }

        List<projectResourceWrapperClone> projResWrapList = new List<projectResourceWrapperClone>();
        Set<String> projeRecSet = new Set<String>();
        for(buildertek__Project__c proj : projectRecordList){
            projectResourceWrapperClone projRec = new projectResourceWrapperClone();

            if(alltypeSearch != '' && alltypeSearch != null && resourceSearch != '' && resourceSearch !=null){
                if(projectAlltypeFilterTask.keyset().Size() > 0){
                    if(projectAlltypeFilterTask.keyset().contains(proj.Id)){
                        projRec.CalendarWrapList = projectAlltypeFilterTask.get(proj.Id);
                        projRec.projectRecAccName = proj.buildertek__Customer__r.Name;
                        projRec.projectRecAccId = proj.buildertek__Customer__c;
                        projRec.projectRecName = proj.Name;
                        projRec.projectRecId = proj.Id;
                        projeRecSet.add(proj.Id);
                        projResWrapList.add(projRec);

                    }

                }
            }else{
                projRec.CalendarWrapList = projectTaskLinkMap.get(proj.Id);
                projRec.projectRecAccName = proj.buildertek__Customer__r.Name;
                projRec.projectRecAccId = proj.buildertek__Customer__c;
                projRec.projectRecName = proj.Name;
                projRec.projectRecId = proj.Id;
                projeRecSet.add(proj.Id);
                projResWrapList.add(projRec);

            }
        }


        combinedWrapper.projectList = projResWrapList;
        //resources and tasks
        combinedWrapper.calendarTaskList = RecordList;

        return combinedWrapper;
    }

    public static ResourceCalendarWrap.ProjectTaskRecords assignResource(ResourceCalendarWrap.ProjectTaskRecords wrapperRecord, String Name){
        ResourceCalendarWrap.ProjectTaskRecords taskObj1 = new ResourceCalendarWrap.ProjectTaskRecords();
        String originalJson = JSON.serialize(wrapperRecord);
        ResourceCalendarWrap.ProjectTaskRecords clonedRecord = (ResourceCalendarWrap.ProjectTaskRecords) JSON.deserialize(originalJson, ResourceCalendarWrap.ProjectTaskRecords.class);
        clonedRecord.contractresourceId = Name;
        clonedRecord.UnitId = Name;
        return clonedRecord;

    }

    public class Wrapper{
        @AuraEnabled
        public string recordId{ get; set; }

        @AuraEnabled
        public string Name{ get; set; }

        @AuraEnabled
        public String Tasks{ get; set; }

        @AuraEnabled
        public String TradeType{ get; set; }
    }

    public class projectResourceWrapper{
        @AuraEnabled
        public String projectRecName{get; set;}

        @AuraEnabled
        public String projectRecId{get; set;}

        @AuraEnabled
        public String projectRecAccName{get; set;}

        @AuraEnabled
        public String projectRecAccId{get; set;}

        @AuraEnabled
        public List<ResourceCalendarWrap> CalendarWrapList {get; set;}
    }

    public class projectResourceWrapperClone{
        @AuraEnabled
        public String projectRecName{get; set;}

        @AuraEnabled
        public String projectRecId{get; set;}

        @AuraEnabled
        public String projectRecAccName{get; set;}

        @AuraEnabled
        public String projectRecAccId{get; set;}

        @AuraEnabled
        public List<ResourceCalendarWrap.ProjectTaskRecords> CalendarWrapList {get; set;}
    }

    public class combinedProjectCalendarWrapper{
        @AuraEnabled
        public List<projectResourceWrapper> projectList {get; set;}

        @AuraEnabled
        public List<ResourceCalendarWrap> calendarTaskList {get; set;}
    }

    public class combinedProjectCalendarWrapperClone{
        @AuraEnabled
        public List<projectResourceWrapperClone> projectList {get; set;}

        @AuraEnabled
        public List<ResourceCalendarWrap> calendarTaskList {get; set;}

        @AuraEnabled
        public Boolean areExternalResource{ get; set; }

        @AuraEnabled
        public Boolean areInternalResource{ get; set; }
    }

    public class projectWrapper{
        @AuraEnabled
        public String Id { get; set; }
        public String Name { get; set; }
        public String AccountName { get; set; }
    }
}