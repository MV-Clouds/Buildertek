({
    doInit: function (component, event, helper) {

        var contId = component.get("v.recordId");
        var action = component.get("c.getPaymentId");
        action.setParams({
            contId: contId
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var paymentId = response.getReturnValue();
                if (paymentId != null) {
                    component.set("v.paymentId", paymentId);
                    console.log('New paymentId:',component.get("v.paymentId"));
                    debugger
                    var action9 = component.get("c.getState");
                    action9.setParams({
                        recId: component.get("v.paymentId")
                    });
                    action9.setCallback(this, function (response) {
                        if (response.getState() === "SUCCESS") {
                            var result = response.getReturnValue();

                            if (result.PeriodDate == null) {

                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'ERROR',
                                    message: 'Period To Field should not be Null.',
                                    duration: "5000",
                                    key: "info_alt",
                                    type: "error",
                                    mode: "pester",
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                            } else {
                                if (result.userrec != true) {
                                    var action2 = component.get("c.getContsheet");
                                    action2.setParams({
                                        recId: component.get("v.paymentId")
                                    });
                                    action2.setCallback(this, function (response) {
                                        var result = response.getReturnValue();
                                        if (response.getState() === "SUCCESS") {
                                            var result = response.getReturnValue();
                                            $A.enqueueAction(action);
                                        }
                                        else {
                                            var navEvt = $A.get("e.force:navigateToSObject");
                                            navEvt.setParams({
                                                "recordId": component.get("v.paymentId"),
                                                "slideDevName": "related"
                                            });
                                            navEvt.fire();

                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                title: 'ERROR',
                                                message: 'There is no Continuation Sheet',
                                                duration: "5000",
                                                key: "info_alt",
                                                type: "error",
                                                mode: "pester",
                                            });
                                            toastEvent.fire();


                                        }

                                    })
                                    $A.enqueueAction(action2);


                                    var action = component.get("c.getUser");
                                    action.setCallback(this, function (response) {
                                        if (response.getState() === "SUCCESS") {

                                            var result = response.getReturnValue();
                                            var commUserId = result.Id;

                                            // alert('isCommunityUser'+result)

                                            if (result.IsPortalEnabled == true) {
                                                var address = '/continuation-sheet-page?id=' + component.get("v.paymentId") + '&userIdFromcommunity=' + commUserId + '&dummy=ignore' + '/';
                                                var urlEvent = $A.get("e.force:navigateToURL");
                                                urlEvent.setParams({
                                                    "url": address,
                                                    "isredirect": false
                                                });
                                                urlEvent.fire();

                                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                                dismissActionPanel.fire();


                                            } else {
                                                var workspaceAPI = component.find("workspace");
                                                workspaceAPI.getFocusedTabInfo().then(function (tabResponse) {

                                                    var parentTabId = tabResponse.tabId;
                                                    var isSubtab = tabResponse.isSubtab;

                                                    workspaceAPI.openSubtab({
                                                        parentTabId: parentTabId,
                                                        pageReference: {
                                                            "type": "standard__component",
                                                            "attributes": {
                                                                "recordId": component.get("v.paymentId"),
                                                                "componentName": "buildertek__ContinuationSheetItems"
                                                            },
                                                            "state": {
                                                                "buildertek__parentId": component.get("v.paymentId")
                                                            }
                                                        },
                                                        //focus: true
                                                    }).then(function (response) {
                                                        console.log(response);
                                                        var workspaceAPI = component.find("workspace");
                                                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                                                            var focusedTabId = response.tabId;
                                                            workspaceAPI.setTabLabel({
                                                                tabId: focusedTabId,
                                                                label: "Continuation Sheet Details",
                                                            });
                                                            workspaceAPI.setTabIcon({
                                                                tabId: focusedTabId,
                                                                icon: "custom:custom5",
                                                                iconAlt: "Continuation Sheet Details"
                                                            });
                                                        })
                                                            .catch(function (error) {
                                                                console.log(error);
                                                            });
                                                    })
                                                });

                                            }

                                        }
                                    })
                                }

                                else {
                                    var action2 = component.get("c.getContsheet");
                                    action2.setParams({
                                        recId: component.get("v.paymentId")
                                    });
                                    action2.setCallback(this, function (response) {
                                        var result = response.getReturnValue();
                                        if (response.getState() === "SUCCESS") {
                                            var result = response.getReturnValue();
                                            $A.enqueueAction(action);

                                        } else {
                                            var navEvt = $A.get("e.force:navigateToSObject");
                                            navEvt.setParams({
                                                "recordId": component.get("v.paymentId"),
                                                "slideDevName": "related"
                                            });
                                            navEvt.fire();

                                            var toastEvent = $A.get("e.force:showToast");
                                            toastEvent.setParams({
                                                title: 'ERROR',
                                                message: 'There is no Continuation Sheet',
                                                duration: "5000",
                                                key: "info_alt",
                                                type: "error",
                                                mode: "pester",
                                            });
                                            toastEvent.fire();
                                        }

                                    })
                                    $A.enqueueAction(action2);

                                    var action = component.get("c.getUser");
                                    action.setCallback(this, function (response) {
                                        if (response.getState() === "SUCCESS") {

                                            var result = response.getReturnValue();
                                            var commUserId = result.Id;

                                            // alert('isCommunityUser'+result)

                                            if (result.IsPortalEnabled == true) {
                                                var address = '/continuation-sheet-page?id=' + component.get("v.paymentId") + '&userIdFromcommunity=' + commUserId + '&dummy=ignore' + '/';
                                                var urlEvent = $A.get("e.force:navigateToURL");
                                                urlEvent.setParams({
                                                    "url": address,
                                                    "isredirect": false
                                                });
                                                urlEvent.fire();

                                                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                                                dismissActionPanel.fire();


                                            } else {
                                                var workspaceAPI = component.find("workspace");
                                                workspaceAPI.getFocusedTabInfo().then(function (tabResponse) {

                                                    var parentTabId = tabResponse.tabId;
                                                    var isSubtab = tabResponse.isSubtab;

                                                    workspaceAPI.openSubtab({
                                                        parentTabId: parentTabId,
                                                        pageReference: {
                                                            "type": "standard__component",
                                                            "attributes": {
                                                                "recordId": component.get("v.paymentId"),
                                                                "componentName": "buildertek__ContinuationSheetItems"
                                                            },
                                                            "state": {
                                                                "buildertek__parentId": component.get("v.paymentId")
                                                            }
                                                        },
                                                        //focus: true
                                                    }).then(function (response) {
                                                        console.log(response);
                                                        var workspaceAPI = component.find("workspace");
                                                        workspaceAPI.getFocusedTabInfo().then(function (response) {
                                                            var focusedTabId = response.tabId;
                                                            workspaceAPI.setTabLabel({
                                                                tabId: focusedTabId,
                                                                label: "Continuation Sheet Details",
                                                            });
                                                            workspaceAPI.setTabIcon({
                                                                tabId: focusedTabId,
                                                                icon: "custom:custom5",
                                                                iconAlt: "Continuation Sheet Details"
                                                            });
                                                        })
                                                            .catch(function (error) {
                                                                console.log(error);
                                                            });
                                                    })
                                                });

                                            }

                                        }
                                    })

                                }
                            }
                        }
                    })
                    $A.enqueueAction(action9);
                } else {
                    helper.showToast('error', 'Error', 'Continuation Sheet must be associated with Payment Application', '3');
                    $A.get("e.force:closeQuickAction").fire();
                }
            } else {
                console.log("Error: " + state);
            }
        });
        $A.enqueueAction(action);

    }

})