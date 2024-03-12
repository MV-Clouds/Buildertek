({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.pageReference.state.buildertek__parentId");
        component.set('v.recordId', recordId);
        helper.getTimeSheetEntries(component, event, helper);
    },

    onMassUpdateSave: function(component, event, helper){
        component.set("v.Spinner", true);
        console.log('onMassUpdateSave');
        helper.updateTimeSheetEntries(component, event, helper);
    },

    onMassUpdateCancel: function(component, event, helper){
        var workspaceAPI = component.find("workspace");
	    workspaceAPI.getFocusedTabInfo().then(function(response) {

		    var focusedTabId = response.tabId;
		    workspaceAPI.closeTab({tabId: focusedTabId});
		});
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                "title": "Info",
                "message": "TimeSheet Entries Update Cancelled.",
                "type": "info",
                "duration": 1000
            });
            toastEvent.fire();
        }
    },
})
