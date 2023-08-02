trigger AssignedResourceTrigger on AssignedResource (after Insert,after update,after delete) {
    if(trigger.isAfter){

        if(trigger.isInsert){
            EventHelper.createEvent(trigger.new,null);
            
            List<AssignedResource> assRecList = [Select Id, ServiceAppointment.ParentRecordId, ServiceResource.RelatedRecordId from AssignedResource where Id IN : Trigger.new];
            if(assRecList.size() > 0){
            	AssignedResourceTriggerHandler.followRecord(assRecList);
            }
           
        }
        if(trigger.isUpdate){
            EventHelper.createEvent(trigger.new,trigger.oldmap);
        }
        if(trigger.isdelete){
            EventHelper.deleteEvents(trigger.old);
        }
    }
}