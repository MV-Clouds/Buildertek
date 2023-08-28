({
    doInit: function (component, event) {

        var action2 = component.get("c.chekIsOldGantt");
        action2.setParams({});
        action2.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                let result = response.getReturnValue();
                console.log('oldGantt::',result);
                component.set("v.isOldGantt", result);
            } else {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Something Went Wrong."
                });
                toastEvent.fire();
            }
        })
        $A.enqueueAction(action2);
    },

    handleFilterChange: function (component, event) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
            .catch(function (error) {
                console.log(error);
            });
    },

})