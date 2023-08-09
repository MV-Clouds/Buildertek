({
	createPO : function(component,event,helper) {
      var action = component.get("c.CreatePOMethod");
        action.setParams({
            COId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            
            if (response.getState() === "SUCCESS") {
            	if(response.getReturnValue().strMessage == 'Success') {
                   // alert('&&&&*********'+response.getReturnValue().strRecordId);
                    console.log("Response : ",response.getReturnValue().strRecordId);
                    var recordId = component.get("v.recordId");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Purchase Orders created Successfully.',
                        duration:' 4000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                 //   alert('response.getReturnValue().strRecordId'+response.getReturnValue().strRecordId);
                    if(response.getReturnValue().strRecordId != null && response.getReturnValue().strRecordId != undefined){
                        var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": response.getReturnValue().strRecordId,
                                "slideDevName": "related"
                            });
                            navEvt.fire();
                       
                    }else{
                      //  $A.get('e.force:refreshView').fire();
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": '/lightning/r/buildertek__Change_Order__c/'+recordId+'/related/buildertek__Purchase_Orders__r/view'
                        });
                        urlEvent.fire();
                        $A.get('e.force:refreshView').fire();     
                    }
            		
            		/*component.find('notifLib').showNotice({
			            "variant": "success",
			            "header": "Success",
			            "message": "PO created.",
			            closeCallback: function() {
			            
			            	var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                              "recordId": response.getReturnValue().strRecordId,
                              "slideDevName": "related"
                            });
                            navEvt.fire();
			            }
			        }); */
            	}
            	else{
            	    $A.get("e.force:closeQuickAction").fire();
                        var messageString = response.getReturnValue().strMessage;
                        if(messageString == undefined || messageString == null || messageString == '')
                        {
                            messageString = ' Please Choose a Vendor for this Change Order.';
                        }
                        var toastEvent = $A.get("e.force:showToast");
                                                toastEvent.setParams({
                                                    title : 'Error',
                                                    message:messageString,
                                                    duration:' 5000',
                                                    key: 'info_alt',
                                                    type: 'error',
                                                    mode: 'pester'
                                                });
                                                toastEvent.fire();
                  /*  component.find('notifLib').showNotice({
			            "variant": "error",
			            "header": "Error",
			            "message": response.getReturnValue().strMessage,
			            closeCallback: function() {
			            	$A.get("e.force:closeQuickAction").fire();
			            }
			        }); */
            	}
            } 
        });
        
        $A.enqueueAction(action); 
	}
})