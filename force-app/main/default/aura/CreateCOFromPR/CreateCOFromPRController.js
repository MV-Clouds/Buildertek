({
    doInit: function (component, event, helper) {
        component.set('v.isLoading', true);
        var action = component.get("c.getprrec");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.isLoading', false);
                console.log('result-->>', { result });
                if (result == 'success') {
                    console.log("Success");
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        title: "Success",
                        message: "Change Order Created Successfully.",
                        type: 'success',
                        duration: '5000',
                        key: 'info_alt',
                        mode: 'dismissible'
                    });
                    showToast.fire();
                } else if (result == 'error') {
                    $A.get("e.force:closeQuickAction").fire();
                    // $A.get('e.force:refreshView').fire();
                    var showToast = $A.get("e.force:showToast");
                    showToast.setParams({
                        title: "Error!",
                        message: "There are No Accepted Lines to create the Change Orders Lines.",
                        type: 'error',
                        duration: '1000',
                        key: 'info_alt',
                        mode: 'pester'
                    });
                    showToast.fire();
                }
            } else{
                var error = response.getError();
                console.log('Error =>', { error });
            }
        });
        $A.enqueueAction(action);
    },
})