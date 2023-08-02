public with sharing class InSiteLoadProjectsWithSharing {

	public static List<pba__Property__c> loadProjects() {
		return [SELECT Id, Name, RecordType.Name FROM pba__Property__c WHERE RecordType.Name = 'Project'];
	}
}