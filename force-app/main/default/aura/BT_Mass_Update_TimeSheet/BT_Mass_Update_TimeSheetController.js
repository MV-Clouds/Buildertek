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
        var timeSheetEntries = component.get('v.timeSheetEntries');
        var valid = timeSheetEntries.every(function(entry){
            console.log('entry.buildertek__Duration_Manual__c', entry.buildertek__Duration_Manual__c);
            return (entry.buildertek__Duration_Manual__c === null || !isNaN(entry.buildertek__Duration_Manual__c) || entry.buildertek__Duration_Manual__c === '' || entry.buildertek__Duration_Manual__c === undefined);
        });
        if(!valid){
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            if(toastEvent){
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Duration should be a number.",
                    "type": "error",
                    "duration": 1000
                });
                toastEvent.fire();
            }
            return;
        }
        debugger;
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
