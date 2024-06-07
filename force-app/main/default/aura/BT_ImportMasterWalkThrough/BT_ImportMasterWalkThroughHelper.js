({
    fetchWalkThroughs: function (component, event, helper, key) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        let action = component.get("c.getMasterWalkThroughDetails");
        action.setParams({ "searchKey": key });

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                if (!result || result.length === 0) {
                    helper.showToast('error', 'Error', 'No Master Walk Through(s) Available');
                    component.set("v.masterWTList", []);
                } else {
                    component.set("v.masterWTList", result);
                }
            } else {
                console.error("Error fetching Walk Through details");
                helper.showToast('error', 'Error', 'Error fetching Walk Through details');
            }
        });
        $A.enqueueAction(action);
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
    },

    showToast: function (type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            "duration": 5000
        });
        toastEvent.fire();
    },

    close: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})