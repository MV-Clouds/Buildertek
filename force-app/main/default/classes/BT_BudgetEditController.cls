public with sharing class BT_BudgetEditController {
    /*
     * @Created Date:- 1st OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : editBudget
     * @ReturnType : buildertek__Budget__c
     * @param : budgetId
     * @Description : Get the Budget Information based on Budget Id
    */
    @AuraEnabled
    public static buildertek__Budget__c editBudget(String budgetId){
        buildertek__Budget__c budget;
        if (Schema.sObjectType.buildertek__Budget__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Is_Budget_Locked__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Budget__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Original_Budget__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Type__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Pending_CO__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Total_CO__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Approved_CO__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Committed_Costs__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Direct_Costs__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Pending_Cost_Changes__c.isAccessible()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Projected_Costs__c.isAccessible()
            && Schema.sObjectType.User.fields.Name.isAccessible() 
            && Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()) {
                
            budget = [select Id, Name, buildertek__Budget__c, buildertek__Project__r.Name,
                                                buildertek__Is_Budget_Locked__c, buildertek__Original_Budget__c,
                                                buildertek__Type__c, buildertek__Pending_CO__c, buildertek__Total_CO__c,
                                                buildertek__Approved_CO__c, buildertek__Committed_Costs__c,
                                                buildertek__Direct_Costs__c, buildertek__Pending_Cost_Changes__c,
                                                buildertek__Projected_Costs__c, CreatedBy.Name, LastModifiedBy.Name
                                                from buildertek__Budget__c where Id =: budgetId];      
            
        }
        
        return budget;                                      
    }
    
    /*
     * @Created Date:- 1st OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getTypeOptions
     * @ReturnType : buildertek__Budget__c
     * @param : budget,field
     * @Description : Get the buildertek__Type__c picklist values
    */
    @AuraEnabled
    public static string getTypeOptions(string budget, string field) { 
        Schema.sObjectType objType = Schema.getGlobalDescribe().get(budget);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe(); // Describe the SObject using its object type.
        map< String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap(); // Get a map of fields for the SObject
        list< Schema.PicklistEntry > values = fieldMap.get(field).getDescribe().getPickListValues(); // Get the list of picklist values for this field.
        list<TypeClass> typeOptionsList = new list<TypeClass>();
        integer i=1;
        for (Schema.PicklistEntry a: values) {
            TypeClass typeOptions = new TypeClass(); 
            typeOptions.label = a.getLabel();
            typeOptions.value = a.getValue();
            typeOptionsList.add(typeOptions);
            i++;
        }
        String Allvalues = json.serialize(typeOptionsList);
        system.debug('typeOptionsList ---->' + typeOptionsList);
        //allOpts.sort();
        return Allvalues;
    }
    
    /*
     * @Created Date:- 1st OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : updateBudgetInformation 
     * @ReturnType : void
     * @param : budgetId
     * @Description : Update Budget Information
    */
    @AuraEnabled 
    public static void updateBudgetInformation(sObject budget){
        
       system.debug('budgetId --> '+budget);
        //buildertek__Budget__c budget = new buildertek__Budget__c();
        //budget.Id = budgetId;
       /* budget.Name = budgetName;
        budget.buildertek__Project__c = lookupValue;
        budget.buildertek__Type__c = type;
        budget.buildertek__Is_Budget_Locked__c = isLocked;*/
        if (Schema.sObjectType.buildertek__Budget__c.fields.id.isUpdateable()
            && Schema.sObjectType.buildertek__Budget__c.fields.Name.isUpdateable()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isUpdateable()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Type__c.isUpdateable()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Is_Budget_Locked__c.isUpdateable()) {
            
            update budget;
            
        }
        
    }
    
    public Class TypeClass{
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }
    }
}