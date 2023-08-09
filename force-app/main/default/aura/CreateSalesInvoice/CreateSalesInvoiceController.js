({  
    doInit: function (component, event, helper) {
        component.set('v.Spinner', true);
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);

        var action = component.get("c.getFieldSet");
        action.setParams({
            objectName: "buildertek__Billings__c",
            fieldSetName: "buildertek__New_InvoiceAR_ComponentFields",

        });
        action.setCallback(this, function (response) {
            console.log(response.getState());
            console.log(response.getError());
            if (response.getState() == 'SUCCESS') {
                var allFieldsLabel = JSON.parse(response.getReturnValue());
                console.log({ allFieldsLabel });

                component.set('v.allFieldsLabel', allFieldsLabel);
                console.log({ allFieldsLabel });

            }
        });

        var recordId = component.get("v.recordId");
        console.log('recordID ==>' + recordId);
        if (recordId != undefined & recordId != null) {
            console.log('1');
            component.set('v.SalesInvoice.buildertek__Project__c', recordId);
            component.set('v.desableProjectSelection', true);
            console.log('2');
        } else {
            component.set('v.desableProjectSelection', false);
        }

        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
            console.log('parentRecordId---->>', { parentRecordId });
            // component.set("v.Spinner", false);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            } else {
                parentRecordId = '';
        }
            component.set("v.parentRecordId", parentRecordId);
            console.log('parentRecordId-->>', { parentRecordId });
        }
        if (parentRecordId != null && parentRecordId != '' && parentRecordId != undefined) {
            var action2 = component.get("c.getobjectNames");
            console.log('getobjectNames-->>', { parentRecordId });

            action2.setParams({
                recordId: parentRecordId,
            });
            action2.setCallback(this, function (response) {
                console.log(response.getState());
                console.log(response.getError());

                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    component.set("v.Spinner", false);

                    var objName = response.getReturnValue();
                    if (objName == 'buildertek__Project__c') {
                        component.set("v.parentprojectRecordId", parentRecordId);
                    }
                    if (objName == 'buildertek__Change_Order__c') {
                        component.set("v.parentChangeOrderRecordId", parentRecordId);
                    }
                    if (objName == 'buildertek__Contract__c') {
                        component.set("v.parentContractRecordId", parentRecordId);
                    }
                }
            });
            $A.enqueueAction(action2);
        }
        component.set("v.Spinner", false);
        $A.enqueueAction(action);

    },
    Cancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleSubmit: function (component, event, helper) {
        console.log('handleSubmit');
        event.preventDefault();
        var fields = event.getParam('fields');
        if (fields.Name) {
            console.log('fields ', JSON.parse(JSON.stringify(fields)));
            debugger

            var data = JSON.stringify(fields);

            console.log('data-->>', { data });
            component.set('v.Spinner', true);
            var action = component.get("c.saveRecord");
            console.log('-----');
            action.setParams({
                "salesInvoiceData": data
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                var error = response.getError();
                console.log('Error =>', { error });
                console.log('state =>', { state });

                if (state === "SUCCESS") {
                    component.set('v.Spinner', false);

                    console.log('success');
                    console.log(response.getReturnValue());
                    var recordId = response.getReturnValue();
                    console.log('recordId-->>', { recordId });

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "Success!",
                        "message": "The record has been created successfully."
                    });
                    toastEvent.fire();

                    var saveNnew = component.get("v.isSaveAndNew");
                    console.log('saveNnew: ' + saveNnew);

                    if (saveNnew) {
                        console.log('saveNnew ==>',saveNnew);
                        // $A.get('e.force:refreshView').fire();
                        component.find('field').forEach(function(f) {
                            f.reset();
                        });
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
                        // component.set("v.parentRecordId", null);

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
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "title": "Error!",
                "message": "Description is Required."
            });
            toastEvent.fire();
        }
    },
    handlesaveNnew: function (component, event, helper) {
        component.set('v.Spinner', true);
        component.set("v.isSaveAndNew", true);
        component.set('v.Spinner', false);

    },

    saveNnew: function (component, event, helper) {
        component.set("v.isSaveAndNew", true);
        console.log('saveNnew');
    },
 
})