({
    doInit : function(component, event, helper) {  
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(tabResponse) {
            
            var parentTabId = tabResponse.tabId;
            var isSubtab = tabResponse.isSubtab;
            
            workspaceAPI.openSubtab({
                parentTabId: parentTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "recordId" : component.get("v.recordId"),
                        "componentName": "buildertek__BT_ReceiveMaterialPOLines"
                    },
                    "state": {
                        "buildertek__parentId": component.get("v.recordId")
                    }
                },
            }).then(function(response){
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Receive Material",
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "custom:custom18",
                        iconAlt: "Receive Material"
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            })
        });                               
    }
    
})