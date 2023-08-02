public with sharing class NewVendorController{
    @AuraEnabled
	public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
	@AuraEnabled
	public static String getFieldSet(){
		String result = '';
		List<String> pickListValuesList = new List<String>();
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Vendor_Review__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey('buildertek__VendorFields')){
				for (Schema.FieldSetMember f : FsMap.get('buildertek__VendorFields').getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					jsonPart += '"name":"' + f.getFieldPath()+'"';
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown('buildertek__Vendor_Review__c', String.valueOf(f.getFieldPath()));
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
	public static Map<Id, String> getNames(String RecordId){
		Map<Id, String> poNames= new Map<Id, String>();

        buildertek__Purchase_Order__c purchaseRec = [select id,Name,buildertek__Vendor__c , buildertek__Project__c from buildertek__Purchase_Order__c where id =: RecordId];
		poNames.put(purchaseRec.buildertek__Vendor__c , 'Vendor');
		poNames.put(purchaseRec.buildertek__Project__c , 'Project');
        return poNames;
    }
	@AuraEnabled
    public static String saveRecord(String vendorReviewData){
        buildertek__Vendor_Review__c vendorReview = (buildertek__Vendor_Review__c)JSON.deserialize(vendorReviewData, buildertek__Vendor_Review__c.class);
        insert vendorReview;
        return vendorReview.Id;
    }

	
   /* @AuraEnabled
    public static  buildertek__Purchase_Order__c Name(buildertek__Purchase_Order__c field)
    { 
        system.debug('vemdor-->'+vemdor);
        if(vemdor != null){
            insert vemdor;
        }
        return vemdor;
    }  */
}