public with sharing class New_WTLine_Controller {
    public New_WTLine_Controller() {

    }

    @AuraEnabled
    public static List<RecordType> getRecordType(String ObjectAPIName) {
        System.debug('ObjectAPIName: ' + ObjectAPIName);
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = :ObjectAPIName];
        System.debug('recordTypes: ' + recordTypes);
        return recordTypes;
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
	//saveData
	public static String saveData(buildertek__Walk_Through_Line_Items__c allData ){
		String result = '';
		try{
			insert allData;
			result = 'Record Inserted Successfully';
		} catch (Exception e){
			result = e.getMessage();
			throw new AuraHandledException(e.getMessage());
		}
		return result;
	}

    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }

    @AuraEnabled
    public static List<pricebookWrapper> getPricebookList(string recordId){
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();
        
        pricebookWrapper priceWrap = new pricebookWrapper();
        priceWrap.defaultValue= new pricebook2();
        priceWrap.priceWrapList = new List<pricebook2>();
        List<pricebook2> PriceList = [SELECT Id, Name FROM pricebook2 ORDER BY Name ASC ];
        priceWrap.priceWrapList=PriceList;
        
        if(PriceList.size() > 0){
            if(recordId != null){
                buildertek__Walk_Through_List__c walkThroughList = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Walk_Through_List__c  WHERE Id = :recordId];
                if(walkThroughList.buildertek__Project__c != null && walkThroughList.buildertek__Project__r.buildertek__Price_Book__c !=null){
                    pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:walkThroughList.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                    if(selectedPriceList != null){
                        priceWrap.defaultValue= selectedPriceList;
                    }
                    else{
                        priceWrap.defaultValue = PriceList[0];
                    }
                }
                else{
                    priceWrap.defaultValue = PriceList[0];
                }
            }
        }

        priceWrapper.add(priceWrap);
        return priceWrapper;
    }

	@AuraEnabled
    public static List<String> getProductFamily(String pbookId){
        try {

            List<PriceBookEntry> pEntries2 = [SELECT Id,Product2Id, toLabel(Product2.Family), 
                                            Product2.IsActive, Pricebook2.Name  //----
                                            FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND Product2.Family != null AND IsActive = True 
                                            ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 50000];

            Set<String> ProductfamilySet = new Set<String>();
            for(PriceBookEntry PE : pEntries2){
                if(PE.Product2.Family != null){
                    ProductfamilySet.add(PE.Product2.Family);
                }
            }

            return new List<String>(ProductfamilySet);
            
        } catch (Exception e) {
            System.debug('Exception in getProductFamily : '+ e.getMessage());
            return null;
        }
    }
}