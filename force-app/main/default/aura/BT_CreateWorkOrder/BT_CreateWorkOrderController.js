({
    doInit: function (component, event, helper) {
        try {
            let recordId = component.get("v.recordId");
            console.log('recordId : ', recordId);
            let action = component.get("c.createWorkOrder");
            action.setParams({
                poId: recordId,
            })
            action.setCallback(this, function (response) {
                let result = response.getReturnValue();
                console.log('return value : ', result);
                $A.get("e.force:closeQuickAction").fire()
                if (result.state === 'Success') {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": result.state + "!",
                        "type": result.state,
                        "message": result.returnMessage,
                        "duration": 3000,
                    });
                    toastEvent.fire();
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": result.workorderId
                    })
                    sObjectEvent.fire();
                } else {
                    let toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": result.state + "!",
                        "type": result.state,
                        "message": result.returnMessage,
                        "duration": 3000,
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);

        } catch (error) {
            console.log('Error: ', error);
        }
    }
})