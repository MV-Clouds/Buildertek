({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getPoRecordTypes");

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recordType = response.getReturnValue();
                console.log('recordType', recordType);
                component.set("v.options", recordType.recordTypeWrp);
                component.set("v.value", recordType.defaultRecordTypeId);
                component.set("v.Spinner", false);
            } else {
                console.log('Error', response.getError());
                component.set("v.Spinner", false);
            }
        });

        $A.enqueueAction(action);
    },

    handleNext: function (component, event, helper) {
        component.set("v.Spinner", true);
        component.set("v.recordTypePage", false);

        helper.afterDoInit(component, event, helper);
    },

    closeModel: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
        })
            .catch(function (error) {
                console.log(error);
            });
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isOpen", false);
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },

    handleSubmit: function (component, event, helper) {
        component.set("v.Spinner", true);
        console.log('handleSubmit');
        event.preventDefault();
        var fields = event.getParam('fields');
        let selectedRecordType = component.get("v.value");
        let recordTypeId = selectedRecordType.split('-');
        fields['RecordTypeId'] = recordTypeId[0];
        console.log('fields: ' + JSON.stringify(fields));
        var data = JSON.stringify(fields);
        console.log('data-->>', { data });
        var action = component.get("c.saveRecord");
        action.setParams({
            "data": data
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var error = response.getError();
            console.log('Error =>', { error });
            if (state === "SUCCESS") {
                console.log('success');
                console.log(response.getReturnValue());
                var recordId = response.getReturnValue();
                console.log('recordId-->>', { recordId });
                var listofPOItems = component.get("v.listofPOItems");
                if (listofPOItems.length > 0) {
                    helper.savePOLineItems(component, event, helper, recordId);
                }
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "Success!",
                    "message": "The record has been created successfully."
                });
                toastEvent.fire();

                var saveNnew = component.get("v.isSaveNew");
                console.log('saveNnew: ' + saveNnew);

                if (saveNnew) {
                    $A.get('e.force:refreshView').fire();
                }
                else {
                    console.log('---Else---');
                    console.log('saveAndClose');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                    component.set("v.parentRecordId", null);

                    var focusedTabId = '';
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        focusedTabId = response.tabId;
                    })

                    window.setTimeout(
                        $A.getCallback(function () {
                            workspaceAPI.closeTab({ tabId: focusedTabId });
                        }), 1000
                    );
                }
            }
            else if (state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "title": "Error!",
                    "message": "Something Went Wrong"
                });
                toastEvent.fire();
                console.log('error', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    handlesaveNnew: function (component, event, helper) {
        component.set("v.isSaveNew", true);
    },

    saveNnew: function (component, event, helper) {
        component.set("v.saveAndNew", true);
        console.log('saveNnew');
    },

    removePOLine: function (component, event, helper) {
        var currentId = event.currentTarget.dataset.id;
        console.log('current ID', { currentId });
        var listofPOItems = component.get("v.listofPOItems");
        //loop over the list and find the index to remove
        for (var i = 0; i < listofPOItems.length; i++) {
            if (listofPOItems[i].index == currentId) {
                listofPOItems.splice(i, 1);
                break;
            }
        }
        component.set("v.listofPOItems", listofPOItems);
    },

    addNewRow: function (component, event, helper) {
        var listofPOItems = component.get("v.listofPOItems");
        let keys = component.get("v.dynamicKeys");
        for (var i = 1; i < 2; i++) {
            let obj = { 'index': listofPOItems.length };
            for (let j = 0; j < keys.length; j++) {
                obj[j] = '';
            }
            listofPOItems.push(obj);
        }
        component.set("v.listofPOItems", listofPOItems);
    },

    handleVersionChange: function (component, event, helper) {
        var selectedVersion = component.find("version").get("v.value");
        console.log('selectedVersion', { selectedVersion });
    },

})