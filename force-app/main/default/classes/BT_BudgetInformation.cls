public with sharing class BT_BudgetInformation {
     /*
     * @Created Date:- 2nd OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getBudgetInformation
     * @ReturnType : object
     * @param : budgetId
     * @Description : Get the Budget Information
    */
    
    @AuraEnabled
    public static buildertek__Budget__c getBudgetInformation(String budgetId){
        buildertek__Budget__c budget;
        if (Schema.sObjectType.buildertek__Budget__c.fields.id.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Projected_Costs__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Original_Budget__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Is_Budget_Locked__c.isAccessible()
            && Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()) {
            
            budget = [select Id, Name, buildertek__Project__c,buildertek__Project__r.Name, buildertek__Projected_Costs__c,
                                                buildertek__Original_Budget__c,buildertek__Is_Budget_Locked__c
                                                from buildertek__Budget__c where Id =: budgetId];
                 
        }
        
        return budget;                                       
    }
    
    /*
     * @Created Date:- 2nd OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : deleteBudgetRecord
     * @ReturnType : 
     * @param : budgetId
     * @Description : Delete Budget Record
    */
    @AuraEnabled
    public static void deleteBudgetRecord(String budgetId) {
        if(buildertek__Budget__c.sObjectType.getDescribe().isDeletable() 
            && Schema.sObjectType.buildertek__Budget__c.fields.id.isAccessible()){
            buildertek__Budget__c budget = [select Id from buildertek__Budget__c where Id =: budgetId];
            delete budget;    
        }
        
    }

}