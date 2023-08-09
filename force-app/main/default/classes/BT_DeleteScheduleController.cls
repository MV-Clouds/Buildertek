public with sharing class BT_DeleteScheduleController {
    @AuraEnabled
    public static void deleteScheduleRecord(String recordId){
        if(Schema.sObjectType.buildertek__Schedule__c.fields.id.isAccessible()
            && buildertek__Schedule__c.sObjectType.getDescribe().isDeletable()){
                
            buildertek__Schedule__c Schedule = [select Id from buildertek__Schedule__c where Id =: recordId];
            delete Schedule;    
        }
        
    }
}