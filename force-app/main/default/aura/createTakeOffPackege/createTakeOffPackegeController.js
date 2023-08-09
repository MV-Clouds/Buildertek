({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        helper.getRecords(component, event, helper);
    },

    handleCheck: function (component, event, helper) {
        var checkbox = event.getSource();
        var packageTakeOffList = component.get("v.packageTakeOffList");
        for (var i = 0; i < packageTakeOffList.length; i++) {
            if (packageTakeOffList[i].packageRecord != null) {
                if (packageTakeOffList[i].packageRecord.Id == checkbox.get("v.text") && packageTakeOffList[i].packageTakeOffCheck == false) {
                    packageTakeOffList[i].packageTakeOffCheck = true;
                } else if (packageTakeOffList[i].packageRecord.Id == checkbox.get("v.text") && packageTakeOffList[i].packageTakeOffCheck == true) {
                    packageTakeOffList[i].packageTakeOffCheck = false;
                }
            }
        }
    },

    selectAll: function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var packageTakeOffList = component.get("v.packageTakeOffList");
        var getAllId = component.find("checkContractor");
        if (packageTakeOffList != null) {
            if (packageTakeOffList.length > 1) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkContractor").set("v.value", true);
                    } else {
                        component.find("checkContractor").set("v.value", false);
                    }
                } else {
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", true);
                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            packageTakeOffList[i].packageTakeOffCheck = true;
                        }
                    } else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkContractor")[i].set("v.value", false);
                            var checkbox = component.find("checkContractor")[i].get("v.text");
                            var packageTakeOffList = component.get("v.packageTakeOffList");
                            packageTakeOffList[i].packageTakeOffCheck = false;
                        }
                    }
                }
            } else {
                var i = 0;
                if (selectedHeaderCheck == true) {
                    component.find("checkContractor").set("v.value", true);
                    var checkbox = component.find("checkContractor").get("v.text");
                    packageTakeOffList[i].packageTakeOffCheck = true;
                } else {
                    component.find("checkContractor").set("v.value", false);
                    var checkbox = component.find("checkContractor").get("v.text");
                    var packageTakeOffList = component.get("v.packageTakeOffList");
                    packageTakeOffList[i].packageTakeOffCheck = false;
                }
            }
        }

    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    closePopup: function (component, event, helper) {
        component.set('v.isModalOpen', false);
        var takeOffLinesIds = component.get('v.takeOffLinesIds');
        takeOffLinesIds.length > 0 ?
            helper.importPackage(component, event, helper, takeOffLinesIds) :
            helper.showToast(component, event, helper, 'Warning!', 'Please select at least one Package', 'warning');
    },

    openNewTab: function (component, event, helper) {
        component.set('v.isModalOpen', false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:DuplicateTakeOffLines",
            componentAttributes: {
                recordId: component.get('v.recordId'),
                takeOffLinesIds: component.get('v.takeOffLinesIds'),
                isConfirmationModalOpen: true
            }
        });
        evt.fire();
        $A.get("e.force:closeQuickAction").fire();

        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getEnclosingTabId().then(function (enclosingTabId) {
        //     workspaceAPI.openSubtab({
        //         parentTabId: enclosingTabId,
        //         pageReference: {
        //             "type": "standard__component",
        //             "attributes": {
        //                 "componentName": "buildertek__DuplicateTakeOffLines"
        //             }
        //         }
        //     }).then(function (subtabId) {
        //         console.log("The new subtab ID is:" + subtabId);
        //     }).catch(function (error) {
        //         debugger;
        //         console.log("error", error);
        //     });
        // });
        // var workspaceAPI = component.find("workspace");
        // workspaceAPI.getEnclosingTabId().then(function (enclosingTabId) {
        //     workspaceAPI.openSubtab({
        //         parentTabId: enclosingTabId,
        //         pageReference: {
        //             "type": "standard__component",
        //             "attributes": {
        //                 "componentName": "c:DuplicateTakeOffLines"
        //             },
        //             "state": {
        //                 takeOffLinesIds: component.get('v.takeOffLinesIds')
        //             }
        //         }
        //     }).then(function (subtabId) {
        //         console.log("The new subtab ID is:" + subtabId);
        //     }).catch(function (error) {
        //         console.log("error");
        //     });
        // });
    },

    addPackage: function (component, event, helper) {
        component.set("v.Spinner", true);
        var takeOffList = component.get("v.packageTakeOffList");
        var takeOffLinesIds = [];
        for (var i = 0; i < takeOffList.length; i++) {
            if (takeOffList[i].packageTakeOffCheck == true) {
                if (takeOffList[i].packageRecord != null) {
                    takeOffLinesIds.push(takeOffList[i].packageRecord.Id);
                }
            }
        }
        if (takeOffLinesIds.length > 0) {
            component.set('v.isModalOpen', true);
            component.set("v.Spinner", false);
            component.set('v.takeOffLinesIds', takeOffLinesIds);
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:DuplicateTakeOffLines",
                componentAttributes: {
                    recordId: component.get('v.recordId'),
                    takeOffLinesIds: takeOffLinesIds
                }
            });
            evt.fire();
            $A.get("e.force:closeQuickAction").fire();
        } else {
            component.set("v.Spinner", false);
            window.setTimeout(
                $A.getCallback(function () {
                    helper.showToast(component, event, helper, 'Warning!', 'Please select at least one Package', 'warning');
                }), 1000
            );
        }
    },

    next: function (component, event, helper) {
        var sObjectList = component.get("v.packageTakeOffList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for (var i = end + 1; i < end + pageSize + 1; i++) {
            if (sObjectList.length > end) {
                paginationList.push(sObjectList[i]);
            }
            counter++;
        }
        start = start + counter;
        end = end + counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.paginationList', paginationList);
    },
    previous: function (component, event, helper) {
        var sObjectList = component.get("v.packageTakeOffList");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var paginationList = [];
        var counter = 0;
        for (var i = start - pageSize; i < start; i++) {
            if (i > -1) {
                paginationList.push(sObjectList[i]);
                counter++;
            } else {
                start++;
            }
        }
        start = start - counter;
        end = end - counter;
        component.set("v.startPage", start);
        component.set("v.endPage", end);
        component.set('v.paginationList', paginationList);
    },
})