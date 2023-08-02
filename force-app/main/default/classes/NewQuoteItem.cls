public with sharing class NewQuoteItem{
	@AuraEnabled
	public static QuoteItemWrapper getQuoteItems(string recordId, Integer pageNumber, Integer pageSize){
		List<String> pickListValuesList = new List<String>();
		Map<String, String> formulaMap = new Map<String, String>();
		QuoteItemWrapper quoteItems = new QuoteItemWrapper();
		Boolean isGroupFieldExist = false;
		String result = '';
		Integer offset = (pageNumber - 1) * pageSize;
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Quote_Item__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			String query = 'SELECT Id';
			if (FsMap.containsKey('buildertek__BT_Related_List_View_Fields')){
				for (Schema.FieldSetMember f : FsMap.get('buildertek__BT_Related_List_View_Fields').getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					if (String.valueOf(f.getType()) == 'REFERENCE'){
						query += f.getSObjectField().getDescribe().getRelationshipName()+'.Name,';
						jsonPart += '"name":"' + f.getSObjectField().getDescribe().getName()+'"';
					} else{
						jsonPart += '"name":"' + f.getFieldPath()+'"';
					}
					if (String.valueOf(f.getSObjectField().getDescribe().getName()).contains('buildertek__Grouping__c')){
						isGroupFieldExist = true;
					}
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown('buildertek__Quote_Item__c', String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					query += ',' + f.getFieldPath();
					jsonPart += '}';
					result += jsonPart;
				}
				Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
				Schema.SObjectType objectSchema = schemaMap.get('buildertek__Quote_Item__c');
				Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
				for (String fieldName : fieldMap.keySet()){
					Schema.DescribeFieldResult df = fieldMap.get(fieldName).getDescribe();
					if (df.isCalculated() && df.getCalculatedFormula() != null){
						formulaMap.put(fieldName, String.valueOf(df.getCalculatedFormula().replace('\n', ' ').replace('\r', ' ')));
					}
				}

				query += !isGroupFieldExist ? ', buildertek__Grouping__c,buildertek__Grouping__r.Name ' : '';
				query += ' FROM buildertek__Quote_Item__c ';
				if (String.isNotBlank(recordId)){
					query += 'WHERE buildertek__Quote__c  =: recordId ';
				}
				query += ' LIMIT : pageSize OFFSET : offset';
				quoteItems.fieldSet = '[' + result + ']';
				quoteItems.formulaFields = JSON.serialize(formulaMap);
				quoteItems.records = Database.query(query);
			}
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			result += e.getLineNumber()+' : ' + e.getMessage();
		}
		return quoteItems;
	}

	@AuraEnabled
	public static QuoteItemWrapper updateRecords(string recordId, String records, Integer pageNumber, Integer pageSize){
		QuoteItemWrapper quoteItems = new QuoteItemWrapper();
		try{
			List<buildertek__Quote_Item__c> items = (List<buildertek__Quote_Item__c>)JSON.deserialize(records, List<buildertek__Quote_Item__c>.class);
			update items;
			quoteItems = getQuoteItems(recordId, pageNumber, pageSize);
			quoteItems.statusCode = '200';
		} catch (Exception e){
			quoteItems = getQuoteItems(recordId, pageNumber, pageSize);
			quoteItems.statusCode = '404';
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
		}
		return quoteItems;
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

	public class QuoteItemWrapper{
		@AuraEnabled
		public String fieldSet;
		@AuraEnabled
		public String statusCode;
		@AuraEnabled
		public String formulaFields;
		@AuraEnabled
		public String fieldSetCount;
		@AuraEnabled
		public List<buildertek__Quote_Item__c> records;

	}
}