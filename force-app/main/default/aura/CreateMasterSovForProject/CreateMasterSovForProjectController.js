({
    doInit : function(component, event, helper) {
        debugger;
        
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
                        "componentName": "buildertek__CreateMasterSovForProjectSubmitted"
                    },
                    "state": {
                        "buildertek__parentId": component.get("v.recordId")
                    }
                },
                //focus: true
            }).then(function(response){
                console.log(response);
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.setTabLabel({
                        tabId: focusedTabId,
                        label: "Create Master SOV",
                    });
                    workspaceAPI.setTabIcon({
                        tabId: focusedTabId,
                        icon: "custom:custom5",
                        iconAlt: "Create Master SOV"
                    });
                })
                .catch(function(error) {
                    console.log(error);
                });
            })
        });
        
        
        
        
      //  $A.get("e.force:closeQuickAction").fire();
        
    }
})