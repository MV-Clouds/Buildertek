public class MassUpdateWarranty{
	@AuraEnabled
	public static WarrantyItemWrapper getWarrantyItems(string recordId, Integer pageNumber, Integer pageSize){
		List<String> pickListValuesList = new List<String>();
		WarrantyItemWrapper warrantyItems = new WarrantyItemWrapper();
		Boolean isGroupFieldExist = false;
		String result = '';
		Integer offset = (pageNumber - 1) * pageSize;
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Warranty_Item__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			String query = 'SELECT Id';
			if (FsMap.containsKey('buildertek__Warranty_items')){
				for (Schema.FieldSetMember f : FsMap.get('buildertek__Warranty_items').getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					
					if (String.valueOf(f.getFieldPath()) == 'Name'){
						jsonPart += '"readOnly:":"true",';
					}
					if (String.valueOf(f.getType()) == 'REFERENCE'){
						query += f.getSObjectField().getDescribe().getRelationshipName()+'.Name,';
						jsonPart += '"name":"' + f.getSObjectField().getDescribe().getName()+'"';
					} else{
						jsonPart += '"name":"' + f.getFieldPath()+'"';
					}
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown('buildertek__Warranty_Item__c', String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					query += ',' + f.getFieldPath();
					jsonPart += '}';
					result += jsonPart;
				}
				query += ' FROM buildertek__Warranty_Item__c ';
				if (String.isNotBlank(recordId)){
					query += 'WHERE buildertek__Warranty__c  =: recordId ';
				}
				query += ' LIMIT : pageSize OFFSET : offset';
				System.debug('Query::' + query);
				warrantyItems.fieldSet = '[' + result + ']';
				warrantyItems.recordCount = [Select COUNT()
				                             FROM buildertek__Warranty_Item__c
				                             WHERE buildertek__Warranty__c = :recordId];
				warrantyItems.records = Database.query(query);
				warrantyItems.parentRecord = JSON.serialize([Select Id, Name
				                                             FROM buildertek__Warranty__c
				                                             WHERE Id = :recordId
				                                             LIMIT 1]);
			}
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			result += e.getLineNumber()+' : ' + e.getMessage();
		}
		return warrantyItems;
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
	public static WarrantyItemWrapper updateRecords(String recordId, String updatedRecords, Integer pageNumber, Integer pageSize){
		try{
			if (String.isNotBlank(updatedRecords)){
				List<buildertek__Warranty_Item__c> items = (List<buildertek__Warranty_Item__c>)JSON.deserialize(updatedRecords, List<buildertek__Warranty_Item__c>.class);
				for (buildertek__Warranty_Item__c item : items){
					if (item.Id == null){
						item.buildertek__Warranty__c = recordId;
					}
				}
				if (items.size() > 0){
					upsert items;
				}
				return getWarrantyItems(recordId, pageNumber, pageSize);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static WarrantyItemWrapper deleteWarrantyRecord(String deleteRecordId, String recordId, Integer pageNumber, Integer pageSize){
		try{
			if (String.isNotBlank(deleteRecordId)){
				delete [Select Id
				        FROM buildertek__Warranty_Item__c
				        WHERE ID = :deleteRecordId];
				return getWarrantyItems(recordId, pageNumber, pageSize);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	public class WarrantyItemWrapper{
		@AuraEnabled
		public String fieldSet;
		@AuraEnabled
		public String fieldSetCount;
		@AuraEnabled
		public Integer recordCount;
		@AuraEnabled
		public List<buildertek__Warranty_Item__c> records;
		@AuraEnabled
		public String parentRecord;

	}
}