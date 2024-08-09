({
    doInit: function (component, event, helper) {
        var action = component.get("c.changeStatus");
        action.setParams({
            contractorInvoiceID: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (result === "Success") {
                $A.get("e.force:closeQuickAction").fire();
                component.find('notifLib').showNotice({
                    "variant": "success",
                    "header": "Success",
                    "message": "Contractor Invoice Status updated successfully.",
                    closeCallback: function () {
                        $A.get('e.force:refreshView').fire();
                    }
                });
            } else {
                component.find('notifLib').showNotice({
                    "variant": "error",
                    "header": "Error",
                    "message": result,
                    closeCallback: function () {
                        $A.get('e.force:refreshView').fire();
                    }
                });
            }
        });

        $A.enqueueAction(action);
    }
})
