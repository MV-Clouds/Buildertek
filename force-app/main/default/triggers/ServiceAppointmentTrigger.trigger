trigger ServiceAppointmentTrigger  on ServiceAppointment (after update) {
    if(trigger.isAfter){
        if(trigger.isupdate){
            EventHelper.updtateFSLEvent(trigger.new,trigger.oldMap);
        }
    }
}