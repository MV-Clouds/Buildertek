public with sharing class NewWarrantyRecordController{
	@AuraEnabled
	public static String getBudgetNameFromProject(String recordId){
		try{
			if (String.isNotBlank(recordId)){

				buildertek__Budget__c budgetName = [SELECT Id, Name, buildertek__Project__c
				                                    FROM buildertek__Budget__c
				                                    WHERE buildertek__Project__c = :recordId
				                                    ORDER BY CreatedDate DESC Limit 1];
				return budgetName.Id;

			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}
    @AuraEnabled
	public static list<WarrantryWrapper> warrantydetails(String projectrecId){
        list<WarrantryWrapper> WarrantryWrapperList = new list<WarrantryWrapper>();
        
        List<id> assosiatedWarrentyIds = new list<id>();
		list<buildertek__Warranty__c> allwarranties = [select id,buildertek__Parent_Warranty__c from buildertek__Warranty__c where buildertek__Project__c =: projectrecId];
		for(buildertek__Warranty__c wrec :allwarranties ){
			assosiatedWarrentyIds.add(wrec.buildertek__Parent_Warranty__c);
		}
        
        list<buildertek__Warranty__c> warrantylist = [select id,Name,buildertek__Project__c,buildertek__Status__c,buildertek__Warranty__c,buildertek__Description__c from buildertek__Warranty__c
                                                      where buildertek__Project__c =: projectrecId and Id NOT IN:assosiatedWarrentyIds];
		if (warrantylist.size() > 0){
            for(buildertek__Warranty__c wRec : warrantylist){
                WarrantryWrapper wrap = new WarrantryWrapper();
                wrap.WarrantyRec = wRec;
                wrap.selectedWarranty = false;
                WarrantryWrapperList.add(wrap);
            }
            system.debug('@@'+WarrantryWrapperList);
			return WarrantryWrapperList;
		}
        
		return WarrantryWrapperList;
	}
    Public class WarrantryWrapper{
        @AuraEnabled
        Public buildertek__Warranty__c WarrantyRec {get;set;}
        @AuraEnabled
        Public Integer LagValue {get;set;}
        @AuraEnabled
        Public Boolean selectedWarranty {get;set;}
       
      }
    @AuraEnabled
	public static buildertek__Warranty__c getwarrantyRec(String warrantyvalue, Integer lagvalue){
        system.debug('warrantyvalue'+warrantyvalue);
        system.debug('lagvalue'+lagvalue);
        buildertek__Warranty__c warrantyRec = [select id,Name,buildertek__Project__c,buildertek__Status__c,buildertek__Effective_Date__c,
                                               buildertek__Warranty__c,buildertek__Description__c,buildertek__Due_Date__c,buildertek__Instructions__c,buildertek__Length_of_Warranty__c,
                                               buildertek__Locked__c,buildertek__Type__c,buildertek__Warranty_Number__c,buildertek__Warranty_Manager__c,buildertek__Lag_Value__c
                                               from buildertek__Warranty__c where Id =: warrantyvalue];
        warrantyRec.buildertek__Lag_Value__c = lagvalue;
        system.debug('******'+warrantyRec + '&&&&&'+  warrantyRec.buildertek__Lag_Value__c);
        Update warrantyRec;
		return warrantyRec;
	}
    @AuraEnabled
	public static void  newWarranty(String warrantyId, String selectedwarrantyId){
        
        if(selectedwarrantyId != null){
        buildertek__Warranty__c selectedwarrantyRec = [select id,Name,buildertek__Project__c,buildertek__Effective_Date__c,
                                               buildertek__Warranty__c,buildertek__Due_Date__c,buildertek__Length_of_Warranty__c,buildertek__Lag_Value__c
                                               from buildertek__Warranty__c where Id =: selectedwarrantyId];
        selectedwarrantyRec.buildertek__Warranty__c = warrantyId;
        Update selectedwarrantyRec;
        }
        
        buildertek__Warranty__c warrantyRec = [select id,Name,buildertek__Project__c,buildertek__Effective_Date__c,
                                               buildertek__Warranty__c,buildertek__Due_Date__c,buildertek__Length_of_Warranty__c/*,buildertek__Previous_Warranty__c*/
                                               from buildertek__Warranty__c where Id =: warrantyId];
       //warrantyRec.buildertek__Previous_Warranty__c = selectedwarrantyId;
        system.debug(warrantyRec);
		system.debug(warrantyRec.buildertek__Effective_Date__c + '********************' + warrantyRec.buildertek__Length_of_Warranty__c );
        if(warrantyRec.buildertek__Length_of_Warranty__c.contains('month') || warrantyRec.buildertek__Length_of_Warranty__c.contains('months')){
            List<string> s = warrantyRec.buildertek__Length_of_Warranty__c.split(' ');
            integer addingDays = integer.valueOf(s[0]) * 30;
            warrantyRec.buildertek__Due_Date__c = warrantyRec.buildertek__Effective_Date__c.adddays(addingDays);
        }
        if(warrantyRec.buildertek__Length_of_Warranty__c.contains('year') || warrantyRec.buildertek__Length_of_Warranty__c.contains('years')){
            List<string> s = warrantyRec.buildertek__Length_of_Warranty__c.split(' ');
            integer addingDays = integer.valueOf(s[0]) * 365;
            warrantyRec.buildertek__Due_Date__c = warrantyRec.buildertek__Effective_Date__c.adddays(addingDays);
        }
        Update warrantyRec;
	}
    
	@AuraEnabled
	public static String getFieldSet(String objectName, String fieldSetName){
		String result = '';
		List<String> pickListValuesList = new List<String>();
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
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
						pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					jsonPart += '}';
					result += jsonPart;
				}
			}

		} catch (Exception e){
			result += e.getLineNumber()+' : ' + e.getMessage();
			System.debug('Error::' + e.getMessage());
			System.debug('Error At Line::' + e.getLineNumber());
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
    public static buildertek__Project__c getNames(String parentrecordid){
       buildertek__Project__c projRec = [select id,Name,buildertek__Customer__c,buildertek__Estimated_Completion_Date__c from buildertek__Project__c  where id =: parentrecordid];
        return projRec;
   } 
    @AuraEnabled
      public Static LookupWrapper getParentObjRec(string parentrecordid){
          Id recordid = parentrecordid;
          string sObjName = recordid.getSObjectType().getDescribe().getName();
          string  Query;
          Query = 'select Id, Name from ' +sObjName +' where Id=:recordid';  
          SObject ObjectRec = Database.query(Query);
          LookupWrapper NewWrapperRec = new LookupWrapper();
          NewWrapperRec.LookupRec = ObjectRec;
          NewWrapperRec.ObjectName = sObjName;
          return NewWrapperRec;
      }
      Public class LookupWrapper{
        @AuraEnabled
        Public SObject LookupRec {get;set;}
        @AuraEnabled
        Public String ObjectName {get;set;}
       
      }
}