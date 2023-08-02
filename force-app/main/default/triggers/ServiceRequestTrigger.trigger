trigger ServiceRequestTrigger on Service_Request__c(after insert, after update ){
	if (Trigger.isInsert && Trigger.isAfter){
		if (!RecursiveCheckTrigger.firstCall){
            RecursiveCheckTrigger.firstCall = true;
			ServiceRequestTriggerHandler.sendEmailForRequestProcess(Trigger.New);
		}
	}

	if (Trigger.isUpdate && Trigger.isAfter){
		if (!RecursiveCheckTrigger.firstCall){
            RecursiveCheckTrigger.firstCall = true;
			ServiceRequestTriggerHandler.sendEmailForRequestComplete(Trigger.OldMap, Trigger.New);
		}
	}
}