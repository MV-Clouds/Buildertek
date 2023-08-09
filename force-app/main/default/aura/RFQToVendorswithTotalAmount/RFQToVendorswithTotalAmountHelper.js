({
	getRfqVendor : function(component, event, helper) {
	   
		var action = component.get("c.getRFQvendorList");  
		action.setParams({
		    recordId: component.get("v.recordId")
		});
        action.setCallback(this, function (response) {
        	if (response.getState() === "SUCCESS") {
        			component.set("v.RFQVendorsList",response.getReturnValue());
        	} else {
        	}	        	
        });  
        $A.enqueueAction(action);
	},
	
})