public with sharing class InSiteSettings {

	private static InSiteSettings__c getOrgDefaults() {
		return InSiteSettings__c.getOrgDefaults();
	}

	public static String getInSiteApiUrl() {
		return InSiteSettings.getOrgDefaults().InSiteApiUrl__c;
	}

	public static String getRemoteGatewayUrl() {
		return InSiteSettings__c.getOrgDefaults().RemoteGatewayUrl__c;
	}
}