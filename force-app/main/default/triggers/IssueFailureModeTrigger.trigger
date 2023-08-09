trigger IssueFailureModeTrigger on Issue_Failure_Mode__c (after delete) {
    if(trigger.isafter){
        if(trigger.isdelete){
            WorkOrderProducts.updateIssueOnFailureModeDelete(trigger.old);
        }
    }
}