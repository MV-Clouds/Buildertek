public with sharing class CommonMassUpdate{
	Public String recordId{ get; set; }

	Private ApexPages.StandardController controller;

	Public CommonMassUpdate(){
		recordId = ApexPages.currentPage().getParameters().get('Id');
	}

	@AuraEnabled
	public static Integer getCount(String objName, String parentField, String recordId){
		try{
			String query = '';
			query = 'Select COUNT() FROM ';
			query += objName;
			if (String.isNotBlank(parentField) && String.isNotBlank(recordId)){
				query += ' WHERE ' + parentField + ' =: recordId';
			}
			return Database.countQuery(query);
		} catch (Exception e){
			System.debug('Error Message :: ' + e.getMessage());
			System.debug('Error Line :: ' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static String getFieldSet(String objName, String fieldSetName){
		String result = '';
		List<String> pickListValuesList = new List<String>();
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get(objName);
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey(fieldSetName)){
				for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					jsonPart += '"name":"' + f.getFieldPath()+'"';
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown(objName, String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					jsonPart += '}';
					result += jsonPart;

				}
			}

		} catch (Exception e){
			result += e.getLineNumber()+' : ' + e.getMessage();
			throw new AuraHandledException(e.getMessage());
		}
		return '[' + result + ']';
	}

	@AuraEnabled
	public static String getRecords(String objName, String parentField, String recordId, String fieldNameJson, Integer pageNumber, Integer pageSize){

		List<sObject> lstResult = new List<sObject>();
		String result = '[]';
		try{
			Integer offset = (pageNumber - 1) * pageSize;
			List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
			Set<String> setFieldNames = new Set<String>();
			String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM ' + objName;
			if (String.isNotBlank(parentField) && String.isNotBlank(recordId)){
				query += ' WHERE ' + parentField + ' =: recordId';
			}
			query += ' ORDER BY Name ASC NULLS LAST';
			query += ' LIMIT : pageSize OFFSET : offset';
			System.debug('Query::' + query);
			for (sObject s : Database.query(query)){
				lstResult.add(s);
			}
			if (lstResult.size() > 0){
				result = JSON.serialize(lstResult);
				return result;
			}
		} catch (Exception e){
			System.debug('Error' + e.getMessage());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
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
	public static String updateRecords(String objName, String parentField, String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize){
		try{
			if (String.isNotBlank(updatedRecords)){
				List<sObject> items = (List<sObject>)JSON.deserialize(updatedRecords, List<sObject>.class);
				if (items.size() > 0){
					upsert items;
				}
				return getRecords(objName, parentField, recordId, fieldSetName, pageNumber, pageSize);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static String deleteProject(String objName, String parentField, String parentRecordId, String recordId, String fieldSetName, Integer pageNumber, Integer pageSize){
		try{
			String query = '';
			if (String.isNotBlank(recordId)){
				query = 'select Id FROM ' + objName;
				query += ' WHERE ID =: recordId';
				List<SObject> deleteRecords = Database.query(query);
				if (deleteRecords.size() > 0){
					delete deleteRecords;
				}
				return getRecords(objName, parentField, parentRecordId, fieldSetName, pageNumber, pageSize);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}
}