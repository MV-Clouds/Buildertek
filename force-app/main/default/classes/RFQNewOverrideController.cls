public with sharing class RFQNewOverrideController{
	@AuraEnabled
	public static String getCurrentApplicationName(){
		UserAppInfo userAppInfo;
		if (Schema.sObjectType.UserAppInfo.fields.Id.isAccessible() && Schema.sObjectType.UserAppInfo.fields.AppDefinitionId.isAccessible()){
			userAppInfo = [SELECT Id, AppDefinitionId
			               FROM UserAppInfo
			               WHERE UserId = :UserInfo.getUserId()];
		}
		AppDefinition appDefinition;
		if (Schema.sObjectType.AppDefinition.fields.DurableId.isAccessible() && Schema.sObjectType.AppDefinition.fields.Label.isAccessible()){
			appDefinition = [SELECT DurableId, Label
			                 FROM AppDefinition
			                 Where DurableId = :userAppInfo.AppDefinitionId];
		}
		return appDefinition.Label;
	}

	@AuraEnabled
	public static String getFieldSet(){
		String result = '';
		List<String> pickListValuesList = new List<String>();
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__RFQ__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey('buildertek__RFQ_Field_Set')){
				for (Schema.FieldSetMember f : FsMap.get('buildertek__RFQ_Field_Set').getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					jsonPart += '"name":"' + f.getFieldPath()+'"';
					// if (f.getFieldPath() == 'Name'){
					// 	jsonPart += ',"readOnly":"' + 'true' + '"';
					// }
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown('buildertek__RFQ__c', String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					jsonPart += '}';
					result += jsonPart;

				}
			}

		} catch (Exception e){
			result += e.getLineNumber()+' : ' + e.getMessage();
		}
		return '[' + result + ']';
	}

	@AuraEnabled
	public static List<String> getDropDown(String objName, String fieldName){
		List<String> pickListValuesList = new List<String>();
		try{
			Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
			Schema.DescribeSObjectResult r = s.getDescribe();
			Map<String, Schema.SObjectField> fields = r.fields.getMap();
			Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry pickListVal : ple){
				pickListValuesList.add(pickListVal.getLabel());
			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return pickListValuesList;
	}

	@AuraEnabled
	public static buildertek__RFQ__c createNewRFQ(String rfqRecord){
		buildertek__RFQ__c rfqToInsert = (buildertek__RFQ__c)JSON.deserialize(rfqRecord, buildertek__RFQ__c.class);

		// rfqToInsert.buildertek__Project__c = projectId;
		// rfqToInsert.buildertek__Opportunity__c = oppId;
		insert rfqToInsert;

		return rfqToInsert;
	}

	@AuraEnabled
	public static List<ListView> getListViews(){
		List<ListView> listviews;
		if (Schema.sObjectType.ListView.fields.id.isAccessible() && Schema.sObjectType.ListView.fields.Name.isAccessible()){
			listviews = [SELECT Id, Name
			             FROM ListView
			             WHERE SobjectType = 'buildertek__RFQ__c'];
		}
		return listviews;
	}
}