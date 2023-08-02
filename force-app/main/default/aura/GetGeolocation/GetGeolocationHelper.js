({
    submit: function (component, event, helper) {
        var lat = component.get("v.latitude");
        var lng = component.get("v.longitude");
        var recordId = component.get('v.recordId');
        var status = component.get("v.UserStartTime");
        var action = component.get('c.updatelocation');
        action.setParams({
            recId: recordId,
            lat: lat,
            lng: lng,
            status: status
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var starttime = response.getReturnValue();
                if(starttime == 'Startime'){
                    component.set("v.isstarttime", true);
                }else{
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "",
                    "message": "Record Updated Successfully",
                    "type": 'success'
                });
                resultsToast.fire();
                $A.get("e.force:refreshView").fire();
                }
            }
        });
        $A.enqueueAction(action);

    },
    showErrorToast: function (component, event, helper,title,message) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '5000',
            type: 'warning',
            mode: 'pester'
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
    },
})