({
    getRfqList: function(component, event, helper, pageNumber, pageSize) {
        var action = component.get("c.getmasterScheduleOValues");
        var recId = component.get("v.recordId");
        action.setParams({
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "recordId": recId


        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                /*for(var i in resultData.recordList){
                    resultData.recordList[i].budgetCheck =false;
                }*/
                for (var i = 0; i < resultData.recordList.length; i++) {
                    if (resultData.recordList[i].buildertek__Project__c) {
                        resultData.recordList[i].buildertek__Project__c = resultData.recordList[i].buildertek__Project__r.Name;
                    }
                }
                if (resultData.recordList.length > 0) {
                    // component.set("v.IsActive", true);
                    var action2 = component.get("c.isSovSubmitted");
                    action2.setParams({
                        recordId: component.get("v.recordId")
                    });
                    action2.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            var result = response.getReturnValue();
                            if (result == "Vendor Submitted") {
                                if (component.get("v.Iscommunity") == true) {
                                    //component.set("v.IsSubmitted", true)
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title: 'Error',
                                        message: 'This SOV Is Under Review',
                                        duration: ' 5000',
                                        key: 'info_alt',
                                        type: 'error',
                                        mode: 'dismissible'
                                    });
                                    toastEvent.fire();
                                    $A.get("e.force:closeQuickAction").fire();
                                } else {
                                    component.set("v.IsActive", true)
                                }

                            } else if (result == "Company Approved") {
                                //component.set("v.IsCompanyApproved", true)
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Error',
                                    message: 'This SOV has been Approved, You Cannot Import additional Lines into an Approved SOV.',
                                    duration: ' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                            } else {
                                component.set("v.IsActive", true)
                            }
                        }
                    });
                    $A.enqueueAction(action2);
                } else {


                    var action3 = component.get("c.isSovSubmitted");
                    action3.setParams({
                        recordId: component.get("v.recordId")
                    });
                    action3.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                            console.log(response);
                            var result = response.getReturnValue();
                            console.log({ result });
                            if (result == "Vendor Submitted") {

                                if (component.get("v.Iscommunity") == true) {
                                    //component.set("v.IsSubmitted", true)
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        title: 'Error',
                                        message: 'This SOV Is Under Review',
                                        duration: ' 5000',
                                        key: 'info_alt',
                                        type: 'error',
                                        mode: 'dismissible'
                                    });
                                    toastEvent.fire();
                                    $A.get("e.force:closeQuickAction").fire();
                                } else {
                                    component.set("v.IsActive", true)
                                }



                            } else if (result == "Company Approved") {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title: 'Error',
                                    message: 'This SOV has been Approved, You Cannot Import additional Lines into an Approved SOV.',
                                    duration: ' 5000',
                                    key: 'info_alt',
                                    type: 'error',
                                    mode: 'dismissible'
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                                //component.set("v.IsCompanyApproved", true)
                            } else {
                                component.set("v.IsActive", true)
                                component.set("v.IsnoLines", true)
                            }
                        }
                    });
                    $A.enqueueAction(action3);

                }
                component.set("v.rfqRecordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(resultData.totalRecords / pageSize)
                );
            }
        });
        $A.enqueueAction(action);
    },

    importContinuationSheetItems: function(component, event, helper, selectedSheetIds, sheetId) {
        // debugger;
        component.set("v.Spinner", true);
        component.set("v.showMessage", true);

        var action = component.get("c.importScheduleOfValueItems");
        // var appId = component.get("v.paymentAppId");
        action.setParams({
            IdList: selectedSheetIds,
            recordId: component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();

            if (state === "SUCCESS") {
                //  component.get("v.cancelCallback")();
                // component.set("v.Spinner", false);
                //  $A.get('e.force:refreshView').fire();
                //location.reload();
                console.log({ state });

                component.set("v.Spinner", false);
                component.set("v.showMessage", false);
                console.log(location.href.includes("fromsovsheet"));
                if (location.href.includes("fromsovsheet")) {
                    var address = '/schedule-of-value-lines?id=' + component.get("v.recordId") + '&dummy=ignore' + '/';
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": address,
                        "isredirect": false
                    });
                    urlEvent.fire();
                    $A.get('e.force:refreshView').fire();

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": 'SOV Lines Successfully Imported',
                        "type": 'Success'
                    });
                    toastEvent.fire();

                } else {


                    /*   */


                    // alert(component.get("v.recordId"))
                    var workspaceAPI = component.find("workspace");
                    console.log({ workspaceAPI });
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        console.log({ focusedTabId });
                        window.setTimeout(
                            $A.getCallback(function() {
                                workspaceAPI.closeTab({ tabId: focusedTabId });

                            }), 1500);


                        var navEvt = $A.get("e.force:navigateToSObject");
                        console.log(component.get('v.recordId'));
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        $A.get('e.force:refreshView').fire();


                    })





                }

            } else {
                this.showErrorToast(component, event, helper, 'Error', response.getReturnValue());
            }

        });
        $A.enqueueAction(action);
    },

    showErrorToast: function(component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "error",
            mode: "pester",
        });
        toastEvent.fire();
    },
    showSuccessToast: function(component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "success",
            mode: "pester",
        });
        toastEvent.fire();
    },
})