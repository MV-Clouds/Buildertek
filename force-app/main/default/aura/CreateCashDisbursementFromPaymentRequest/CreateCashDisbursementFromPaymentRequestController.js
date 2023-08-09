({
    doInit: function(component, event, helper) {
        console.log('doInit');
            component.set("v.parentRecordId", component.get("v.recordId"));
            
            helper.getFields(component, event, helper);
    },

    handleSubmit: function(component, event, helper){

        console.log('handleSubmit');
        event.preventDefault();
        var elements = document.getElementsByClassName("myTest");
        console.log('fieldValue = > ', elements);
        var fields = event.getParam('fields');
        // console.log('Fieldvalue => ', {event.getParam('value')[0]});

        var PaymentamountField = parseFloat(fields.buildertek__Payment_Amount__c);
        var PaymentdateField = new Date(fields.buildertek__Payment_Date__c);

        fields.buildertek__Payment_Amount__c = PaymentamountField;
        fields.buildertek__Payment_Date__c = PaymentdateField.toISOString().slice(0,10);
        console.log({fields});

        console.log('fields ', JSON.parse(JSON.stringify(fields)));
        var data = JSON.stringify(fields);
        console.log('data-->>', { data });
        component.set('v.Spinner', true);
        var action = component.get("c.saveRecord");
        console.log('-----');
        action.setParams({
            "CashDisbursementData": data
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var error = response.getError();
            console.log('Error =>', { error });
            console.log('state =>', { state });
            if (state === "SUCCESS") {
                
                console.log('success');
                var result = response.getReturnValue();
                console.log('Result => ', result);
                
                if(result != null){

                    var toastEvent  = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "Success!",
                        "message": "The record has been created successfully."
                    });
                    toastEvent.fire();
                    
                    var saveNnew = component.get("v.isSaveNew");
                    console.log('saveNnew: ' + saveNnew);

                    if(saveNnew == true){
                        $A.get('e.force:refreshView').fire();
                        // component.find('inputFields');
                        // (component.find('inputFields').getComponent).forEach(function(f) {
                        //     console.log(f)
                        // });
                        // component.set('v.parentRecord', '');
                        component.set("v.isSaveNew", false);
                        component.set('v.Spinner', false);

                    }
                    else {
                        var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": result,
                                "slideDevName": "detail"
                            });
                        navEvt.fire();
                        component.set('v.Spinner', false);
                    }


                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Error",
                        "title": "Error!",
                        "message": "Something Went Wrong"
                    });
                    toastEvent.fire();
                    component.set('v.Spinner', false);
                    console.log( 'Error => ', result);
                }

                // var saveNnew = component.get("v.saveAndNew");
                // console.log('saveNnew: ' + saveNnew);

                // if (saveNnew) {
                //     console.log('saveNnew ==>',saveNnew);
                //     // component.find('inputFields').set('v.value' , ''); 
                //     $A.get('e.force:refreshView').fire();

                //     component.find('inputFields').forEach(function(f) {
                //         f.reset();
                //     });

                //     component.find('Name').set('v.value' ,'');
                //     component.set("v.saveAndNew" , false);
                // }
                // else {
                //     $A.get("e.force:closeQuickAction").fire();
                //     console.log('---Else---');
                //     console.log('saveAndClose');
                //     var navEvt = $A.get("e.force:navigateToSObject");
                //     navEvt.setParams({
                //         "recordId": recordId,
                //         "slideDevName": "Detail"
                //     });
                //     navEvt.fire();
                
                // }
                
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

    handlesaveNnew: function(component, helper, event) {
        component.set("v.isSaveNew", true);
    },
            

    closePopup: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})