trigger ParticipantsTrigger on buildertek__Session_Participant__c (after insert,after delete,after update) {  
    if(Trigger.isInsert && Trigger.isAfter){
        ParticipantsCount.calculateCourseParticipants(Trigger.new,null,null);
    } 
    
    if(Trigger.isUpdate){
        ParticipantsCount.updateParticipants(Trigger.new, Trigger.OldMap);
    }
    
    if(Trigger.isDelete && Trigger.isAfter){
       ParticipantsCount.deleteParticipants(Trigger.old);
    } 
    
         
}