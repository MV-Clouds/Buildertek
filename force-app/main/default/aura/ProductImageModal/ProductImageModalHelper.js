({
    getProductImages: function (component, event, helper) {
        debugger;
        console.log('Product Id::', component.get('v.recordId'));
        var action = component.get('c.getImages');
        action.setParams({
            recordId: component.get('v.recordId')
        });

        action.setCallback(this, function (response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue()) {
                var result = JSON.parse(response.getReturnValue());
                component.set('v.listOfImages', result);
                component.set("v.isSpinner",false);
            } else {
                console.log('Error');
                component.set("v.isSpinner",false);
            }
        });
        $A.enqueueAction(action);
    }
})