({
    doInit: function (component, event, helper) {
        try {
            var recordId = component.get("v.recordId");
            console.log('recordId : ', recordId);
            var action = component.get("c.createPOsFromBOM");
            action.setParams({
                bomId: recordId,
            })
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                console.log('return value : ', result);
                $A.get("e.force:closeQuickAction").fire()
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": result.state + "!",
                    "type": result.state,
                    "message": result.returnMessage,
                    "duration": 3000,
                });
                toastEvent.fire();
            });
            $A.enqueueAction(action);

        } catch (error) {
            console.log('Error: ', error);
        }
    }
})