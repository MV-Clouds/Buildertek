public with sharing class NewGanttChartTaskTriggerHandler{
    public static Boolean blnSkipTaskTrigger = false;
    public static void upsertMilestoneData(List<buildertek__Project_Task__c> newTaskList, Map<ID, buildertek__Project_Task__c> newTaskMap){

        if (!blnSkipTaskTrigger){

            Id scheduleId = newTaskList[0].buildertek__Schedule__c;

            List<buildertek__Project_Task__c> projectTaskList = [SELECT Id, Name, buildertek__Dependency__c, buildertek__Milestone__c, buildertek__Dependency__r.Name, buildertek__Schedule__c, buildertek__Phase__c, buildertek__Start__c, buildertek__finish__c
                                                                 FROM buildertek__Project_Task__c
                                                                 WHERE buildertek__Schedule__c = :scheduleId
                                                                 ORDER BY buildertek__Phase__c];

            Map<String, Date> phaseDateMap = new Map<String, Date>();
            Map<String, buildertek__Project_Task__c> phaseMileStoneMap = new Map<String, buildertek__Project_Task__c>();

            for (buildertek__Project_Task__c projectTask : projectTaskList){
                System.debug('projectTask ==> '+projectTask);
                if (projectTask.buildertek__Milestone__c){
                    phaseMileStoneMap.put(projectTask.buildertek__Phase__c, projectTask);
                } else{
                    if (projectTask.buildertek__finish__c == null) {
                        projectTask.buildertek__finish__c = projectTask.buildertek__Start__c.addDays(1);
                    }
                    if (phaseDateMap.containsKey(projectTask.buildertek__Phase__c)){
                        Date endDate = phaseDateMap.get(projectTask.buildertek__Phase__c);
                        if (endDate < projectTask.buildertek__finish__c){
                            phaseDateMap.put(projectTask.buildertek__Phase__c, projectTask.buildertek__finish__c);
                        }
                    } else{
                        phaseDateMap.put(projectTask.buildertek__Phase__c, projectTask.buildertek__finish__c);
                    }
                }

            }

            List<buildertek__Project_Task__c> mileStoneList = new List<buildertek__Project_Task__c>();
            for (String key : phaseDateMap.keySet()){
                System.debug('phaseDateMap ==> '+phaseDateMap.get(key));
                if (phaseMileStoneMap.containsKey(key)){
                    buildertek__Project_Task__c task = phaseMileStoneMap.get(key);
                    task.buildertek__Start__c = skipWeekend(phaseDateMap.get(key));
                    task.buildertek__finish__c = skipWeekend(phaseDateMap.get(key));
                    if (key != null && key != ''){
                        System.debug('task ===> '+task);
                        mileStoneList.add(task) ;
                    }
                } else{
                    buildertek__Project_Task__c task = new buildertek__Project_Task__c();
                    task.Name = 'Milestone Complete';
                    task.buildertek__Phase__c = key;
                    task.buildertek__Start__c = skipWeekend(phaseDateMap.get(key));
                    task.buildertek__Finish__c = skipWeekend(phaseDateMap.get(key));
                    task.buildertek__Duration__c = 0;
                    task.buildertek__Schedule__c = scheduleId;
                    task.buildertek__Milestone__c = true;
                    task.buildertek__Type__c = 'Milestone';
                    if (key != null && key != ''){
                        System.debug('task ===> '+task);
                        mileStoneList.add(task) ;
                    }
                }
            }
            NewGanttChartTaskTriggerHandler.blnSkipTaskTrigger = true;
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;

            for (buildertek__Project_Task__c task : mileStoneList) {
                System.debug('Task before update ==> '+ task);
            }
            upsert mileStoneList;
            updateProjectAnticipatedDate(newTaskList);
            NewGanttChartTaskTriggerHandler.blnSkipTaskTrigger = false;
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
            System.debug('mileStoneList: ' + mileStoneList);

        }
    }

    public static Date skipWeekend(Date startDate){
		DateTime currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
		String todayDay = currDate.format('EEEE');
		if (todayDay == 'Saturday'){
			startDate = startDate.addDays(2);
		} else if (todayDay == 'Sunday'){
			startDate = startDate.addDays(1);
		}
		return startDate;
	}

    public static void updateProjectAnticipatedDate(List<buildertek__Project_Task__c> taskList) {
        if (taskList.size()>0) {
            String projectId = taskList[0].buildertek__Project__c;

            if (!String.isBlank(projectId)) {
                buildertek__Schedule__c scheduleRec = [SELECT Id, Name, buildertek__End_Date__c, buildertek__Start_Date__c, buildertek__Project__c
                                                       FROM buildertek__Schedule__c
                                                       WHERE buildertek__Project__c = :projectId ORDER BY buildertek__End_Date__c DESC LIMIT 1];

                buildertek__Project__c projectOnSchedule = new buildertek__Project__c();
                projectOnSchedule.Id = projectId;
                projectOnSchedule.buildertek__Estimated_Completion_Date__c = scheduleRec.buildertek__End_Date__c;
                update projectOnSchedule;
            }
        }
    }

}