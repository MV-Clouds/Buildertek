({
    getVendors : function(component, event, helper) {
        console.log('getVendors');
        var action = component.get("c.getVendors");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var vendors = response.getReturnValue();
                console.log('vendors: ', vendors);
                component.set("v.MainvendorList", vendors);
                component.set("v.ItervendorList", vendors);
            }
        });
        $A.enqueueAction(action);
    },
})