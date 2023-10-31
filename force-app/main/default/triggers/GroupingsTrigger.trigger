trigger GroupingsTrigger on BT_Grouping__c (before insert, before update, after insert, after update, before delete) {

    GroupingsHandler handler = new GroupingsHandler(Trigger.isExecuting, Trigger.size);

    if (Trigger.isAfter && Trigger.isInsert) {
        handler.afterInsert(Trigger.new, Trigger.newMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }

    if (Trigger.isBefore && Trigger.isDelete) {
        handler.beforeDelete(Trigger.old, Trigger.oldMap);
    }

}