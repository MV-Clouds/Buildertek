public class MassUpdatePackageLien{
	@AuraEnabled
	public static MassUpdateWrapper getRecords(string recordId, Integer pageNumber, Integer pageSize){
		List<String> pickListValuesList = new List<String>();
		MassUpdateWrapper packageLines = new MassUpdateWrapper();
		Boolean isGroupFieldExist = false;
		String result = '';
		Integer offset = (pageNumber - 1) * pageSize;
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Package_Line__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			String query = 'SELECT Id ';
			if (FsMap.containsKey('buildertek__Package_Liens')){
				for (Schema.FieldSetMember f : FsMap.get('buildertek__Package_Liens').getFields()){
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
						query += ',' + f.getSObjectField().getDescribe().getRelationshipName()+'.Name';
						jsonPart += '"name":"' + f.getSObjectField().getDescribe().getName()+'"';
					} else{
						jsonPart += '"name":"' + f.getFieldPath()+'"';
					}
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown('buildertek__Package_Line__c', String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					query += ',' + f.getFieldPath();
					System.debug('Query : 0: ' + query);
					jsonPart += '}';
					result += jsonPart;
				}
				query += ' FROM buildertek__Package_Line__c ';
				if (String.isNotBlank(recordId)){
					query += 'WHERE buildertek__Package_Name__c  =: recordId ';
				}
				query += ' LIMIT : pageSize OFFSET : offset';
				System.debug('Query::' + query);
				packageLines.fieldSet = '[' + result + ']';
				packageLines.recordCount = [Select COUNT()
				                            FROM buildertek__Package_Line__c
				                            WHERE buildertek__Package_Name__c = :recordId];
				packageLines.records = Database.query(query);
				packageLines.parentRecord = [Select Id, Name
				                             FROM buildertek__Package__c
				                             WHERE Id = :recordId
				                             LIMIT 1];
				System.debug('Parent Record ::' + packageLines.parentRecord);
			}
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			result += e.getLineNumber()+' : ' + e.getMessage();
		}
		return packageLines;
	}

	@AuraEnabled
	public static List<String> getDropDown(String objName, String fieldName){
		List<String> pickListValuesList = new List<String>();
		try{
			Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
			Schema.DescribeSObjectResult r = s.getDescribe();
			Map<String, Schema.SObjectField> fields = r.fields.getMap();
			Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
			List<Schema.PickListEntry> ple = fieldResult.getPickListValues();
			for (Schema.PickListEntry pickListVal : ple){
				pickListValuesList.add(pickListVal.getLabel());
			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return pickListValuesList;
	}

	@AuraEnabled
	public static MassUpdateWrapper updateRecords(String recordId, String updatedRecords, Integer pageNumber, Integer pageSize){
		try{
			if (String.isNotBlank(updatedRecords)){
				List<buildertek__Package_Line__c> items = (List<buildertek__Package_Line__c>)JSON.deserialize(updatedRecords, List<buildertek__Package_Line__c>.class);
				for (buildertek__Package_Line__c item : items){
					if (item.Id == null){
						item.buildertek__Package_Name__c = recordId;
					}
				}
				if (items.size() > 0){
					upsert items;
				}
				return getRecords(recordId, pageNumber, pageSize);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static MassUpdateWrapper deleteRecords(String deleteRecordId, String recordId, Integer pageNumber, Integer pageSize){
		try{
			if (String.isNotBlank(deleteRecordId)){
				delete [Select Id
				        FROM buildertek__Package_Line__c
				        WHERE ID = :deleteRecordId];
				return getRecords(recordId, pageNumber, pageSize);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	public class MassUpdateWrapper{
		@AuraEnabled
		public String fieldSet{ get; set; }

		@AuraEnabled
		public String fieldSetCount{ get; set; }

		@AuraEnabled
		public Integer recordCount{ get; set; }

		@AuraEnabled
		public List<buildertek__Package_Line__c> records{ get; set; }

		@AuraEnabled
		public buildertek__Package__c parentRecord{ get; set; }
	}
}