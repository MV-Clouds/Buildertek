({
	CreateInvoice : function(component, event, helper) {
		console.log('Helper Call');
		var action = component.get("c.CreateInvoiceMethod");
        action.setParams({
            ContractId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            
            if (response.getState() === "SUCCESS") {
            	if(response.getReturnValue().strMessage == 'Success') {
            		$A.get("e.force:closeQuickAction").fire();
            		component.find('notifLib').showNotice({
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
			        });
                }else if(response.getReturnValue().strMessage == 'No PR'){
                    
            		component.find('notifLib').showNotice({
			            "variant": "Warning",
			            "header": "Warning",
			            "message": "This contract we don't have purchase order, so cannot create a Invoice(AP).",
			            closeCallback: function() {
			            //	$A.get('e.force:refreshView').fire();
			            	$A.get("e.force:closeQuickAction").fire();
			            }
			        });
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