trigger TakeOffLineTrigger on Buildertek__Project_Takeoff_Lines__c (after update, after insert) {

    public static Boolean hasEntered = false;

    if(!hasEntered) {

        if(Trigger.isBefore) {

        }
        else {

            if(!hasEntered ) {

                if(Trigger.isUpdate) {
                    TakeOffLineTriggerHandler.handleFieldChanges(Trigger.oldMap, Trigger.newMap);
                }

                hasEntered = true;
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        TakeOffLineTriggerHandler.afterInsert(Trigger.oldMap, Trigger.newMap);
    }
   // if(Trigger.isAfter && Trigger.isUpdate){
     //   TakeOffLineTriggerHandler.afterUpdate(Trigger.oldMap, Trigger.newMap,Trigger.old, Trigger.new);
   // }
}