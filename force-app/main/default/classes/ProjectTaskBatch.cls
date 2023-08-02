global class ProjectTaskBatch implements Database.BatchAble<SObject>{
	public Map<Id, buildertek__Project_Task__c> mapAllTask;
	public String soqlQuery;
	public Set<Id> scheduleIds;
	List<buildertek__Project_Task__c> projectTaskToUpdate;
	Map<Id, List<Project_Task__c>> projectTaskMaps = new Map<Id, List<Project_Task__c>>();
	List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
	Map<String, buildertek__Project_Task__c> milestoneList = new Map<String, buildertek__Project_Task__c>();
	Map<String, buildertek__Project_Task__c> taskMaps = new Map<String, buildertek__Project_Task__c>();
	global ProjectTaskBatch(Set<Id> scheduleIds){
		this.scheduleIds = scheduleIds;
	}

	global Database.QueryLocator start(Database.BatchAbleContext bc){
		this.soqlQuery = 'Select Id, buildertek__Dependency__c,buildertek__Milestone__c,buildertek__Schedule__c,buildertek__Phase__c, buildertek__Duration__c, buildertek__Expected_End_Date__c, buildertek__Expected_Start_Date__c, buildertek__Start__c, buildertek__Finish__c, buildertek__Lag__c, buildertek__Order__c FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c In : scheduleIds ORDER by buildertek__ORDER__c ASC NULLS LAST LIMIT 1000';
		return Database.getQueryLocator(soqlQuery);
	}

	global void execute(Database.BatchAbleContext bd, List<buildertek__Project_Task__c> sc){
		projectTaskToUpdate = new List<buildertek__Project_Task__c>();
		mapAllTask = new Map<Id, buildertek__Project_Task__c>();
		for (buildertek__Project_Task__c projectTask : sc){
			mapAllTask.put(projectTask.Id, projectTask);
		}
		Date startDate;
		Date endDate;
		Integer numberDaysDue;
		for (Id taskId : mapAllTask.keySet()){
			buildertek__Project_Task__c projectTask = mapAllTask.get(taskId);
			Id Dependency = projectTask.buildertek__Dependency__c;
			if (projectTask.buildertek__Dependency__c != null){
				buildertek__Project_Task__c parentTask = mapAllTask.get(projectTask.buildertek__Dependency__c);
				Integer lag = projectTask.buildertek__Lag__c != null ? Integer.valueOf(projectTask.buildertek__Lag__c) : 0;
				startDate = parentTask.buildertek__finish__c.addDays(1);
				endDate = parentTask.buildertek__finish__c.addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
				numberDaysDue = startDate.daysBetween(endDate);
				projectTask.buildertek__Start__c = startDate;
				projectTask.buildertek__finish__c = ProjectTaskTriggerHandler.getEndDate(startDate, endDate);
				projectTaskToUpdate.add(projectTask);
			}
		}

		ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
		//update projectTaskToUpdate;
		ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
	}

	public void finish(database.BatchAbleContext bc){
	}
}