public with sharing class Projects{
	@AuraEnabled
	public static List<buildertek__Project__c> getAllProjects(){
		try{
			List<buildertek__Project__c> projects = [Select Id, Name, (Select Id, Name
			                                                           FROM buildertek__Schedules__r)
			                                         FROM buildertek__Project__c];
			if (projects.size() > 0){
				return projects;
			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}
}