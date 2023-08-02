public class MassUpdateMasterSelection{
	Public String recordId{ get; set; }

	Private ApexPages.StandardController controller;

	Public MassUpdateMasterSelection(){
		recordId = ApexPages.currentPage().getParameters().get('Id');
		system.debug('hiiii' + recordId);
	}

	@AuraEnabled
	public static string getName(String recordId){
		try{
			List<buildertek__Project_Selection_Sheet_Takeoff__c> takeOff = [Select Id, Name
			                                                                From buildertek__Project_Selection_Sheet_Takeoff__c
			                                                                WHERE Id = :recordId];
			if (takeOff.size() > 0){
				return takeOff[0].Name;
			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static string getParentId(String recordId){
		try{
			List<buildertek__Project_Selection_Sheet_Takeoff__c> takeOff = [Select Id, buildertek__Project__c
			                                                                From buildertek__Project_Selection_Sheet_Takeoff__c
			                                                                WHERE Id = :recordId];
			if (takeOff.size() > 0){
				return takeOff[0].buildertek__Project__c;
			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static Integer getCount(String recordId){
		try{
			if (String.isNotBlank(recordId)){
				return [Select COUNT()
				        FROM buildertek__Select_Sheet__c
				        WHERE buildertek__Selection_Sheet_Takeoff__c = :recordId];

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
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Select_Sheet__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey('buildertek__SST_Related_List_View_Fields')){
				for (Schema.FieldSetMember f : FsMap.get('buildertek__SST_Related_List_View_Fields').getFields()){
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
						pickListValuesList = getDropDown('buildertek__Select_Sheet__c', String.valueOf(f.getFieldPath()));
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
	public static String getRecords(String recordId, String fieldNameJson, Integer pageNumber, Integer pageSize, String productType, String searchLocation, String searchCategory, String searchTradeType){
        List<sObject> lstResult = new List<sObject>();
		String result = '[]';
		try{
			if (String.isNotBlank(recordId)){
				Integer offset = (pageNumber - 1) * pageSize;
				List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
				Set<String> setFieldNames = new Set<String>();
				String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c =: recordId';
				if (String.isNotBlank(productType)){
				 productType = '%' + productType + '%';
				 query += ' AND buildertek__Product_Type__r.NAME LIKE : productType';
				 }
				 if (String.isNotBlank(searchLocation)){
				 searchLocation = '%' + searchLocation + '%';
				 query += ' AND buildertek__Location__r.Name LIKE : searchLocation';
				 }
				 if (String.isNotBlank(searchCategory)){
				 searchCategory = '%' + searchCategory + '%';
				 query += ' AND buildertek__Category__r.Name LIKE : searchCategory';
				 }
				 if (String.isNotBlank(searchTradeType)){
				 searchTradeType = '%' + searchTradeType + '%';
				 query += ' AND buildertek__Trade_Type__r.Name LIKE : searchTradeType';
				 }
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
	public static String updateRecords(String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize, String productType, String searchLocation, String searchCategory, String searchTradeType){
		// try{
		if (String.isNotBlank(updatedRecords)){
			List<buildertek__Select_Sheet__c> items = (List<buildertek__Select_Sheet__c>)JSON.deserialize(updatedRecords, List<buildertek__Select_Sheet__c>.class);
			for (buildertek__Select_Sheet__c item : items){
				if (item.Id == null){
					item.buildertek__Selection_Sheet_Takeoff__c = recordId;
				}
			}
			if (items.size() > 0){
				upsert items;
			}
			return getRecords(recordId, fieldSetName, pageNumber, pageSize,productType,searchLocation,searchCategory,searchTradeType);
		}
		/*  } catch (Exception e){
		 System.debug('Error::' + e.getMessage());
		 System.debug('Error Line::' + e.getLineNumber());
		 throw new AuraHandledException(e.getMessage());
		 }*/
		return null;
	}

	@AuraEnabled
	public static String deleteProject(String deleteRecordId, String recordId, String fieldSetName, Integer pageNumber, Integer pageSize, String productType, String searchLocation, String searchCategory, String searchTradeType){
		try{
			if (String.isNotBlank(deleteRecordId)){
				delete [Select Id
				        FROM buildertek__Select_Sheet__c
				        WHERE ID = :deleteRecordId];
				return getRecords(recordId, fieldSetName, pageNumber, pageSize, productType,searchLocation,searchCategory,searchTradeType);
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}
    @AuraEnabled
    public static String DeleteMassBOMLines1(List<String> bomLineIds) {
        system.debug('bomLineIds--->'+ bomLineIds);
        List<buildertek__Select_Sheet__c> BOMLineList = [select Id, Name from buildertek__Select_Sheet__c where Id IN:bomLineIds];
        
        if(!BOMLineList.isEmpty()){
           
            Delete BOMLineList;
            return 'success';
        }else{
            return null;
        }  
    }
}