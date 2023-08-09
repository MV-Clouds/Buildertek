({
	createPO : function(component, helper) {
      var action = component.get("c.CreatePOMethod");
        action.setParams({
            RFQId: component.get("v.recordId")
        });
		
        action.setCallback(this, function (response) {
            
            if (response.getState() === "SUCCESS") {
            	if(response.getReturnValue().strMessage == 'Success') {
            		$A.get("e.force:closeQuickAction").fire();
            		component.find('notifLib').showNotice({
			            "variant": "success",
			            "header": "Success",
			            "message": "PO created.",
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