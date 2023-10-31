({
    doInit: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.gettaskOfSchedules");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                console.log(JSON.parse(JSON.stringify(response.getReturnValue())));
                var taskdata = JSON.parse(JSON.stringify(response.getReturnValue()));
                
            }
        })
        $A.enqueueAction(action);
    },
})