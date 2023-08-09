public with sharing class PunchListMassUpdate{
	Public String recordId{ get; set; }

	Private ApexPages.StandardController controller;

	Public PunchListMassUpdate(){
		recordId = ApexPages.currentPage().getParameters().get('Id');
	}

	@AuraEnabled
	public static Integer getCount(String recordId){
		try{
			if (String.isNotBlank(recordId)){
				return [Select COUNT()
				        FROM buildertek__Punch_List_item__c
				        WHERE buildertek__Punch_List__c = :recordId];

			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static String getFieldSet(){
		String result = '';
		List<String> pickListValuesList = new List<String>();
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Punch_List_item__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey('buildertek__Punch_List_Line')){
				for (Schema.FieldSetMember f : FsMap.get('buildertek__Punch_List_Line').getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					jsonPart += '"name":"' + f.getFieldPath()+'"';
					if (f.getFieldPath() == 'Name'){
						jsonPart += ',"readOnly":"' + 'true' + '"';
					}
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown('buildertek__Punch_List_item__c', String.valueOf(f.getFieldPath()));
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
	public static String getRecords(String recordId, String fieldNameJson, Integer pageNumber, Integer pageSize){
		List<sObject> lstResult = new List<sObject>();
		String result = '[]';
		try{
			if (String.isNotBlank(recordId)){
				Integer offset = (pageNumber - 1) * pageSize;
				List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
				Set<String> setFieldNames = new Set<String>();
				String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM buildertek__Punch_List_item__c WHERE buildertek__Punch_List__c =: recordId';
				query += ' ORDER BY Name ASC NULLS LAST';
				query += ' LIMIT : pageSize OFFSET : offset';

				for (sObject s : Database.query(query)){
					lstResult.add(s);
				}
				if (lstResult.size() > 0){
					result = JSON.serialize(lstResult);
					return result;
				}
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
	public static String updateRecords(String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize){
		try{
			if (String.isNotBlank(updatedRecords)){
				List<buildertek__Punch_List_item__c> items = (List<buildertek__Punch_List_item__c>)JSON.deserialize(updatedRecords, List<buildertek__Punch_List_item__c>.class);
				for (buildertek__Punch_List_item__c item : items){
					if(item.Id == null){
						item.buildertek__Punch_List__c = recordId;
					}
				}
				if (items.size() > 0){
					upsert items;
				}
				return getRecords(recordId, fieldSetName, pageNumber, pageSize);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static String deleteProject(String deleteRecordId, String recordId, String fieldSetName, Integer pageNumber, Integer pageSize){
		try{
			if (String.isNotBlank(deleteRecordId)){
				delete [Select Id
				        FROM buildertek__Punch_List_item__c
				        WHERE ID = :deleteRecordId];
				return getRecords(recordId, fieldSetName, pageNumber, pageSize);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}
}