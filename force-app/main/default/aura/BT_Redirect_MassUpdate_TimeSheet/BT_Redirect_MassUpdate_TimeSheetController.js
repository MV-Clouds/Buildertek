({
    doInit : function(component, event, helper) {
        console.log('doInit');
        console.log('recordId: ' + component.get("v.recordId"));
        var action = component.get("c.checkTimeSheetEntries");
        action.setParams({
            "timeSheetId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state: ' + state);
            if(state === "SUCCESS") {
                var timeSheetEntryExists = response.getReturnValue();
                if(!timeSheetEntryExists) {
                    console.log('timeSheet has no entries');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "No TimeSheet Entries",
                        "type": "error",
                        "message": "TimeSheet has no entries."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }else {
                    console.log('timeSheet has entries');
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
                                    "componentName": "buildertek__BT_Mass_Update_TimeSheet"
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
                                    label: "Mass Update TimeSheet Entries",
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

            }else{
                console.log('error');
            }
        });
        $A.enqueueAction(action);
        

    }
})
