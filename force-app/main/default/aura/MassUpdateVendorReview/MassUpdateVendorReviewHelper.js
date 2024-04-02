({
    getVendorReviewLines: function (component, event, helper) {
        var action = component.get("c.fetchVendorReviewLines");
        action.setParams({
            vendorReviewId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.vendorReviewLines", response.getReturnValue());
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    validateVendorReviewLines: function (component, event, helper) {
        var vendorReviewLines = component.get('v.vendorReviewLines');
        var isEmptyNameError = false;
        var isInvalidWeightError = false;
        var errorMessages = [];

        for (var i = 0; i < vendorReviewLines.length; i++) {
            var name = vendorReviewLines[i].Name || '';
            var weight = vendorReviewLines[i].buildertek__Weighting__c || 0;
            name = name.trim();

            if (!name) {
                isEmptyNameError = true;
            }
            if (isNaN(weight) || weight < 0 || weight > 100) {
                isInvalidWeightError = true;
            }
        }

        if (isEmptyNameError) {
            errorMessages.push("Name cannot be empty");
        }

        if (isInvalidWeightError) {
            errorMessages.push("Weight must be a valid percentage between 0 and 100");
        }

        if (errorMessages.length > 0) {
            component.set("v.Spinner", false);
            var toastMessage = "Please fix the following errors:\n" + errorMessages.join("\n");
            this.showToast("Error!", toastMessage, "error");
        } else {
            this.updateVendorReviewLines(component, event, helper);
        }
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    updateVendorReviewLines: function (component, event, helper) {
        component.set("v.Spinner", true);
        console.log('updateVendorReviewLines');
        var vendorReviewLines = component.get('v.vendorReviewLines');
        var deletedVendorReviewLines = component.get('v.deletedVendorReviewLines');
        var action = component.get("c.updateVendorReviewLines");
        action.setParams({
            "insertVRL": JSON.stringify(vendorReviewLines),
            "deleteVRL": JSON.stringify(deletedVendorReviewLines)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                if (result == 'Success') {
                    this.showToast("Success!", "Record updated successfully", "success");
                    this.closeScreenAndRedirect(component, event, helper);
                } else {
                    this.showToast("Error!", "An error occurred while updating the record", "error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    closeScreenAndRedirect: function (component, event, helper) {
        let vendorReviewId = component.get("v.recordId");
        component.set("v.isCancelModalOpen", false);
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        }).catch(function (error) {
            console.log(error);
        });
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": vendorReviewId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },

})