({
    createItemReceipt: function (component, event, helper, purchaseOrderList) {
        var action = component.get('c.createItem');
        action.setParams({
            "recordId": component.get('v.recordId'),
            "purchaseOrderList": purchaseOrderList
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() === 'Success') {
                component.set('v.loading', false);
                $A.get("e.force:closeQuickAction").fire();
                window.location.reload();
            } else {
                component.set('v.loading', false);
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },
})