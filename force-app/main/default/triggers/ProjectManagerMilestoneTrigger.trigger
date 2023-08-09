trigger ProjectManagerMilestoneTrigger on Project_Milestones__c (before insert, before update, before delete) {

    if(Trigger.isInsert) {
        SmartSheetUtil.assignOwners(Trigger.New);
    }

    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            List<Project_Milestones__c> assignedToEmailUpdatedMilestones = new List<Project_Milestones__c>();
            Integer indx = 0;
            for(Project_Milestones__c eachMilestone : Trigger.New) {
                if(Trigger.old.get(indx).Assigned_To_Email__c != eachMilestone.Assigned_To_Email__c)
                    assignedToEmailUpdatedMilestones.add(eachMilestone);
            }
    
            if(assignedToEmailUpdatedMilestones.size() > 0)
                SmartSheetUtil.assignOwners(assignedToEmailUpdatedMilestones);
        }
               
    }
    if(Trigger.IsBefore && Trigger.isDelete){
        Set<Id> Pm_Ids = new Set<Id>();
        List<Project_Tasks__c> deletetasks = new List<Project_Tasks__c>();
        for(Project_Milestones__c pmRec: trigger.old){
            
            Pm_Ids.add(pmRec.Id);
        }
        if(Pm_Ids.size() <> 0){
            deletetasks = [select Id, Name, Project_Milestones__c from Project_Tasks__c where Project_Milestones__r.id =:Pm_Ids];
            system.debug('taskrecords'+deletetasks);
        }
        if(deletetasks.size() <> 0 ){
            delete deletetasks;
        }
    }

}