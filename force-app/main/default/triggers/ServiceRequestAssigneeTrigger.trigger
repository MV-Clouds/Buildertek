trigger ServiceRequestAssigneeTrigger on Service_Request_Assignee__c (before insert,before update) {
    ServiceRequestAssigneeHandler.UniqueSRAId(Trigger.oldMap,Trigger.New);
}