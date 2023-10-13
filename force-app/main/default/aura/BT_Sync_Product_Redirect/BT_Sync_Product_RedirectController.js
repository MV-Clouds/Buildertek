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
                        "componentName": "buildertek__BT_Sync_Products"
                    },
                    "state": {
                        "buildertek__parentId": component.get("v.recordId")
                    }
                },
                //focus: true
            }).then(function(response){
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Sync Products",
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "custom:custom5",
                        iconAlt: "products"
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            })
        });                           
    }
    
})