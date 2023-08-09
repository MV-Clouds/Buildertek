trigger QuestionTrigger on buildertek__Question__c (before insert, after insert, before update, after update, before delete, after delete) {
    if(!BT_Utils.isTriggerDeactivate('Question__c')){
        
        QuestionTriggerHandler handler = new QuestionTriggerHandler (Trigger.isExecuting, Trigger.size);
    
        if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        } 
         
        else if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
        }
        
        else if(Trigger.isUpdate && Trigger.isBefore && QuestionTriggerHandler.firstRun == true){
            QuestionTriggerHandler.firstRun = false;
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap , Trigger.oldMap);
        }
        
        else if(Trigger.isUpdate && Trigger.isAfter ){
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
        }
        
        else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
        }
        
        else if(Trigger.isDelete && Trigger.isAfter){
            handler.OnAfterDelete(Trigger.old); 
        }
    }
}