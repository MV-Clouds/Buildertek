({
    getEmailTemplate: function (component, event, helper) {
        component.set('v.isLoading',true);
        var recordId = component.get("v.recordId");
        console.log('recordId::',recordId);
        var action = component.get("c.getContractTemplate");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.emailBody", result);
                component.set('v.isLoading',false);
            } else {
                component.set('v.isLoading',false);
                helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: '5000',
            key: 'info_alt',
            type: type,
            mode: 'pester'
        });
        toastEvent.fire();
    },
})