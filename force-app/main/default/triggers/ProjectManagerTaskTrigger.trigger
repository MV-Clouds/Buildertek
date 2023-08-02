trigger ProjectManagerTaskTrigger on Project_Tasks__c (before insert, before update, after update) {

    if(Trigger.isInsert && Trigger.isBefore) {
        SmartSheetUtil.assignOwners(Trigger.New);
    }

    if(Trigger.isUpdate && Trigger.isBefore){

        List<Project_Tasks__c> assignedToEmailUpdatedTasks = new List<Project_Tasks__c>();
        Integer indx = 0;
        for(Project_Tasks__c eachPrjTask : Trigger.New) {
            if(Trigger.old.get(indx).Is_Active__c != eachPrjTask.Is_Active__c && !eachPrjTask.Is_Active__c){
                eachPrjTask.Milestone_Reference_Id__c  = eachPrjTask.Project_Milestones__c;
                eachPrjTask.Project_Milestones__c = null;                
            }
            if(Trigger.old.get(indx).Assigned_To_Email__c != eachPrjTask.Assigned_To_Email__c)
                assignedToEmailUpdatedTasks.add(eachPrjTask);
                indx++;
        }

        if(assignedToEmailUpdatedTasks.size() > 0)
            SmartSheetUtil.assignOwners(assignedToEmailUpdatedTasks);
    }

    if(Trigger.isUpdate && Trigger.isAfter){

       /* List<Id> prjTaskIds = new List<Id>();
        Integer indx = 0;
        for(Project_Tasks__c eachTask : Trigger.new) {
            if(Trigger.old.get(indx).Percent_Complete__c != eachTask.Percent_Complete__c || Trigger.old.get(indx).Comments__c != eachTask.Comments__c 
            || Trigger.old.get(indx).Duration__c != eachTask.Duration__c || Trigger.old.get(indx).Deadline__c != eachTask.Deadline__c 
            || Trigger.old.get(indx).Order__c != eachTask.Order__c || Trigger.old.get(indx).Functional_Responsibility__c != eachTask.Functional_Responsibility__c
            || Trigger.old.get(indx).End_Date__c != eachTask.End_Date__c  || Trigger.old.get(indx).Start_Date__c!= eachTask.Start_Date__c) {
                prjTaskIds.add(eachTask.Id);
                indx++;
            } //   Trigger.old.get(indx).End_Date__c != eachTask.End_Date__c  || Trigger.old.get(indx).Start_Date__c!= eachTask.Start_Date__c
        }
 
        if(!SmartSheetUtil.isSmartSheetAPITransaction && prjTaskIds.size() > 0)
            SmartSheetUtil.syncProjectTasksAsync(prjTaskIds);
        */
    }

}