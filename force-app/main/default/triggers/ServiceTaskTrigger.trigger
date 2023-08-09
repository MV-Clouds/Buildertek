trigger ServiceTaskTrigger on Service_Project_Tasks__c (before insert, before update, after update) {

    if(Trigger.isInsert && Trigger.isBefore) {
        SmartSheetUtil.assignOwners(Trigger.New);
    }

    if(Trigger.isUpdate && Trigger.isBefore){

        List<Service_Project_Tasks__c> assignedToEmailUpdatedTasks = new List<Service_Project_Tasks__c>();
        Integer indx = 0;
        for(Service_Project_Tasks__c eachPrjTask : Trigger.New) {
        
            if(Trigger.old.get(indx).Is_Active__c != eachPrjTask.Is_Active__c && !eachPrjTask.Is_Active__c){
                eachPrjTask.Milestone_Reference_Id__c  = eachPrjTask.Service_Project_Milestones__c;
                eachPrjTask.Service_Project_Milestones__c = null;                
            }
            
            if(Trigger.old.get(indx).Assigned_To_Email__c != eachPrjTask.Assigned_To_Email__c)
                assignedToEmailUpdatedTasks.add(eachPrjTask);
                indx++;
        }

        if(assignedToEmailUpdatedTasks.size() > 0)
            SmartSheetUtil.assignOwners(assignedToEmailUpdatedTasks);
    }

   

}