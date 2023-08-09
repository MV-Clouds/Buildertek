public with sharing class InSiteEnquiryUtils {

	public static pba__Request__c lookupPropertybaseEnquiryByEmailAddress(String emailAddress) {
		pba__Request__c returnValue = null;

		List<pba__Request__c> queryResult = Database.query('SELECT Id,Project_Look_Up__c,pba__Contact__r.FirstName,pba__Contact__r.LastName,pba__Contact__r.Email FROM pba__Request__c WHERE pba__Contact__r.Email=:emailAddress');
		if (!queryResult.isEmpty()) {
			returnValue = queryResult[0];
		}

		return returnValue;
	}

	public static pba__Request__c lookupPropertybaseEnquiryById(Id recordId) {
		pba__Request__c returnValue = null;

		List<pba__Request__c> queryResult = Database.query('SELECT Id,Project_Look_Up__c,pba__Contact__r.FirstName,pba__Contact__r.LastName,pba__Contact__r.Email FROM pba__Request__c WHERE Id=:recordId');
		if (!queryResult.isEmpty()) {
			returnValue = queryResult[0];
		}

		return returnValue;
	}
}