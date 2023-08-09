public class ScheduleCalendarController {
    @AuraEnabled
    public static List<buildertek__Project_Task__c> getProjects(List<Id> projectIdList, String tradeTypeId, String vendorId){
        // system.debug('projectId --------> '+projectId);
        system.debug('tradeTypeId --------> '+tradeTypeId);
        system.debug('vendorId --------> '+vendorId);

        List<ScheduleWrapper> scheduleWrapperList = new List<ScheduleWrapper>();
        string scheduletype = 'Master';
        String query = 'SELECT Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Notes__c, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Schedule__r.buildertek__Project__c, buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Type__c FROM  buildertek__Project_Task__c';
        // if(scheduleItemsStatus == 'Active'){
        //     query += ' WHERE buildertek__Completion__c != 100';
        // }else if(scheduleItemsStatus == 'Completed'){
        //     query += ' WHERE buildertek__Completion__c = 100';
        // }

        if(projectIdList.size() > 0){
            if(query.contains('WHERE')){
                query += ' AND buildertek__Schedule__r.buildertek__Project__c IN: projectIdList';
            }else{
                query += ' WHERE buildertek__Schedule__r.buildertek__Project__c IN: projectIdList';
            }
        }
        if(vendorId != 'All' && vendorId != ''){
            if(query.contains('WHERE')){
                query += ' AND buildertek__Contractor__c =: vendorId';
            }else{
                query += ' WHERE buildertek__Contractor__c =: vendorId';
            }
        }
        if(tradeTypeId != 'All' && tradeTypeId != ''){
            if(query.contains('WHERE')){
                query += ' AND buildertek__Trade_Type__c =: tradeTypeId';
            }else{
                query += ' WHERE buildertek__Trade_Type__c =: tradeTypeId';
            }
        }
        if(query.contains('WHERE')){
            query += ' AND buildertek__Schedule__r.buildertek__Type__c !=: scheduletype';
        }else{
            query += ' WHERE buildertek__Schedule__r.buildertek__Type__c !=: scheduletype';
        }
        query += ' ORDER By Name ASC';
        system.debug('query-->'+query);
        List<buildertek__Project_Task__c> scheduleItemsList = Database.query(query);
        system.debug('scheduleItemsList.......'+scheduleItemsList);
        /*String query = 'SELECT Id, Name, (SELECT Id, Name, buildertek__Project__r.Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Notes__c FROM buildertek__Project_Tasks__r';
        if(scheduleItemsStatus == 'Active'){
            query += ' WHERE buildertek__Completion__c != 100';
        }else if(scheduleItemsStatus == 'Completed'){
            query += ' WHERE buildertek__Completion__c = 100';
        }
        if(projectId != 'All'){
            if(query.contains('WHERE')){
                query += ' AND buildertek__Project__c =: projectId';
            }else{
                query += ' WHERE buildertek__Project__c =: projectId';
            }
        }
        if(vendorId != 'All'){
            if(query.contains('WHERE')){
                query += ' AND buildertek__Contractor__c =: vendorId';
            }else{
                query += ' WHERE buildertek__Contractor__c =: vendorId';
            }
        }
        if(tradeTypeId != 'All'){
            if(query.contains('WHERE')){
                query += ' AND buildertek__Trade_Type__c =: tradeTypeId';
            }else{
                query += ' WHERE buildertek__Trade_Type__c =: tradeTypeId';
            }
        }
        query += ') FROM buildertek__Project__c WHERE buildertek__Active__c = true ORDER BY Name ASC';
        system.debug('query ------> '+query);
        List<buildertek__Project__c> projectList = Database.query(query);
        List<ScheduleWrapper> scheduleWrapperList = new List<ScheduleWrapper>();
        if(projectList.size() > 0){
            for(buildertek__Project__c proj : projectList){
                scheduleWrapperList.add(new ScheduleWrapper(proj, proj.buildertek__Project_Tasks__r));
            }
        }*/
        //FinalResultWrapper FRW = new FinalResultWrapper();
        //FRW.ScheduleWrapperList = scheduleWrapperList;
        return scheduleItemsList;
    }

    public class ScheduleWrapper{
        @AuraEnabled public buildertek__Project__c projectList;
        @AuraEnabled public List<buildertek__Project_Task__c> scheduleItemList;
        public ScheduleWrapper(buildertek__Project__c projectList, List<buildertek__Project_Task__c> scheduleItemList){
            this.projectList = projectList;
            this.scheduleItemList = scheduleItemList;
        }
    }

    public class FinalResultWrapper{
        @AuraEnabled public List<ScheduleWrapper> ScheduleWrapperList;
    }

    @AuraEnabled
    public static List<buildertek__Project__c> getAllProjects(){
        List<buildertek__Project__c> projectsList = [SELECT Id, Name FROM buildertek__Project__c WHERE buildertek__Active__c = true ORDER By Name ASC];
        return projectsList;
    }

    @AuraEnabled
    public static List<Account> getVendors(){
        List<Account> accountsList = [SELECT Id, Name, buildertek__Trade_Type_Lookup__c FROM Account ORDER BY Name ASC];
        return accountsList;
    }

    @AuraEnabled
    public static List<buildertek__Trade_Type__c> getTradeTypes(){
        List<buildertek__Trade_Type__c> tradeTypesList = [SELECT Id, Name FROM buildertek__Trade_Type__c ORDER BY Name ASC];
        return tradeTypesList;
    }

    @AuraEnabled
    public static Date updateDate(String recordId, String endDate){
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        try{
        	Date startDate = Date.valueOf(endDate);
        	List<buildertek__Project_Task__c> scheduleItem = [SELECT Id,
                                                                buildertek__Start__c,
                                                                buildertek__Finish__c,
                                                                buildertek__Duration__c,
                                                                buildertek__Dependency__c
                                                                FROM buildertek__Project_Task__c
                                                                WHERE Id =: recordId LIMIT 1];
            scheduleItem[0].buildertek__Start__c = startDate;
            Integer dayToAdd = 0;
            Integer duration = Integer.valueOf(scheduleItem[0].buildertek__Duration__c) - 1;
            for(integer i=0; i < duration; i++){
                Date dt = scheduleItem[0].buildertek__Start__c + i;
                DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                String todayDay = currDate.format('EEEE');
                if(todayDay == 'Saturday'){
                    duration = duration + 1;
                }else if(todayDay == 'Sunday'){
                    duration = duration + 1;
                }
            }
            system.debug('duration ------> '+duration);
            system.debug('dayToAdd -------> '+dayToAdd);
            scheduleItem[0].buildertek__Finish__c = startDate.addDays(duration);
        	update scheduleItem;
            system.debug('scheduleItem -------> '+scheduleItem);
            checkDependency(scheduleItem);
            return startDate;
        }catch(Exception exp){
        	return null;
        }


    }

    public static void checkDependency(List<buildertek__Project_Task__c> scheduleItemId){
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
    	List<buildertek__Project_Task__c> scheduleItem = [SELECT Id,
                                                                        buildertek__Start__c,
                                                                        buildertek__Finish__c,
                                                                        buildertek__Duration__c,
                                                                        buildertek__Dependency__c,
                                                              			buildertek__Dependency__r.buildertek__Start__c,
                                                              			buildertek__Dependency__r.buildertek__Finish__c
                                                                        FROM buildertek__Project_Task__c
                                                                        WHERE buildertek__Dependency__c IN: scheduleItemId];
        if(scheduleItem.size() > 0){
            List<buildertek__Project_Task__c> projectTaskToUpdate = new List<buildertek__Project_Task__c>();
                for(buildertek__Project_Task__c tsk : scheduleItem){
                	Date startDate = tsk.buildertek__Dependency__r.buildertek__Finish__c.addDays(1);
                    DateTime currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
                    String todayDay = currDate.format('EEEE');
                    if(todayDay == 'Saturday'){
                        startDate = startDate.addDays(2);
                    }else if(todayDay == 'Sunday'){
                        startDate = startDate.addDays(1);
                    }
                    buildertek__Project_Task__c scheduleItemUpdate = new buildertek__Project_Task__c();
                    scheduleItemUpdate.Id = tsk.Id;
                    scheduleItemUpdate.buildertek__Start__c = startDate;
                    scheduleItemUpdate.buildertek__Finish__c = getTaskEndDate(startDate, Integer.valueOf(tsk.buildertek__Duration__c));
                    projectTaskToUpdate.add(scheduleItemUpdate);
                }
                if(projectTaskToUpdate.size() > 0){
                    update projectTaskToUpdate;
                    checkDependency(projectTaskToUpdate);
                }
        }
    }

    public static Date getTaskEndDate(Date startDate, Integer Duration){
        Duration = Duration - 1;
    	for(integer i=0; i <= Duration; i++){
            Date dt = startDate + i;
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
            String todayDay = currDate.format('EEEE');
            if(todayDay == 'Saturday'){
                Duration = Duration + 1;
            }else if(todayDay == 'Sunday'){
                Duration = Duration + 1;
            }
        }
        Date endDate = startDate.addDays(Duration);
        return endDate;
    }

    @AuraEnabled
    public static Date updateEndDate(String recordId, String endDate){
    	ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        try{
        	List<buildertek__Project_Task__c> scheduleItem = [SELECT Id,
                                                                buildertek__Start__c,
                                                                buildertek__Finish__c,
                                                                buildertek__Duration__c,
                                                                buildertek__Dependency__c
                                                                FROM buildertek__Project_Task__c
                                                                WHERE Id =: recordId LIMIT 1];


            Date finalEndDate = Date.valueOf(endDate);
            DateTime currDate = DateTime.newInstance(finalEndDate.year(), finalEndDate.month(), finalEndDate.day());
            String todayDay = currDate.format('EEEE');
            Integer duration = 0;
            if(todayDay == 'Saturday'){
                duration = duration + 1;
            }else if(todayDay == 'Sunday'){
                duration = duration + 1;
            }
            system.debug('duration -------> '+duration);
            finalEndDate = finalEndDate.addDays(duration);
            system.debug('finalEndDate -------> '+finalEndDate);
            Date changedEndDate = Date.newInstance(finalEndDate.year(), finalEndDate.month(), finalEndDate.day());
			Date actualEndDate = Date.newInstance(scheduleItem[0].buildertek__Start__c.year(), scheduleItem[0].buildertek__Start__c.month(), scheduleItem[0].buildertek__Start__c.day());
			Integer numberofDays = actualEndDate.daysBetween(changedEndDate)+1;
            system.debug('Days between --------> '+numberofDays);
            Integer days = numberofDays;
            for(integer i=0; i < days; i++){
                system.debug('initial --------> '+i);
                Date dt = scheduleItem[0].buildertek__Start__c + i;
                DateTime currentDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                String currentDay = currentDate.format('EEEE');
                if(currentDay == 'Saturday'){
                    numberofDays = numberofDays - 1;
                }else if(currentDay == 'Sunday'){
                    numberofDays = numberofDays - 1;
                }
                system.debug('currentDay ------> '+currentDay);
                system.debug('numberofDays ------> '+numberofDays);
                system.debug('final --------> '+i);
            }
            scheduleItem[0].buildertek__Duration__c = numberofDays;
            scheduleItem[0].buildertek__Finish__c = finalEndDate;

			system.debug('numberDaysDue ------> '+numberofDays);
        	update scheduleItem;
            system.debug('scheduleItem -------> '+scheduleItem);
            checkDependency(scheduleItem);
            return scheduleItem[0].Start__c;
        }catch(Exception exp){
        	return null;
        }
    }

}