({
    doInitHelper: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        component.set('v.poColumns', [
            { label: 'PO Line Name', fieldName: 'Name', type: 'text' },
            { label: 'Quantity', fieldName: 'buildertek__Quantity__c', type: 'text' },
            { label: 'Unit Price', fieldName: 'buildertek__Unit_Price__c', type: 'text' },
            { label: 'Rate', fieldName: 'buildertek__Tax__c', type: 'text' },

        ]);
        var action = component.get('c.getPOLines');
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.poData', response.getReturnValue());
                var result = response.getReturnValue();
                console.log("Result ---> ", { result });
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);

    },

    showToast: function(type, title, message, time) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            "duration": time
        });
        toastEvent.fire();
    },
})