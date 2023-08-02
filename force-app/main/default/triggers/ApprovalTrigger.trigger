trigger ApprovalTrigger on sbaa__Approval__c (before insert, after insert,before update,after update) {
    if(Trigger.isbefore && (Trigger.isUpdate||Trigger.isInsert)){
        ApprovalTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldmap);
    }
    if(Trigger.isAfter && (Trigger.isUpdate||Trigger.isInsert)){
        ApprovalTriggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
    }
}