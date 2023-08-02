({
    createNewQuote: function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        console.log('recordId =>', { recordId });
        var action = component.get("c.createQuote");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            console.log('Result =>', { result });

            if (result == 'Error') {
                tst.setParams({
                    title: 'Error',
                    message: 'Something Went Wrong',
                    type: 'Error',
                    duration: 5000
                });
                tst.fire();
            } else {
                var tst = $A.get("e.force:showToast");
                tst.setParams({
                    title: 'Complete',
                    message: 'Your Quote is created',
                    type: 'success',
                    duration: 5000
                });
                tst.fire();
                var navEvent = $A.get("e.force:navigateToSObject");
                navEvent.setParams({
                    "recordId": result,
                });

                navEvent.fire();
            }
            component.set("v.Spinner", false);
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },
    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})