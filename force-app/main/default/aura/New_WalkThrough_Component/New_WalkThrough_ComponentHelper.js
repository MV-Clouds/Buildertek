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
        component.set("v.isLoading", true);
        let action = component.get("c.getMasterWalkThroughDetails");

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                if (!result || result.length === 0) {
                    // let toastEvent = $A.get("e.force:showToast");
                    // toastEvent.setParams({
                    //     "title": "Error!",
                    //     "message": "No Master Walk Through(s) Available",
                    //     "type": "error"
                    // });
                    // toastEvent.fire();
                    console.error("No Master Walk Through(s) Available");
                    component.set("v.masterWTList", []);
                } else {
                    component.set("v.masterWTList", result);
                }
            } else {
                console.error("Error fetching Walk Through details");
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Error fetching Walk Through details",
                    "type": "error"
                });
                toastEvent.fire();

            }
        });
        $A.enqueueAction(action);
        component.set("v.isLoading", false);
    }
})