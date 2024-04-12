public with sharing class BT_MassUpdateWalkThroughLineController {
    
    @AuraEnabled
    public static List<buildertek__Walk_Through_Line_Items__c> getWalkthroughLineItems(String walkthroughId) {
        return [SELECT Id, Name, buildertek__Area__c, buildertek__Description__c, buildertek__Details__c, buildertek__Location__c, buildertek__Notes__c, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name, buildertek__Quantity__c, buildertek__BT_Category__c, buildertek__BT_Category__r.Name FROM buildertek__Walk_Through_Line_Items__c WHERE buildertek__Walk_Through_List__c = :walkthroughId ORDER BY buildertek__BT_Category__r.Name NULLS LAST];
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
	public static String updateWalkThroughLines(List<buildertek__Walk_Through_Line_Items__c> insertWTL, List<buildertek__Walk_Through_Line_Items__c> deleteWTL){
		List<buildertek__Walk_Through_Line_Items__c> toInsert = new List<buildertek__Walk_Through_Line_Items__c>();
		List<buildertek__Walk_Through_Line_Items__c> toUpdate = new List<buildertek__Walk_Through_Line_Items__c>();
		List<buildertek__Walk_Through_Line_Items__c> toDelete = new List<buildertek__Walk_Through_Line_Items__c>();
		
		for(buildertek__Walk_Through_Line_Items__c wtl : insertWTL){
			if(wtl.Id == null){
				toInsert.add(wtl);
			} else {
				toUpdate.add(wtl);
			}
		}
		
		for(buildertek__Walk_Through_Line_Items__c wtl : deleteWTL){
			toDelete.add(wtl);
		}

		try{
			if(toInsert.size() > 0){
				insert toInsert;
			}
			if(toUpdate.size() > 0){
				update toUpdate;
			}
			if(toDelete.size() > 0){
				delete toDelete;
			}
		} catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
		return 'Success';

	}
}