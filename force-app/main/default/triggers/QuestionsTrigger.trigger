trigger QuestionsTrigger on buildertek__Questions__c (before insert, after insert, before update, after update, before delete, after delete) {
    QuestionsTriggerHandler handler = new QuestionsTriggerHandler();
    
    if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
    }
}