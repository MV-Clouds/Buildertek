({
    createPO: function (component, event, helper) {
        var action = component.get("c.getRecordType");
        action.setParams({
            coId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var recordType = response.getReturnValue();

                // Check if the record type is "Vendor"
                if (recordType === "Customer") {
                    $A.get("e.force:closeQuickAction").fire();
                    // Show a toast message indicating that PO creation is not allowed for Vendor records
                    var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Error',
                                    message: 'You cannot create a PO for Customer Invoice',
                                    duration: '5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                } else {
                    // Continue with the CreatePOMethod action
                    var createPOAction = component.get("c.CreatePOMethod");
                    createPOAction.setParams({
                        COId: component.get("v.recordId")
                    });

                    createPOAction.setCallback(this, function (response) {
                        if (component.isValid() && response.getState() === "SUCCESS") {
                            if (response.getReturnValue().strMessage == 'Success') {
                                // PO created successfully logic here
                                var recordId = response.getReturnValue().strRecordId;
                                // Show success toast message
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Success',
                                    message: 'Purchase Orders created Successfully.',
                                    duration: '4000',
                                    key: 'info_alt',
                                    type: 'success',
                                    mode: 'pester'
                                });
                                toastEvent.fire();

                                // Navigate to the related tab
                                if (recordId) {
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": recordId,
                                        "slideDevName": "related"
                                    });
                                    navEvt.fire();
                                } else {
                                    // If recordId is not available, navigate to the related tab using URL
                                    var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": '/lightning/r/buildertek__Change_Order__c/' + component.get("v.recordId") + '/related/buildertek__Purchase_Orders__r/view'
                                    });
                                    urlEvent.fire();
                                    $A.get('e.force:refreshView').fire();
                                }
                            } else {
                                // Handle error if PO creation is not successful
                                $A.get("e.force:closeQuickAction").fire();
                                var messageString = response.getReturnValue().strMessage;
                                if (messageString == undefined || messageString == null || messageString == '') {
                                    messageString = ' Please Choose a Vendor for this Change Order.';
                                }
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Error',
                                    message: messageString,
                                    duration: '5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'pester'
                                });
                                toastEvent.fire();
                            }
                        }
                    });

                    $A.enqueueAction(createPOAction);
                }
            } else {
                console.error("Error retrieving record type: " + response.getState());
            }
        });

        $A.enqueueAction(action);
    }
})
