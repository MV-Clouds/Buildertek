({
    getTemplateBody: function(component, event, helper) {
       
        var recordId = component.get("v.recordId");
        var action = component.get("c.getPurchaseOrderLines");
        action.setParams({
            recordId: recordId,
            templateId: component.get("v.selectedTemplate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('get template body');
                console.log({ result });
                component.set("v.poLines", result);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

})