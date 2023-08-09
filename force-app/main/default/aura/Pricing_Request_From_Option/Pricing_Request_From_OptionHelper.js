({
    createRecord: function(component, event, helper){
        var recordId = component.get("v.recordId");

        var pricingRequest = component.get('v.pricingRequest');
        console.log('pricingRequest Data ==> '+pricingRequest.Name);

        if (pricingRequest.Name != '') {
            component.set("v.Spinner", true);

            var action = component.get("c.createPR");
            action.setParams({
                recordId: recordId,
                pricingRequest: pricingRequest
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('State => ' + state);
                if (state == "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('Result ==> '+result);
                    if (result == 'PRLD is already exist') {
                        helper.showToast("Error", "Error", "Pricing Request is already exist on option", "5000");
                        $A.get("e.force:closeQuickAction").fire();
                    } else{
                        helper.showToast("Success", "Success", "New Pricing Request Created.", "5000");
                        
                        $A.get("e.force:closeQuickAction").fire();
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result,
                            "slideDevName": "Detail"
                        });
                        navEvt.fire();
                    }
                    
                } else{
                    helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                    var error = response.getError();
                    console.log('Error =>', {error});
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        } else{
            helper.showToast("Error", "Error", "Pricing Request Name is required", "5000");
        }

    },

    showToast: function(type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log({ error });
        }
    },
})