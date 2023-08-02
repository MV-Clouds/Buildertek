({
    getDropDownValues: function (component, event, helper, fieldName) {
        var record = component.get('v.record');
        var action = component.get("c.getDropDown");
        action.setParams({
            fieldName: fieldName
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.dropDown', response.getReturnValue());
            } else if (state === "ERROR") {
                console.log('A Problem Occurred: ' + JSON.stringify(response.error));
            }
        });
        $A.enqueueAction(action);
    }
})