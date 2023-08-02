({
    getSR: function(component, event, helper) {
        //Get Current User ID
        var actionGetSR, state, actionGetNameSpace, actionGetOrganizationName;
        actionGetSR = component.get("c.getAllSR");
        actionGetSR.setCallback(this, function (response) {
            state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.recordList", response.getReturnValue());
            } else {
                console.log(response.getReturnValue());
            }
        });
        
        $A.enqueueAction(actionGetSR);
    }
})