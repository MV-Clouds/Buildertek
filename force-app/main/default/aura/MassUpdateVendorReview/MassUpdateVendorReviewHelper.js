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
        var isValid = true;
        for (var i = 0; i < vendorReviewLines.length; i++) {
            var name = vendorReviewLines[i].Name || '';
            name = name.trim();
            console.log(`name: ${name}`);
            console.log(`vendorReviewLines[i] ${JSON.stringify(vendorReviewLines[i])}`);
            if (!name) {
                isValid = false;
                break;
            }
        }

        if (!isValid) {
            component.set("v.Spinner", false);
            this.showToast("Error!", "Name cannot be empty", "error");
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
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                } else {
                    this.showToast("Error!", "An error occurred while updating the record", "error");
                }
            }
        });
        $A.enqueueAction(action);
    }

})