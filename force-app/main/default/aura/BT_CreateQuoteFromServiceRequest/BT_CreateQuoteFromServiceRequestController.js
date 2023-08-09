({
	doInit : function(component, event, helper) {
	    
	    console.log("newquote");
	    
	   var action = component.get("c.getServiceReqDetails");
       action.setParams({ "recordId": component.get("v.recordId") });
       
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var projectvalues = response.getReturnValue();
                console.log(response.getReturnValue());
                console.log(projectvalues.buildertek__Address__c);
                var evt = $A.get("e.force:createRecord");
                evt.setParams({
                    'entityApiName':'buildertek__Quote__c',
                    'defaultFieldValues': {
                        'buildertek__Service_Request__c':component.get("v.recordId"),
                        'buildertek__Project__c': projectvalues.buildertek__Project__c
                    }
                    //'recordTypeId':YOUR_RECORDTYPE_ID_HERE
                });
                evt.fire();
            }else {
                console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
       $A.enqueueAction(action);
    },
    
    doneRendering: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})({
	myAction : function(component, event, helper) {

	
	}
})