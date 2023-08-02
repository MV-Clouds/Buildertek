public with sharing class QuoteLinesController {
	@AuraEnabled
    public static SearchResult getLookupData(String strObject, String strSearch) {
        SearchResult result = new SearchResult();
        result.isSuccess = true;
        
        try {
            //strSearch = '\'*' + String.escapeSingleQuotes(strSearch) + '*\'';
            strSearch = '% LIKE '+strSearch+'% ';
            if(strObject != null && strObject.trim() != '' && Schema.getGlobalDescribe().get(strObject) != null){
                //String strQuery = 'FIND ' + strSearch + ' IN ALL FIELDS RETURNING ' + strObject + '(Id, Name)';
                String strQuery = 'SELECT Id, Name FROM '+strObject+ 'WHERE Name'+strSearch;
                
                List<SObject> searchResult = Database.query(String.escapeSingleQuotes(strQuery));
                
                if(searchResult.size() > 0) {
                    for(sObject currObj : searchResult) {
                        result.listSearchObjects.add(new SearchObject(currObj));
                    }
                }
                else {
                    result.strMessage = 'No records found!';
                }
            }
        }
        catch(Exception ex) {
            result.isSuccess = false;
            result.strMessage = ex.getMessage();
        }
        
        return result;
    }
    
    @AuraEnabled
    public static BaseData getBaseData() {
        BaseData result = new BaseData();
        result.isSuccess = true;
        
        try {
            for(Schema.PicklistEntry pickListVal : buildertek__Quote_Item__c.buildertek__UOM__c.getDescribe().getPicklistValues()) {
                result.listUOMs.add(pickListVal.getLabel());
            }
            
            for(Schema.PicklistEntry pickListVal : buildertek__Quote_Item__c.buildertek__Pricing_Method__c.getDescribe().getPicklistValues()) {
                result.listPricingMethods.add(pickListVal.getLabel());
            }
        }
        catch(Exception ex) {
            result.isSuccess = false;
            result.strMessage = ex.getMessage();
        }
        
        return result;
    }
    
    @AuraEnabled
    public static ResponseBase insertQuoteLineItem(string quoteItem) {
        ResponseBase result = new ResponseBase();
        result.isSuccess = true;
        // List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();
        // quoteItemList.add(quoteItem);
        buildertek__Quote_Item__c quoteItemRec = new buildertek__Quote_Item__c();
        quoteItemRec = (buildertek__Quote_Item__c)System.JSON.deserialize(quoteItem, buildertek__Quote_Item__c.class);
        try {
            if(Schema.sObjectType.buildertek__Quote_Item__c.isCreateable()&&
            Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable()&&
            Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable() &&
			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Vendor__c.isCreateable() &&
			Schema.sObjectType.buildertek__Quote_Item__c.fields.Product__c.isCreateable() ){
            insert quoteItemRec;
			}
        }
        catch(Exception ex) {
            result.isSuccess = false;
            result.strMessage = ex.getMessage();
        }
        
        return result;
    }
    
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
    }
    
    public class BaseData extends ResponseBase {
        @AuraEnabled public List<String> listUOMs;
        @AuraEnabled public List<String> listPricingMethods;
        @AuraEnabled public buildertek__Quote_Item__c quoteItem;
        
        public BaseData() {
            this.listUOMs = new List<String>();
            this.listPricingMethods = new List<String>();
            this.quoteItem = new buildertek__Quote_Item__c();
        }
    }
    
    /**
     *  @description Search wrapper
     */
    public class SearchResult extends ResponseBase {
        @AuraEnabled public List<SearchObject> listSearchObjects {get; set;}
        
        public SearchResult() {
            this.listSearchObjects = new List<SearchObject>();
        }
    }
    
    /**
     *  @description Search wrapper
     */
    public class SearchObject {
        @AuraEnabled public String strId {get; set;}
        @AuraEnabled public String strName {get; set;}
        
        public SearchObject(sObject currObj) {
            this.strId = currObj.Id;
            this.strName = (String) currObj.get('Name');
        }
    }
}