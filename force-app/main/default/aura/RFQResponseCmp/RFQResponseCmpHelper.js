({
    doInitHelper : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log(('recordId ==> '+recordId));

        var action = component.get("c.getRFQdata");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result ==> '+result);
            }
        });
        $A.enqueueAction(action);

    }
})