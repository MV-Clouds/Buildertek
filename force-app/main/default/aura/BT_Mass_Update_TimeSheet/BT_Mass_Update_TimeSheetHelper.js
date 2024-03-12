({
    getTimeSheetEntries : function(component, event, helper) {
        console.log('getTimeSheetEntries');
        var recordId = component.get('v.recordId');
        var action = component.get("c.getTimeSheetEntries");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set("v.timeSheetEntries", result);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    updateTimeSheetEntries : function(component, event, helper) {
        console.log('updateTimeSheetEntries');
        var timeSheetEntries = component.get('v.timeSheetEntries');
        console.log('timeSheetEntries', timeSheetEntries);
        var action = component.get("c.updateTimeSheetEntries");
        action.setParams({
            "timeSheetEntries": timeSheetEntries
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                component.set("v.Spinner", false);
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                });
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        "title": "Success",
                        "message": "TimeSheet Entries Updated Successfully.",
                        "type": "success",
                        "duration": 1000
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
})
