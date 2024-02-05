({
    showErrorToast: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error Message',
            message:'Status is Paid so Invoice cannot be created',
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },


	createInvoice: function(component, event, helper) {
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
            	}
            }
        });
        
        $A.enqueueAction(action);
	} 
})