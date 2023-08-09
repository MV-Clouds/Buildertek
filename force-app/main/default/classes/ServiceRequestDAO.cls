public with sharing class ServiceRequestDAO {
    @AuraEnabled
    public static ErrorClass createServiceRequest(String recordId){
        ErrorClass err = new ErrorClass();
        try{
            buildertek__Warranty_Item__c warrantyItem ;
            if(Schema.sObjectType.buildertek__Warranty_Item__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Warranty_Item__c.fields.buildertek__Description__c.isAccessible()&&
            Schema.sObjectType.buildertek__Warranty_Item__c.fields.buildertek__Project__c.isAccessible()&&
            Schema.sObjectType.buildertek__Warranty_Item__c.fields.buildertek__Contractor_Resource__c.isAccessible()){
             warrantyItem = [select Id, buildertek__Description__c, buildertek__Project__c, buildertek__Contractor_Resource__c from buildertek__Warranty_Item__c where Id =: recordId];
            }
            RecordType RT;
            if(Schema.sObjectType.RecordType.fields.Id.isAccessible()&&
            Schema.sObjectType.RecordType.fields.Name.isAccessible()&&
            Schema.sObjectType.RecordType.fields.sObjectType.isAccessible()  ){
            RT = [select Id, Name from RecordType where Name = 'Estimate'];
            }
            buildertek__Service_Request__c serviceReq = new buildertek__Service_Request__c();
            serviceReq.RecordTypeId = RT.Id;
            serviceReq.buildertek__Project__c = warrantyItem.buildertek__Project__c;
            serviceReq.buildertek__Request_Status__c = 'New';
            serviceReq.buildertek__Subject__c = warrantyItem.buildertek__Description__c;
            serviceReq.buildertek__Warranty_Item__c = recordId;
            serviceReq.buildertek__Customer_Name__c = warrantyItem.buildertek__Contractor_Resource__c;
            if (Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Customer_Name__c.isCreateable() && Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Request_Status__c.isCreateable()&&
                Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Warranty_Item__c.isCreateable() && Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isCreateable()&&
                Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Subject__c.isCreateable() && Schema.sObjectType.buildertek__Service_Request__c.fields.RecordTypeId.isCreateable()) {
                insert serviceReq;
                }
            err.Message = 'Success';
            err.RecordId = serviceReq.Id;
            return err;     
        }catch(Exception exp){
            err.Message = exp.getMessage();
            err.RecordId = '';
            return err;
        }
        
    }
    
    @AuraEnabled
    public static ErrorClass createServiceRequestFromIssue(String recordId){
        ErrorClass err = new ErrorClass();
        try{
             buildertek__Issue_Logs__c  issueLogs;
            if(Schema.sObjectType.buildertek__Issue_Logs__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Issue_Logs__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Issue_Logs__c.fields.buildertek__Description_of_the_Issue__c.isAccessible()&&
            Schema.sObjectType.buildertek__Issue_Logs__c.fields.buildertek__Project__c.isAccessible()&& 
            Schema.sObjectType.buildertek__Issue_Logs__c.fields.buildertek__Owner_of_the_Issue__c.isAccessible()){
            issueLogs = [select Id, Name, buildertek__Description_of_the_Issue__c, buildertek__Project__c, buildertek__Owner_of_the_Issue__c from buildertek__Issue_Logs__c where Id =: recordId];
            }
            RecordType RT ;
            if(Schema.sObjectType.RecordType.fields.Id.isAccessible()&&
            Schema.sObjectType.RecordType.fields.Name.isAccessible()&&
            Schema.sObjectType.RecordType.fields.sObjectType.isAccessible()  ){
            RT= [select Id, Name from RecordType where Name = 'Estimate'];
            }
            buildertek__Service_Request__c serviceReq = new buildertek__Service_Request__c();
            serviceReq.RecordTypeId = RT.Id;
            serviceReq.buildertek__Project__c = issueLogs.buildertek__Project__c;
            serviceReq.buildertek__Request_Status__c = 'New';
            serviceReq.buildertek__Subject__c = issueLogs.buildertek__Description_of_the_Issue__c;
            serviceReq.buildertek__Issues__c = recordId;
            serviceReq.buildertek__Customer_Name__c = issueLogs.buildertek__Owner_of_the_Issue__c;
            if (Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Customer_Name__c.isCreateable() && Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Request_Status__c.isCreateable()&&
                Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Issues__c.isCreateable() && Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isCreateable()&&
                Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Subject__c.isCreateable() && Schema.sObjectType.buildertek__Service_Request__c.fields.RecordTypeId.isCreateable()) {
                    // List<buildertek__Service_Request__c> serreq = [Select id, buildertek__Issues__c From buildertek__Service_Request__c Where buildertek__Issues__c =: recordId];
                    // if (!serreq.isEmpty()) {
                    //     err.Message = 'Cannot Create the Service Request';
                    //     err.RecordId = '';
                    // }
                    // else {
                        insert serviceReq;
                        // err.Message = 'Success';
                        // err.RecordId = serviceReq.Id;
                        
                    // }
                
            }
            err.Message = 'Success';
            err.RecordId = serviceReq.Id;
            return err;    
        }catch(Exception exp){
            err.Message = exp.getMessage();
            err.RecordId = '';
            return err;
        }
        
    }
    
    public class ErrorClass{
        @AuraEnabled public String Message { get; set; }
        @AuraEnabled public String RecordId { get; set; }
    }
    
}