public with sharing class CreatePurchaseOrderDAO {
    @AuraEnabled
    public static string createPO(String recordId){
        buildertek__Service_Request__c serviceReq;
        Account accRec = [select id,Name from Account limit 1];
        if(Schema.sObjectType.buildertek__Service_Request__c.fields.Id.isAccessible()&&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Subject__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Vendor__c.isAccessible()){ 
          serviceReq= [select Id, buildertek__Subject__c, buildertek__Project__c,buildertek__Project__r.buildertek__Customer__c,
                       buildertek__Vendor__c from buildertek__Service_Request__c where Id =: recordId];
          }
        buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
        PO.buildertek__Project__c = serviceReq.buildertek__Project__c;
        PO.buildertek__Status__c = 'New';
        PO.buildertek__Description__c = serviceReq.buildertek__Subject__c;
        if(serviceReq.buildertek__Vendor__c != null){
           PO.buildertek__Vendor__c = serviceReq.buildertek__Vendor__c; 
        }else if(serviceReq.buildertek__Project__r.buildertek__Customer__c != null){
            PO.buildertek__Vendor__c = serviceReq.buildertek__Project__r.buildertek__Customer__c;
        }else{
            PO.buildertek__Vendor__c = accRec.id;
        }
        
        if(Schema.sObjectType.buildertek__Purchase_Order__c.isCreateable()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isCreateable()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isCreateable() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isCreateable()&&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isCreateable() ){
            insert PO;
		}
        return PO.Id;    
    }
}