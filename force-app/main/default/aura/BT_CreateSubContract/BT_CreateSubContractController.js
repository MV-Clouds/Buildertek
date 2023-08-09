({
    doInit: function (component, event, helper) {
        //  $A.get("e.force:closeQuickAction").fire();
        var action = component.get("c.createSubContractRec");
        action.setParams({
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            $A.get("e.force:closeQuickAction").fire();
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result == 'Success') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Sub-Contract created successfully!',
                        type: 'success',
                    });
                    toastEvent.fire();
                    var recordId = component.get("v.recordId");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/lightning/r/buildertek__RFQ__c/'+recordId+'/related/buildertek__Contracts__r/view'
                    });
                    urlEvent.fire();
                    $A.get('e.force:refreshView').fire();
                    /*	var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                              "recordId": component.get('v.recordId'),
                              "slideDevName": "related"
                            });
                            navEvt.fire();
			           // } */
                    
                } else if (result == 'Error1') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'You cannot create the Sub-Contract until the RFQ status is Awarded or Accepted.',
                        type: 'warning',
                    });
                    toastEvent.fire();
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'You cannot create the Sub-Contract until the RFQ status is Awarded or Accepted.',
                    type: 'error',
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
        //-------------------------------------------------------------------------------------
        
        /*   var action1 = component.get("c.CreatePOMethod");
        action1.setParams({
            RFQId: component.get("v.recordId")
        });
        //alert("ok")
        action1.setCallback(this, function (response) {
            
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue().strMessage == 'Success') {
                    $A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message: 'Purchase Order created successfully!',
                        type: 'success',
                    });
                    toastEvent.fire();
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
        
        $A.enqueueAction(action1); */
        
    },
    
})