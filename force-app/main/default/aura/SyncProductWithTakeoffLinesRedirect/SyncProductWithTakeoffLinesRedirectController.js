({
    doInit : function(component, event, helper) {
        console.log("recordId--->" , component.get("v.recordId"));
        debugger;
        var action = component.get("c.checkTakeoffLineItems");
        action.setParams({
            "takeOffId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allQuoteLineItemsHaveProducts = response.getReturnValue();
                if (allQuoteLineItemsHaveProducts) {
                    //show toast message that all takeoff line items have products
                    console.log('all takeoff line items have products');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "All Takeoff Line have Products",
                        "type": "error",
                        "message": "All Takeoff Line have been sync'd to a product."

                    });
                    toastEvent.fire();
                    //close quick action
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    console.log('not all takeoff line items have products');
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
                                    "componentName": "buildertek__SyncProductWithTakeoffLine"
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
            }
        });
        $A.enqueueAction(action);

    }
    
})