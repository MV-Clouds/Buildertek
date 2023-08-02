public with sharing class EditScheduleController {
    @AuraEnabled
    public static buildertek__Schedule__c getScheduleDetails(String recordId){
        buildertek__Schedule__c schedule;
        if (Schema.sObjectType.buildertek__Schedule__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Schedule__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Description__c.isAccessible()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Complete__c.isAccessible()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Start_Date__c.isAccessible()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Days_Completed__c.isAccessible() 
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__End_Date__c.isAccessible()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Total_Duration__c.isAccessible() 
             && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Contractor__c.isAccessible()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Type__c.isAccessible()) {
            schedule   = [SELECT Id,
                           Name,
                           buildertek__Description__c,
                           buildertek__Complete__c,
                           buildertek__Start_Date__c,
                           buildertek__Days_Completed__c,
                           buildertek__End_Date__c,
                           buildertek__Total_Duration__c,
                           buildertek__Contractor__c,
                           buildertek__Type__c
                           FROM buildertek__Schedule__c
                           WHERE Id =: recordId];
            }                                   
       return schedule;                                              
    }
    
    @AuraEnabled
    public static buildertek__Schedule__c updateSchedule(buildertek__Schedule__c scheduleRecord, String accountId) {
        buildertek__Schedule__c sch = new buildertek__Schedule__c();
        if (Schema.sObjectType.buildertek__Schedule__c.fields.Id.isUpdateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Days_Completed__c.isCreateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Type__c.isCreateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Description__c.isCreateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Contractor__c.isCreateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Days_Completed__c.isUpdateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Type__c.isUpdateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Description__c.isUpdateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Contractor__c.isUpdateable()) {
                    
            if(scheduleRecord.Id != null){
                sch.Id = scheduleRecord.Id;
                sch.buildertek__Days_Completed__c = scheduleRecord.buildertek__Days_Completed__c;
                sch.buildertek__Type__c = scheduleRecord.buildertek__Type__c;
                sch.buildertek__Description__c = scheduleRecord.buildertek__Description__c;
                sch.buildertek__Contractor__c = accountId; 
                update sch;    
            }else{
                sch.buildertek__Days_Completed__c = scheduleRecord.buildertek__Days_Completed__c;
                sch.buildertek__Type__c = scheduleRecord.buildertek__Type__c;
                sch.buildertek__Description__c = scheduleRecord.buildertek__Description__c;
                sch.buildertek__Contractor__c = accountId; 
                insert sch;    
            }    
        }        
        
        
        return sch;
    }
    
    @AuraEnabled
    public static buildertek__Schedule__c insertSchedule(buildertek__Schedule__c scheduleRecord, String accountId) {
        buildertek__Schedule__c sch = new buildertek__Schedule__c();
        if (Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Days_Completed__c.isCreateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Type__c.isCreateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Description__c.isCreateable()
            && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Contractor__c.isCreateable()) {
            
            sch.buildertek__Days_Completed__c = scheduleRecord.buildertek__Days_Completed__c;
            sch.buildertek__Type__c = scheduleRecord.buildertek__Type__c;
            sch.buildertek__Description__c = scheduleRecord.buildertek__Description__c;
            sch.buildertek__Contractor__c = accountId; 
            insert sch;    
        }
        return sch;
    }
}