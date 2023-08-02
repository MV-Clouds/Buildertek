public with sharing class CloneMasterBudgetController {
    @AuraEnabled
    public static String getUserTimeZone(){
         User currentUser ;
        if(Schema.sObjectType.User.fields.Id.isAccessible()&&
            Schema.sObjectType.User.fields.TimeZoneSidKey.isAccessible()){
             currentUser = [Select TimeZoneSidKey from User where id =: USerInfo.getUserId()];
            }
        return currentUser.TimeZoneSidKey;
    }
    @AuraEnabled
    public static MasterBudgetClass getMasterData(String recordId){
        buildertek__Master_Budget__c masterBudget;
        if(Schema.sObjectType.buildertek__Master_Budget__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Is_Budget_Locked__c.isAccessible() &&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Budget__c.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Total_Budget_Price__c.isAccessible() &&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Type__c.isAccessible() &&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.OwnerId.isAccessible()){
                                masterBudget= [SELECT Id, 
                                            Name,
                                            buildertek__Is_Budget_Locked__c,
                                            buildertek__Budget__c,
                                            buildertek__Type__c,
                                            buildertek__Total_Budget_Price__c,
                                            Owner.Name,
                                            CreatedBy.Name,
                                            LastModifiedBy.Name,
                                            CreatedDate,
                                            LastModifiedDate
                                            FROM buildertek__Master_Budget__c
                                            WHERE Id =: recordId];
        }
        Schema.DescribeSObjectResult r = buildertek__Master_Budget_Line__c.sObjectType.getDescribe();
        String apiNames = '';
        for(string apiName : r.fields.getMap().keySet()){
           apiNames += apiName +','; 
        }
        apiNames = apiNames.removeEnd(',');
        System.debug(apiNames);
        string query = 'SELECT '+apiNames+ ' FROM buildertek__Master_Budget_Line__c WHERE buildertek__Master_Budget__c =: recordId';
        system.debug('query -------------> '+query);
        List<buildertek__Master_Budget_Line__c> masterBudgetLineList;
         /* if(Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Id.isAccessible()&&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Amount_In__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Budget_Item_Name__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Contractor__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Cost_Code__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Description__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Forecast_To_Complete__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Group__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Group_Name__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget_Item_Group__c.isAccessible() &&
		     Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget_Item__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget_Item_Number__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Original_Budget__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Product__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Quantity__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Trade_Type__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Unit_Price__c.isAccessible() &&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__UOM__c.isAccessible() ){ */
            masterBudgetLineList = Database.query(String.escapeSingleQuotes(query));
             /*}*/
        MasterBudgetClass MBClass = new MasterBudgetClass();
        MBClass.masterBudgetRecord = masterBudget;
        MBClass.masterBudgetLineRecord = masterBudgetLineList;
        return  MBClass;                                                   
        
    }
    
    @AuraEnabled
    public static Map<String, String> getselectOptions(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = buildertek__Master_Budget__c.buildertek__Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static buildertek__Master_Budget__c saveMasterBudget(buildertek__Master_Budget__c masterBudgetRecord, List<buildertek__Master_Budget_Line__c> masterBudgetLines){
        system.debug('masterBudgetRecord ---------> '+masterBudgetRecord);
        system.debug('masterBudgetLines ---------> '+masterBudgetLines);
        buildertek__Master_Budget__c mb = new buildertek__Master_Budget__c();
        mb.Name = masterBudgetRecord.Name;
        mb.buildertek__Is_Budget_Locked__c = masterBudgetRecord.buildertek__Is_Budget_Locked__c;
        mb.buildertek__Type__c = masterBudgetRecord.buildertek__Type__c;
        if(Schema.sObjectType.buildertek__Master_Budget__c.isCreateable()&&
                Schema.sObjectType.buildertek__Master_Budget__c.fields.Name.isCreateable()&&
                Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Is_Budget_Locked__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Type__c.isCreateable() ){ 
                insert mb; 
    			}
        List<buildertek__Master_Budget_Line__c> masterBudgetLinesToInsert = masterBudgetLines.deepclone();
        for(buildertek__Master_Budget_Line__c msBudgets : masterBudgetLinesToInsert){
            if(Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget__c.isCreateable()){
                msBudgets.buildertek__Master_Budget__c = mb.Id;  
            } 
        }
        insert masterBudgetLinesToInsert;
        return mb;
    }
    
    public class MasterBudgetClass{
        @AuraEnabled public buildertek__Master_Budget__c masterBudgetRecord;
        @AuraEnabled public List<buildertek__Master_Budget_Line__c> masterBudgetLineRecord;
    }
}