({
    navigateToOptUpgrade: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:OptionUpgradePage",
            componentAttributes: {
                recordId: component.get("v.recordId")
            }
        });
        evt.fire();
    },
    newOption: function(component, event, helper) {

        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "SHOW" }).fire();
        component.set('v.openOptionBox', true);
        var action = component.get('c.getOptionRecord');
        action.setParams({
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state == 'SUCCESS') {
                component.set('v.Option', result);
            } else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Something went wrong",
                    "type": "error",
                    "duration": 5000
                });
                toastEvent.fire();
            }
            $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
        });
        $A.enqueueAction(action);

    },
    createRecord: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "SHOW" }).fire();
        var getOption = component.get('v.Option');
        var action = component.get('c.cloneOptionRecord');
        action.setParams({
            optionRec: getOption,
            recordId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state == 'SUCCESS') {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue(),
                    "slideDevName": "detail"
                });
                navEvt.fire();

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Option created successfully",
                    "type": "success",
                    "duration": 5000
                });
                toastEvent.fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Something went wrong",
                    "type": "error",
                    "duration": 5000
                });
                toastEvent.fire();
            }
            $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
        });
        $A.enqueueAction(action);

    },
    closePopup: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})