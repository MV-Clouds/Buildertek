({
    submit: function (component, event, helper) {
        var lat = component.get("v.latitude");
        var lng = component.get("v.longitude");
        // alert('lat----'+lat+'lng----'+lng);
        var recordId = component.get("v.recordId");
        var action = component.get('c.updatelocation');
        action.setParams({
            recId: recordId,
            lat: lat,
            lng: lng,
            status: 'Endtime'
        });
        action.setCallback(this, function (response) {
            component.set("v.Spinner",false)
            var state = response.getState();
            if (state === "SUCCESS") {
              console.log("In call back")
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "",
                    "message": "Record Updated Successfully",
                    "type": 'success'
                });
                resultsToast.fire();
                component.find("overlayLib").notifyClose();
                  var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get("e.force:refreshView").fire();
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    showErrorToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '5000',
            type: 'warning',
            mode: 'pester'
        });
        toastEvent.fire();
    },
})