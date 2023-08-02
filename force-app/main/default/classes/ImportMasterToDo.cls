public with sharing class ImportMasterToDo{
	@AuraEnabled
	public Static List<buildertek__To_Do__c> getAllMaseterRecords(String recordId){
		List<buildertek__To_Do__c> toDo = [SELECT Id, Name, buildertek__Project__c,buildertek__Project__r.Name, buildertek__Description__c, buildertek__Additional_Details__c, buildertek__Assigned_To__c, buildertek__Due_Date__c, buildertek__Status__c, buildertek__Priority__c, buildertek__Assigned_Vendor__c, buildertek__Date_Completed__c, buildertek__Schedule_Item__c, buildertek__Type__c
		                                   FROM buildertek__To_Do__c
		                                   WHERE buildertek__Type__c = :'Master' AND ID != :recordId];
		if (toDo.size() > 0){
			return toDo;
		}
		return null;
	}

	@AuraEnabled
	public static void importToDoRecords(String recordId, List<String> selectedRecordId){
		try{
			List<buildertek__To_Do_Items__c> toDoItems = [SELECT buildertek__Description__c, buildertek__Additional_Details__c, buildertek__Assigned_To__c, buildertek__Assigned_Vendor__c, buildertek__Status__c, buildertek__Priority__c, buildertek__Due_Date__c, buildertek__Date_Completed__c
			                                              FROM buildertek__To_Do_Items__c
			                                              WHERE buildertek__To_Do__c In :selectedRecordId];

			for (buildertek__To_Do_Items__c item : toDoItems){
				item.Id = null;
				item.buildertek__To_Do__c = null;
				item.buildertek__To_Do__c = recordId;
			}
			insert toDoItems;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}
}