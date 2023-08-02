/*
    @ PURPOSE : CREATES WORK ORDER LINE ITEMS FOR ISSUES WHO DO NOT HAVE WOLI WHEN WORK ORDER IS CREATED.
*/
Trigger WorkOrderTrigger on WorkOrder ( After Insert ,After Update) {
    if(WorkOrderTriggerHandler.runcurrentTrigger('WorkOrderTrigger')){
    if( Trigger.isAfter ) {
        
        if( Trigger.isInsert ) {
            
            WorkOrderTriggerHandler.updateCaseIssuesWithWorkOrders( Trigger.new );
           
            
        }
        if(trigger.isUpdate)
        {
            WorkOrderTriggerHandler.deleteEntitySubscriptions(Trigger.new, Trigger.OldMap);
        }
    }
    }
}