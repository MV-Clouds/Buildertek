({
	doInit : function(component, event, helper) {
		var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Service_Request__c",
            "recordTypeId":"01228000000yXgeAAE"
        });
        //createRecordEvent.fire();

	}
})