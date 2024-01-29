({
    createInvoice: function (component, helper) {
        var action = component.get("c.getRecordType");
        action.setParams({
            coId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var recordType = response.getReturnValue();

                // Check if the record type is "Vendor"
                if (recordType === "Vendor") {
					$A.get("e.force:closeQuickAction").fire();
                    // Show a toast message indicating that invoice creation is not allowed for Vendor records
                    var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Error',
                                    message: 'You cannot create a Invoice for Vendor records',
                                    duration: '5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                } else {
					console.log('entered in wrong place');
                    // Continue with the createARFromCO action
                    var createARAction = component.get("c.createARFromCO");
                    createARAction.setParams({
                        coId: component.get("v.recordId")
                    });

                    createARAction.setCallback(this, function (response) {
                        if (component.isValid() && response.getState() === "SUCCESS") {
                            if (response.getReturnValue().strMessage == 'Success') {
                                $A.get("e.force:closeQuickAction").fire();
                                component.find('notifLib').showNotice({
                                    "variant": "success",
                                    "header": "Success",
                                    "message": "Invoice created.",
                                    closeCallback: function () {
                                        $A.get('e.force:refreshView').fire();
                                    }
                                });
                                var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": response.getReturnValue().strRecordId,
                                    "slideDevName": "detail"
                                });
                                navEvt.fire();
                            }
                        } else {
                            component.find('notifLib').showNotice({
                                "variant": "error",
                                "header": "Error",
                                "message": response.getError()[0].message,
                                closeCallback: function () {
                                    $A.get("e.force:closeQuickAction").fire();
                                }
                            });
                        }
                    });

                    $A.enqueueAction(createARAction);
                }
            } else {
                console.error("Error retrieving record type: " + response.getState());
            }
        });

        $A.enqueueAction(action);
    }
})
