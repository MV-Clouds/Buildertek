public with sharing class AddExistingBudgetController {
    @AuraEnabled
    public static BudgetInnerClass getContractDetails(string contractId, string Objects, string sObjectFields){
        string query = 'SELECT ';
        integer i=1;
        String[] Fieldslist = sObjectFields.split(',');
        for(string Fields : sObjectFields.split(',')){
            query += Fields;
            integer FieldsSize = (sObjectFields.split(',')).size();
            system.debug(i + ' sObjectFields. ' + FieldsSize);
            if(i < FieldsSize ){
               query += ','; 
            }
            i = i+1;
        }
        
        query += ' FROM ' + Objects + ' WHERE Id =: contractId';
        
        SObject buildertekContract = Database.query(String.escapeSingleQuotes(query));
        system.debug('buildertekContract ****'+ buildertekContract);
        BudgetInnerClass BudgetInnerClassRecord = new BudgetInnerClass();
        BudgetInnerClassRecord.Name = String.valueOf(buildertekContract.get('Name'));
        BudgetInnerClassRecord.Amount = integer.valueOf(buildertekContract.get(Fieldslist[2]));
        system.debug('BudgetInnerClassRecord ****'+ BudgetInnerClassRecord);
        return BudgetInnerClassRecord;
    }
    
    @AuraEnabled
    public static ErrorMessages updateBudgetItemRecordMethod(buildertek__Budget_Item__c BudgetItems){
        ErrorMessages ErrorMessagesrecord = new ErrorMessages();
        try{
            system.debug('BudgetItems ***************' + BudgetItems);
            string groupId;
            if(BudgetItems.buildertek__Budget_Line_Group__c == null){
                List<buildertek__Quote_Line_Group__c> budgetGroup;
                if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                    budgetGroup = [SELECT Id FROM buildertek__Quote_Line_Group__c WHERE Name = 'No Grouping'];     
                }
                if(budgetGroup.size() > 0){
                    groupId = budgetGroup[0].Id;   
                }else{
                    buildertek__Quote_Line_Group__c budGroup = new buildertek__Quote_Line_Group__c();
                    if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                        budGroup.Name = 'No Grouping';    
                    }
                    insert budGroup;
                    groupId = budGroup.Id;
                }
            }else{
                groupId = BudgetItems.buildertek__Budget_Line_Group__c;
            }
            buildertek__Budget_Item__c BudgetLineToInsert = new buildertek__Budget_Item__c();
            if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isCreateable()
                && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget_Line_Group__c.isCreateable()
                && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isCreateable()
                && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isCreateable()
                && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isCreateable()
                && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Description__c.isCreateable()) {
                
                BudgetLineToInsert.Name = BudgetItems.buildertek__Description__c;
                BudgetLineToInsert.buildertek__Budget_Line_Group__c = groupId;
                BudgetLineToInsert.buildertek__Unit_Price__c = BudgetItems.buildertek__Unit_Price__c;
                BudgetLineToInsert.buildertek__Quantity__c = BudgetItems.buildertek__Quantity__c;
                BudgetLineToInsert.buildertek__Budget__c = BudgetItems.buildertek__Budget__c;
                BudgetLineToInsert.buildertek__Description__c = BudgetLineToInsert.buildertek__Description__c;    
            }
            
            insert BudgetLineToInsert;
            ErrorMessagesrecord.status = 'Success';
            ErrorMessagesrecord.Message = 'Budget Item Inserted Successfully';
            
        }
        catch(exception e){
            ErrorMessagesrecord.status = 'Error';
            ErrorMessagesrecord.Message = e.getMessage(); 
        }
        return ErrorMessagesrecord;
    }
    
    public Class BudgetInnerClass{
        @AuraEnabled
        public String Name { get;set; }
        @AuraEnabled
        public integer Amount { get;set; }
    }
    
    public class ErrorMessages{
        @AuraEnabled
        public String status { get;set; }
        @AuraEnabled
        public string Message { get;set; }
    }
}