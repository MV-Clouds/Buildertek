({    
    invoke : function(component, event, helper) {
        // Get the record ID attribute
        var record = component.get("v.recId");
        sforce.one.navigateToSObject(record,"RELATED"); 

    },
    closeFocusedTab : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }
})