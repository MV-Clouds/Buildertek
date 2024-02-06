({
    getRecordTypes: function (component, event, helper) {
        component.set('v.isLoading', true);
        let action = component.get("c.getRecordType");
        action.setCallback(this, function (response) {
            let state = response.getState();
            console.log('result ' + JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                component.set("v.recordTypes", response.getReturnValue());
                for (let i = 0; i < response.getReturnValue().length; i++) {
                    if (response.getReturnValue()[i].Name === 'Customer') {
                        component.set("v.RecordTypeId", response.getReturnValue()[i].Id);
                    }
                }
                console.log('default record type ' + component.get("v.RecordTypeId"));
            } else {
                console.log("Failed with state: " + state);
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    type: "error",
                    message: "Failed to get Record Types.",
                    duration: 3000
                });
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    getParameterByName: function (component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
})