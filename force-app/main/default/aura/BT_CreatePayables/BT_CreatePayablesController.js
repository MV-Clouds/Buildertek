({
    doInit: function (component, event, helper) {
        var action = component.get("c.Checkifpaid");    
        var recId = component.get("v.recordId");
        console.log(recId);
        action.setParams({
            "recId":recId
        });

        action.setCallback(this, function (response) {
            console.log(response.getState());
            if (response.getState() === "SUCCESS") { // Use triple equals for strict comparison
                console.log(response.getReturnValue()); // Use parentheses for method invocation

                // Check for true with lowercase 't'
                if (response.getReturnValue() === true) {
                    $A.get("e.force:closeQuickAction").fire();
                    helper.showErrorToast(component, event, helper);
                    component.destroy();

                } else {
                    helper.createInvoice(component, event, helper);
                }
            } else {
                alert('Something Went Wrong');
            }
        });
        $A.enqueueAction(action);
    },
})