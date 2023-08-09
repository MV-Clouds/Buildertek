({
	createPO : function(component, helper) {
       var action = component.get("c.createPO");
        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	if(response.getReturnValue()) {
            		$A.get("e.force:closeQuickAction").fire();
            		component.find('notifLib').showNotice({
			            "variant": "success",
			            "header": "Success",
			            "message": "Purchase Order created.",
			            closeCallback: function() {
			            	$A.get('e.force:refreshView').fire();
			            	var event = $A.get('e.force:navigateToSObject');
			            	event.setParams({
					            'recordId' : response.getReturnValue()
					        }).fire();
			            }
			        });
            	}
            }
        });
        
        $A.enqueueAction(action);
	} 
})