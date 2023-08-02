public with sharing class SSTMassUpdate {
	Public String recordId{ get; set; }

	Private ApexPages.StandardController controller;

	Public SSTMassUpdate(){
		recordId = ApexPages.currentPage().getParameters().get('Id');
	}

	@AuraEnabled
	public static string getName(String recordId){
		try{
			List<buildertek__Project_Selection_Sheet_Takeoff__c> record = [Select Id, Name
			                                     From buildertek__Project_Selection_Sheet_Takeoff__c
			                                     WHERE Id = :recordId];
			if (record.size() > 0){
				return record[0].Name;
			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static String getRecords(String parentRecordId, String fieldNameJson){

		List<sObject> lstResult = new List<sObject>();
		String result = '[]';
		try{
			List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
			Set<String> setFieldNames = new Set<String>();
			String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM buildertek__Select_Sheet__c';
			query += ' WHERE buildertek__Selection_Sheet_Takeoff__c = : parentRecordId ORDER BY Name ASC NULLS LAST';
            system.debug('query'+query);
			for (sObject s : Database.query(query)){
				lstResult.add(s);
			}
			if (lstResult.size() > 0){
				result = JSON.serialize(lstResult);
			}
		} catch (Exception e){
			System.debug('Error' + e.getMessage());
		}
		return result;
	}

	@AuraEnabled
	public static String getFieldSet(){
		String result = '';
		try{
			List<String> pickListValuesList = new List<String>();
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Select_Sheet__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey('buildertek__SST_Related_List_View_Fields'))
				for (Schema.FieldSetMember f : FsMap.get('buildertek__SST_Related_List_View_Fields').getFields()){
					if (result != ''){
						result += ',';
				}
				String jsonPart = '{';
				jsonPart += '"label":"' + f.getLabel()+'",';
				jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
				jsonPart += '"type":"' + (f.getType())+'",';
				jsonPart += '"name":"' + f.getFieldPath()+'"';
				if (String.valueOf(f.getType()) == 'PICKLIST'){
					pickListValuesList = getDropDown('buildertek__Select_Sheet__c', String.valueOf(f.getFieldPath()));
					jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
				}
				jsonPart += '}';
				result += jsonPart;
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
	public static String updateRecords(String recordId, String updatedRecords, String fieldSetName){
		try{
			if (String.isNotBlank(updatedRecords)){
				List<buildertek__Select_Sheet__c> items = (List<buildertek__Select_Sheet__c>)JSON.deserialize(updatedRecords, List<buildertek__Select_Sheet__c>.class);
				upsert items;
				//delete [Select Id
				//        FROM buildertek__Quote_Item__c
				//        WHERE buildertek__Quote__c = :recordId AND Id NOT IN :items];
				return getRecords(recordId, fieldSetName);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}
    
    @AuraEnabled
	public static String deleteQuoteItem(String quoteId, String recordId, String fieldSetName){
		try{
			if (String.isNotBlank(recordId)){
				delete [Select Id
				        FROM buildertek__Select_Sheet__c
				        WHERE Id = :recordId];
				return getRecords(quoteId, fieldSetName);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}    
}