({
    getTemplateBody: function(component, event, helper) {
        
        var recordId = component.get("v.recordId");
        var action = component.get("c.getInvoiceLines");
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
                component.set("v.invoiceLines", result);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);     
    },

    getContact: function(component, event, helper) {
		
        var action = component.get("c.getObjectContact");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert('result ---------> '+result);
                var selectedContact = component.get("v.selectedToContact");
                if (result != undefined) {
                    selectedContact.push(result);
                }
                component.set("v.selectedToContact", selectedContact);
            }
        });
        $A.enqueueAction(action);
    },

})