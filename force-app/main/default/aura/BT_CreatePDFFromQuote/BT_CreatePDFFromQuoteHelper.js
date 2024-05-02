({
    getQuoteTemplate: function (component, event, helper) {
        // helper.showSpinner(component, event, helper);

        var action = component.get("c.getTemplates");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(`Templates: ${JSON.stringify(result)}`);
                if (!result || result.length === 0) {
                    helper.showToast('Error', 'No quote template available', 'error', 2000);
                    helper.close(component, event, helper);
                } else {
                    component.set("v.templateList", result);
                    component.set("v.selectedTemplateId", result[0].Id);
                    if (result.length > 1) {
                        component.set("v.showModal", true);
                    } else {
                        helper.createPDF(component, event, helper);
                    }
                }
            } else {
                var errors = response.getError();
                var message = 'An error occurred while fetching the quote templates.';
                console.error(message + ' Error: ' + JSON.stringify(errors));
                helper.showToast('Error', message, 'error', 2000);
            }

            // helper.hideSpinner(component, event, helper);
        });

        $A.enqueueAction(action);
    },

    showToast: function (title, message, type, duration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            duration: duration
        });
        toastEvent.fire();
    },

    createPDF: function (component, event, helper) {
        helper.showSpinner(component, event, helper);

        var template = component.get("v.selectedTemplateId");
        var quote = component.get("v.recordId");
        var action = component.get("c.createPDFAndStoreInFiles");
        console.log(`template: ${template}, quote: ${quote}`);

        action.setParams({
            "templateId": template,
            "quoteId": quote
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(`result: ${result}`);
                if (result === 'Success') {
                    helper.showToast('Success', 'PDF created successfully.', 'success', 2000);
                } else {
                    helper.showToast('Error', result, 'error', 2000);
                }
            } else {
                console.log(`Error: ${JSON.stringify(response.getError())}`);
                helper.showToast('Error', response.getError(), 'error', 2000);
            }
            helper.hideSpinner(component, event, helper);
            helper.close(component, event, helper);
        });

        $A.enqueueAction(action);
    },

    close: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    showSpinner: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
    },

    hideSpinner: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();
    }
})
