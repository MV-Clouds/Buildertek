({
	createInvoice : function(component, helper) {
	  console.log('Event Fired');
	    var action = component.get("c.createAPFromPO");
        action.setParams({
            poid: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	if(response.getReturnValue() != null) {
            		$A.get("e.force:closeQuickAction").fire();
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                            sObjectEvent.setParams({
                                "recordId": response.getReturnValue(),
                            })
                            sObjectEvent.fire(); 
            	/*	component.find('notifLib').showNotice({
			            "variant": "success",
			            "header": "Success",
			            "message": "Payable created.",
			            closeCallback: function() {
			            	var sObjectEvent = $A.get("e.force:navigateToSObject");
                            sObjectEvent.setParams({
                                "recordId": response.getReturnValue(),
                            })
                            sObjectEvent.fire(); 
			            }
			        }); */
            	}
            }
        });
        
        $A.enqueueAction(action);
	} 
})