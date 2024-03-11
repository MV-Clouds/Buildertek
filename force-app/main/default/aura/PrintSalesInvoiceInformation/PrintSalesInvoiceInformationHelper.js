({
    getTemplateBody: function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.getInvoiceLines");
        action.setParams({
            recordId: recordId,
            templateId: component.get("v.selectedTemplate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var error = response.getError();

            console.log({state});
            console.log({error});
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('get template body');
                console.log({ result });
                component.set("v.salesInvoiceLines", result);
                component.set("v.Spinner", false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'ERROR',
                    message: 'Something Went Wrong',
                    duration: '5000',
                });
                toastEvent.fire();
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

})