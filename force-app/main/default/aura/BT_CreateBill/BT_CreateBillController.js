({
    doInit: function (component, event, helper) {
        if (component.get('v.recordId') != undefined) {
            var action = component.get('c.createBillFromReciept');
            action.setParams({
                "recordId": component.get('v.recordId')
            });
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "type": 'success',
                        "title": 'Success!',
                        "message": 'Bill created successfully!'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    window.location.reload();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "type": 'error',
                        "title": 'Error!',
                        "message": 'Something went wrong!'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire()
                }
            });
            $A.enqueueAction(action);
        }
    }
})