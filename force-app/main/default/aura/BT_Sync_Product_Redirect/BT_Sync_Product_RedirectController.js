({
    doInit : function(component, event, helper) {
        var action = component.get("c.checkQuoteLineItems");
        action.setParams({
            "quoteId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allQuoteLineItemsHaveProducts = response.getReturnValue();
                if (allQuoteLineItemsHaveProducts) {
                    //show toast message that all quote line items have products
                    console.log('all quote line items have products');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "All Quote Line have Products",
                        "type": "error",
                        "message": "All Quote Line have been sync'd to a product."

                    });
                    toastEvent.fire();
                    //close quick action
                    $A.get("e.force:closeQuickAction").fire();
                } else {
                    console.log('not all quote line items have products');
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
            }
        });
        $A.enqueueAction(action);

    }
    
})