({
    doInit: function (component, event, helper) {
        component.set('v.Spinner', true);
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        console.log('value',value);
        // var pageRef = component.get("v.pageReference");
        // var state = pageRef.state;
        // var base64Context = state.inContextOfRef;
        // if (base64Context.startsWith("1\.")) {
        //     base64Context = base64Context.substring(2);
        // }
        // var addressableContext = JSON.parse(window.atob(base64Context));
        // var kid = component.set("v.recordId", addressableContext.attributes.recordId);
        // console.log('kid',kid);
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
        console.log('parentRecordId',component.get("v.parentRecordId"));
        // if(parentRecordId != null && parentRecordId != ''){
        //         var action = component.get("c.getobjectName");
        //         action.setParams({
        //             recordId: parentRecordId,
        //         });
        //         action.setCallback(this, function (response) {
        //             if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
        //                 var objName = response.getReturnValue();
        //                 console.log({objName});
        //                 if(objName == 'Account'){
        //                     component.set("v.NameOfVendor", parentRecordId);
        //                 }else if(objName == 'buildertek__Purchase_Order__c'){
        //                     component.set("v.parentpurchaseRecordId", parentRecordId);
        //                     helper.vendorsAndProject(component,event,helper);
        //                 }

        //             } 
        //         });
        //         $A.enqueueAction(action);
        //     }
        helper.getFields(component, event, helper);    
    },
    
    


    closeModel: function (component, event, helper) {
    
        // $A.get("e.force:closeQuickAction").fire();
        helper.closePopupHelper(component, event, helper);
    },

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
            "pricingRequestData": data
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
                    console.log('saveNnew ==>',saveNnew);
                    // component.find('inputFields').set('v.value' , ''); 
                    $A.get('e.force:refreshView').fire();

                    component.find('inputFields').forEach(function(f) {
                        f.reset();
                    });

                    component.find('Name').set('v.value' ,'');
                    component.set("v.saveAndNew" , false);
                }
                else {
                    // $A.get("e.force:closeQuickAction").fire();
                    // console.log('---Else---');
                    // console.log('saveAndClose');
                    // var navEvt = $A.get("e.force:navigateToSObject");
                    // navEvt.setParams({
                    //     "recordId": recordId,
                    //     "slideDevName": "Detail"
                    // });
                    // navEvt.fire();
                    // var workspaceAPI = component.find("workspace");
                    // workspaceAPI.getFocusedTabInfo().then(function(tabResponse) {
            
                    //     var parentTabId = tabResponse.tabId;
                    //     var isSubtab = tabResponse.isSubtab;
                        
                    //     workspaceAPI.openSubtab({
                    //         parentTabId: parentTabId,
                    //         recordId:recordId,
                    //         focus: true
                    //     });
                    // });
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({
                                tabId: focusedTabId
                            });
                        })
                        .catch(function(error) {
                            console.log(error);
                        });
                        var navEvent = $A.get("e.force:navigateToSObject");
                        navEvent.setParams({
                            "recordId": recordId,
                        });
                        navEvent.fire();
                  
                    
                
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
                component.set('v.Spinner', false);
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
})