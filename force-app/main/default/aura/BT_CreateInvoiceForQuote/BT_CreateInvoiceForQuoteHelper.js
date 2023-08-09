({
	CreateInvoice : function(component, event, helper) {
		console.log('Helper Call');
         component.set("v.IsSpinner",true);
		var action = component.get("c.CreateInvoiceMethod");
        action.setParams({
            QuoteId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            
            if (response.getState() === "SUCCESS") {
            	if(response.getReturnValue().strMessage == 'Success') {
            		$A.get("e.force:closeQuickAction").fire();
                     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Invoice created successfully.",
                            "type": 'Success'
                        });
                        toastEvent.fire(); 
                    var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                              "recordId": response.getReturnValue().strRecordId,
                              "slideDevName": "related"
                            });
                            navEvt.fire();
            	/*	component.find('notifLib').showNotice({
			            "variant": "success",
			            "header": "Success",
			            "message": "Invoice created.",
			            closeCallback: function() {
			            //	$A.get('e.force:refreshView').fire();
			            	var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                              "recordId": response.getReturnValue().strRecordId,
                              "slideDevName": "related"
                            });
                            navEvt.fire();
			            }
			        });*/
            	}
            	else{
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