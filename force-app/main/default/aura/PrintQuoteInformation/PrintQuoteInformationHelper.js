({
    getTemplateBody: function(component, event, helper) {
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.getQuoteLines");
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
                component.set("v.quoteLines", result);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

})