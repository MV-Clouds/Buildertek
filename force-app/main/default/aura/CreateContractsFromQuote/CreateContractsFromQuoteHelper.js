({
    showToast : function(component, event, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "type": type,
            "message": message,
            "mode" : "sticky"
    	});
    	
        toastEvent.fire();
	},
	
	createContract : function(component, helper){
	   var action = component.get("c.createContract");
        action.setParams({ quotetId : component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
        		component.find('notifLib').showNotice({
		            "variant": "success",
		            "header": "Success",
		            "message": "Contract created.",
		            closeCallback: function() {
		            	$A.get('e.force:refreshView').fire();
		            	var event = $A.get('e.force:navigateToSObject' );
		            	event.setParams({
				            'recordId' : response.getReturnValue().newRecordId
				        }).fire();
		            }
		        });
            }
        });
        
        $A.enqueueAction(action);   
	}
})