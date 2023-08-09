public class ProjectTaskQueueable implements Queueable{
	public Map<Id, Project_Task__c> mapAllTask;
	public ProjectTaskQueueable(Set<Id> scheduleIds){
		this.mapAllTask = new Map<Id, Project_Task__c>([Select Id, Dependency__c, Duration__c, Expected_End_Date__c, Expected_Start_Date__c, Start__c, Finish__c, Lag__c, Order__c
		                                                from Project_Task__c
		                                                where Schedule__c In :scheduleIds
		                                                order by ORDER__c ASC
		                                                NULLS LAST]);
	}

	public void execute(QueueableContext context){
		Date startDate;
		Date endDate;
		Integer numberDaysDue;
		for (Id taskId : mapAllTask.keySet()){
			Project_Task__c projectTask = mapAllTask.get(taskId);
			Id Dependency = projectTask.Dependency__c;
			if (projectTask.Dependency__c != null){
				Project_Task__c parentTask = mapAllTask.get(projectTask.Dependency__c);
				Integer lag = projectTask.Lag__c != null ? Integer.valueOf(projectTask.Lag__c) : 0;
				startDate = parentTask.finish__c.addDays(1);
				endDate = parentTask.finish__c.addDays(Integer.valueOf(parentTask.Duration__c)+1);
				numberDaysDue = startDate.daysBetween(endDate);
				projectTask.duration__c = numberDaysDue + 1;
				projectTask.Start__c = startDate;
				projectTask.finish__c = ProjectTaskTriggerHandler.getEndDate(startDate, endDate);
			}
		}
		update mapAllTask.values();
	}
}