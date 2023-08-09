public with sharing class newServiceRequest{
    public buildertek__service_request__c newSR {get;set;}
    public contact newContact {get;set;}
    public boolean isNewSRCreated {get;set;}
    
    public newServiceRequest(){
        isNewSRCreated  = false;
        newSR = new buildertek__service_request__c ();
        newContact = new contact ();
    }
    
    
    public void saveNewSR(){
        if(Schema.sObjectType.contact.isCreateable() &&
         Schema.sObjectType.contact.fields.Name.isCreateable()){
        insert newContact;
        }
        
        RecordType rt;
        if(Schema.sObjectType.RecordType.fields.Id.isAccessible()
            && Schema.sObjectType.RecordType.fields.developerName.isAccessible()){
            rt = [Select Id from recordType where developerName = 'Work_Order'];
            }
            newSR.buildertek__Customer_Name__c = newContact.Id;
            newSR.RecordTypeId = rt.Id;
        
         if(Schema.sObjectType.buildertek__service_request__c.fields.buildertek__Customer_Name__c.isCreateable() 
            && Schema.sObjectType.buildertek__service_request__c.fields.RecordTypeId.isCreateable()){
           insert newSR;
        }
        isNewSRCreated  = true;
    }

}