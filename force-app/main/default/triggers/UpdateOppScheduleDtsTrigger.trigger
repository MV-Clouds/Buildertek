trigger UpdateOppScheduleDtsTrigger on Opportunity (before update) {
    
    if(Trigger.IsBefore){
        if(Trigger.isUpdate){
            OppScheduleDatesHandler.updateScheduleShipDates(Trigger.oldMap, Trigger.newMap);
        }
    }

}