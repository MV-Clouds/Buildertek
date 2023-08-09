trigger CourseSessionTrigger on buildertek__Course_Session_Scheduling__c (before insert,before delete) {
if(Trigger.isUpdate){
        CourseSessionTriggerHandler.updateParticipantsCount(Trigger.new, Trigger.OldMap);
    }
     if(Trigger.isbefore && Trigger.isDelete)
    {
        System.debug('Old trigger *******************'+Trigger.old);
     CourseSessionTriggerHandler.deleteMethod(Trigger.old); 
    }
}