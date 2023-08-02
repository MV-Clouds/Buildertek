({
    doInit: function (component, event, helper) {
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
            component.set("v.parentRecordId", parentRecordId);
        }
        if(parentRecordId != null && parentRecordId != ''){
                var action = component.get("c.getobjectName");
                action.setParams({
                    recordId: parentRecordId,
                });
                action.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var objName = response.getReturnValue();
                        if(objName == 'Account'){
                            component.set("v.NameOfVendor", parentRecordId);
                        }else if(objName == 'buildertek__Purchase_Order__c'){
                            component.set("v.parentpurchaseRecordId", parentRecordId);
                            helper.vendors(component,event,helper);
                        }
                    } 
                });
                $A.enqueueAction(action);
            }
        helper.getFields(component, event, helper);
        
    },
    
    


    closeModel: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({
                    tabId: focusedTabId
                });
            })
            .catch(function (error) {
                console.log(error);
            });
        $A.get("e.force:closeQuickAction").fire();
        window.setTimeout(
            $A.getCallback(function () {
                $A.get('e.force:refreshView').fire();
            }), 1000
        );
    },

    // handleSubmit: function (component, event, helper) {
    //     component.set('v.spinner', true);
    //     var fields = event.getParam("fields");
    //      var name = component.find("Name").get("v.value");
    //     if(name != null){ 
    //     	fields["Name"] = name;
    //     }
    //     event.preventDefault(); // Prevent default submit
    //     component.find('recordViewForm').submit(fields); // Submit form
    // },

    // onRecordSuccess: function (component, event, helper) {
    //     var workspaceAPI = component.find("workspace");
    //     workspaceAPI.getFocusedTabInfo().then(function (response) {
    //         var focusedTabId = response.tabId;
    //         workspaceAPI.closeTab({
    //             tabId: focusedTabId
    //         });
    //     }).catch(function (error) {
    //         console.log('Error', JSON.stringify(error));
    //     });
    //     setTimeout(function () {
    //         component.set('v.spinner', false);
    //         var payload = event.getParams().response;
    //         var url = location.href;
    //         var baseURL = url.substring(0, url.indexOf('/', 14));
    //         var toastEvent = $A.get("e.force:showToast");
    //         toastEvent.setParams({
    //             mode: 'sticky',
    //             message: 'Vendor Review created successfully',
    //             messageTemplate: "Vendor Review created successfully.",
    //             messageTemplateData: [{
    //                 url: baseURL + '/lightning/r/buildertek__Vendor_Review__c/' + escape(payload.id) + '/view',
    //                 label: payload.name,
    //             }],
    //             type: 'success',
    //             duration: '10000',
    //             mode: 'dismissible'
    //         });
    //         toastEvent.fire();

    //         var navEvt = $A.get("e.force:navigateToSObject");
    //         navEvt.setParams({
    //             "recordId": payload.id,
    //             "slideDevName": "related"
    //         });
    //         navEvt.fire();
    //     }, 200);
    // },

    handleSubmit: function (component, event, helper) {

        console.log('handleSubmit');
        event.preventDefault();
        var fields = event.getParam('fields');
        console.log({fields});
        console.log('fields ', JSON.parse(JSON.stringify(fields)));
        var data = JSON.stringify(fields);
        console.log('data-->>', { data });
        component.set('v.Spinner', true);
        var action = component.get("c.saveRecord");
        console.log('-----');
        action.setParams({
            "vendorReviewData": data
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
                console.log( component.find('inputFields'));

                var saveNnew = component.get("v.saveAndNew");
                console.log('saveNnew: ' + saveNnew);

                if (saveNnew) {
                    $A.get('e.force:refreshView').fire();
                    component.set("v.saveAndNew" , false);
                }
                else {

                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function (response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({
                            tabId: focusedTabId
                        });
                    }).catch(function (error) {
                        console.log('Error', JSON.stringify(error));
                    });
                    setTimeout(function () {
                        component.set('v.spinner', false);
                        var payload = event.getParams().response;
                        var url = location.href;
                        var baseURL = url.substring(0, url.indexOf('/', 14));
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Vendor Review created successfully',
                            messageTemplate: "Vendor Review created successfully.",
                            messageTemplateData: [{
                                url: baseURL + '/lightning/r/buildertek__Vendor_Review__c/' + escape(payload.id) + '/view',
                                label: payload.name,
                            }],
                            type: 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();

                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": payload.id,
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                    }, 200);
                    // var navEvt = $A.get("e.force:navigateToSObject");
                    // navEvt.setParams({
                    //     "recordId": recordId,
                    //     "slideDevName": "Detail"
                    // });
                    // navEvt.fire();
                  
                    
                
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
        console.log('handlesaveNnew');
        component.set('v.Spinner', true);
        component.set("v.saveAndNew", true);
        component.set('v.Spinner', false);

    },

    // saveAndNew: function (component, event, helper) {
    //      var Name = component.get("v.NameOfVendorReview");
    //    // alert(Name);
    //      if(Name != null){
    //         // alert("hai");
    //     component.set('v.spinner', true);
    //     event.preventDefault(); // Prevent default submit
    //     var fields = event.getParam("listOfFields");
    //     component.find('recordViewForm').submit(fields); // Submit form
    //     $A.get('e.force:refreshView').fire();
    //           } else{
    //               var toastEvent = $A.get("e.force:showToast");
    //                 toastEvent.setParams({
    //                     title: 'ERROR',
    //                     message: 'Please Enter the Vendor Review Name.',
    //                     duration: "5000",
    //                     key: "info_alt",
    //                     type: "error",
    //                     mode: "pester",
    //                 });
    //                 toastEvent.fire();
    //          }
    // }
})