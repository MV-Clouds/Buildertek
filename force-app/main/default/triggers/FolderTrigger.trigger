/*
*   Executed:   After Insert, Before Update
*   Purpose:    When Folder created Amazon Folder path will be setted for it using the parent foldrs Amazon Foldr Path.
*/
    
trigger FolderTrigger on Folder__c (before insert, after insert, before update, after update, before delete) {
    if(!BT_Utils.isTriggerDeactivate('Folder__c')){
        FolderTriggerHandler objFolderTriggerHandler = new FolderTriggerHandler();
        if (Trigger.isInsert && Trigger.isBefore) {
            objFolderTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isInsert && Trigger.isAfter){
            objFolderTriggerHandler.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate && Trigger.isBefore){
            objFolderTriggerHandler.onBeforeUpdate(Trigger.newMap,Trigger.oldMap);
        } else if (Trigger.isUpdate && Trigger.isAfter){
            objFolderTriggerHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
        } else if (Trigger.isDelete && Trigger.isBefore) {
            objFolderTriggerHandler.onBeforeDelete(Trigger.oldMap);
        }
    }
}