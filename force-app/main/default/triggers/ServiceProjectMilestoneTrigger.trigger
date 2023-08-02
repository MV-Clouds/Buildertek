trigger ServiceProjectMilestoneTrigger on Service_Project_Milestones__c (before insert, before update, before delete) {

    if(Trigger.isInsert) {
        SmartSheetUtil.assignOwners(Trigger.New);
    }

    if(Trigger.isUpdate){
        if(Trigger.isBefore){
            List<Service_Project_Milestones__c> assignedToEmailUpdatedMilestones = new List<Service_Project_Milestones__c>();
            Integer indx = 0;
            for(Service_Project_Milestones__c eachMilestone : Trigger.New) {
                if(Trigger.old.get(indx).Assigned_To_Email__c != eachMilestone.Assigned_To_Email__c)
                    assignedToEmailUpdatedMilestones.add(eachMilestone);
            }
    
            if(assignedToEmailUpdatedMilestones.size() > 0)
                SmartSheetUtil.assignOwners(assignedToEmailUpdatedMilestones);
        }
	}
    if(Trigger.IsBefore && Trigger.isDelete){
        Set<Id> serMil_Ids = new Set<Id>();
        List<Service_Project_Tasks__c> deleteTasks = new List<Service_Project_Tasks__c>();
        for(Service_Project_Milestones__c serMilestoneRec: trigger.old){
            
            serMil_Ids.add(serMilestoneRec.Id);
        }
        if(serMil_Ids.size() <> 0){
            deleteTasks = [select Id, Name, Service_Project_Milestones__c from Service_Project_Tasks__c where Service_Project_Milestones__r.Id =: serMil_Ids];
            system.debug('taskrecords'+deleteTasks);
        }
        if(deleteTasks.size() <> 0 ){
            delete deleteTasks;
        }
    }  

}