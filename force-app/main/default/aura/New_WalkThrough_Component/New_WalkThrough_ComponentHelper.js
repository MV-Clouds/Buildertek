({
    getParameterByName: function (component, event, name) {
		name = name.replace(/[\[\]]/g, "\\$&");
		var url = window.location.href;
		var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
		var results = regex.exec(url);
		if (!results) return null;
		if (!results[2]) return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	},

	fetchWalkThroughs: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        let action = component.get("c.getMasterWalkThroughDetails");

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
})