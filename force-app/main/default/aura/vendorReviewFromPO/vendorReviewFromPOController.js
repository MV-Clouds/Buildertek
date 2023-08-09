({
    doInit: function (component, event, helper) {
        component.set('v.Spinner', true);
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
                        console.log({objName});
                        if(objName == 'Account'){
                            component.set("v.NameOfVendor", parentRecordId);
                        }else if(objName == 'buildertek__Purchase_Order__c'){
                            component.set("v.parentpurchaseRecordId", parentRecordId);
                            helper.vendorsAndProject(component,event,helper);
                        }

                    } 
                });
                $A.enqueueAction(action);
            }
        helper.getFields(component, event, helper);    
    },
    
    


    closeModel: function (component, event, helper) {
    
        $A.get("e.force:closeQuickAction").fire();
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
                    $A.get("e.force:closeQuickAction").fire();
                    console.log('---Else---');
                    console.log('saveAndClose');
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                  
                    
                
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
})