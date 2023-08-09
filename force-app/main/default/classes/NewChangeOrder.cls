public with sharing class NewChangeOrder{
	@AuraEnabled
	public static String getAccount(String projectrecordId){
		try{
			List<buildertek__Project__c> project = [Select Id, Name, buildertek__Account__c,buildertek__Customer__c
			                                        FROM buildertek__Project__c
			                                        WHERE Id = :projectrecordId];
			if (project.size() > 0){
				return project[0].buildertek__Customer__c;
            }else{
               return null; 
            }
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		
	}
}