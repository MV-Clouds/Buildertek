public with sharing class CreateChangeOrderFromRFI {
    /*
     * @Created Date:- 16th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getProjectId
     * @ReturnType : buildertek__RFI__c
     * @param : recordId
     * @Description : Get the RFI Information based on RFI Id
    */
    @AuraEnabled
    public static buildertek__RFI__c getProjectId(String recordId){
        buildertek__RFI__c rfi;
        if (Schema.sObjectType.buildertek__RFI__c.fields.Name.isAccessible()
			&& Schema.sObjectType.buildertek__RFI__c.fields.buildertek__Project__c.isAccessible()
			&& Schema.sObjectType.buildertek__RFI__c.fields.Id.isAccessible() &&
			Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible()){
            rfi= [select Id, Name, buildertek__Project__c, buildertek__Project__r.Id from buildertek__RFI__c where Id =: recordId];
		}
        return rfi;
    }
    
    /*
     * @Created Date:- 16th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getselectOptions
     * @ReturnType : string
     * @param : changeOrderObject, changeOrderField
     * @Description : Get Picklist values of a field from a selected object
    */
    @AuraEnabled
    public static string getselectOptions(sObject changeOrderObject, string changeOrderField) {
        system.debug('changeOrderObject --->' + changeOrderObject);
        system.debug('changeOrderField --->' + changeOrderField);
        Schema.sObjectType objType = changeOrderObject.getSObjectType();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values =
        fieldMap.get(changeOrderField).getDescribe().getPickListValues();
        
        list<ChangeOrderClass> allChangeOrderOptions = new list<ChangeOrderClass>();
        integer i=1;
        for (Schema.PicklistEntry a: values) {
            ChangeOrderClass changeOrderOption = new ChangeOrderClass(); 
            changeOrderOption.label = a.getLabel();
            changeOrderOption.value = a.getValue();
            allChangeOrderOptions.add(changeOrderOption);
            i++;
        }
        String allChangeordervalues = json.serialize(allChangeOrderOptions);
        system.debug('allOpts ---->' + allChangeOrderOptions);
        //allOpts.sort();
        return allChangeordervalues;
    }
    
    /*
     * @Created Date:- 16th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : insertChangeOrder
     * @ReturnType : ErrorMessages(Inner class)
     * @param : changeOrder, name, projectId, accountPeriod, accountId
     * @Description : Insert a Change Order Record
    */
    @AuraEnabled
    public static ErrorMessages insertChangeOrder(buildertek__Change_Order__c changeOrder, String name, String projectId, String accountPeriod, String accountId){
        ErrorMessages ErrorMessagesrecord = new ErrorMessages();
        try{
            system.debug('ChangeOrder ***************' + changeOrder);
            buildertek__Change_Order__c changeOrderToCreate = new buildertek__Change_Order__c();
            changeOrderToCreate.Name = name;
            changeOrderToCreate.buildertek__Date_Approved__c = changeOrder.buildertek__Date_Approved__c;
            changeOrderToCreate.buildertek__Period__c = accountPeriod;
            changeOrderToCreate.buildertek__Status__c = changeOrder.buildertek__Status__c;
            changeOrderToCreate.buildertek__Project__c = projectId;
            changeOrderToCreate.buildertek__Tax_Rate__c = changeOrder.buildertek__Project__r.buildertek__Project_Tax_Rate__c;
            changeOrderToCreate.buildertek__Schedule_Impact_in_Days__c = changeOrder.buildertek__Schedule_Impact_in_Days__c;
            changeOrderToCreate.buildertek__Details__c = changeOrder.buildertek__Details__c;
            changeOrderToCreate.buildertek__Type__c = changeOrder.buildertek__Type__c;
            changeOrderToCreate.buildertek__Customer_Account__c = accountId;
            changeOrderToCreate.buildertek__Date_Created__c = changeOrder.buildertek__Date_Created__c;
            if(Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isCreateable()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Date_Approved__c.isCreateable()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Period__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Tax_Rate__c.isCreateable() &&
				Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Schedule_Impact_in_Days__c.isCreateable()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Details__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Type__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Customer_Account__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Date_Created__c.isCreateable() ){
                insert changeOrderToCreate;
    			}
            ErrorMessagesrecord.recordId = changeOrderToCreate.Id;
            ErrorMessagesrecord.recordName = changeOrderToCreate.Name;
            ErrorMessagesrecord.status = 'Success';
            ErrorMessagesrecord.Message = 'Change Order Created Successfully';
            
        }
        catch(exception e){
            ErrorMessagesrecord.status = 'Error';
            ErrorMessagesrecord.Message = e.getMessage(); 
        }
        system.debug('ErrorMessagesrecord --> '+ErrorMessagesrecord);
        return ErrorMessagesrecord;
    }
    
    /*
     * @Created Date:- 16th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Description : Wrapper Class to Display Error and Success Messages
    */
    public class ErrorMessages{
        @AuraEnabled
        public String recordId { get;set; }
        @AuraEnabled
        public String recordName { get;set; }
        @AuraEnabled
        public String status { get;set; }
        @AuraEnabled
        public string Message { get;set; }
    }
    
    /*
     * @Created Date:- 16th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Description : Wrapper Class to Display the picklist values
    */
    public Class ChangeOrderClass{
        @AuraEnabled public String label{get;set;}
        @AuraEnabled public String value{get;set;}
    }
}