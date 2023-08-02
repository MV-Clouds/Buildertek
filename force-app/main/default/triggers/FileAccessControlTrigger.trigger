/*
*   Executed:   After insert, delete and update
*   Purpose:    When any file access control record gets created gratee will get the access for that. We will create share for grantee.
*               On delete we will delete that share record.
*/
trigger FileAccessControlTrigger on File_Access_Control__c (after delete, after insert, after update) {
    if(!BT_Utils.isTriggerDeactivate('File_Access_Control__c')){
        FileAccessControlTriggerHandler objFileAccessControlTriggerHandler = new FileAccessControlTriggerHandler();
        if (Trigger.isInsert && Trigger.isAfter) {
            objFileAccessControlTriggerHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate && Trigger.isAfter) {
            objFileAccessControlTriggerHandler.onAfterUpdate(Trigger.new, Trigger.old);
        }
        if (Trigger.isDelete && Trigger.isAfter) {
            objFileAccessControlTriggerHandler.onAfterDelete(Trigger.old);
        }
    }
}