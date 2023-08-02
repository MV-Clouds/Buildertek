({
	createCO : function(component, helper) {
	var recordId = component.get("v.recordId");
		var action = component.get("c.CreateCOMethod"); 
        action.setParams({
            rfqId: recordId 
        });

        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
            	if(response.getReturnValue().strMessage == 'Success') {
            		$A.get("e.force:closeQuickAction").fire();
            		component.find('notifLib').showNotice({
			            "variant": "success",
			            "header": "Success",
			            "message": "Change order created.",
			            closeCallback: function() {
			            //	$A.get('e.force:refreshView').fire();
			            	var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                              "recordId": response.getReturnValue().strRecordId,
                              "slideDevName": "related"
                            });
                            navEvt.fire();
			            }
			        });
            	}
            	else{
            	    $A.get("e.force:closeQuickAction").fire();
                    component.find('notifLib').showNotice({
			            "variant": "error",
			            "header": "Error",
			            "message": response.getReturnValue().strMessage,
			            closeCallback: function() {
			            	$A.get("e.force:closeQuickAction").fire();
			            }
			        });
            	}
            }
        });
        
        $A.enqueueAction(action);	
	}
})