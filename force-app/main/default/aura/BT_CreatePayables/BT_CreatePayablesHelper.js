({
    init: function (component) {
        var action = component.get("c.Checkifpaid");    
        var recId = component.get("v.recordId");
        console.log(recId);
        action.setParams({
            "recId":recId
        });

        action.setCallback(this, function (response) {
            console.log(response.getState());
            if (response.getState() === "SUCCESS") { // Use triple equals for strict comparison
                console.log(response.getReturnValue()); // Use parentheses for method invocation

                // Check for true with lowercase 't'
                if (response.getReturnValue() === true) {
                    $A.get("e.force:closeQuickAction").fire();
                    this.showErrorToast();
                    component.destroy();

                } else {
                    this.createInvoice(component, helper);
                }
            } else {
                alert('Something Went Wrong');
            }
        });
        $A.enqueueAction(action);
      },

      showErrorToast : function(component, event, helper) {
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